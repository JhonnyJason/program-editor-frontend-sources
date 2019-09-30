dynamiccontentmodule = {name: "dynamiccontentmodule", uimodule: true}

import Timesegment from "./timesegment.js"
import {TemperatureValueline, VibrationValueline, AgressionValueline} from "./valueline.js"

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["dynamiccontentmodule"]?  then console.log "[dynamiccontentmodule]: " + arg
    return

AppVars = null

applyZoomFactor = 1.1
selectRectMinDim = 4

chartObject =
    zoomFactor: 1.0
    totalDurationMS: 0
    allTimesegments: []
    allChannels: {}
    chartWidth: 0
    dynamicBackground: null
    staticBackground: null
    timelineLayer: null
    channelLayer: null
    minTempC: 5
    maxTempC: 40
    minVibration: 0
    maxVibration: 255
    minAgression: 0 
    maxAgression: 100
    geometryAvailable: false

selectRectData = 
    isActive: false
    element: null
    initialX: 0
    initialY: 0
    currentX: 0
    currentY: 0

backgroundContainer = null
noRenderingStack = 0
alertTimeout = null

channelTemplate = null
timesegmentTemplate = null
valuelineTemplate = null

staticSVGContainerPTE1 = null
staticSVGContainerPTE23 = null
staticSVGContainerPTE4 = null

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
dynamiccontentmodule.initialize = () ->
    log "maincontentmodule.initialize"
    AppVars = allModules.appstatemodule
    chartObject.dynamicBackground = document.getElementById("dynamic-background")
    chartObject.staticBackground = document.getElementById("static-background")
    chartObject.timelineLayer = document.getElementById("timeline-layer")
    chartObject.channelLayer = document.getElementById("channel-layer")
    backgroundContainer = chartObject.dynamicBackground.parentNode
    timesegmentTemplate = document.getElementById("timesegment-hidden-template")
    valuelineTemplate = document.getElementById("valueline-hidden-template")
    channelTemplate = document.getElementById("channel-hidden-template")
    selectRectData.element = document.getElementById("select-rect")
    staticSVGContainerPTE1 = document.getElementById("pte1-svg-container")
    staticSVGContainerPTE23 = document.getElementById("pte23-svg-container")
    staticSVGContainerPTE4 = document.getElementById("pte4-svg-container")
    chartObject.dynamicBackground.addEventListener("mousedown", mouseDowned)
    chartObject.dynamicBackground.addEventListener("mousemove", mouseMoved)
    # chartObject.dynamicBackground.addEventListener("keydown", keyDownedForDynamicData)
    document.addEventListener("mouseup", mouseUpped)
    document.addEventListener("keydown", keyDownedForDynamicData)
    # deny dragging
    absorbEvent = (event) ->
        event.preventDefault() 
        event.stopPropagation()
    document.addEventListener("dragstart", absorbEvent)

############################################################################
#region internal functions
#- - - - - - - - - - - - - - - - - - - -

############################################################################
#region UI Event Handlers
mouseDowned = (event) ->
    return if selectRectData.isActive
    log "mouseDowned"
    # if this.id != "dynamic-background" then return
    selectRectData.isActive = true
    selectRectData.initialX = event.offsetX
    selectRectData.initialY = event.offsetY
    selectRectData.currentX = event.offsetX
    selectRectData.currentY = event.offsetY

    selectRectData.element.style.display = "block"
    selectRectData.element.setAttribute("x", selectRectData.initialX)
    selectRectData.element.setAttribute("y", selectRectData.initialY)
    selectRectData.element.setAttribute("width", 0)
    selectRectData.element.setAttribute("height", 0)

mouseMoved = (event) ->
    return unless selectRectData.isActive
    # if this.id != "dynamic-background" then return
    # log "mouseMoved"
    offsetX = event.offsetX
    offsetY = event.offsetY
    
    selectRectData.currentX = offsetX
    selectRectData.currentY = offsetY

    width = offsetX - selectRectData.initialX
    height = offsetY - selectRectData.initialY
    
    if width < 0
        x = selectRectData.initialX + width
        selectRectData.element.setAttribute("x", x)
        width = -width
    if height < 0
        y = selectRectData.initialY + height
        selectRectData.element.setAttribute("y", y)
        height = -height

    selectRectData.element.setAttribute("width", width)
    selectRectData.element.setAttribute("height", height)

