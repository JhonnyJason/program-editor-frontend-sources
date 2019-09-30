appstatemodule = {name: "appstatemodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["appstatemodule"]?  then console.log "[appstatemodule]: " + arg
    return

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
appstatemodule.initialize = () ->
    log "appstatemodule.initialize"
    

#region the appstate object
appstatemodule.authToken = "0xoxox"
appstatemodule.loginState = 'notloggedin'
appstatemodule.currentProgram = null
appstatemodule.currentLangTag = "de"

#endregion

export default appstatemodule
