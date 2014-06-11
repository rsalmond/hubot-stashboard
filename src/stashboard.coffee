# Description:
#   A Hubot script to read and write status messages on Stashboard.
#
# Configuration:
#   HUBOT_STASHBOARD_TOKEN
#   HUBOT_STASHBOARD_SECRET
#   HUBOT_STASHBOARD_URL
#
# Commands:
#   hubot stashboard (status|?) - Display current stashboard status (via stupid hipchat icons)
#   hubot stashboard set <service> <status> <message> - Set <service> to <status> with description <message>
#
# URL:
#
#  http://www.stashboard.org/
#
# Author:
#   rsalmond

urllib = require 'url'
oauth = require 'oauth-lite'
request = require 'request'

class Stashbot
    #hipchat icons, customize away
    statusUp: '(successful)'
    statusDown: '(failed)'
    statusWarn: '(unknown)'

    constructor: (@robot, cb) ->
        if process.env.HUBOT_STASHBOARD_URL? and process.env.HUBOT_STASHBOARD_TOKEN? and process.env.HUBOT_STASHBOARD_SECRET?
            @state =
                oauth_consumer_key: 'anonymous'
                oauth_consumer_secret: 'anonymous'
                oauth_token: process.env.HUBOT_STASHBOARD_TOKEN
                oauth_token_secret: process.env.HUBOT_STASHBOARD_SECRET
            @base_url = process.env.HUBOT_STASHBOARD_URL
        else
            cb 'Please set environment variables.'

    get_status_all: (cb) ->
        request.get @base_url + '/services', (error, data, response) =>
            if err?
                return cb('Unable to retrieve status. ERROR: ' + err)

            if data.statusCode != 200
                return cb('Unable to retrieve status. HTTP: ' + data.statusCode)

            status = JSON.parse response
            for service in status.services
                serviceMsg = ''
                switch service['current-event'].status.id
                    when 'down' then serviceMsg += @statusDown
                    when 'up' then serviceMsg += @statusUp
                    when 'warn' then serviceMsg += @statusWarn
                serviceMsg += ' ' + service.name
                cb(null, serviceMsg)

    set_status: (search_string, status, message, cb) ->
        found = false
        request.get @base_url + "/services", (error, data, response) =>
            if response?
                services = JSON.parse response
                for service in services['services']
                    do (service) =>
                        if (service.id.search search_string.toLowerCase()) > -1
                            found = true
                            form = status: status, message: message
                            options = urllib.parse(@base_url + '/services/' + service.id + '/events')
                            options.url = options
                            options.method = 'POST'
                            headers = 'Authorization': oauth.makeAuthorizationHeader(@state, options)
                            request.post url: options.url, form: form, headers: headers, (error, response, body) =>
                                if response.statusCode != 200
                                    return cb('Setting service failed! ' + response.statusCode + ' ' + response.body)
                                return cb('Okay, service ' + service.name + ' marked as ' + status + ' due to ' + message)
                unless found
                    cb('Unable to find service service called: ' + search_string)

module.exports = (robot) ->

    stashbot = new Stashbot robot, (err) ->
        robot.send null, 'Stashbot init error: ' + err

    robot.respond /stashboard (status|sup|\?)/i, (msg) =>
        msg.send 'Checking stashboard status ...'
        stashbot.get_status_all (err, status_msg) ->
            unless err?
                msg.send status_msg
            else
                msg.send err

    robot.respond /stashboard set (.*?) (.*?) (.*)/i, (msg) =>
        stashbot.set_status msg.match[1], msg.match[2], msg.match[3], (data) ->
            msg.send data
