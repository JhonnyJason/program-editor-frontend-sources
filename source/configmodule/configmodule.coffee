configmodule = {name: "configmodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
configmodule.initialize = () ->
    log "configmodule.initialize"
    log JSON.stringify(configmodule)

#region the configuration Object
# configmodule.sServerURL = 'http://program-tester.aurox.at'
# configmodule.websocketURL = 'http://program-tester.aurox.at' 
configmodule.sServerURL = 'https://localhost:6969'
configmodule.websocketURL = 'wss://localhost:6969'

################################################################################
configmodule.fatality_alerts = true
configmodule.fatality_death = false
#endregion

export default configmodule
