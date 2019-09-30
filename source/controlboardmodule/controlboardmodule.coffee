controlboardmodule = {name: "controlboardmodule", uimodule: true}


#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["controlboardmodule"]?  then console.log "[controlboardmodule]: " + arg
    return

#region internal variables

## UI Cache vars
controlboard = null
verticalSelectModeButton = null
horizontalSelectModeButton = null

#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
controlboardmodule.initialize = () ->
    log "controlboardmodule.initialize"
    controlboard = document.getElementById("controlboard")
    verticalSelectModeButton= document.getElementById("vertical-select-mode-button")
    horizontalSelectModeButton = document.getElementById("horizontal-select-mode-button")

    controlboard.addEventListener("click", controlboardClicked)
    verticalSelectModeButton.addEventListener("click", verticalSelectModeButtonActivated)
    horizontalSelectModeButton.addEventListener("click", horizontalSelectModeButtonActivated)

#region internal functions

##Event Handlers
controlboardClicked = (event) ->
    log "controlboardClicked"
    controlboard.classList.toggle("compressed")

verticalSelectModeButtonActivated = (event) ->
    log "verticalSelectModeButtonActivated"
    event.stopPropagation()
    allModules.selectmodule.setSelectMode("vertical")
    applyVerticalSelectMode()

horizontalSelectModeButtonActivated = (event) ->
    log "horizontalSelectModeButtonActivated"
    event.stopPropagation()
    allModules.selectmodule.setSelectMode("horizontal")
    applyHorizontalSelectMode()

##set the UI state
applyVerticalSelectMode = ->
    log "applyVerticalSelectMode"
    verticalSelectModeButton.classList.add("selected")
    horizontalSelectModeButton.classList.remove("selected")


applyHorizontalSelectMode = ->
    log "applyhorizontalSelectMode"
    horizontalSelectModeButton.classList.add("selected")
    verticalSelectModeButton.classList.remove("selected")

#endregion

#region Exposed Functions
#endregion
export default controlboardmodule
