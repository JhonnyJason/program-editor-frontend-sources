pageheadermodule = {name: "pageheadermodule", uimodule: true}



#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pageheadermodule"]?  then console.log "[pageheadermodule]: " + arg
    return

############################################################
#region internalVariables
loginButton = null
saveButton = null
discardButton = null
passwordInput = null
rightBlock = null
maincontent = null

AppVars = null
#endregion internal variables

############################################################
pageheadermodule.initialize = () ->
    log "pageheadermodule.initialize"
    AppVars = allModules.appstatemodule
    loginButton = document.getElementById 'login-button'
    saveButton = document.getElementById 'save-button'
    discardButton = document.getElementById 'discard-button'
    passwordInput = document.getElementById 'password'
    rightBlock = document.getElementById 'right-block'
    maincontent = document.getElementById 'maincontent'

    passwordInput.addEventListener 'keydown', passwordKeyPressed
    loginButton.addEventListener 'click', loginButtonClicked
    discardButton.addEventListener 'click', discardButtonClicked 
    saveButton.addEventListener 'click', saveButtonClicked 
    return

############################################################
#region internalFunctions
startLogIn = ->
    password = passwordInput.value if passwordInput
    log password
    data =
        secret: password

    allModules.websocketmodule.attemptLogin(data)

passwordKeyPressed = (evt) ->
	loginButtonClicked() if evt.keyCode == 13

saveButtonClicked = ->
    log "saveButtonClicked"
    allModules.datahandlermodule.saveData()

discardButtonClicked = ->
    log "discardButtonClicked"
    allModules.datahandlermodule.discardChanges()

loginButtonClicked = ->
    switch AppVars.loginState
        when "notloggedin" then setStateTyping()
        when "typing" then startLogIn()
        when "loggedin" then setStateNotLoggedIn()
        else
            log "we had weird state: " + AppVars.loginState
    return

################################################################################
# State Setter Function
################################################################################
setStateLoggedIn = (token) ->
    log "setStateLoggedIn"
    AppVars.authToken = token
    AppVars.loginState = "loggedin"
    rightBlock.classList.remove 'typing'
    saveButton.classList.add 'present'
    discardButton.classList.add 'present'
    loginButton.innerHTML = "Logout"
    maincontent.classList.add 'loggedin'

setStateNotLoggedIn = ->
    log "setStateNotLoggedIn"
    AppVars.loginState = "notloggedin"
    AppVars.authToken = "0xoxox"
    saveButton.classList.remove 'present'
    discardButton.classList.remove 'present'
    rightBlock.classList.remove 'typing'
    loginButton.innerHTML = "Login"
    maincontent.classList.remove 'loggedin'

setStateTyping = ->
    log "setStateTyping"
    AppVars.loginState = "typing"
    rightBlock.classList.add 'typing'
    saveButton.classList.remove 'present'
    discardButton.classList.remove 'present'
    loginButton.innerHTML = "OK"
    passwordInput.focus()
#endregion

############################################################
#region exposedFunctions
pageheadermodule.setStateUnsavedChanges = ->
    log "pageheadermodule.setStateUnsavedChanges"
    saveButton.disabled = false
    discardButton.disabled = false

pageheadermodule.setStateNoUnsavedChanges = ->
    log "pageheadermodule.setStateNoUnsavedChanges"
    saveButton.disabled = true
    discardButton.disabled = true


############################################################
pageheadermodule.applyLoginSuccess = () ->
    log "applyLoginSuccess"
    setStateLoggedIn()
    allModules.datahandlermodule.retrieveAllData()

pageheadermodule.applyLoginFail = () ->
    log "applyLoginFail"
    setStateNotLoggedIn()

pageheadermodule.communicationFail = (error) ->
    log "communication to the Server has failed!"
    log error
    pageheadermodule.applyLoginFail()

#endregion

export default pageheadermodule
