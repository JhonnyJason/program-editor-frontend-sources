websocketmodule = {name: "websocketmodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["websocketmodule"]?  then console.log "[websocketmodule]: " + arg
    return
ostr = (o) -> "\n" + JSON.stringify(o, null, 4)
olog = (o) -> log ostr(o)

############################################################
cfg = null

############################################################
socket = null
connected = false

############################################################
communicationQueu = []
reflexes = {}

############################################################
websocketmodule.initialize = () ->
    log "websocketmodule.initialize"
    cfg = allModules.configmodule
    serverURL = cfg.websocketURL

    log "server URL is: " + serverURL

    ############################################################
    socket = new WebSocket(serverURL)
    
    socket.onopen = onSocketConnect
    socket.onmessage = onSocketMessage
    socket.onerror = onSocketError
    socket.onclose = onSocketClose

    reflexes["programsOverview"] = handleRetrievedProgramsOverview
    reflexes["staticProgramData"] = handleRetrievedStaticProgramData
    reflexes["program"] = handleRetrievedProgram
    reflexes["cloneCreated"] = handleCloneCreated
    reflexes["runOverview"] = handleRetrievedRunOverview
    reflexes["run"] = handleRetrievedRun
    # other
    reflexes["langStrings"] = handleRetrievedLangStrings
    reflexes["loginResult"] = handleLoginResult

    # socket = io(allModules.configmodule.websocketURL)
    # socketConfiguration()
    return

############################################################
#region internalFunctions
createMessage = (name, data) -> return JSON.stringify({name, data})

############################################################
#region socketEvents
onSocketConnect = (arg) ->
    log "onSocketConnect"
    log Date.now()
    connected = true
    do task() for task in communicationQueu
    communicationQueu.length = 0    
    return

onSocketError = (arg) ->
    log "onSocketError"
    allModules.messageboxmodule.showErrorMessage("Socket error!\n" + arg)
    # connected = false
    # allModules.pageheadermodule.communicationFail("connect error: " + arg)
    return

onSocketClose = (arg) ->
    log "onSocketClose"
    log Date.now()
    allModules.messageboxmodule.showErrorMessage("Socket closed!\n" + arg)
    connected = false
    allModules.pageheadermodule.communicationFail("Socket closed!: " + arg)
    return

onSocketMessage = (arg) ->
    log "onSocketMessage"
    try 
        signal = JSON.parse(arg.data)
        return unless reflexes[signal.name]
        reflexes[signal.name](signal.data)
    catch err then log "Error occurred onmessage!"
    return

#endregion

############################################################
#region oldCode
# socketConfiguration = ->
#     log "socketConfiguration"
#     socket.on("connect", 
#         -> 
#             connected = true
#             for task in communicationQueu
#                 task()
#             communicationQueu.length = 0
#     )
#     socket.on("connect_error", 
#         (reason) -> 
#     )
#     socket.on("connect_timeout", 
#         (reason) -> 
#             allModules.messageboxmodule.showErrorMessage("connect timeout!\n" + reason)
#             connected = false
#             allModules.pageheadermodule.communicationFail("connect timeout!: " + reason)
#     )
#     socket.on("disconnect", 
#         (reason) ->
#             allModules.messageboxmodule.showErrorMessage("we disconnected!\n" + reason)
#             connected = false
#             allModules.pageheadermodule.communicationFail("disconnect: " + reason)
#     )

#     # programs DB data
#     socket.on("programsOverview", handleRetrievedProgramsOverview)
#     socket.on("staticProgramData", handleRetrievedStaticProgramData)
#     socket.on("program", handleRetrievedProgram)
#     socket.on("cloneCreated", handleCloneCreated)
#     socket.on("runOverview", handleRetrievedRunOverview)
#     socket.on("run", handleRetrievedRun)
#     # other
#     socket.on("langStrings", handleRetrievedLangStrings)
#     socket.on("loginResult", handleLoginResult)
#endregion

############################################################
#region reflexFunctions
handleCloneCreated = (programsOverviewEntry) ->
    log "handleDataUpdate"
    allModules.datahandlermodule.addCloneToProgramsOverview(programsOverviewEntry)

handleLoginResult = (response) ->
    log(JSON.stringify(response))
    if response.result == "ok"
        allModules.pageheadermodule.applyLoginSuccess()
    else if response.result == "error"
        allModules.pageheadermodule.applyLoginFail() 

handleRetrievedProgram = (program) ->
    log "handleRetrievedProgram"
    allModules.datahandlermodule.setProgram(program)

handleRetrievedRun = (run) ->
    log "handleRetrievedRun"
    allModules.datahandlermodule.setRun(run)

handleRetrievedStaticProgramData = (staticProgramData) ->
    log "handleStaticProgramData"
    allModules.datahandlermodule.setStaticProgramData(staticProgramData)

handleRetrievedProgramsOverview = (programsOverview) ->
    log "handleRetrievedProgramsOverview"
    allModules.datahandlermodule.setProgramsOverview(programsOverview)

handleRetrievedRunOverview = (runOverview) ->
    log "handleRetrievedRunOverview"
    allModules.datahandlermodule.setRunOverview(runOverview)

handleRetrievedLangStrings = (langStrings) ->
    log "handleRetrievedLangStrings"
    allModules.datahandlermodule.setLangStrings(langStrings)
    
#endregion

#endregion

############################################################
#region exposedFunctions
websocketmodule.attemptLogin = (data) ->
    log "websocketmodule.attemptLogin"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.attemptLogin
            argument: data
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("loginAttempt", data)
    socket.send(message)

    # socket.emit("loginAttempt", data, (data)-> log "loginAttempt: is there an answer? " + JSON.stringify(data))

websocketmodule.communicateClonage = (dynamicProgramId) ->
    log "websocketmodule.communicateClonage"
    log "cloning program with id: " + dynamicProgramId 
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.communicateClonage
            argument: dynamicProgramId
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("cloneProgramPlease", dynamicProgramId)
    socket.send(message)

    # socket.emit("cloneProgramPlease", dynamicProgramId, (data)-> log "cloneProgram: is there an answer? " + JSON.stringify(data))

websocketmodule.setProgramActive = (dynamicProgramId) ->
    log "websocketmodule.setProgramActive"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.setProgramActive
            argument: dynamicProgramId
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("setProgramActivePlease", dynamicProgramId)
    socket.send(message)

    # socket.emit("setProgramActivePlease", dynamicProgramId, (data)-> log "setProgramActivePlease: is there an answer? " + JSON.stringify(data))

websocketmodule.saveProgram = (program) ->
    log "websocketmodule.saveProgram"
    log JSON.stringify(program)
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.saveProgram
            argument: program
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("saveProgramPlease", program)
    socket.send(message)

    # socket.emit("saveProgramPlease", program, (data) -> log "saveProgramPlease: is there an answer? " + JSON.stringify(data))


websocketmodule.updateRunLabel = (data) ->
    log "websocketmodule.updateRunLabel"
    log JSON.stringify(data)
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.updateRunLabel
            argument: data
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("updateRunLabelPlease", data)
    socket.send(message)

    # socket.emit("updateRunLabelPlease", data, (data) -> log "updateRunLabelPlease: is there an answer? " + JSON.stringify(data))

############################################################
#region retrievalFunctions
websocketmodule.retrieveProgram = (programsDynamicId) ->
    log "websocketmodule.retrieveProgram"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveProgram
            argument: programsDynamicId
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("programPlease", programsDynamicId)
    socket.send(message)
    # socket.emit("programPlease", programsDynamicId, (data) -> log "programPlease: is there an answer? " + JSON.stringify(data))

websocketmodule.retrieveRun = (programsRunsId) ->
    log "websocketmodule.retrieveRun"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveRun
            argument: programsRunsId
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("runPlease", programsRunsId)
    socket.send(message)

    # socket.emit("runPlease", programsRunsId, (data) -> log "runPlease: is there an answer? " + JSON.stringify(data))


websocketmodule.retrieveProgramsOverview = ->
    log "websocketmodule.retrieveProgramsOverview"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveProgramsOverview
            argument: null
        communicationQueu.push(commmunicationBlock)
        return
    
    message = createMessage("programOverviewPlease", null)
    socket.send(message)
    return

websocketmodule.retrieveRunOverview = (id) ->
    log "websocketmodule.retrieveRunOverview"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveRunOverview
            argument: id
        communicationQueu.push(commmunicationBlock)
        return
    
    message = createMessage("programOverviewPlease", null)
    socket.send(message)

    return

websocketmodule.retrieveStaticProgramData = ->
    log "websocketmodule.retrieveStaticProgramData"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveStaticProgramData
            argument: null
        communicationQueu.push(commmunicationBlock)
        return

    message = createMessage("staticProgramDataPlease", null)
    socket.send(message)

    return




websocketmodule.retrieveLangStrings = ->
    log "websocketmodule.retrieveLangStrings"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveLangStrings
            argument: null
        communicationQueu.push(commmunicationBlock)
        return

    ## TODO here we should retrieve the langStrings from the Program Manager
    message = createMessage("langStringsPlease", null)
    socket.send(message)
    return
    
#endregion

#endregion

export default websocketmodule