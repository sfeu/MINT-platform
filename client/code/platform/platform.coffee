# Client-side Code
pointer = require("/ir/pointer.coffee")
touch = require("/ir/touch.coffee")
interactorJS = require("/interactor.coffee")
Array::remove = ( e ) -> @splice i, 1 if (i = @indexOf e) isnt -1

current_user = null

class InteractorSize
    x: null
    y: null
    width: null
    height: null
    name: null
    constructor: (name,interactor,w,h) ->
        @x = Math.round interactor.offset().left
        @y = Math.round interactor.offset().top
        @width = Math.round w
        @height = Math.round h
        @name = name
        console.log("width!!! #{@width}")


displaySignInForm = ->
  $('#signIn').show().submit ->
    ss.rpc 'platform.signIn',$('#signIn').find('input').val(), (userid) ->
      $('#signInError').remove()
      console.log(userid)
      $('#signIn').fadeOut(230)
      setUser(userid)
      displayMainScreen()
    false

displayMainScreen = ->
  pointer.init(ss)
  touch.init(ss)
  ss.rpc 'platform.retrieveActiveInteractors'
 #   interactors.forEach (interactor) ->
 #     displayInteractor(interactor)

getIdentifier = (interactor) ->
  types = interactor.cio.classtype.split("::")
  i_type = types[types.length - 1]
  "#"+i_type.toLowerCase() + "-" + interactor.cio.name

hideInteractor = (interactor) ->
  identifier = getIdentifier(interactor)
  if $(identifier).length == 0
    displayInteractor(interactor)
  else
    $(identifier).hide()

highlightInteractor = (highlight,interactor) ->
  identifier = getIdentifier(interactor)
  if highlight
    $(identifier).addClass("ui-state-hover")
    $(identifier).removeClass("displayed")
  else
    $(identifier).removeClass("ui-state-hover")
    $(identifier).addClass("displayed")

displayInteractor = (interactor) ->
  console.log interactor
  if hasUnresolvedDependencies(interactor)
    window.unresolvedDepsInteractors.push interactor
    return

  identifier = getIdentifier(interactor)

  if ($(identifier).length > 0)  # check if the interactor is just hidden
    $(identifier).show()
  else
    types = interactor.cio.classtype.split("::")
    i_type = types[types.length - 1]
    fim = $('#tmpl-platform-'+i_type).tmpl(interactor)

    elem = null
    if ("hidden" in interactor.cio.states.split('|')) or "hidden" in interactor.cio.abstract_states.split('|')
      fim.hide()
    if (interactor.aio.parent and $('#'+interactor.aio.parent).length > 0)
      fim.appendTo('#'+interactor.aio.parent)
    else
      fim.appendTo('#main')
    fim.addClass("displayed")

    elem = $(identifier)
    if elem.length >0
      console.log("sizes #{elem.offset().left}/#{elem.offset().top} - #{elem.outerWidth()}/#{elem.outerHeight()}")
      ss.rpc 'platform.updateInteractorSize',(new InteractorSize(interactor.aio.name,elem,elem.outerWidth(),elem.outerHeight()))

    window.displayedInteractors.push interactor

    for interactor in window.unresolvedDepsInteractors
          if not hasUnresolvedDependencies(interactor)
            window.unresolvedDepsInteractors.remove interactor
            displayInteractor interactor
            break

initJSInteractor = (interactor) ->
  types = interactor.cio.classtype.split("::")
  i_type = types[types.length - 1]
  #call a javacsript function that can be used to initialize the new interactor
  jsfunction = "interactorJS." + i_type.toLowerCase() + "JS"
  if (eval("typeof " + jsfunction + " == 'function'"))
    f = eval(jsfunction)  # bad style TODO but windows does not work like expected
    f(interactor)

  elem = $('#'+interactor.aio.name)
  if elem.length >0
    console.log("init_js sizes #{elem.offset().left}/#{elem.offset().top} - #{elem.css('width')}/#{elem.css('height')}")
    ss.rpc 'platform.updateInteractorSize',(new InteractorSize(interactor.aio.name,elem,elem.width(),elem.height()))

setUser = (userid) ->
  $('#user').text("User:"+userid)


hasUnresolvedDependencies = (interactor) ->
  return false if not interactor.cio.depends
  dependencies = interactor.cio.depends.split("|")
  for dependency in dependencies
    return true if dependencyNotMet(dependency)
  return false

dependencyNotMet = (dependency) ->
  for interactor in window.displayedInteractors
    return false if !!~ interactor.cio.name.indexOf dependency
  return true


window.displayedInteractors = []
window.unresolvedDepsInteractors = []

ss.event.on 'command', (msg,channel) ->
  data = JSON.parse msg
  console.log "command: #{data['command']} for #{data.aio.name}"
  switch data["command"]
    when "interactor" then displayInteractor(data)
    when 'hide' then hideInteractor(data)
    when 'init_js' then initJSInteractor(data)
    when 'highlight' then highlightInteractor(true,data)
    when 'unhighlight' then highlightInteractor(false,data)

ss.rpc 'platform.init', (user) ->
  console.log(user)
  if user
    setUser(user.user_id)
    $('#main').show()
    displayMainScreen()
  else
    displaySignInForm()