mouseUpped = (event) ->
    return unless selectRectData.isActive
    # log "mouseUpped"
    width = selectRectData.initialX - selectRectData.currentX
    height = selectRectData.initialY - selectRectData.currentY

    if width < 0 then width = -width
    if height < 0 then height = -height

    # log "height: " + height
    # log "width: " + width

    if width < selectRectMinDim
        stopSelectRect()
        return
    if height < selectRectMinDim
        stopSelectRect()
        return

    allModules.selectmodule.applySelectRect(selectRectData, event.ctrlKey)
    stopSelectRect()

keyDownedForDynamicData = (event) ->
    switch event.keyCode
        when 46 
            allModules.selectmodule.deleteSelection()
            event.preventDefault()
        when 40 
            allModules.selectmodule.passArrowDownEvent()
            event.preventDefault()
        when 38 
            allModules.selectmodule.passArrowUpEvent()
            event.preventDefault()
        when 27 then allModules.selectmodule.cancelSelection()

channelClicked = (event) ->
    log "channelClicked"
    parent = event.target.parentNode
    allModules.selectmodule.selectChannel(parent.id, event.ctrlKey)

timesegmentClicked = (timesegment, ctrl) ->
    log "timesegmentClicked"
    allModules.selectmodule.selectTimesegment(timesegment.index, ctrl)

valuelineClicked = (valueline, event) ->
    log "valuelineClicked"
    event.stopPropagation()
    allModules.selectmodule.selectValueline(valueline, event.ctrlKey)

addInputKeyDown = (timesegment, keyCode) ->
    log "addInputEscaped"
    if keyCode == 27 #escape
        log "escape key downed"
        timesegment.cleanAddLine()
        return
    if keyCode == 13 #enter
        log "enter key downed"
        if timesegment.addInput.value && (parseFloat(timesegment.addInput.value) > 0)
            addNewTimesegment(timesegment.index, 10 * parseFloat(timesegment.addInput.value))
            return
        timesegment.cleanAddLine()
        return

timesegmentAddButtonActivated = (timesegment) ->
    log "timesegmentAddButtonActivated"
    if timesegment.addInput.value && (parseFloat(timesegment.addInput.value) > 0)
        addNewTimesegment(timesegment.index, 10 * parseFloat(timesegment.addInput.value))
        timesegment.cleanAddLine()
        return
    timesegment.addLine.classList.toggle("open")
    if timesegment.addLine.classList.contains("open")
        timesegment.addInput.focus()

timesegmentDurationChanged = (timesegment) ->
    log "timesegmentDurationChanged"
    program = assertCurrentProgram()
    index = timesegment.index
    inputElement = timesegment.editInput
    programDurationBuffer = allModules.appstatemodule.currentProgram.bufferduration 
    
    allModules.actionhistorymodule.startAction()

    programDurationBuffer[index] = Math.round(parseFloat(inputElement.value) * 10)
    
    if programDurationBuffer[index] == 0 or isNaN(programDurationBuffer[index])
        removeTimesegment(index)
    else
        sumTotalDuration()
        updateTotalDuration()
        updateGeometries()
    
    allModules.actionhistorymodule.endAction()
    allModules.datahandlermodule.dataChanged()
#endregion
############################################################################

############################################################################
#region helper functions
fuckupAlert = ->
    m = "Error: Rendering of the program is still disabled - obviously Lenny fucked up so please tell him :-)"
    alert m
    throw m

containsChannel = (channel, yStart, yEnd) ->
    log "containsChannel"
    if !chartObject.geometryAvailable then throw "No chartGeometries available!"
    
    topKey = channel + "Top"
    heightKey = channel + "Height"
    
    top = chartObject[topKey]
    height = chartObject[heightKey]
    bottom = top + height

    contains = false

    if yStart < top #interval starts above this channel
        if yEnd >= top #and ends below this channel
            contains = true
    else #interval starts below this channel
        if yStart <= bottom #but starts above the bottom of this channel 
            contains = true

    return contains

stopSelectRect = ->
    log "stopSelectrect"
    selectRectData.isActive = false
    selectRectData.element.style.display = "none"
    selectRectData.element.setAttribute("x", 0)
    selectRectData.element.setAttribute("y", 0)
    selectRectData.element.setAttribute("width", 0)
    selectRectData.element.setAttribute("height", 0)

