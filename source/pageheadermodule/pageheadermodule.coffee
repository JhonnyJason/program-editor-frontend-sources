pageheadermodule = {name: "pageheadermodule", uimodule: true}



#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["pageheadermodule"]?  then console.log "[pageheadermodule]: " + arg
    return

#region internal variables
loginButton = null
saveButton = null
discardButton = null
passwordInput = null
rightBlock = null
maincontent = null

AppVars = null
#endregion internal variables

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
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

#region exposed functions
pageheadermodule.setStateUnsavedChanges = ->
    log "pageheadermodule.setStateUnsavedChanges"
    saveButton.disabled = false
    discardButton.disabled = false

pageheadermodule.setStateNoUnsavedChanges = ->
    log "pageheadermodule.setStateNoUnsavedChanges"
    saveButton.disabled = true
    discardButton.disabled = true

#endregion

#region internal functions
startLogIn = ->
	password = passwordInput.value if passwordInput
	console.log password
	data =
		secret: password
	allModules.networkmodule.requestBackendService "login", data, loginResponse, communicationFail

passwordKeyPressed = (evt) ->
	loginButtonClicked() if evt.keyCode == 13

saveButtonClicked = ->
    log "saveButtonClicked"
    allModules.datahandlermodule.saveData()

discardButtonClicked = ->
    log "discardButtonClicked"
    allModules.datahandlermodule.retrieveData()
    allModules.networkmodule.requestBackendService "discardUploads", null, discardResponse, communicationFail

loginButtonClicked = ->
    switch AppVars.loginState
        when "notloggedin" then setStateTyping()
        when "typing" then startLogIn()
        when "loggedin" then setStateNotLoggedIn()
        else
            console.log "we had weird state: " + AppVars.loginState
    return

communicationFail = (error) ->
    console.log "communication to the Server has failed!"
    console.log error
    applyLoginFail()

discardResponse = (response) ->
    console.log "discardResponse"
    console.log response
    allModules.maincontentmodule.clearFileUpload()
	

loginResponse = (response) ->
	console.log "loginResponse"
	console.log response
	applyLoginSuccess(response.authToken) if response.result == "ok"
	applyLoginFail() if response.result == "error"

applyLoginSuccess = (authToken) ->
    console.log "applyLoginSuccess"
    console.log authToken
    setStateLoggedIn(authToken)
    allModules.datahandlermodule.retrieveData()

applyLoginFail = () ->
    console.log "applyLoginFail"
    setStateNotLoggedIn()

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

export default pageheadermodule
