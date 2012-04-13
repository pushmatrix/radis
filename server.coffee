express = require('express')

if process.env.REDISTOGO_URL
  rtg = require("url").parse(process.env.REDISTOGO_URL)
  redis = require("redis").createClient(rtg.port, rtg.hostname)
  redis.auth(rtg.auth.split(":")[1])
else
  redis = require("redis").createClient()

redis.on "error", (err) ->
  console.log("Error " + err)

app = express.createServer()

app.get '/*', (req,res) ->
  path = req.path.substring(1)
  redis.get path, (err, results) ->
    res.send(results)

app.post '/*', (req,res) ->
  path = req.path.substring(1)
  req.content = ""

  req.addListener 'data', (chunk) ->
    req.content += chunk

  req.addListener 'end', ->
    redis.set path, req.content
    console.log req.content
    res.send("ok\n")

app.listen(3000)

console.log('Server running at http://127.0.0.1:1337/')