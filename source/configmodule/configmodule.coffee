configmodule = {name: "configmodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["configmodule"]?  then console.log "[configmodule]: " + arg
    return

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
configmodule.initialize = () ->
    log "configmodule.initialize"
    

#region the configuration Object
configmodule.sServerURL = 'https://program-manager-backend.auroxtech.com' ## service Server
################################################################################
configmodule.fatality_alerts = true
configmodule.fatality_death = false
#endregion

export default configmodule