deleteProgramSegment = (program, index) ->
    log "deleteProgramSegment"
    program.dataPoints--    
    program.buffertemp1.splice(index, 1)
    program.buffertemp2.splice(index, 1)
    program.buffertemp3.splice(index, 1)
    program.buffertemp4.splice(index, 1)
    program.buffervib1.splice(index, 1)
    program.buffervib2.splice(index, 1)
    program.bufferagression.splice(index, 1)
    program.bufferduration.splice(index, 1)

sanitizeProgram = (program) ->
    log "sanitizeProgram"
    return unless program
    points = program.dataPoints
    maxPoints = 0
    
    if program.buffertemp1.length > maxPoints then maxPoints = program.buffertemp1.length
    if program.buffertemp2.length > maxPoints then maxPoints = program.buffertemp2.length
    if program.buffertemp3.length > maxPoints then maxPoints = program.buffertemp3.length
    if program.buffertemp4.length > maxPoints then maxPoints = program.buffertemp4.length
    if program.buffervib1.length > maxPoints then maxPoints = program.buffervib1.length
    if program.buffervib2.length > maxPoints then maxPoints = program.buffervib2.length
    if program.bufferagression.length > maxPoints then maxPoints = program.bufferagression.length
    if program.bufferduration.length > maxPoints then maxPoints = program.bufferduration.length

    program.dataPoints = maxPoints
    
    program.buffertemp1.length = maxPoints
    program.buffertemp2.length = maxPoints
    program.buffertemp3.length = maxPoints
    program.buffertemp4.length = maxPoints
    program.buffervib1.length = maxPoints
    program.buffervib2.length = maxPoints
    program.bufferagression.length = maxPoints
    program.bufferduration.length = maxPoints

    for duration, index in program.bufferduration
        if duration == 0 then deleteProgramSegment(program, index)


isCorrectChannelId = (channelId) ->
    log "isCorrectChannelId"
    switch(channelId)
        when "pte1-channel" then return true
        when "pte23-channel" then return true
        when "pte4-channel" then return true
        when "vib1-channel" then return true
        when "vib2-channel" then return true
        when "agression-channel" then return true
        else return false

assertCurrentProgram = ->
    program = allModules.appstatemodule.currentProgram
    if !program 
        alert("Error: We Called the displayCurrentProgram function but did not have any currentProgram in the AppState!!")
        throw "No Current Program!"
    return program

updateTotalDuration  = ->
    allModules.appstatemodule.currentProgram.durationMS = chartObject.totalDurationMS
    allModules.maincontentmodule.updateCurrentTotalDuration()

wireUpTimesegment = (timesegment) ->
    # log "wireUpTimeSegment"
    timesegmentClickedFunc = (event) ->
        timesegmentClicked(timesegment, event.ctrlKey)
    timesegment.DOMElement.addEventListener("click", timesegmentClickedFunc)
        
    ## duration edit
    timesegmentDurationChangeFunc = ->
        timesegmentDurationChanged(timesegment)
    timesegment.editInput.addEventListener("change", timesegmentDurationChangeFunc)
    ## add button click
    timesegmentAddButtonActivatedFunc = ->
        timesegmentAddButtonActivated(timesegment)
    timesegment.addButton.addEventListener("click", timesegmentAddButtonActivatedFunc)
    ## enter or escape type on input
    addInputKeyDownFunc = (event) ->
        addInputKeyDown(timesegment, event.keyCode)
    timesegment.addInput.addEventListener("keydown", addInputKeyDownFunc)

sumTotalDuration = ->
    log "sumTotalDuration"
    
    program = assertCurrentProgram()
    durations = program.bufferduration
    totalDurationMS = 0

    for duration, index in durations
        if duration == 0 then indicesToRemove.unshift(index) 
        totalDurationMS += duration * 100

    chartObject.totalDurationMS = totalDurationMS

