# Server-side Code

redis = require('redis')
R = redis.createClient(6379,"127.0.0.1",null)

subscribed = false

forwardCommand =(ss, counter, command, name,userId,session_id=null) ->
  session =""
  R.hgetall "mint_interactors:aui"+name, (err,aio) =>
    R.hgetall "mint_interactors:cui-gfx"+name, (err,cio) =>
      if (cio)
        session=":session:#{session_id}" if session_id
        ss.publish.channel "user:#{userId}#{session}","command",JSON.stringify {"counter":counter, "command":command,"aio":aio,"cio":cio}

subscribeInteractors = (ss, userId,session_id = null) ->
  counter = 0
  pubsub = redis.createClient(6379,"127.0.0.1",null)
  pubsub.psubscribe("Interactor.CIO.*")
  pubsub.on "pmessage", (pattern, channel, msg) =>
    if pattern == "Interactor.CIO.*"
      data = JSON.parse msg
      counter++
      data["counter"] = counter
      console.log "received #{data['name']} with new states #{data["new_states"]}"
      if "displaying" in data["new_states"]
        console.log "publish #{data['name']}"
        forwardCommand(ss,counter,"interactor",data["name"],userId)
        if "init_js"  in data["new_states"]
          forwardCommand(ss,counter,"init_js",data["name"],userId)
      else
        if "highlighted" in data["new_states"]
          console.log "highlighted #{data['name']}"
          forwardCommand(ss,counter,"highlight",data["name"],userId)
        if "displayed" in data["new_states"]
          forwardCommand(ss,counter,"unhighlight",data["name"],userId)
        if "hidden"  in data["new_states"]
          forwardCommand(ss,counter,"hide",data["name"],userId)
        if "selected" in data["new_states"]
          forwardCommand(ss,counter,"select",data["name"],userId)
        if "unselected" in data["new_states"]
          forwardCommand(ss,counter,"unselect",data["name"],userId)
        if "init_js"  in data["new_states"]
          forwardCommand(ss,counter,"init_js",data["name"],userId)
        if channel == "Interactor.CIO.Button"
          if "pressed" in data["new_states"]
            forwardCommand(ss,counter,"button",data["name"],userId)
          else
            if "released" in data["new_states"]
              forwardCommand(ss,counter,"button",data["name"],userId)
  # Test that should be later on changed to forward all changes to client if the object is in presenting!
  pubsub.subscribe("out_channel:Interactor.AIO.AIOUT.AIOUTContinuous.volume:testuser")
  pubsub.on "message", (channel, msg) =>
    console.log("received msg #{channel}")
    if channel== "out_channel:Interactor.AIO.AIOUT.AIOUTContinuous.volume:testuser"
      session=":session:#{session_id}" if session_id
      ss.publish.channel "user:#{userId}","Interactor.AIO.AIOUT.AIOUTContinuous.volume",JSON.parse(msg)

  console.log("Subscribed for displaying interactors")
  subscribed = true

# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
exports.actions = (req, res, ss) ->
  # Load session data into req.session
  req.use('session')

  init: () ->
    if req.session.userId
      # R.get "user:#{req.session.userId}", (err, data) =>
      #  if data
      console.log "Found data #{JSON.stringify req.session}"
      res req.session
    else
      res false

  signIn: (user) ->
    req.session.setUserId(user)
    req.session.channel.subscribe("user:#{req.session.userId}")
    req.session.channel.subscribe("user:#{req.session.userId}:session:#{req.session.id}")
    subscribeInteractors(ss,req.session.userId,req.session.id)  if not subscribed
    res req.session.userId

  newTouch: (touches) ->
    console.log("newTouch")
    ss.publish.channel "user:#{req.session.userId}","thumb",JSON.stringify {cmd: "NEW", touches: touches }

  removeTouch: (touches) ->
    console.log("removeTouch")
    ss.publish.channel "user:#{req.session.userId}","thumb",JSON.stringify {cmd: "DEL", touches: touches }

  updateTouch: (touches) ->
    console.log("updateTouch")
    ss.publish.channel "user:#{req.session.userId}","thumb",JSON.stringify {cmd: "POS", touches: touches }

  updatePointer: (coords) ->
    ss.publish.channel "user:#{req.session.userId}","pointer",coords
    r = JSON.stringify {"cmd": "pointer", "data" : [coords.x,coords.y]}
    R.publish "data:Interactor.Pointer.Mouse.mouse:user:#{req.session.userId}",r

  updateInteractorSize: (coords) ->
    console.log("update interactor #{coords}")
    R.publish "in_channel:Interactor.CIO.coordinates."+coords.name+":"+req.session.userId,JSON.stringify coords

  updateMouse: (cmd) ->
    r = JSON.stringify {"cmd": "button", "data" : cmd}
    R.publish "data:Interactor.Pointer.Mouse.mouse:user:#{req.session.userId}",r

  updateSlider: ([name,value]) ->
    R.publish "in_channel:Interactor.AIO.AIIN.AIINContinuous."+name+":"+req.session.userId,value

  stopSlider: (name) ->
    R.publish "in_channel:Interactor.AIO.AIIN.AIINContinuous."+name+":"+req.session.userId,"stop"


  retrieveActiveInteractors: () ->
    console.log "in retrieve interactos session #{JSON.stringify req.session}"
    R.smembers "mint_interactors:mint_model:name:all", (err,ids) =>
      for id in ids
        ((id_copy,userId,session_id) ->
          R.hmget "mint_interactors:"+id_copy, "mint_model","abstract_states", "states", "name", (err,element) =>
            if (element[0] is "cui-gfx") and (("displaying" in element[1].split('|')) or "displaying" in element[2].split('|') or ("hidden" in element[1].split('|')) or "hidden" in element[2].split('|') )
              ((name,uid,sid) ->
                console.log "session before publish #{JSON.stringify req.session}"
                forwardCommand(0,"interactor",name,uid,sid)
              ) element[3],userId,session_id
        ) id,req.session.userId,req.session.id
    res true

  # Quick Chat Demo
  sendMessage: (message) ->
    if message.length > 0                             # Check for blank messages
      ss.publish.broadcast 'newMessage', message      # Broadcast the message to everyone
      res true                                         # Confirm it was sent to the originating client
    else
      res false

  authenticate: (params) ->
    req.session.authenticate 'custom_auth', params, (response) =>
      req.session.setUserId(response.userId) if response.success       # sets session.user.id and initiates pub/sub
      res response                                                  # sends additional info back to the client

  getUser: () ->
    res req.session.userId

  logout: () ->
    req.session.user.logout()                                        # disconnects pub/sub and returns a new Session object

