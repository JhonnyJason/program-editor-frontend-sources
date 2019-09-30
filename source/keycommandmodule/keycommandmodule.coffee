keycommandmodule = {name: "keycommandmodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["keycommandmodule"]?  then console.log "[keycommandmodule]: " + arg
    return

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
keycommandmodule.initialize = () ->
    log "keycommandmodule.initialize"
    document.addEventListener("keydown", checkForKeyCommands)

#region Internal Functions
checkForKeyCommands = (event) ->
    log "checkForKeyCommands"
    if !event.ctrlKey then return true
    
    switch event.key
        when "c" then return copyCommandActivated(event)
        when "v" then return pasteCommandActivated(event)
        when "z" then return backCommandActivated(event)
        when "y" then return forwardCommandActivated(event)
        when "s" then return saveCommandActivated(event)
        when "x" then return cutCommandActivated(event)
        when "+" then return zoomInCommandActivated(event)
        when "-" then return zoomOutCommandActivated(event)
        when " " then return pauseCommandActivated(event)
        when "a" then return selectAllCommandActivated(event)

selectAllCommandActivated = (event) ->
    log "selectAllCommandActivated"
    allModules.selectmodule.selectAll()
    event.preventDefault()

pauseCommandActivated = (event) ->
    log "pauseCommandActivated"
    allModules.selectmodule.pauseSelection()
    return true # also thes not matter here hopefully

copyCommandActivated = (event) ->
    log "copyCommandActivated"
    allModules.selectmodule.copySelection()
    return true # does not matter here

pasteCommandActivated = (event) ->
    log "pasteCommandActivated"
    allModules.selectmodule.pasteSelection()
    event.preventDefault() # could lead to unexpected UX
    
backCommandActivated = (event) ->
    log "backCommandActivated"
    allModules.actionhistorymodule.actionBack()
    event.preventDefault() # could lead to unexpected UX

forwardCommandActivated = (event) ->
    log "forwardCommandActivated"
    allModules.actionhistorymodule.actionForward()
    event.preventDefault() # could lead to unexpected UX

saveCommandActivated = (event) ->
    log "saveCommandActivated"
    allModules.datahandlermodule.saveData()
    event.preventDefault() # could lead to unexpected UX

cutCommandActivated = (event) ->
    log "cutCommandActivated"
    allModules.selectmodule.cutSelection()
    event.preventDefault() # could lead to unexpected UX

zoomInCommandActivated = (event) ->
    log "zoomInCommandActivated"
    event.preventDefault()
    allModules.dynamiccontentmodule.zoomIn()

zoomOutCommandActivated = (event) ->
    log "zoomOutCommandActivated"
    event.preventDefault()
    allModules.dynamiccontentmodule.zoomOut()

#endregion

export default keycommandmodule
