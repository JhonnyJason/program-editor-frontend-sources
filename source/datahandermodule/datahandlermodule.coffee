datahandlermodule = {name: "datahandlermodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["datahandlermodule"]?  then console.log "[datahandlermodule]: " + arg
    return

#region Internal Variables
allLangStrings = null
staticProgramData = null
programsOverview = null
idToRunOverviews = {}
idToRuns = {}
idToPrograms = {}
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
datahandlermodule.initialize = () ->
    log "datahandlermodule.initialize"
    
#region Internal Functions
createDeferredPromise = () ->
    deferred = {}
    promise = new Promise(
        (resolve, reject) ->
            deferred.resolve = resolve
    )
    promise.resolve = deferred.resolve
    return promise


getStaticProgramsObject = (staticId) ->
    staticId  = parseInt(staticId)
    log "getStaticProgramsObject"
    allStaticData = await datahandlermodule.getStaticProgramData()
    for data in allStaticData
        if data.programs_static_id == staticId then return data


setProgramsOfStaticIdInactive = (staticId) ->
    staticId  = parseInt(staticId)
    log "getStaticProgramsObject"
    programsOverview = await datahandlermodule.getProgramsOverview()
    for program in programsOverview
        if program.programs_static_id == staticId 
            program.is_active = false

#endregion

#region Exposed Functions
################################################################################
# Functions To Set Data
################################################################################
datahandlermodule.setLangStrings = (data) ->
    log "datahandlermodule.setLangStrings"
    if allLangStrings? and typeof allLangStrings.resolve == "function"
        allLangStrings.resolve(data)
    allLangStrings = data

datahandlermodule.setStaticProgramData = (data) ->
    log "datahandlermodule.setStaticProgramData"
    if staticProgramData? and typeof staticProgramData.resolve == "function"
        staticProgramData.resolve(data)
    staticProgramData = data


datahandlermodule.setProgram = (program) ->
    log "datahandlermodule.setProgram"
    dynamicId = parseInt(program.id)
    if idToPrograms[dynamicId]? and typeof idToPrograms[dynamicId].resolve == "function"
        idToPrograms[dynamicId].resolve(program)
    idToPrograms[dynamicId] = program

datahandlermodule.setRun = (run) ->
    log "datahandlermodule.setRun"
    log JSON.stringify(run)
    runId = parseInt(run.id)
    if idToRuns[runId]? and typeof idToRuns[runId].resolve == "function"
        idToRuns[runId].resolve(run)
    idToRuns[runId] = run

datahandlermodule.setProgramsOverview = (data) ->
    log "datahandlermodule.setProgramsOverview"
    #log JSON.stringify(data)
    if programsOverview? and typeof programsOverview.resolve == "function"
        programsOverview.resolve(data)
    programsOverview = data

datahandlermodule.setRunOverview = (data) ->
    log JSON.stringify(data)
    id = data.id
    if idToRunOverviews[id]? and typeof idToRunOverviews[id].resolve == "function"
        idToRunOverviews[id].resolve(data.runOverview)
    
    idToRunOverviews[id] = data.runOverview


################################################################################
# Functions To Get Data
################################################################################
datahandlermodule.getLangStrings = ->
    log "datahandlermodule.assignLangStrings"
    if !allLangStrings?
        allLangStrings = createDeferredPromise()
    
    return allLangStrings

datahandlermodule.getStaticProgramData = ->
    log "datahandlermodule.getStaticProgramData"
    if !staticProgramData?
        staticProgramData = createDeferredPromise()
    return staticProgramData

datahandlermodule.getProgram = (id) ->
    id = parseInt(id)
    log "datahandlermodule.getProgram"
    if !idToPrograms[id]?
        idToPrograms[id] = createDeferredPromise()
        allModules.websocketmodule.retrieveProgram(id)
        
    return idToPrograms[id]

datahandlermodule.getRun = (id) ->
    id = parseInt(id)
    log "datahandlermodule.getRun"
    if !idToRuns[id]?
        idToRuns[id] = createDeferredPromise()
        allModules.websocketmodule.retrieveRun(id)
        
    return idToRuns[id]

datahandlermodule.getProgramsOverview = ->
    log "datahandlermodule.getProgramsOverview"
    if !programsOverview?
        programsOverview = createDeferredPromise()

    return programsOverview

datahandlermodule.getProgramRunOverview = (id) ->
    id = parseInt(id)
    log "datahandlermodule.getProgramRunOverview"
    if !idToRunOverviews[id]?
        idToRunOverviews[id] = createDeferredPromise()
        allModules.websocketmodule.retrieveRunOverview(id)

    return idToRunOverviews[id]

datahandlermodule.getDynamicDataForProgram = (id) ->
    id = parseInt(id)
    log "datahandlermodule.getDynamicDataForProgram"
    ##TODO get real dynamic data not overview - there are things missing...!!!
    overview = await datahandlermodule.getProgramsOverview()
    for program in overview
        if program.programs_dynamic_id == id then return program
################################################################################
# Functions To Request Information
################################################################################
datahandlermodule.updateRunLabel = (runId, runLabel) ->
    log "datahandlermodule.updateRunLabel"
    data = 
        id: runId
        label: runLabel
    allModules.websocketmodule.updateRunLabel(data)

datahandlermodule.addCloneToProgramsOverview = (programsOverviewEntry) ->
    log "datahandlermodule.addCloneToProgramsOverview"
    if programsOverview? 
        programsOverview.push(programsOverviewEntry)
        try allModules.programversiontablemodule.buildTable()
        catch e then log e


datahandlermodule.discardChanges = ->
    log "datahandlermodule.discardChanges"
    
    currentId = false
    currentProgram = allModules.appstatemodule.currentProgram
    if currentProgram? and currentProgram.id
        currentId = parseInt(currentProgram.id)
    
    allModules.appstatemodule.currentProgram = null
    allLangStrings = null
    staticProgramData = null
    programsOverview = null
    idToPrograms = {}

    datahandlermodule.retrieveAllData()
    try allModules.programversiontablemodule.buildTable()
    catch e then log e
    allModules.maincontentmodule.fillCurrentProgramData()
    datahandlermodule.selectProgramById(currentId)
    return 

datahandlermodule.retrieveAllData = ->
    log "datahandlermodule.retrieveData"
    ## sending the retrieval requests for all basic datasets
    allModules.websocketmodule.retrieveProgramsOverview()
    allModules.websocketmodule.retrieveStaticProgramData()
    allModules.websocketmodule.retrieveLangStrings()

datahandlermodule.saveData = ->
    log "datahandlermodule.saveData"
    log JSON.stringify(idToPrograms)
    for id,program of idToPrograms
        allModules.websocketmodule.saveProgram(program)

    allModules.messageboxmodule.showInfoMessage("all data to save, was sent to server!")
    ##TODO split saveData to smaller more direct requests
    # saveAllLangStrings
    # save specific program's dynamic data
    # save specific program's static data

    # allModules.networkmodule.requestBackendService "saveProgramData", data, dataSaveResponse, communicationFail

datahandlermodule.cloneCurrentProgram = ->
    log "datahandlermodule.cloneCurrentProgram"
    currentProgram = allModules.appstatemodule.currentProgram
    if currentProgram? and currentProgram.id
        currentId = parseInt(currentProgram.id)
        allModules.websocketmodule.communicateClonage(currentId)

datahandlermodule.setCurrentProgramActive = ->
    log "datahandlermodule.setCurrentProgramActive"
    currentProgram = allModules.appstatemodule.currentProgram
    if currentProgram? and currentProgram.id
        try
            currentId = parseInt(currentProgram.id)
            dynamicData = await datahandlermodule.getDynamicDataForProgram(currentId) 
            if dynamicData.is_active then return
            staticId = dynamicData.programs_static_id
            await setProgramsOfStaticIdInactive(staticId)
            dynamicData.is_active = true
            allModules.programversiontablemodule.buildTable()
            allModules.maincontentmodule.fillCurrentProgramInfo()
            allModules.websocketmodule.setProgramActive(currentId)
        catch e then log e

datahandlermodule.changeCurrentProgramVersionLabel = (newVersionLabel) ->
    log "datahandlermodule.changeCurrentProgramVersionLabel"
    currentProgram = allModules.appstatemodule.currentProgram
    if currentProgram? and currentProgram.id
        try
            currentId = parseInt(currentProgram.id)
            currentProgram.new_version_label = newVersionLabel
            dynamicData = await datahandlermodule.getDynamicDataForProgram(currentId)
            if dynamicData.version_label == newVersionLabel then return
            dynamicData.version_label = newVersionLabel
            newerObject = await datahandlermodule.getDynamicDataForProgram(currentId)
            allModules.programversiontablemodule.buildTable() 
        catch e then log e

datahandlermodule.changeCurrentRunLabel = (newRunLabel) ->
    log "datahandlermodule.changeCurrentRunLabel"
    run = allModules.appstatemodule.currentRun
    log " current Run Object looks like: "
    log JSON.stringify(run)

    if run? and run.id
        try
            runId = parseInt(run.id)
            ## do nothing if nothing changed
            if run.runLabel == newRunLabel then return
            ## change the table
            run.runLabel = newRunLabel
            cells = document.querySelectorAll('[run-id="' + runId + '"]')
            for cell in cells
                cell.textContent = newRunLabel
            
            ## change the Overview Object
            programId = run.programId
            runOverview = await datahandlermodule.getProgramRunOverview(programId)
            for runHead in runOverview
                if runHead.programs_runs_id == runId
                    runHead.run_label = newRunLabel
            ## update Database
            datahandlermodule.updateRunLabel(runId, newRunLabel)
        catch e then log e

datahandlermodule.selectProgramById = (id) ->
    id = parseInt(id)
    log "datahandlermodule.selectProgramById"
    if !id then return

    try
        program =  await datahandlermodule.getProgram(id)
    catch e 
        log e
        return 

    allModules.appstatemodule.currentProgram = program
    allModules.programversiontablemodule.indicateCurrentChosenProgram(id)
    allModules.maincontentmodule.fillCurrentProgramData()
    allModules.appstatemodule.currentRun = null
    allModules.maincontentmodule.fillCurrentRunInfo()

datahandlermodule.selectRunById = (id) ->
    id = parseInt(id)
    log "datahandlermodule.selectRunById"
    if !id then return
    try 
        run =  await datahandlermodule.getRun(id)
    catch e 
        log e
        return

    allModules.appstatemodule.currentRun = run
    allModules.runhistorymodule.indicateCurrentChosenRun(id)
    allModules.maincontentmodule.fillCurrentRunData()

datahandlermodule.languageTextForKey = (key) ->
    #log "datahandlermodule.languageTextForKey"
    langTag = allModules.appstatemodule.currentLangTag
    return (allLangStrings[key])[langTag]

datahandlermodule.setLanguageTextForKey = (key, text) ->
    log "datahandlermodule.setLanguageTextForKey"
    langTag = allModules.appstatemodule.currentLangTag
    if !allLangStrings
        alert("we lost or never had the langstrings but want to access languageTexts...!")
        return
    (allLangStrings[key])[langTag] = text
    datahandlermodule.dataChanged()
    return

################################################################################
# Miscellanneious
################################################################################

datahandlermodule.dataChanged = ->
    log "datahandlermodule.dataChangeNotification"
    allModules.pageheadermodule.setStateUnsavedChanges()
    # allModules.maincontentmodule.drawBufferTable()

#endregion

export default datahandlermodule
