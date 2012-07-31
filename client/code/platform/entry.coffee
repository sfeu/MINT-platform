# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
  $('#main').css opacity: 0.3
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  $('#main').css opacity: 1
  console.log('Connection back up :-)')

ss.server.on 'ready', ->

  # Wait for the DOM to finish loading
  jQuery ->
    
    # Load app
    require('/platform')
