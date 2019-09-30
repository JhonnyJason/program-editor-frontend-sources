maincontentmodule = {name: "maincontentmodule", uimodule: true}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["maincontentmodule"]?  then console.log "[maincontentmodule]: " + arg
    return

#region internal variables

## UI Cache vars
# run-info-section
editRunLabelInput = null
runTimestamp = null
# choose-program-section
cloneProgramButton = null
beingActiveIndicator = null
setActiveButton = null
editVersionLabelInput = null
durationInput = null
bufferTableContainer = null
#endregion

AppVars = null

performOptionList = ""
relaxOptionList = ""
currentModeSelection = ""

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
maincontentmodule.initialize = () ->
    log "maincontentmodule.initialize"

    AppVars = allModules.appstatemodule
    #duration-section
    cloneProgramButton = document.getElementById 'clone-program-button'
    beingActiveIndicator = document.getElementById 'being-active-indicator'
    setActiveButton = document.getElementById 'set-active-button'
    editVersionLabelInput = document.getElementById 'edit-version-label-input'
    durationInput = document.getElementById 'duration-input'

    editRunLabelInput = document.getElementById 'edit-run-label-input'
    runTimestamp = document.getElementById 'run-timestamp'
    bufferTableContainer = document.getElementById 'buffer-table-container'
    
    ## Add the eventListeners
    #duration-section
    durationInput.addEventListener 'change', durationInputChanged
    cloneProgramButton.addEventListener 'click', cloneProgramButtonClicked
    setActiveButton.addEventListener 'click', setActiveButtonClicked
    editVersionLabelInput.addEventListener 'change', editVersionLabelInputChanged
    editRunLabelInput.addEventListener 'change', editRunLabelInputChanged

#region internal functions
################################################################################
# Layer 0 UI Event Handler Functions
################################################################################
cloneProgramButtonClicked = ->
    log "cloneProgramButtonClicked"
    allModules.datahandlermodule.cloneCurrentProgram()

setActiveButtonClicked = ->
    log "setActiveButtonClicked"
    allModules.datahandlermodule.setCurrentProgramActive()

editRunLabelInputChanged = (event) ->
    log  "editRunLabelInputChanged"
    value = event.target.value
    allModules.datahandlermodule.changeCurrentRunLabel(value)


editVersionLabelInputChanged = (event) ->
    log  "editVersionLabelInputChanged"
    value = event.target.value
    allModules.datahandlermodule.changeCurrentProgramVersionLabel(value)
    
relaxButtonClicked = ->
    log "relaxButtonClicked"
    currentModeSelection = "relax"
    relaxButton.classList.add("selected")
    performButton.classList.remove("selected")
    initializeProgramSelect()

programSelectChanged = ->
    log "programSelectChanged"
    if !programSelect[programSelect.selectedIndex]
        return
    value = programSelect[programSelect.selectedIndex].value;
    allModules.datahandlermodule.selectProgramById(value)
    fillCurrentProgramData()

programNameChanged = ->
    log "programNameChanged"
    program = allModules.appstatemodule.currentProgram
    text = programNameInput.value
    if !program then return
    allModules.datahandlermodule.setLanguageTextForKey(program.namekey, text)
    return 

durationInputChanged = ->
    log "durationInputChanged"
    if !allModules.appstatemodule.currentProgram then return
    adjustCurrentProgramToNewTotalDuration()
    allModules.dynamiccontentmodule.displayCurrentProgram()
    allModules.datahandlermodule.dataChanged()
    return

################################################################################
# Other Functions
################################################################################
adjustCurrentProgramToNewTotalDuration = ->
    log "adjustCurrentProgramToNewTotalDuration"
    totalDurationMS = parseInt(durationInput.value)
    log "totalDurationMS is: " + totalDurationMS
    if !totalDurationMS || (totalDurationMS == 0)  
        totalDurationMS = 100
        durationInput.value = 100
    program = allModules.appstatemodule.currentProgram
    if !program
        log "We tried to adjust the total duration Input, while there was no current Program!"
        return
    program.durationMS = totalDurationMS
    durations = program.bufferduration
    durationMS = 0
    index = 0
    for duration in durations
        durationMS += duration * 100
        if durationMS >= totalDurationMS
            difMS = durationMS - totalDurationMS
            durations[index] -= difMS / 100
            program.bufferduration = program.bufferduration.slice(0, index + 1)
            program.buffertemp1 = program.buffertemp1.slice(0, index + 1)
            program.buffertemp2 = program.buffertemp2.slice(0, index + 1)
            program.buffertemp3 = program.buffertemp3.slice(0, index + 1)
            program.buffertemp4 = program.buffertemp4.slice(0, index + 1)
            program.buffervib1 = program.buffervib1.slice(0, index + 1)
            program.buffervib2 = program.buffervib2.slice(0, index + 1)
            program.bufferagression = program.bufferagression.slice(0, index + 1)
            return 
        index++
    if durationMS < totalDurationMS
        difMS = totalDurationMS - durationMS
        program.bufferduration[program.bufferduration.length - 1] += difMS / 100

initializeProgramSelect = ->
    log "initializeProgramSelect"
    if currentModeSelection == "relax"
        programSelect.innerHTML = relaxOptionList
        programSelectChanged()
    if currentModeSelection == "perform"
        programSelect.innerHTML = performOptionList
        programSelectChanged()


fillProgramDuration = ->
    log "fillProgramDuration"
    return unless AppVars.currentProgram

