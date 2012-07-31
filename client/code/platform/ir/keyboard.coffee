exports.init = ->
  $(document).keypress (e) ->
    console.log(e)
    SS.server.app.keyPress("test")