saveChartGeometries = ->
    log "saveChartGeometries"
    staticContent = document.getElementById("static-background")
    pte1space = document.getElementById("pte1-space")
    pte23space = document.getElementById("pte23-space")
    pte4space = document.getElementById("pte4-space")
    vib1space = document.getElementById("vib1-space")
    vib2space = document.getElementById("vib2-space")
    agressionSpace = document.getElementById("agression-space")

    chartObject.pte1Top = pte1space.offsetTop
    chartObject.pte1Height = pte1space.offsetHeight
    chartObject.pte23Top = pte23space.offsetTop
    chartObject.pte23Height = pte23space.offsetHeight
    chartObject.pte4Top = pte4space.offsetTop
    chartObject.pte4Height = pte4space.offsetHeight

    chartObject.vib1Top = vib1space.offsetTop
    chartObject.vib1Height = vib1space.offsetHeight
    chartObject.vib2Top = vib2space.offsetTop
    chartObject.vib2Height = vib2space.offsetHeight
    
    chartObject.agressionTop = agressionSpace.offsetTop
    chartObject.agressionHeight = agressionSpace.offsetHeight
    chartObject.geometryAvailable = true
#endregion
############################################################################

############################################################################
#region functions to de/construct chart
createChannel = (id, height, y) ->
    log "createChannel"
    newChannel = channelTemplate.cloneNode(true)
    newChannel.addEventListener("click", channelClicked)
    newChannel.id = id
    background = newChannel.getElementsByClassName("channel-background")[0]
    background.setAttribute("height", height) 
    background.setAttribute("y", y)
    chartObject.channelLayer.appendChild(newChannel)
    chartObject.allChannels[id] = newChannel

createChannels = ->
    log "createChannels"
    if Object.keys(chartObject.allChannels).length > 0 then return 
    createChannel("agression-channel", chartObject.agressionHeight, chartObject.agressionTop)
    createChannel("pte1-channel", chartObject.pte1Height, chartObject.pte1Top)
    createChannel("pte23-channel", chartObject.pte23Height, chartObject.pte23Top)
    createChannel("pte4-channel", chartObject.pte4Height, chartObject.pte4Top)
    createChannel("vib1-channel", chartObject.vib1Height, chartObject.vib1Top)
    createChannel("vib2-channel", chartObject.vib2Height, chartObject.vib2Top)
    
createTimesegments = ->
    log "createTimesegments"
    program = assertCurrentProgram()
    durations = program.bufferduration
    chartObject.allTimesegments = []
    latestStartMS = 0
    index = 0
    for duration in durations
        newNode = timesegmentTemplate.cloneNode(true)
        newNode.removeAttribute("id")
        durationMS = duration * 100
        timesegment = new Timesegment(index, durations, chartObject, newNode)
        wireUpTimesegment(timesegment)
        chartObject.allTimesegments.push(timesegment)
        timesegment.valueLines = createValueLines(newNode, program, index)
        latestStartMS += durationMS
        index++

createValueLine = (type, index, buffer, topY, height, parent, channelId) ->
    log "createValueLine"
    valueLine = null
    
    element = valuelineTemplate.cloneNode(true)
    element.removeAttribute("id")
    
    switch(type)
        when "temperature"
            valueLine = new TemperatureValueline(index, buffer, topY, height, element, chartObject, parent, channelId)
        when "vibration"
            valueLine = new VibrationValueline(index, buffer, topY, height, element, chartObject, parent, channelId)
        when "agression"
            valueLine = new AgressionValueline(index, buffer, topY, height, element, chartObject, parent, channelId)
    
    valuelineClickedFunc = (event) ->
        valuelineClicked(valueLine, event)

    element.addEventListener("click", valuelineClickedFunc)
    parent.appendChild(element)

    return valueLine
    
createValueLines = (node, program, index) ->
    log "createValueLines"
    valueLines = {}
    
    if !chartObject.geometryAvailable then throw "No chartGeometries available!"

    valueLines["pte1-channel"] = createValueLine("temperature", index, program.buffertemp1, chartObject.pte1Top, chartObject.pte1Height, node, "pte1-channel")#pte1
    valueLines["pte23-channel"] = createValueLine("temperature", index, program.buffertemp2, chartObject.pte23Top, chartObject.pte23Height, node, "pte23-channel")#pte23
    valueLines["pte4-channel"] = createValueLine("temperature", index, program.buffertemp4, chartObject.pte4Top, chartObject.pte4Height, node, "pte4-channel")#pte4
    valueLines["vib1-channel"] = createValueLine("vibration", index, program.buffervib1, chartObject.vib1Top, chartObject.vib1Height, node, "vib1-channel")#vib1
    valueLines["vib2-channel"] = createValueLine("vibration", index, program.buffervib2, chartObject.vib2Top, chartObject.vib2Height, node, "vib2-channel")#vib2
    valueLines["agression-channel"] = createValueLine("agression", index, program.bufferagression, chartObject.agressionTop, chartObject.agressionHeight, node, "agression-channel")#agression
    
    return valueLines

