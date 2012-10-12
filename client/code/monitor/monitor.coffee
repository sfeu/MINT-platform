# Client-side Code

interactor_ref = {}
table = null
mapping_table = null
mapping_ref ={}
mapping_counter = 0

createReferences = (data) ->
  row = 0
  for interactor in data
    interactor_ref["#{interactor[5]}#{interactor[1]}"]=row
    row++

retrieveInteractors = () ->
  ss.rpc 'monitor.retrieveInteractors', (response) ->
      aDataSet = jQuery.parseJSON response
      createReferences(aDataSet)
      table = $('#example').dataTable( {
        "aaData": aDataSet,
        "iDisplayLength": 50,
        "aoColumns": [
          { "sTitle": "class" },
          { "sTitle": "name" },
          { "sTitle": "states" },
          { "sTitle": "abstract_states", "sClass": "center" },
          { "sTitle": "new_states", "sClass": "center"}
        ]
      } )

  ss.rpc 'monitor.retrieveCIOInteractors', (response) ->
        aDataSet = jQuery.parseJSON response
        createReferences(aDataSet)
        table = $('#cio').dataTable( {
          "aaData": aDataSet,
          "iDisplayLength": 50,
          "aoColumns": [
            { "sTitle": "class" },
            { "sTitle": "name" },
            { "sTitle": "x" },
            { "sTitle": "y", "sClass": "center" },
            { "sTitle": "width", "sClass": "center"}
            { "sTitle": "height", "sClass": "center"}
            { "sTitle": "layer", "sClass": "center"}
          ]
        } )

updateInteractor = (data) ->
  row = interactor_ref["#{data['mint_model']}#{data['name']}"]
  table.fnUpdate( data['new_states'].join("|"), row, 4 )
  table.fnUpdate( data['abstract_states'], row, 3 )
  table.fnUpdate( data['states'].join("|"), row, 2 )
  $(table.fnGetNodes(row)).effect( 'highlight', null, 1000);
  #console.log ("update row #{row} with newstates #{data['new_states'].join("|")} requested")

# This method is called automatically when the websocket connection is established. Do not rename/delete
ss.rpc('monitor.init',null)
#SS.server.monitor.init()
ss.event.on 'interactor', (msg,channel) ->
  updateInteractor(JSON.parse msg)

ss.event.on 'newMapping', (msg,channel) ->
  console.log "mapping #{msg}"
  row = mapping_table.fnAddData([msg,"t","t"])
  mapping_ref["#{msg}"]=row[0]

ss.event.on 'updateMapping', (msg,channel) ->
    mapping_counter++
    data = JSON.parse(msg)
    console.log data
    mapping_table.fnAddData(["#{mapping_counter}",JSON.parse(data['status'])['name'],data['name']])

retrieveInteractors()

ss.rpc 'monitor.retrieveMappings',null, (response) ->
  mapping_table = $('#mappings').dataTable( {
    "iDisplayLength": 50,
    "aoColumns": [
      { "sTitle": "nr" },
      { "sTitle": "name" },
      { "sTitle": "mapping" }

    ]
  } )
$('#tabs').tabs();
$('#refresh_interactors').button().click ->
  retrieveInteractors()
