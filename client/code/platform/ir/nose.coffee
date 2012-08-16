nosePointer = null
coord_system_width= 0
coord_system_height = 0
x_max_calibrated = 1
x_min_calibrated = -1
y_max_calibrated = 1
y_min_calibrated = -1
x_factor = 1
y_factor = 1

exports.init = (ss) ->
  subscribeServer(ss)

recalibrate_x = (x) ->
  if x > x_max_calibrated
    x_max_calibrated = x
  if x < x_min_calibrated
    x_min_calibrated = x
  x_input_width = Math.abs(x_max_calibrated) + Math.abs(x_min_calibrated)
  x_factor = coord_system_width / x_input_width

recalibrate_y = (y) ->
 if y > y_max_calibrated
   y_max_calibrated = y
 if y < y_min_calibrated
   y_min_calibrated = y

 y_input_width = Math.abs(y_max_calibrated) + Math.abs(y_min_calibrated)
 y_factor = coord_system_height / y_input_width

translate = (nose) ->
  x = nose.x
  y = nose.y
  if x > x_max_calibrated or x< x_min_calibrated
    recalibrate_x(x)
  if y > y_max_calibrated or y< y_min_calibrated
    recalibrate_y(y)

  nose.x = Math.round((x+Math.abs(x_min_calibrated)) * x_factor)
  nose.y = coord_system_height-Math.round((y+Math.abs(y_min_calibrated)) * y_factor)
  nose

addNose = (nose) ->
  coord_system_width = $('#main').width()
  coord_system_height = $('#main').height()
  recalibrate_x(nose.x)
  recalibrate_y(nose.y)
  nosePointer = $("<canvas style='z-index:255;' class='nose' width='80' height='80' id='nose-canvas'></canvas>")
  $("#pointerCanvas").append nosePointer
  nosePointer.css
      left: nose.x - (nosePointer.width() / 2)
      top: nose.y - (nosePointer.height() / 2)
    drawNose nose

moveNose = (nose) ->
  nosePointer.css
      left: nose.x - (nosePointer.width() / 2)
      top: nose.y - (nosePointer.height() / 2)

removeNose = (touches) ->
  nosePointer.remove()

drawNose = ->
  canvas = document.getElementById('nose-canvas');
  if (!canvas)
       return
  ctx = canvas.getContext("2d")
  ctx.clearRect 0, 0, canvas.width, canvas.height
  ctx.save()
  ctx.setAlpha 0.3
  ctx.fillStyle = "#0000BB"
  ctx.beginPath()
  ctx.arc canvas.width / 2, canvas.height / 2, (canvas.width / 2) - 20, 0, Math.PI * 2, true
  ctx.closePath()
  ctx.fill()
  ctx.restore()
  ctx.save()

subscribeServer = (ss) ->
  ss.event.on "Interactor.Head.head", (nose,channel) ->
   # nose = jQuery.parseJSON(data)
    nose = translate(nose)
    console.log ("Translated nose #{nose.x},#{nose.y}")
    if not nosePointer
      addNose nose
    else
      moveNose nose
    #when "DEL"
    #    removeNose