removeTimesegment = (index) ->
    log "removeTimesegment"
    program  = assertCurrentProgram()
    program.bufferduration[index] = 0
    if program.dataPoints == 1
        if index != 0 then throw "Error, we only have 1 datapoint and the index to remove is: " + index
        program.bufferduration[0] = 1
        chartObject.allTimesegments[0].editInput.value = 0.1
        sumTotalDuration()
        updateTotalDuration()
        updateGeometries()
    else
        dynamiccontentmodule.displayCurrentProgram()

addNewTimesegment = (index, duration) ->
    log "addNewTimesegment"
    program = assertCurrentProgram()
    oldtemp1 = program.buffertemp1[index]
    oldtemp2 = program.buffertemp2[index]
    oldtemp3 = program.buffertemp3[index]
    oldtemp4 = program.buffertemp4[index]
    oldvib1 = program.buffervib1[index]
    oldvib2 = program.buffervib2[index]
    oldagression = program.bufferagression[index]
    index++
    program.dataPoints++    
    program.buffertemp1.splice(index, 0, oldtemp1)
    program.buffertemp2.splice(index, 0, oldtemp2)
    program.buffertemp3.splice(index, 0, oldtemp3)
    program.buffertemp4.splice(index, 0, oldtemp4)
    program.buffervib1.splice(index, 0, oldvib1)
    program.buffervib2.splice(index, 0, oldvib2)
    program.bufferagression.splice(index, 0, oldagression)
    program.bufferduration.splice(index, 0, duration)
    dynamiccontentmodule.displayCurrentProgram()
    allModules.datahandlermodule.dataChanged()

cleanCurrentChart = ->
    log "cleanCurrentChart"
    dynamiccontentmodule.stopRendering() ##########\

    for timesegment in chartObject.allTimesegments
        timesegment.destroy()

    dynamiccontentmodule.continueRendering() #####/
#endregion
############################################################################

############################################################################
#region functions to draw content
drawMeasurementDataToSVGContainer = (data, ticks, container, color, label) ->
    log "drawMeasurementDataToSVGContainer"            
    x =  container.viewBox.baseVal.x
    y = container.viewBox.baseVal.y
    width =  container.viewBox.baseVal.width
    height = container.viewBox.baseVal.height

    if data.length != ticks.length
        log "Error: number of datapoints and timing data was not consistent! data.length: " + data.length  + " ticks.length: " + ticks.length
        throw "shit"

    yScale = (1.0 * height ) / (1.0 * chartObject.maxTempC - 1.0 * chartObject.minTempC)  
    xScale = (1.0 * width) / (1.0 * chartObject.totalDurationMS)
    
    yCoords = []
    xCoords = []   
    
    for date in data
        temp = 0.5 * date
        leveledTemp = temp - chartObject.minTempC
        desiredPosition = leveledTemp * yScale
        yCoord = height - desiredPosition
        yCoords.push(yCoord)
    
    for tick in ticks
        timeMS = 100.0 * tick
        xCoord = timeMS * xScale
        xCoords.push(xCoord) 

    path = document.createElementNS("http://www.w3.org/2000/svg", 'path');
    pathD = "M"
    
    for xCoord, i in xCoords
        pathD += " " + xCoord
        pathD += "," + yCoords[i]
    
    #draw the shit
    path.setAttribute("d", pathD)
    path.style.stroke = color
    path.style.strokeWidth = "10px";
    path.style.fill = "none"
    container.appendChild(path)
    ## TODO draw the label

updateGeometries = ->
    log "updateGeometries"
    
    dynamiccontentmodule.stopRendering() ##########\

    for timesegment in chartObject.allTimesegments
        timesegment.calculateGeometry() 

    dynamiccontentmodule.continueRendering() #####/
