websocketmodule = {name: "websocketmodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["websocketmodule"]?  then console.log "[websocketmodule]: " + arg
    return

#region internal variables
socket = null
connected = false

communicationQueu = []
#endregion internal variables

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
websocketmodule.initialize = () ->
    log "websocketmodule.initialize"
    # socket = io(allModules.configmodule.websocketURL)
    # socketConfiguration()


#region internal functions
socketConfiguration = ->
    log "socketConfiguration"
    socket.on("connect", 
        -> 
            connected = true
            for task in communicationQueu
                task()
            communicationQueu.length = 0
    )
    socket.on("connect_error", 
        (reason) -> 
            allModules.messageboxmodule.showErrorMessage("connect error!\n" + reason)
            connected = false
            allModules.pageheadermodule.communicationFail("connect error: " + reason)
    )
    socket.on("connect_timeout", 
        (reason) -> 
            allModules.messageboxmodule.showErrorMessage("connect timeout!\n" + reason)
            connected = false
            allModules.pageheadermodule.communicationFail("connect timeout!: " + reason)
    )
    socket.on("disconnect", 
        (reason) ->
            allModules.messageboxmodule.showErrorMessage("we disconnected!\n" + reason)
            connected = false
            allModules.pageheadermodule.communicationFail("disconnect: " + reason)
    )
    # programs DB data
    socket.on("programsOverview", handleRetrievedProgramsOverview)
    socket.on("staticProgramData", handleRetrievedStaticProgramData)
    socket.on("program", handleRetrievedProgram)
    socket.on("cloneCreated", handleCloneCreated)
    socket.on("runOverview", handleRetrievedRunOverview)
    socket.on("run", handleRetrievedRun)
    # other
    socket.on("langStrings", handleRetrievedLangStrings)
    socket.on("loginResult", handleLoginResult)


################################################################################
# Response Handling Functions
################################################################################
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
################################################################################
#endregion internal functions
    
#region exposed functions
websocketmodule.attemptLogin = (data) ->
    log "websocketmodule.attemptLogin"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.attemptLogin
            argument: data
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("loginAttempt", data, (data)-> log "loginAttempt: is there an answer? " + JSON.stringify(data))

websocketmodule.communicateClonage = (dynamicProgramId) ->
    log "websocketmodule.communicateClonage"
    log "cloning program with id: " + dynamicProgramId 
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.communicateClonage
            argument: dynamicProgramId
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("cloneProgramPlease", dynamicProgramId, (data)-> log "cloneProgram: is there an answer? " + JSON.stringify(data))

websocketmodule.setProgramActive = (dynamicProgramId) ->
    log "websocketmodule.setProgramActive"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.setProgramActive
            argument: dynamicProgramId
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("setProgramActivePlease", dynamicProgramId, (data)-> log "setProgramActivePlease: is there an answer? " + JSON.stringify(data))

websocketmodule.saveProgram = (program) ->
    log "websocketmodule.saveProgram"
    log JSON.stringify(program)
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.saveProgram
            argument: program
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("saveProgramPlease", program, (data) -> log "saveProgramPlease: is there an answer? " + JSON.stringify(data))


websocketmodule.updateRunLabel = (data) ->
    log "websocketmodule.updateRunLabel"
    log JSON.stringify(data)
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.updateRunLabel
            argument: data
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("updateRunLabelPlease", data, (data) -> log "updateRunLabelPlease: is there an answer? " + JSON.stringify(data))


# Retrieve Functions
################################################################################

websocketmodule.retrieveProgram = (programsDynamicId) ->
    log "websocketmodule.retrieveProgram"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveProgram
            argument: programsDynamicId
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("programPlease", programsDynamicId, (data) -> log "programPlease: is there an answer? " + JSON.stringify(data))

websocketmodule.retrieveRun = (programsRunsId) ->
    log "websocketmodule.retrieveRun"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveRun
            argument: programsRunsId
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("runPlease", programsRunsId, (data) -> log "runPlease: is there an answer? " + JSON.stringify(data))


websocketmodule.retrieveProgramsOverview = ->
    log "websocketmodule.retrieveProgramsOverview"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveProgramsOverview
            argument: null
        communicationQueu.push(commmunicationBlock)
        return
    
    socket.emit("programOverviewPlease", '?', (data) -> log "programOverviewPlease: is there an answer? " + JSON.stringify(data) )

websocketmodule.retrieveRunOverview = (id) ->
    log "websocketmodule.retrieveRunOverview"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveRunOverview
            argument: id
        communicationQueu.push(commmunicationBlock)
        return
    
    socket.emit("runOverviewPlease", id, (data) -> log "runOverviewPlease: is there an answer? " + JSON.stringify(data) )

websocketmodule.retrieveStaticProgramData = ->
    log "websocketmodule.retrieveStaticProgramData"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveStaticProgramData
            argument: null
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("staticProgramDataPlease", "?", (data) -> log "staticDataPlease: is there an answer? " + JSON.stringify(data) )

websocketmodule.retrieveLangStrings = ->
    log "websocketmodule.retrieveLangStrings"
    if (!connected) 
        commmunicationBlock = 
            function: websocketmodule.retrieveLangStrings
            argument: null
        communicationQueu.push(commmunicationBlock)
        return

    socket.emit("langStringsPlease", "?", (data) -> log "staticDataPlease: is there an answer? " + JSON.stringify(data) )

#endregion

export default websocketmodule