fillProgramGraphs = ->
    log "fillProgramGraphs"
    return unless AppVars.currentProgram
    createCharts()

createCharts = () ->
    log "createCharts"

#endregion

#region Exposed Functions
maincontentmodule.prepareProgramSelect = (programs)->
    log "maincontentmodule.prepareProgramSelect"
    if (!programs || !(programs.performprograms) || !(programs.relaxprograms))
        alert("We are missing some part of the programs object!")
        return

    performOptionList = ""
    relaxOptionList = ""
    performPrograms = programs.performprograms
    relaxPrograms = programs.relaxprograms

    for program in performPrograms
        performOptionList += '<option '
        performOptionList += 'value="' + program.id + '">'
        performOptionList += allModules.datahandlermodule.languageTextForKey(program.namekey)
        performOptionList += '</option>'
    for program in relaxPrograms
        relaxOptionList += '<option '
        relaxOptionList += 'value="' + program.id + '">'
        relaxOptionList += allModules.datahandlermodule.languageTextForKey(program.namekey)
        relaxOptionList += '</option>'

    initializeProgramSelect()


maincontentmodule.updateCurrentTotalDuration = ->
    log "maincontentmodule.updateCurrentTotalDuration"
    program = allModules.appstatemodule.currentProgram
    if !program
        alert("Error: We called the updateCurretnTotalDuration function but we did not have any currentProgram in the AppState!!")
    durationInput.value = program.durationMS

maincontentmodule.fillCurrentProgramInfo = ->
    log "maincontentmodule.fillCurrentProgramInfo"
    program = allModules.appstatemodule.currentProgram
    if !program 
        durationInput.value = ""
        beingActiveIndicator.textContent = ""
        editVersionLabelInput.value = ""
        setActiveButton.disabled = true
        return

    id = parseInt(program.id)
    
    try 
        dynamicProgramData = await allModules.datahandlermodule.getDynamicDataForProgram(id)  
    catch e 
        log e
        return 
    
    durationInput.value = program.durationMS

    if dynamicProgramData.is_active
        beingActiveIndicatorText = "Active"
        setActiveButton.disabled = true
    else
        beingActiveIndicatorText = "Not Active"
        setActiveButton.disabled = false

    beingActiveIndicator.textContent = beingActiveIndicatorText
    editVersionLabelInput.value = dynamicProgramData.version_label

maincontentmodule.fillCurrentRunInfo = ->
    log "maincontentmodule.fillCurrentRunInfo"
    run = allModules.appstatemodule.currentRun
    if !run 
        editRunLabelInput.value = ""
        runTimestamp.textContent = ""
        return

    id = parseInt(run.id)
    
    editRunLabelInput.value = run.runLabel
    dateObject = new Date()
    dateObject.setTime(run.timestamp)
    runTimestamp.textContent = " " + dateObject.toString()


maincontentmodule.fillCurrentProgramData = ->
    log "fillCurrentProgramData"
    if !allModules.appstatemodule.currentProgram then return

    maincontentmodule.fillCurrentProgramInfo()
    allModules.runhistorymodule.buildTable()
    allModules.dynamiccontentmodule.displayCurrentProgram()

maincontentmodule.fillCurrentRunData = ->
    log "fillCurrentRunData"
    if !allModules.appstatemodule.currentRun then return

    maincontentmodule.fillCurrentRunInfo()
    allModules.dynamiccontentmodule.displayCurrentRun()


maincontentmodule.drawBufferTable = ->
    log "maincontentmodule.drawBufferTable"
    currentProgram = allModules.appstatemodule.currentProgram
    if currentProgram?
        htmlTable = "<table>"
        htmlTable += "<thead>"
        htmlTable += "<tr><th>buffer property name</th><th>buffer.toString()</th><th>dataPoints: " + currentProgram.dataPoints + "</th></tr>"
        htmlTable += "</thead>"
        htmlTable += "<tbody>"
        tableInner = ""

        ##row buffertemp1
        tableInner += "<tr><td>buffertemp1: </td><td>" + currentProgram.buffertemp1.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.buffertemp1
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row buffertemp2
        tableInner += "<tr><td>buffertemp2: </td><td>" + currentProgram.buffertemp2.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.buffertemp2
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row buffertemp3
        tableInner += "<tr><td>buffertemp3: </td><td>" + currentProgram.buffertemp3.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.buffertemp3
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row buffertemp4
        tableInner += "<tr><td>buffertemp4: </td><td>" + currentProgram.buffertemp4.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.buffertemp4
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row buffervib1
        tableInner += "<tr><td>buffervib1: </td><td>" + currentProgram.buffervib1.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.buffervib1
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row buffervib2
        tableInner += "<tr><td>buffervib2: </td><td>" + currentProgram.buffervib2.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.buffervib2
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row bufferagression
        tableInner += "<tr><td>bufferagression: </td><td>" + currentProgram.bufferagression.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.bufferagression
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        ##row bufferduration
        tableInner += "<tr><td>bufferduration: </td><td>" + currentProgram.bufferduration.toString() + "</td>"
        dataPoints = ""
        for value in currentProgram.bufferduration
            dataPoints += "<td>" + value + "</td>"
        tableInner += dataPoints
        tableInner += "</tr>"

        htmlTable += tableInner
        htmlTable += "</tbody>"
        htmlTable += "</table>"

        bufferTableContainer.innerHTML = htmlTable



#endregion
export default maincontentmodule