#endregion
############################################################################

#- - - - - - - - - - - - - - - - - - - -
#endregion
############################################################################

############################################################################
#region Exposed Functions

dynamiccontentmodule.stopRendering = ->
    log "dynamiccontentmodule.stopRendering"
    noRenderingStack++
    if noRenderingStack == 1
        backgroundContainer.removeChild(chartObject.dynamicBackground)
        alertTimeout = setTimeout(fuckupAlert, 1000)
    return 
    
dynamiccontentmodule.continueRendering = ->
    log "dynamiccontentmodule.continueRendering"
    noRenderingStack--
    if noRenderingStack == 0
        clearTimeout(alertTimeout)
        alertTimeout = null
        backgroundContainer.appendChild(chartObject.dynamicBackground)
        allModules.maincontentmodule.drawBufferTable()
    if noRenderingStack < 0  then throw "Error! You have too many continueRendering calls!"
    return

dynamiccontentmodule.deleteTimesegment = (index) ->
    log "deleteTimesegment"
    removeTimesegment(index)

dynamiccontentmodule.getIndexForXCoord = (x) ->
    log "dynamiccontentmodule.getIndexForXCoord"
    found = false
    for timesegment, index in chartObject.allTimesegments
        if timesegment.getStartXCoord() > x then return index - 1
    
    return chartObject.allTimesegments.length - 1

dynamiccontentmodule.getChannelIdsForYCoords = (yStart, yEnd) ->
    log "dynamiccontentmodule.getChannelIdsForYCoords"
    channelIds = []

    if containsChannel("agression", yStart, yEnd) then channelIds.push("agression-channel")
    if containsChannel("pte1", yStart, yEnd) then channelIds.push("pte1-channel")
    if containsChannel("pte23", yStart, yEnd) then channelIds.push("pte23-channel")
    if containsChannel("pte4", yStart, yEnd) then channelIds.push("pte4-channel")
    if containsChannel("vib1", yStart, yEnd) then channelIds.push("vib1-channel")
    if containsChannel("vib2", yStart, yEnd) then channelIds.push("vib2-channel")

    return channelIds

dynamiccontentmodule.setTimesegmentSelected = (index) ->
    log "dynamiccontentmodule.setTimesegmentSelected"
    chartObject.allTimesegments[index].setSelected(true)

dynamiccontentmodule.unsetTimesegmentSelected = (index) ->
    log "dynamiccontentmodule.unsetTimesegmentSelected"
    chartObject.allTimesegments[index].setSelected(false)

dynamiccontentmodule.setChannelSelected = (channelId) ->
    log "dynamiccontentmodule.setChannelSelected"
    return unless isCorrectChannelId(channelId)
    chartObject.allChannels[channelId].classList.add("selected")

dynamiccontentmodule.unsetChannelSelected = (channelId) ->
    log "dynamiccontentmodule.unsetChannelSelected"
    return unless isCorrectChannelId(channelId)
    chartObject.allChannels[channelId].classList.remove("selected") 

dynamiccontentmodule.allValuelines = ->
    log "dynamiccontentmodule.allValuelines"
    return unless chartObject.allTimesegments?

    valuelines = []

    for timesegment in chartObject.allTimesegments
        for name,valueline of timesegment.valueLines
            valuelines.push(valueline)        

    return valuelines


dynamiccontentmodule.valuelinesForChannel = (channelId) ->
    log "dynamiccontentmodule.valuelinesForChannel"
    return unless isCorrectChannelId(channelId)

    valuelines = []
    for timesegment in chartObject.allTimesegments
        valueline = timesegment.valueLines[channelId]
        valuelines.push(valueline)

    return valuelines

dynamiccontentmodule.valuelinesForTimesegment = (index) ->
    log "dynamiccontentmodule.valuelinesForTimesegment"
    if !chartObject.allTimesegments[index]?
        allModules.messageboxmodule.showErrorMessage("Unexpected State in function: dynamiccontentmodule.valuelinesForTimesegment")
        return
    valuelines = []

    for key, valueline of chartObject.allTimesegments[index].valueLines
        valuelines.push(valueline)
    
    return valuelines

