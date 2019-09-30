messageboxmodule = {name: "messageboxmodule", uimodule: true}


#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["messageboxmodule"]?  then console.log "[messageboxmodule]: " + arg
    return

#region internal variables

## UI Cache vars
messagebox = null
resetTimeoutMS = 12000
intervalId = 0 #is also the indicator if we have a message to reset
#endregion


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
messageboxmodule.initialize = () ->
    log "messageboxmodule.initialize"
    messagebox = document.getElementById("messagebox")

#region internal functions
resetMessageBox = ->
    log "resetMessageBox"
    if intervalId 
        clearInterval(intervalId)
        intervalId = 0

    messagebox.removeAttribute("class")
    messagebox.textContent = ""

setResetTimeout = ->
    log "setResetTimeout"

    if intervalId 
        clearInterval(intervalId)
        intervalId = 0

    intervalId = setInterval(resetMessageBox, resetTimeoutMS)


#endregion

#region Exposed Functions
messageboxmodule.showMessage = (message, type) ->
    log "messageboxmodule.showMessage"
    switch(type)
        when "success" then messageboxmodule.showSuccessMessage(message)
        when "info" then messageboxmodule.showInfoMessage(message)
        when "error" then messageboxmodule.showErrorMessage(message)
        when "warning" then messageboxmodule.showWarningMessage(message)

messageboxmodule.showInfoMessage = (message) ->
    log "messageboxmodule.showInfoMessage"
    messagebox.removeAttribute("class")
    messagebox.classList.add("info-msg")
    messagebox.textContent = "info: " + message
    setResetTimeout()

messageboxmodule.showErrorMessage = (message) ->
    log "messageboxmodule.showErrorMessage"
    messagebox.removeAttribute("class")
    messagebox.classList.add("error-msg")
    messagebox.textContent = "error: " + message
    setResetTimeout()

messageboxmodule.showWarningMessage = (message) ->
    log "messageboxmodule.showWarningMessage"
    messagebox.removeAttribute("class")
    messagebox.classList.add("warning-msg")
    messagebox.textContent = "warning: " + message
    setResetTimeout()

messageboxmodule.showSuccessMessage = (message) ->
    log "messageboxmodule.showSuccessMessage"
    messagebox.removeAttribute("class")
    messagebox.classList.add("success-msg")
    messagebox.textContent = "success: " + message
    setResetTimeout()

#endregion
export default messageboxmodule
