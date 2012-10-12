
TIP_NAME = "tip-point"
touch_gfx = {}
tip_count = 0
tip_touched = {} # remembers if a tip has been displayed as touched or not to redraw just in case of a change

exports.init = (ss) ->
  subscribeServer(ss)

moveTouch = (id,coordinates) ->
  [touched,x,y] = coordinates

  t = touch_gfx[id]
  t.css
    left:x - (t.width() / 2)
    top: y - (t.height() / 2)
  paintTouch(id,touched) if tip_touched[id]!=touched

removeTouch = (id) ->
  t = touch_gfx[id]
  t.remove()
  delete touch_gfx[id]

drawTouch = (id,coordinates) ->
  [touched,x,y] = coordinates
  template = $("<canvas class='touch' style='z-index:255;' width='60' height='60' id='#{TIP_NAME}-#{id}'></canvas>")
  $("#pointerCanvas").append template
  touch_gfx[id] = template
  moveTouch(id,coordinates)
  paintTouch(id,touched)

paintTouch = (id,touched) ->
  tip_touched[id] = touched
  canvas = document.getElementById("#{TIP_NAME}-#{id}")
  ctx = canvas.getContext("2d")
  ctx.clearRect 0, 0, canvas.width, canvas.height
  ctx.save()
  ctx.setAlpha 0.8
  if parseInt( touched, 10 )==0
    ctx.fillStyle = "#FF0000"
  else
    ctx.fillStyle = "#00FF00"
  ctx.beginPath()
  ctx.arc canvas.width / 2, canvas.height / 2, (canvas.width / 2) - 20, 0, Math.PI * 2, true
  ctx.closePath()
  ctx.fill()
  ctx.restore()
  ctx.save()


updateTouches = (touches) ->
  i = 0
  for touch in touches
     if tip_count <= i # a new finger tip
       drawTouch(i,touch)
     else
       moveTouch(i,touch) # a movement
     i++
  existing_tips = i
  # remove all touches for that no updates have been received
  while i < tip_count
    removeTouch i
    i++
  tip_count = existing_tips

subscribeServer = (ss) ->
  ss.event.on "touches", (touches,channel) ->
    console.log "received touches:#{touches}"
    updateTouches(touches)