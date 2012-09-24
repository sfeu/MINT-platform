
exports.init = (ss) ->
  subscribeServer(ss)


recordTouch = (touch) ->
  if newTouch(touch)
    template = $("<canvas class='touch' width='60' height='60' id='" + touch.identifier + "'></canvas>")
    $("#pointerCanvas").append template
    template.css
      left: touch.pageX - (template.width() / 2)
      top: touch.pageY - (template.height() / 2)

    t =
      touch: touch
      element: template

    touches.push t


moveTouch = (touch) ->
  i = 0

  while i < touches.length
    if touches[i].touch.identifier is touch.identifier
      touches[i].element.css
        left: touch.pageX - (touches[i].element.width() / 2)
        top: touch.pageY - (touches[i].element.height() / 2)
    i++


newTouch = (touch) ->
  i = 0
  while i < touches.length
    return false  if touches[i].touch.identifier is touch.identifier
    i++
  true

removeTouch_fromexisting = (all_touches) ->
  toRemove = []
  i = 0

  while i < touches.length
    found = false
    j = 0

    while j < all_touches.length
      found = true  if touches[i].touch.identifier is all_touches[j].identifier
      j++
    unless found
      toRemove.push
        obj: touches[i]
        ref: i

    i++
  i = 0

  while i < toRemove.length
    j = 0

    while j < touches.length
      touches.splice j, 1  if touches[j].touch.identifier is toRemove[i].obj.touch.identifier
      j++
    $(toRemove[i].obj.element).remove()
    i++


removeTouch = (touch) ->
  toRemove = []
  i = 0

  while i < touches.length
    if touches[i].touch.identifier is touch.identifier
      toRemove.push
        obj: touches[i]
        ref: i

    i++
  i = 0

  while i < toRemove.length
    j = 0

    while j < touches.length
      touches.splice j, 1  if touches[j].touch.identifier is toRemove[i].obj.touch.identifier
      j++
    $(toRemove[i].obj.element).remove()
    i++


drawTouch = (ref) ->
  canvas = document.getElementById(ref.touch.identifier)
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
  setTimeout drawTouches, 33

touches = []
angle = 0

setTimeout drawTouches, 33

subscribeServer = (ss) ->
  ss.event.on "touch", (data,channel) ->
    #a = jQuery.parseJSON(data)
    console.log "received thumb:#{data}"
    switch data.cmd
      when "NEW"
        recordTouch data.touch
      when "DEL"
        removeTouch data.touch
      when "POS"
        moveTouch data.touch