dynamiccontentmodule.valuelinesForChannelsInTimesegment = (channelIds, index) ->
    log "dynamiccontentmodule.valuelinesForChannelsInTimesegment"
    if !chartObject.allTimesegments[index]?
        allModules.messageboxmodule.showErrorMessage("Unexpected State in function: dynamiccontentmodule.valuelinesForTimesegment")
        return
    valuelines = []

    for key, valueline of chartObject.allTimesegments[index].valueLines
        for channelId in channelIds
            if key == channelId then valuelines.push(valueline)
    
    return valuelines


dynamiccontentmodule.applyHorizontalSelectStyles = ->
    log "dynamiccontentmodule.applyHorizontalSelectStyles"
    chartObject.dynamicBackground.classList.add("channel-select")

dynamiccontentmodule.applyVerticalSelectStyles = ->
    log "dynamiccontentmodule.applyVerticalSelectStyles"
    chartObject.dynamicBackground.classList.remove("channel-select")

dynamiccontentmodule.zoomIn = ->
    log "dynamiccontentmodule.zoomIn"
    chartObject.zoomFactor *= applyZoomFactor
    zoomPercentage = 100.0 * chartObject.zoomFactor
    chartObject.dynamicBackground.style.width = "" + zoomPercentage + "%"
    chartObject.staticBackground.style.width = "" + zoomPercentage + "%"

dynamiccontentmodule.zoomOut = ->
    log "dynamiccontentmodule.zoomOut"
    chartObject.zoomFactor /= applyZoomFactor
    zoomPercentage = 100.0 * chartObject.zoomFactor
    chartObject.dynamicBackground.style.width = "" + zoomPercentage + "%"
    chartObject.staticBackground.style.width = "" + zoomPercentage + "%"

dynamiccontentmodule.displayCurrentProgram = ->
    log "dynamiccontentmodule.displayCurrentProgram"
    
    saveChartGeometries()
    createChannels()

    program = assertCurrentProgram()
    sanitizeProgram(program)

    dynamiccontentmodule.stopRendering() ##########\

    allModules.selectmodule.flushSelection()
    cleanCurrentChart()
    sumTotalDuration()
    updateTotalDuration()
    createTimesegments() # already creates the valuelines
    updateGeometries()
    
    dynamiccontentmodule.continueRendering() #####/
    

dynamiccontentmodule.displayCurrentRun = ->
    log "dynamiccontentmodule.displayCurrentRun"
    run = allModules.appstatemodule.currentRun
    if !run
        alert("Error: We Called the displayCurrentRun function but did not have any currentRun in the AppState!!")

    drawMeasurementDataToSVGContainer(run.tempPTE1, run.programsProgress, staticSVGContainerPTE1, "#c88", "inside")

    drawMeasurementDataToSVGContainer(run.tempPTE2, run.programsProgress, staticSVGContainerPTE23, "#8c8", "inside")

    drawMeasurementDataToSVGContainer(run.tempPTE4, run.programsProgress, staticSVGContainerPTE4, "#88c", "inside")

    drawMeasurementDataToSVGContainer(run.tempPTE1Outside, run.programsProgress, staticSVGContainerPTE1, "#666", "outside")

    drawMeasurementDataToSVGContainer(run.tempPTE2Outside, run.programsProgress, staticSVGContainerPTE23, "#666", "outside")

    drawMeasurementDataToSVGContainer(run.tempPTE4Outside, run.programsProgress, staticSVGContainerPTE4, "#666", "outside")

    # log JSON.stringify(printable)
    # printable = 
    #     container: "viewBox with commas"
    #     x: staticSVGContainerPTE4.viewBox.baseVal.x
    #     y: staticSVGContainerPTE4.viewBox.baseVal.y
    #     width: staticSVGContainerPTE4.viewBox.baseVal.width
    #     height: staticSVGContainerPTE4.viewBox.baseVal.height
    # log JSON.stringify(printable)
    # printable = 
    #     container: "not defined viewBox"
    #     x: staticSVGContainerPTE23.viewBox.baseVal.x
    #     y: staticSVGContainerPTE23.viewBox.baseVal.y
    #     width: staticSVGContainerPTE23.viewBox.baseVal.width
    #     height: staticSVGContainerPTE23.viewBox.baseVal.height
    # log JSON.stringify(printable)

    ## TODO implement the drawing


#endregion
############################################################################

export default dynamiccontentmodule