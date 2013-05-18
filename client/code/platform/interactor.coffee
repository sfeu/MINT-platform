exports.htmlheadJS = (interactor) ->
  $("#htmlhead-"+interactor.cio.name).appendTo("#mint-header")

exports.labelJS = (interactor) ->
  $("#label-"+interactor.cio.name).prependTo("#"+interactor.aio.refers)

exports.sliderJS = (interactor) ->
  $("#slider-"+interactor.cio.name).slider
    slide: (event, ui) ->
      ss.rpc "platform.updateSlider",([interactor.cio.name, ui.value])
    stop:(event,ui) ->
      ss.rpc "platform.stopSlider",(interactor.cio.name)

exports.progressbarJS = (interactor) ->
  $("#progressbar-"+interactor.cio.name).progressbar({ value: interactor.aio.data });
  ss.event.on 'Interactor.AIO.AIOUT.AIOUTContinuous.'+interactor.cio.name, (msg,channel) ->
      $("#progressbar-volume").progressbar( "option", "value", msg);

exports.minimaloutputsliderJS = (interactor) ->
  ss.event.on 'Interactor.AIO.AIOUT.AIOUTContinuous.'+interactor.cio.name, (msg,channel) ->
      console.log("minimal #{msg}")
      $("#"+interactor.cio.name).css( "left" , msg+"%" );

exports.minimalverticaloutputsliderJS = (interactor) ->
  ss.event.on 'Interactor.AIO.AIOUT.AIOUTContinuous.'+interactor.cio.name, (msg,channel) ->
      console.log("minimal #{msg}")
      $("#"+interactor.cio.name).css( "top" , msg+"%" );

exports.buttonJS = (interactor) ->
  $("#button-"+interactor.cio.name).button().unbind('mouseenter mouseleave');
  ss.event.on 'button', (msg,channel) ->
    msg = JSON.parse msg
    cio = msg.cio
    id = getIdentifier(msg)
    if !!~ cio.new_states.indexOf  "released"
      $(id).removeClass("ui-state-active")
    else
      if !!~ cio.new_states.indexOf "pressed"
        $(id).addClass("ui-state-active")
      #$("#button-"+name).removeClass('hover');

exports.radiobuttongroupJS = (interactor) ->
  $("#radiobuttongroup-"+interactor.cio.name).buttonset();

exports.caroufredselJS = (interactor) ->
  #$("#" + interactor.cio.name + " img").each (index) ->
  #  src = $(this).attr("src").replace(".png", "_thumb.png")
  #  $('#pager').append "<img src=\"" + src + "\" border=\"0\" />"

  #copy images into the right container div
  $("#caroufredsel-sheets > img").appendTo("#sheets")

  #init the carousel
  $("#" + interactor.cio.name).carouFredSel
    circular: (interactor.cio["circular"] is true)
    auto: (interactor.cio["auto"] is true)
    scroll_items: interactor.cio.scroll_items
    scroll_fx: interactor.cio.scroll_fx
    scroll_duration: interactor.cio.scroll_duration
    width: interactor.cio.width
    height: interactor.cio.height
    pagination:
      container: '#pager',
      event: '',
      items: 1,
      anchorBuilder: (nr, item) ->
            src = item.attr("src").replace(".png", "_thumb.png")
            "<img src=\"" + src + "\" border=\"0\" />"

exports.caroufredselimageJS = (interactor) ->
  console.log("#{interactor.aio.parent} switch to #{interactor.aio.name}")
  $('#'+interactor.aio.parent).trigger("slideTo","#caroufredselimage-"+interactor.aio.name);

exports.webcamJS = (interactor) ->
  console.log("webcam JS"+interactor.cio.name)
  navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia || navigator.oGetUserMedia;

  navigator.getUserMedia
    video: true
    audio: true
  , ((localMediaStream) ->
    video = document.querySelector('#'+ interactor.cio.name+"-webcam")
    console.log video
    video.src = window.URL.createObjectURL(localMediaStream)
    video.onloadedmetadata = (e) ->
# Ready to go. Do some stuff.
      console.log "ready"
  ), (e) ->
    console.log "Reeeejected!", e



