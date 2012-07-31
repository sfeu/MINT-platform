touches = {}
angle = 0
touch_gfx = {}

class Touch
  x: null
  y: null
  id: null
  constructor: (touch) ->
      @x = touch.pageX
      @y = touch.pageY
      @id = touch.identifier
  toJSON  = ->
    [id,x,y].toJSON

exports.init = (ss) ->
  subscribeServer(ss)
#  setTimeout drawTouches, 33
  #bind touch events
  $(document).bind "touchstart", (event) ->
    event.preventDefault()
    new_touches = []
    allTouches = event.originalEvent.touches
    i = 0
    while i < allTouches.length
      if newTouch allTouches[i]
        touches[allTouches[i].identifier] = allTouches[i]
        new_touches.push(new Touch(allTouches[i]))
      i++
    ss.rpc "platfotm.newTouch",new_touches if new_touches.length >0

  $(document).bind "touchend",(event) ->
    event.preventDefault()
   # console.log(event.originalEvent.changedTouches)
    allTouches = event.originalEvent.changedTouches
    console.log(allTouches)
    delete_touches = []
    for t in allTouches
      console.log "remove touches #{t}"
      delete_touches.push(new Touch(t))
    ss.rpc "platform.removeTouch",delete_touches

  $(document).bind "touchmove", (event) ->
    event.preventDefault()
    allTouches = event.originalEvent.touches
    moved_touches = []
    for t in allTouches
      console.log "move touches #{t}"
      moved_touches.push(new Touch(t))
    ss.rpc "platform.updateTouch", moved_touches

recordTouch = (touches) ->
  for touch in touches
    template = $("<canvas class='touch' width='60' height='60' id='" + touch.id + "'></canvas>")
    $("#pointerCanvas").append template
    template.css
      left: touch.x - (template.width() / 2)
      top: touch.y - (template.height() / 2)
    t =
      touch: touch
      element: template
    touch_gfx[touch.id] = t
    drawTouch touch

moveTouch = (touches) ->
  for touch in touches
    t = touch_gfx[touch.id]
    t.element.css
      left: touch.x - (t.element.width() / 2)
      top: touch.y - (t.element.height() / 2)

newTouch = (touch) ->
  touches[touch.identifier] == undefined


removeTouch = (touches) ->
  for touch in touches
    t = touch_gfx[touch.id]
    t.element.remove()
    delete touches[touch.id]
    delete touch_gfx[touch.id]

drawTouch = (ref) ->
  canvas = document.getElementById(ref.id)
  return  unless canvas
  ctx = canvas.getContext("2d")
  ctx.clearRect 0, 0, canvas.width, canvas.height
  ctx.save()
  ctx.setAlpha 0.8
  ctx.fillStyle = "#FF0000"
  ctx.beginPath()
  ctx.arc canvas.width / 2, canvas.height / 2, (canvas.width / 2) - 20, 0, Math.PI * 2, true
  ctx.closePath()
  ctx.fill()
  ctx.restore()
  ctx.save()


drawTouches = ->
  i = 0
  while i < touches.length
    drawTouch touches[i]
    i++
  angle = angle + 8


subscribeServer = (ss) ->
  ss.event.on "thumb", (data,channel) ->
    a = jQuery.parseJSON(data)
    console.log "received thumb:#{data}"
    switch a.cmd
      when "NEW"
        recordTouch a.touches
      when "DEL"
        removeTouch a.touches
      when "POS"
        moveTouch a.touches