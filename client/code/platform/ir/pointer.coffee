
last_send_mouse_X = -1
last_send_mouse_Y = -1

THRESHOLD_MOUSE_MOVEMENT_X = 9
THRESHOLD_MOUSE_MOVEMENT_Y = 6 # Address 16:9 format




# pointer display

SCREEN_WIDTH = 1200;
SCREEN_HEIGHT = 900 ;

pointer = null;
pointer_color = null;
pointer_size = 10
pointer_mid = 5

class Coordinate
  x: null
  y: null
  constructor: (x, y) ->
      @x = x
      @y = y
  toJSON  = ->
    [x,y].toJSON

exports.init = (ss)  ->
  document.oncontextmenu = ->
    false

  $(document).mousemove (e) ->
    x = e.clientX
    y = e.clientY
    if ( (Math.abs(last_send_mouse_X -  x)>THRESHOLD_MOUSE_MOVEMENT_X) || (Math.abs(last_send_mouse_Y -  y)>THRESHOLD_MOUSE_MOVEMENT_Y))
      ss.rpc "platform.updatePointer", (new Coordinate(x,y))
      last_send_mouse_X = x
      last_send_mouse_Y = y
  ss.rpc "platform.getUser", (user) ->
    ss.event.on "pointer", (c,channel) ->
      #console.log "hi!"
      if (pointer == null)
        recordPointer(c.x,c.y,'#00ff00')
      movePointer(c.x,c.y,'#00ff00')
  $(document).mouseup (e) ->
    #console.log(e)
    switch e.which
      when 1 then ss.rpc "platform.updateMouse","LEFT_RELEASED"
      when 2 then ss.rpc "platform.updateMouse","MIDDLE_RELEASED"
      when 3 then ss.rpc "platform.updateMouse","RIGHT_RELEASED"
  $(document).mousedown (e) ->
    switch e.which
      when 1 then ss.rpc "platform.updateMouse","LEFT_PRESSED"
      when 2 then ss.rpc "platform.updateMouse","MIDDLE_PRESSED"
      when 3 then ss.rpc "platform.updateMouse","RIGHT_PRESSED"


recordPointer = (x,y,color) ->
    template = $("<canvas class='touch' width='#{pointer_size}' height='#{pointer_size}' id='pointer'></canvas>")
    $('#pointerCanvas').append(template)
    template.css left: x - pointer_mid , top: y - pointer_mid
    pointer = template
    drawPointer(color)

movePointer = (x,y,color) ->
    pointer.css left: x - pointer_mid , top: y - pointer_mid
    #if (pointer_color!=color)
      #drawPointer(color)

drawPointer = (color) ->
    canvas = document.getElementById('pointer')
    if (!canvas)
      return
    ctx = canvas.getContext("2d")
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.save()
    ctx.setAlpha(0.4)
    ctx.clearRect(0,0, canvas.width, canvas.height)
    ctx.beginPath()
    ctx.fillStyle= color
    # Draws a circle of radius 5 at the coordinates x,y on the canvas
    ctx.arc(canvas.width / 2, canvas.height / 2,5,0,Math.PI*2,true)
    ctx.closePath()
    ctx.fill()
    ctx.restore()
    ctx.save()
    pointer_color = color

