maincontentmodule = {name: "maincontentmodule", uimodule: true}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["maincontentmodule"]?  then console.log "[maincontentmodule]: " + arg
    return

#region internal variables

## UI Cache vars
# choose-program-section
performButton = null
relaxButton = null
programSelect = null
# loadButton = null
#langtag-section
deButton = null
enButton =  null
esButton = null
#program-name-section
programNameInput = null
#program-description-section
programDescriptionTextarea = null
#program-stats-section
intensityStatInput = null
temperatureStatInput = null
vibrationStatInput = null
#program-icon-section
programIcon = null
animatedIcon = null
svgFileInput = null
gifFileInput = null
programButton = null
programButtonText = null
programButtonSVGContainer = null
uploadingIndicator = null 
#min-max-define-section
# minTempInput = null
# maxTempInput = null
# minVibInput = null
# maxVibInput = null
# minAgressionInput = null
# maxAgressionInput = null
#duration-section
durationInput = null
#endregion

AppVars = null
cfg = null

performOptionList = ""
relaxOptionList = ""
currentModeSelection = ""

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
maincontentmodule.initialize = () ->
    log "maincontentmodule.initialize"
    cfg = allModules.configmodule

    AppVars = allModules.appstatemodule
    # choose-program-section
    performButton = document.getElementById 'perform-programs-button'
    relaxButton = document.getElementById 'relax-programs-button'
    programSelect = document.getElementById 'program-select'
    # loadButton = document.getElementById 'load-button'
    #langtag-section
    deButton = document.getElementById('de-langtag-button')
    enButton =  document.getElementById('en-langtag-button')
    esButton = document.getElementById('es-langtag-button')
    #program-name-section
    programNameInput = document.getElementById 'program-name-input'
    #program-description-section
    programDescriptionTextarea = document.getElementById 'program-description-text'
    #program-stats-section
    intensityStatInput = document.getElementById 'intensity-stat-input'
    temperatureStatInput = document.getElementById 'temperature-stat-input'
    vibrationStatInput = document.getElementById 'vibration-stat-input'
    #program-icon-section
    # programIcon = document.getElementById 'program-icon'
    # animatedIcon = document.getElementById 'animated-icon'
    programButton = document.getElementsByClassName('programbutton')[0]
    programButtonText = document.getElementsByClassName('button-text')[0]
    programButtonSVGContainer = document.getElementsByClassName('button-svg-container')[0]

    svgFileInput = document.getElementById 'svg-file-input'
    uploadingIndicator = document.getElementById 'uploading-indicator'
    # gifFileInput = document.getElementById 'gif-file-input'
    #min-max-define sections
    # minTempInput = document.getElementById 'min-temp-input'
    # maxTempInput = document.getElementById 'max-temp-input'
    # minVibInput = document.getElementById 'min-vib-input'
    # maxVibInput = document.getElementById 'max-vib-input'
    # minAgressionInput = document.getElementById 'min-agression-input'
    # maxAgressionInput = document.getElementById 'max-agression-input'
    #duration-section
    ## Add the eventListeners
    # choose-program-section
    performButton.addEventListener 'click', performButtonClicked
    relaxButton.addEventListener 'click', relaxButtonClicked
    programSelect.addEventListener 'change', programSelectChanged
    # loadButton.addEventListener 'click', loadButtonClicked
    #langtag-section
    deButton.addEventListener 'click', deButtonActivated
    enButton.addEventListener 'click', enButtonActivated
    esButton.addEventListener 'click', esButtonActivated
    #program-name-section
    programNameInput.addEventListener 'change', programNameChanged
    #program-description-section
    programDescriptionTextarea.addEventListener 'change', programDescriptionChanged
    #program-stats-section
    intensityStatInput.addEventListener 'change', intensityStatChanged
    temperatureStatInput.addEventListener 'change', temperatureStatChanged
    vibrationStatInput.addEventListener 'change', vibrationStatChanged
    #min-max-define sections
    svgFileInput.addEventListener 'change', svgFileChanged
    # gifFileInput.addEventListener 'change', gifFileChanged
    #min-max-define-section
    # minTempInput.addEventListener 'change', minTempChanged
    # maxTempInput.addEventListener 'change', maxTempChanged
    # minVibInput.addEventListener 'change', minVibChanged
    # maxVibInput.addEventListener 'change', maxVibChanged
    # minAgressionInput.addEventListener 'change', minAgressionChanged
    # maxAgressionInput.addEventListener 'change', maxAgressionChanged
    #duration-section
    showActiveLangTag()

#region internal functions
################################################################################
# Layer 0 UI Event Handler Functions
################################################################################
performButtonClicked = ->
    log "performButtonClicked"
    currentModeSelection = "perform"
    performButton.classList.add("selected")
    relaxButton.classList.remove("selected")
    initializeProgramSelect()

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

# loadButtonClicked = ->
#     log 'loadButtonClicked'

deButtonActivated = ->
    log "deButtonActivated"
    if allModules.appstatemodule.currentLangTag != "de"
        allModules.appstatemodule.currentLangTag = "de"
        getLanguageStuffForCurrentProgram()
        showActiveLangTag()
    return

enButtonActivated = ->
    log "enButtonActivated"
    if allModules.appstatemodule.currentLangTag != "en"
        allModules.appstatemodule.currentLangTag = "en"
        getLanguageStuffForCurrentProgram()
        showActiveLangTag()
    return

esButtonActivated = ->
    log "esButtonActivated"
    if allModules.appstatemodule.currentLangTag != "es"
        allModules.appstatemodule.currentLangTag = "es"
        getLanguageStuffForCurrentProgram()
        showActiveLangTag()
    return

