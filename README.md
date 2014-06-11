# hubot-stashboard

Teaches hubot to read and write to a [Stashboard](http://www.stashboard.org) instance.

See [`src/stashboard.coffee`](src/stashboard.coffee) for full documentation.

[![Build Status](https://travis-ci.org/rsalmond/hubot-stashboard.svg?branch=master)](https://travis-ci.org/rsalmond/hubot-stashboard)

## Installation

In hubot project repo, run:

`npm install hubot-stashboard --save`

Then add **hubot-stashboard** to your `external-scripts.json`:

```json
["hubot-stashboard"]
```

## Sample Interaction

```
user1>> hubot stashboard sup
hubot>> Production (successful)
```
