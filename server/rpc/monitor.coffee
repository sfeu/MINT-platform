# Server-side Code
net = require('net')
redis = require('redis')
R = redis.createClient(6379,"127.0.0.1",null)
subscribed_interactors = false
subscribed_mappings = false
console.log "called"

# connection to mapping server
mapping_client = null

subscribeInteractors = (ss) ->
  if not subscribed_interactors
    #config = SS.config.redis_pubsub || SS.config.redis
    pubsub = redis.createClient(6379,"127.0.0.1",null)

    pubsub.psubscribe("Interactor.*")
    console.log "in subscribe"
    pubsub.on "pmessage", (pattern, channel, msg) =>
      ss.publish.channel "MINT-monitor",'interactor', msg
    subscribed_interactors = true
  else
    console.log "already subscribed to interactors"

# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
exports.actions = (req, res, ss) ->

  # Example of pre-loading sessions into req.session using internal middleware
  req.use('session')

  # Uncomment line below to use the middleware defined in server/middleware/example
  #req.use('example.authenticated')

  sendMessage: (message) ->
    if message && message.length > 0            # Check for blank messages
      ss.publish.all('newMessage', message)     # Broadcast the message to everyone
      res(true)                                 # Confirm it was sent to the originating client
    else
      res(false)

  init: () ->
   req.session.channel.subscribe("MINT-monitor")
   res "SocketStream version #{ss.version} is up and running. This message was sent over Socket.IO so everything is working OK."

  retrieveInteractors: () ->
   console.log("R:"+R)

   list = []
   R.smembers "mint_interactors:mint_model:name:all", (err,ids) =>
     count = ids.length
     for id in ids
       ((id_copy) ->
         R.hmget "mint_interactors:"+id_copy, "classtype","name", "states","abstract_states", "new_states","mint_model", (err,element) =>
           list.push element
           count--
           if count==0
             subscribeInteractors(ss)
             result = JSON.stringify list
             res result
       ) id

  retrieveMappings: () ->
    if not subscribed_mappings
     TCPClient = require('simpletcp').client()

     mapping_client = new TCPClient("client1", "localhost", 8000, ->
       mapping_client.write "LIST"
       #client.close()
     )
     mapping_client.on "data", (obj) ->
       d = obj.split "%"
       console.log "data #{obj}"
       if !!~ d[0].indexOf "MAPPING"
         #SS.publish.broadcast 'newMapping', d[1]
         mapping_client.write "REGISTER%#{d[1]}"
       if !!~ d[0].indexOf "INFO"
         ss.publish.channel "MINT-monitor",'updateMapping', JSON.stringify {name: d[1],status:d[2]}
     mapping_client.on('error', (err) ->
      console.log('Trying to connect to server. Got error: '+err))
     mapping_client.open()
     subscribed_mappings = true
    else
     console.log "already subscribed to mappings"
    res JSON.stringify []