programNameChanged = ->
    log "programNameChanged"
    program = allModules.appstatemodule.currentProgram
    text = programNameInput.value
    if !program then return
    allModules.datahandlermodule.setLanguageTextForKey(program.namekey, text)
    programButtonText.textContent = text
    return 

programDescriptionChanged = ->
    log "programDescriptionChanged"
    program = allModules.appstatemodule.currentProgram
    text = programDescriptionTextarea.value
    if !program then return
    allModules.datahandlermodule.setLanguageTextForKey(program.descriptionkey, text)
    return

intensityStatChanged = ->
    log "intensityStatChanged"
    program = allModules.appstatemodule.currentProgram
    intensity = parseInt(intensityStatInput.value)
    if !program then return
    intensity = sanitizeStat(intensity)
    program.intensity = intensity
    intensityStatInput.value = intensity
    allModules.datahandlermodule.dataChanged()
    return

temperatureStatChanged = ->
    log "temperatureStatChanged"
    program = allModules.appstatemodule.currentProgram
    temperature = parseInt(temperatureStatInput.value)
    if !program then return
    temperature = sanitizeStat(temperature)
    program.temperature = temperature
    temperatureStatInput.value = temperature
    allModules.datahandlermodule.dataChanged()
    return

vibrationStatChanged = ->
    log "vibrationStatChanged"
    program = allModules.appstatemodule.currentProgram
    vibration = parseInt(vibrationStatInput.value)
    if !program then return
    vibration = sanitizeStat(vibration)
    program.vibration = vibration
    vibrationStatInput.value = vibration
    allModules.datahandlermodule.dataChanged()
    return

svgFileChanged = ->
    log "svgFileChanged"
    ## formData API Upload
    formData = new FormData()
    file = svgFileInput.files[0]
    if !allModules.appstatemodule.currentProgram then return
    iconFileName = allModules.appstatemodule.currentProgram.iconfilename
    authToken = allModules.appstatemodule.authToken
    formData.append(iconFileName, file)
    # formData.append("authToken", authToken) does not work...
    allModules.networkmodule.uploadFileFormData(formData, uploadingIndicator)
    ## file attatched upload
    # iconFileName = allModules.appstatemodule.currentProgram.iconfilename
    # fileHandle = svgFileInput.files[0]
    # allModules.networkmodule.uploadFile(iconFileName, fileHandle)

gifFileChanged = ->
    log "gifFileChanged"

# minTempChanged = ->
#     log "minTempChanged"

# maxTempChanged = ->
#     log "maxTempChanged"

# minVibChanged = ->
#     log "minVibChanged"

# maxVibChanged = ->
#     log "maxVibChanged"

# minAgressionChanged = ->
#     log "minAgressionChanged"

# maxAgressionChanged = ->
#     log "maxAgressionChanged"


################################################################################
# Other Functions
################################################################################
sanitizeStat = (stat) ->
    if stat < 0 then return 0
    if stat > 6 then return 6
    return stat

showActiveLangTag = ->
    log "showActiveLangTag"
    if(allModules.appstatemodule.currentLangTag == "de")
        deButton.classList.add("selected")
        enButton.classList.remove("selected")
        esButton.classList.remove("selected")
        return
    if(allModules.appstatemodule.currentLangTag == "en")
        deButton.classList.remove("selected")
        enButton.classList.add("selected")
        esButton.classList.remove("selected")
        return
    if(allModules.appstatemodule.currentLangTag == "es")
        deButton.classList.remove("selected")
        enButton.classList.remove("selected")
        esButton.classList.add("selected")
        return

getLanguageStuffForCurrentProgram = ->
    log "getLanguageStuffForCurrentProgram"
    program = allModules.appstatemodule.currentProgram
    if !program then return 

    langFun = allModules.datahandlermodule.languageTextForKey
    
    programName = langFun(program.namekey)
    programDescription = langFun(program.descriptionkey)

    programNameInput.value = programName
    programDescriptionTextarea.value = programDescription
    programButtonText.textContent = programName

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

fillCurrentProgramData = ->
    log "fillCurrentProgramData"
    program = allModules.appstatemodule.currentProgram
    if !program then return

    getLanguageStuffForCurrentProgram()

    intensityStatInput.value = program.intensity
    temperatureStatInput.value = program.temperature
    vibrationStatInput.value = program.vibration
    time = (new Date()).getTime()
    imageURL = "url(" + cfg.sServerURL + "/" + program.iconfilename + "?" + time + ")"
    programButton.style.backgroundImage = imageURL
    svgFileInput.setAttribute("name", program.iconfilename)
    
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

maincontentmodule.fileUploadSucceeded = () ->
    log "maincontentmodule.fileUploadSucceeded"
    program = allModules.appstatemodule.currentProgram
    if !program then return
    time = (new Date()).getTime()
    programButton.style.backgroundImage = "url(" + cfg.sServerURL + "/" + program.iconfilename + "?" + time + ")"
    allModules.datahandlermodule.dataChanged()

maincontentmodule.updateCurrentTotalDuration = ->
    log "maincontentmodule.updateCurrentTotalDuration"
    program = allModules.appstatemodule.currentProgram
    if !program
        alert("Error: We called the updateCurretnTotalDuration function but we did not have any currentProgram in the AppState!!")
    durationInput.value = program.durationMS

maincontentmodule.clearFileUpload = ->
    log "maincontentmodule.clearFileUpload"
    uploadingIndicator.textContent = ""
    svgFileInput.value = ""

#endregion
export default maincontentmodule
