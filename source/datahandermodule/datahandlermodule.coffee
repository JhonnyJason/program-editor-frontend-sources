datahandlermodule = {name: "datahandlermodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["datahandlermodule"]?  then console.log "[datahandlermodule]: " + arg
    return

#region Internal Variables
allProgramsById = null
programsObject = null
allLangStrings = null
#endregion

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
datahandlermodule.initialize = () ->
    log "datahandlermodule.initialize"
    
#region Internal Functions
communicationFail = (error) ->
    console.log "communication to the Server has failed!"
    console.log error
    applyDataLoadFail()

dataSaveResponse = (response) ->
    log "dataSaveResponse"
    # console.log response
    if response.result == "ok"
        applyDataSaveSuccess()
    else 
        applyDataSaveFail(response)

applyDataSaveSuccess = ->
    log "applyDataSaveSuccess"
    allModules.pageheadermodule.setStateNoUnsavedChanges()

applyDataSaveFail = (response) ->
    log "applyDataSaveFail"
    alert("data save failed and we donot know what to do - so we alert you :-)\n\n Aren't we cool?")
    log JSON.stringify(response)

dataLoadResponse = (response) ->
    log "dataLoadResponse"
    # console.log response
    if response.result == "ok"
        applyDataLoadSuccess(response.programs, response.langStrings)
    else 
        applyDataLoadFail(response)

applyDataLoadFail = (response) ->
    log "applyDataLoadFail"
    alert("data load failed and we donot know what to do - so we alert you :-)\n\n Aren't we cool?")
    log JSON.stringify(response)

applyDataLoadSuccess = (programs, langStrings) ->
    log "applyDataLoadSuccess"
    if !programs
        alert("We had a dataLoadSuccess, but we have no programs!")
        return
    if !langStrings
        alert("We had a dataLoadSuccess, but we have no langStrings")
        return
    programsObject =  programs
    allLangStrings = langStrings
    initializeAllProgramsById()
    allModules.maincontentmodule.prepareProgramSelect(programsObject)
    allModules.pageheadermodule.setStateNoUnsavedChanges()

initializeAllProgramsById = ->
    log "initializeAllProgramsById"
    if !programsObject
        alert("We try to initialize allsProgramsById but had no programsObjec!")
        return
    if !programsObject.performprograms
        alert("We try to initialize allProgramsById but had no performprograms in programsObject!")
        return
    if !programsObject.relaxprograms
        alert("We try to initialize allProgramsById but had no relaxprograms in programsObject!")
        return

    allProgramsById = {}
    for program in programsObject.performprograms
        allProgramsById[program.id] = program
        ##pfush to ensure pte2 and pte3 have always the same value
        program.buffertemp3 = program.buffertemp2

    for program in programsObject.relaxprograms
        allProgramsById[program.id] = program
        ##pfush to ensure pte2 and pte3 have always the same value
        program.buffertemp3 = program.buffertemp2


#endregion

#region Exposed Functions    
datahandlermodule.retrieveData = ->
    log "datahandlermodule.retrieveData"
    data = 
        authToken: allModules.appstatemodule.authToken

    allModules.networkmodule.requestBackendService "loadProgramData", data, dataLoadResponse, communicationFail

datahandlermodule.saveData = ->
    log "datahandlermodule.saveData"
    data = 
        authToken: allModules.appstatemodule.authToken
        langstrings: allLangStrings 
        programs: programsObject

    allModules.networkmodule.requestBackendService "saveProgramData", data, dataSaveResponse, communicationFail

datahandlermodule.selectProgramById = (id) ->
    log "datahandlermodule.selectProgramByid"
    if !id
        alert("We try to selectProgramById but we have no id!")
        return
    if !allProgramsById
        alert("We try to selectProgramById but we have not allProgramsById Object!")
        return
    if !(allProgramsById[id])
        alert("We try to selectProgramsById but we did not find the program for id: " + id)
    allModules.appstatemodule.currentProgram = allProgramsById[id]

datahandlermodule.languageTextForKey = (key) ->
    log "datahandlermodule.languageTextForKey"
    langTag = allModules.appstatemodule.currentLangTag
    if !allLangStrings
        alert("we lost or never had the langstrings but want to access languageTexts...!")
        return
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

datahandlermodule.dataChanged = ->
    log "datahandlermodule.dataChangeNotification"
    allModules.pageheadermodule.setStateUnsavedChanges()

#endregion

export default datahandlermodule
