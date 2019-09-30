selectmodule = {name: "selectmodule", uimodule: false}

import SelectUnit from "./selectunit.js"

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["selectmodule"]?  then console.log "[selectmodule]: " + arg
    return

#region internal variables
copyClipboard = null
clipboardMap = null
currentSelection = []
#endregion internal variables

selectMode = "vertical" ##bear in mind that this should be in alignment with the initial UI state...
##To easily change the selectMode - change it on initialization by using the appropriate functions

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
selectmodule.initialize = () ->
    log "selectmodule.initialize"

#region internal functions#
isFullColumn = (column) ->
    log "isFullColumn?"
    if !column["agression-channel"]? then return answerNo()
    if !column["pte1-channel"]? then return answerNo()
    if !column["pte23-channel"]? then return answerNo()
    if !column["pte4-channel"]? then return answerNo()
    if !column["vib1-channel"]? then return answerNo()
    if !column["vib2-channel"]? then return answerNo()
    return answerYes()

removeColumn = (column) ->
    log "removeColumn"
    index = column["pte1-channel"].index
    log "- - INDEX:  " + index
    allModules.dynamiccontentmodule.deleteTimesegment(index)

resetColumnFields = (column) ->
    log "resetColumnFields"
    if column["agression-channel"]?
        column["agression-channel"].value = 0

    if column["pte1-channel"]?
        column["pte1-channel"].value = 10
    if column["pte23-channel"]?
        column["pte23-channel"].value = 10
    if column["pte4-channel"]?
        column["pte4-channel"].value = 10
    
    if column["vib1-channel"]?
        column["vib1-channel"].value = 0
    if column["vib2-channel"]?
        column["vib2-channel"].value = 0
    
    reflectValuesToBuffer(column)

deleteSelection = (selectionMap) ->
    log "deleteSelection"
    condensed = condenseMap(selectionMap)
    for column in condensed by -1
        if isFullColumn(column) then removeColumn(column)
        else resetColumnFields(column)

answerYes = ->
    log "answerYes!"
    return true

answerNo = ->
    log "answerNo!"
    return false

reflectValuesToBuffer = (column) ->
    log "reflectValuesToBuffer"
    
    durationMS = NaN
    index = NaN

    program = allModules.appstatemodule.currentProgram
    if !program then throw "Error: we don't have a current program!!"

    if column["pte1-channel"]?
        index = column["pte1-channel"].index
        program.buffertemp1[index] = column["pte1-channel"].value
        durationMS = column["pte1-channel"].durationMS

    if column["pte23-channel"]?
        index = column["pte23-channel"].index
        program.buffertemp2[index] = column["pte23-channel"].value
        program.buffertemp3[index] = column["pte23-channel"].value
        durationMS = column["pte23-channel"].durationMS

    if column["pte4-channel"]?
        index = column["pte4-channel"].index
        program.buffertemp4[index] = column["pte4-channel"].value
        durationMS = column["pte4-channel"].durationMS

    if column["vib1-channel"]?
        index = column["vib1-channel"].index
        program.buffervib1[index] = column["vib1-channel"].value
        durationMS = column["vib1-channel"].durationMS

    if column["vib2-channel"]?
        index = column["vib2-channel"].index
        program.buffervib2[index] = column["vib2-channel"].value
        durationMS = column["vib2-channel"].durationMS

    if column["agression-channel"]?
        index = column["agression-channel"].index
        program.bufferagression[index] = column["agression-channel"].value
        durationMS = column["agression-channel"].durationMS

    program.bufferduration[index] = durationMS

insertColumn = (columnToInsert, selectedColumn) ->
    log "insertColumn"

    vib1Insert = columnToInsert["vib1-channel"]?
    vib2Insert = columnToInsert["vib2-channel"]?

    pte1Insert = columnToInsert["pte1-channel"]?
    pte23Insert = columnToInsert["pte23-channel"]?
    pte4Insert = columnToInsert["pte4-channel"]?

    vib1Selected = selectedColumn["vib1-channel"]?
    vib2Selected = selectedColumn["vib2-channel"]?

    pte1Selected = selectedColumn["pte1-channel"]?
    pte23Selected = selectedColumn["pte23-channel"]?
    pte4Selected = selectedColumn["pte4-channel"]?

    totalTempInsert = pte1Insert + pte23Insert + pte4Insert
    totalTempSelected = pte1Selected + pte23Selected + pte4Selected
    totalVibInsert = vib1Insert + vib2Insert
    totalVibSelected = vib1Selected + vib2Selected

    if columnToInsert["agression-channel"]?
        insert1 = columnToInsert["agression-channel"].value
        durationMS = columnToInsert["agression-channel"].durationMS
        selectedColumn["agression-channel"].value = insert1
        selectedColumn["agression-channel"].durationMS = durationMS

    switch totalTempInsert
        when 3 
            insert1 = columnToInsert["pte1-channel"].value
            insert2 = columnToInsert["pte23-channel"].value
            insert3 = columnToInsert["pte4-channel"].value
            durationMS = columnToInsert["pte1-channel"].durationMS
            switch totalTempSelected
                when 3
                    selectedColumn["pte1-channel"].value = insert1
                    selectedColumn["pte1-channel"].durationMS = durationMS
                    selectedColumn["pte23-channel"].value = insert2
                    selectedColumn["pte23-channel"].durationMS = durationMS
                    selectedColumn["pte4-channel"].value = insert3
                    selectedColumn["pte4-channel"].durationMS = durationMS
                when 2
                    if !pte1Selected
                        selectedColumn["pte23-channel"].value = insert1
                        selectedColumn["pte23-channel"].durationMS = durationMS
                        selectedColumn["pte4-channel"].value = insert2
                        selectedColumn["pte4-channel"].durationMS = durationMS
                    else if !pte23Selected
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                        selectedColumn["pte4-channel"].value = insert2
                        selectedColumn["pte4-channel"].durationMS = durationMS
                    else
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                        selectedColumn["pte23-channel"].value = insert2
                        selectedColumn["pte23-channel"].durationMS = durationMS
                when 1
                    if pte1Selected 
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                    if pte23Selected
                        selectedColumn["pte23-channel"].value = insert1
                        selectedColumn["pte23-channel"].durationMS = durationMS
                    if pte4Selected
                        selectedColumn["pte4-channel"].value = insert1
                        selectedColumn["pte4-channel"].durationMS = durationMS
        when 2 
            insert1DataPoint = (columnToInsert["pte1-channel"] || columnToInsert["pte23-channel"])
            insert2DataPoint = (columnToInsert["pte4-channel"] || columnToInsert["pte23-channel"])
            insert1 = insert1DataPoint.value
            insert2 = insert2DataPoint.value
            durationMS = insert1DataPoint.durationMS
            switch totalTempSelected
                when 3
                    selectedColumn["pte1-channel"].value = insert1
                    selectedColumn["pte1-channel"].durationMS = durationMS
                    selectedColumn["pte23-channel"].value = insert2
                    selectedColumn["pte23-channel"].durationMS = durationMS
                when 2
                    if !pte1Selected
                        selectedColumn["pte23-channel"].value = insert1
                        selectedColumn["pte23-channel"].durationMS = durationMS
                        selectedColumn["pte4-channel"].value = insert2
                        selectedColumn["pte4-channel"].durationMS = durationMS
                    else if !pte23Selected
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                        selectedColumn["pte4-channel"].value = insert2
                        selectedColumn["pte4-channel"].durationMS = durationMS
                    else
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                        selectedColumn["pte23-channel"].value = insert2
                        selectedColumn["pte23-channel"].durationMS = durationMS
                when 1
                    if pte1Selected
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                    if pte23Selected
                        selectedColumn["pte23-channel"].value = insert1
                        selectedColumn["pte23-channel"].durationMS = durationMS
                    if pte4Selected
                        selectedColumn["pte4-channel"].value = insert1
                        selectedColumn["pte4-channel"].durationMS = durationMS
        when 1 
            insert1DataPoint = (columnToInsert["pte1-channel"] || columnToInsert["pte23-channel"] || columnToInsert["pte4-channel"])
            insert1 = insert1DataPoint.value
            durationMS = insert1DataPoint.durationMS
            switch totalTempSelected
                when 3
                    selectedColumn["pte1-channel"].value = insert1
                    selectedColumn["pte1-channel"].durationMS = durationMS
                when 2
                    if !pte1Selected
                        selectedColumn["pte23-channel"].value = insert1
                        selectedColumn["pte23-channel"].durationMS = durationMS
                    else
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                when 1
                    if pte1Selected
                        selectedColumn["pte1-channel"].value = insert1
                        selectedColumn["pte1-channel"].durationMS = durationMS
                    if pte23Selected
                        selectedColumn["pte23-channel"].value = insert1
                        selectedColumn["pte23-channel"].durationMS = durationMS
                    if pte4Selected
                        selectedColumn["pte4-channel"].value = insert1
                        selectedColumn["pte4-channel"].durationMS = durationMS

    switch totalVibInsert
        when 2
            insert1 = columnToInsert["vib1-channel"].value
            insert2 = columnToInsert["vib2-channel"].value
            durationMS = columnToInsert["vib1-channel"].durationMS
            switch totalVibSelected
                when 2
                    selectedColumn["vib1-channel"].value = insert1
                    selectedColumn["vib1-channel"].durationMS = durationMS
                    selectedColumn["vib2-channel"].value = insert2
                    selectedColumn["vib2-channel"].durationMS = durationMS
                when 1
                    if vib1Selected
                        selectedColumn["vib1-channel"].value = insert1
                        selectedColumn["vib1-channel"].durationMS = durationMS
                    if vib2Selected
                        selectedColumn["vib2-channel"].value = insert1
                        selectedColumn["vib2-channel"].durationMS = durationMS
        when 1
            insert1DataPoint = (columnToInsert["vib1-channel"] || columnToInsert["vib2-channel"])
            insert1 = insert1DataPoint.value
            durationMS = insert1DataPoint.durationMS
            switch totalVibSelected
                when 2
                    selectedColumn["vib1-channel"].value = insert1
                    selectedColumn["vib1-channel"].durationMS = durationMS
                when 1
                    if vib1Selected
                        selectedColumn["vib1-channel"].value = insert1
                        selectedColumn["vib1-channel"].durationMS = durationMS
                    if vib2Selected
                        selectedColumn["vib2-channel"].value = insert1
                        selectedColumn["vib2-channel"].durationMS = durationMS

    reflectValuesToBuffer(selectedColumn)

appendColumn = (column) ->
    log "appendColumn"
    program = allModules.appstatemodule.currentProgram
    # log JSON.stringify(program)
    if !program? then return
    
    durationMS = NaN

    if column["agression-channel"]?
        program.bufferagression.push(column["agression-channel"].value)
        durationMS = column["agression-channel"].durationMS
    else program.bufferagression.push(0)

    if column["pte1-channel"]?
        program.buffertemp1.push(column["pte1-channel"].value)
        durationMS = column["pte1-channel"].durationMS
    else program.buffertemp1.push(10)
    if column["pte23-channel"]?
        program.buffertemp2.push(column["pte23-channel"].value)
        program.buffertemp3.push(column["pte23-channel"].value)
        durationMS = column["pte23-channel"].durationMS
    else 
        program.buffertemp2.push(10)
        program.buffertemp3.push(10)
    if column["pte4-channel"]?
        program.buffertemp4.push(column["pte4-channel"].value)
        durationMS = column["pte4-channel"].durationMS
    else program.buffertemp4.push(10)
    
    if column["vib1-channel"]?
        program.buffervib1.push(column["vib1-channel"].value)
        durationMS = column["vib1-channel"].durationMS
    else program.buffervib1.push(0)
    if column["vib2-channel"]?
        program.buffervib2.push(column["vib2-channel"].value)
        durationMS = column["vib2-channel"].durationMS
    else program.buffervib2.push(0)
    
    program.bufferduration.push(durationMS)
    program.dataPoints++

    # log JSON.stringify(program)

isInsertable = (columnToInsert, selectedColumn) ->
    log "isInsertable?"

    log "columnToInsert:"
    log JSON.stringify(columnToInsert)
    log "selectedColumn:"
    log JSON.stringify(selectedColumn)

    vib1Insert = columnToInsert["vib1-channel"]?
    vib2Insert = columnToInsert["vib2-channel"]?

    pte1Insert = columnToInsert["pte1-channel"]?
    pte23Insert = columnToInsert["pte23-channel"]?
    pte4Insert = columnToInsert["pte4-channel"]?

    vib1Selected = selectedColumn["vib1-channel"]?
    vib2Selected = selectedColumn["vib2-channel"]?

    pte1Selected = selectedColumn["pte1-channel"]?
    pte23Selected = selectedColumn["pte23-channel"]?
    pte4Selected = selectedColumn["pte4-channel"]?


    if columnToInsert["agression-channel"]?
        if !selectedColumn["agression-channel"]? then return answerNo()

    totalTempInsert = pte1Insert + pte23Insert + pte4Insert
    totalTempSelected = pte1Selected + pte23Selected + pte4Selected
    totalVibInsert = vib1Insert + vib2Insert
    totalVibSelected = vib1Selected + vib2Selected

    if totalTempInsert == 3
        if totalTempSelected == 3 then return answerYes()
        return answerNo()
    
    if totalTempInsert == 2
        if totalTempSelected >= 2 then return answerYes()
        return answerNo()
    
    if totalTempInsert == 1
        if totalTempSelected >= 1 then return answerYes()
        return answerNo()

    if totalVibInsert == 2
        if totalVibSelected == 2 then return answerYes()
        return answerNo()

    if totalVibInsert == 1
        if totalVibSelected >= 1 then return answerYes()
        return answerNo()

    return answerYes()

condenseMap = (map) ->
    log "condenseMap"
    
    condensed = []
    for content in map
        if content then condensed.push(content)

    return condensed

tryInsert = (column, handle) ->
    log "tryInsert"
    if handle.noFreeSlots then return
    while handle.index < handle.slots.length
        slot = handle.slots[handle.index]
        handle.index++
        if isInsertable(column, slot) 
            insertColumn(column, slot)
            return
    
    handle.noFreeSlots = true
    return

pasteClipboardToSelection = (selectionMap) ->
    log "pasteClipboardToSelection"
    
    condensedClipboard = condenseMap(clipboardMap)
    condensedSelection = condenseMap(selectionMap)

    insertHandle = 
        index: 0
        slots: condensedSelection
        noFreeSlots: false

    for column in condensedClipboard
        tryInsert(column, insertHandle)
        if insertHandle.noFreeSlots then appendColumn(column)

generateSelectionMap = (selectionArray) ->
    log "generateSelectionMap"
    # log selectionArray
    durationBuffer = allModules.appstatemodule.currentProgram.bufferduration

    selectionMap = []
    
    if !selectionArray then return selectionMap
    
    for valueline in selectionArray
        index = valueline.index
        channelId = valueline.channelId

        dataPoint = 
            index: index
            rowId: channelId
            durationMS: durationBuffer[index]
            value: valueline.buffer[index]

        if !selectionMap[index]? then selectionMap[index] = {} 
        
        selectionMap[index][channelId] = dataPoint

    return selectionMap

selectTimesegmentsAt = (xStart, xEnd) ->
    log "selectTimesegmentsAt"
    index = allModules.dynamiccontentmodule.getIndexForXCoord(xStart)
    endIndex = allModules.dynamiccontentmodule.getIndexForXCoord(xEnd)
    
    log "startIndex: " + index + " endIndex: " + endIndex

    allModules.dynamiccontentmodule.stopRendering() ##########\

    loop
        valuelines = allModules.dynamiccontentmodule.valuelinesForTimesegment(index)
        select(valuelines)
        if index == endIndex then return allModules.dynamiccontentmodule.continueRendering() #####/
        index++

selectValuelinesAt = (xStart, xEnd, yStart, yEnd) ->
    log "selectValuelinesAt"
    index = allModules.dynamiccontentmodule.getIndexForXCoord(xStart)
    endIndex = allModules.dynamiccontentmodule.getIndexForXCoord(xEnd)
    channelIds = allModules.dynamiccontentmodule.getChannelIdsForYCoords(yStart, yEnd)
    
    log channelIds

    allModules.dynamiccontentmodule.stopRendering() ##########\
    
    loop
        valuelines = allModules.dynamiccontentmodule.valuelinesForChannelsInTimesegment(channelIds, index)
        select(valuelines)
        if index == endIndex then return allModules.dynamiccontentmodule.continueRendering() #####/
        index++

checkAndSelectCompletedChannels = () ->
    # log "checkAndSelectCompletedChannels"
    return unless allModules.appstatemodule.currentProgram

    totalPoints = allModules.appstatemodule.currentProgram.dataPoints
    countStruct = 
        "pte1-channel": 0
        "pte23-channel": 0
        "pte4-channel": 0
        "vib1-channel": 0
        "vib2-channel": 0
        "agression-channel": 0

    for valueline in currentSelection
        countStruct[valueline.channelId]++

    allModules.dynamiccontentmodule.stopRendering() ##########\

    if countStruct["pte1-channel"] == totalPoints
        allModules.dynamiccontentmodule.setChannelSelected("pte1-channel")
    else
        allModules.dynamiccontentmodule.unsetChannelSelected("pte1-channel")

    if countStruct["pte23-channel"] == totalPoints
        allModules.dynamiccontentmodule.setChannelSelected("pte23-channel")
    else
        allModules.dynamiccontentmodule.unsetChannelSelected("pte23-channel")

    if countStruct["pte4-channel"] == totalPoints
        allModules.dynamiccontentmodule.setChannelSelected("pte4-channel")
    else
        allModules.dynamiccontentmodule.unsetChannelSelected("pte4-channel")

    if countStruct["vib1-channel"] == totalPoints
        allModules.dynamiccontentmodule.setChannelSelected("vib1-channel")
    else
        allModules.dynamiccontentmodule.unsetChannelSelected("vib1-channel")

    if countStruct["vib2-channel"] == totalPoints
        allModules.dynamiccontentmodule.setChannelSelected("vib2-channel")
    else 
        allModules.dynamiccontentmodule.unsetChannelSelected("vib2-channel")

    if countStruct["agression-channel"] == totalPoints
        allModules.dynamiccontentmodule.setChannelSelected("agression-channel")
    else
        allModules.dynamiccontentmodule.unsetChannelSelected("agression-channel")

    allModules.dynamiccontentmodule.continueRendering() #####/

checkAndSelectCompletedTimesegments = () ->
    # log "checkAndSelectCompletedTimesegments"
    return unless allModules.appstatemodule.currentProgram
    numChannels = 6
    dataPoints = allModules.appstatemodule.currentProgram.dataPoints
    countArray = new Array(dataPoints).fill(0)
    
    for valueline in currentSelection
        countArray[valueline.index]++
    
    allModules.dynamiccontentmodule.stopRendering() ##########\

    for count, index in countArray
        # log "count: " + count + " index: " + index 
        if count == numChannels
            allModules.dynamiccontentmodule.setTimesegmentSelected(index)
        else
            allModules.dynamiccontentmodule.unsetTimesegmentSelected(index)
    
    allModules.dynamiccontentmodule.continueRendering() #####/

select = (valuelines) ->
    log "select"
    newSelection = []

    allModules.dynamiccontentmodule.stopRendering() ##########\    
    for valueline in valuelines
        isNew = true
        for selected, index in currentSelection
            if selected && (selected.id == valueline.id)
                isNew = false
                selected.setSelected(false)
                currentSelection[index] = null
        if isNew
            valueline.setSelected(true)
            newSelection.push(valueline)
    
    for element in currentSelection
        if element then newSelection.push(element)

    currentSelection = newSelection

    switch selectMode
        when "horizontal" then checkAndSelectCompletedChannels()
        when "vertical" then checkAndSelectCompletedTimesegments()

    allModules.dynamiccontentmodule.continueRendering() #####/

applyVerticalSelectMode = ->
    log "applyVerticalSelectMode"
    selectMode = "vertical"
    allModules.dynamiccontentmodule.applyVerticalSelectStyles()

applyHorizontalSelectMode = ->
    log "applyHorizontalSelectMode"
    selectMode = "horizontal"
    allModules.dynamiccontentmodule.applyHorizontalSelectStyles()

resetSelection = ->
    log "resetSelection"
    for valueline in currentSelection
        valueline.setSelected(false)
    currentSelection.length = 0
    checkAndSelectCompletedChannels()
    checkAndSelectCompletedTimesegments()

#endregion internal functions
    
#region exposed functions
selectmodule.flushSelection = ->
    log "selectmodule.flushSelection"
    currentSelection.length = 0

selectmodule.setSelectMode = (mode) ->
    log "selectmodule.setSelectMode"
    if selectMode != mode then resetSelection()
    
    switch mode
        when "horizontal" then applyHorizontalSelectMode()
        when "vertical" then applyVerticalSelectMode()

################################################################################
# select functions
################################################################################
selectmodule.selectAll = ->
    log "selectmodule.selectAll"
    valuelines = allModules.dynamiccontentmodule.allValuelines()
    select(valuelines)

selectmodule.selectChannel = (id, ctrl) -> 
    log "selectmodule.selectChannel"
    resetSelection() unless ctrl
    valuelines = allModules.dynamiccontentmodule.valuelinesForChannel(id)
    select(valuelines)
    
selectmodule.selectTimesegment = (index, ctrl) ->
    log "selectmodule.selectTimesegment"
    resetSelection() unless ctrl
    valuelines = allModules.dynamiccontentmodule.valuelinesForTimesegment(index)
    select(valuelines)

selectmodule.selectValueline = (valueline, ctrl) ->
    log "selectmodule.selectValueline"
    resetSelection() unless ctrl
    valuelines = []
    valuelines.push(valueline)
    select(valuelines)

selectmodule.applySelectRect = (selectRectData, ctrl) ->
    log "selectmodule.applySelectRect"
    resetSelection() unless ctrl
    xStart = selectRectData.initialX
    xEnd = selectRectData.currentX
    if xStart > xEnd
        xStart = selectRectData.currentX
        xEnd = selectRectData.initialX
            
    yStart = selectRectData.initialY
    yEnd = selectRectData.currentY
    if yStart > yEnd
        yStart = selectRectData.currentY
        yEnd = selectRectData.initialY

    # log " - - - - Applying SelectRect xStart: " +  xStart + " xEnd: " + xEnd + " yStart: " + yStart + " yEnd: " + yEnd
    switch selectMode
        when "vertical" then selectTimesegmentsAt(xStart, xEnd)
        when "horizontal" then  selectValuelinesAt(xStart, xEnd, yStart, yEnd)

selectmodule.cancelSelection = (arg) ->
    log "selectmodule.cancelSelection"
    resetSelection()
################################################################################
# manipulation functions
################################################################################
selectmodule.copySelection = (arg) ->
    log "selectmodule.copySelection"
    copyClipboard = currentSelection.slice()
    clipboardMap = generateSelectionMap(copyClipboard)
    allModules.messageboxmodule.showInfoMessage("copied the current selection!")

selectmodule.pasteSelection = (arg) ->
    log "selectmodule.pasteSelection"
    allModules.actionhistorymodule.startAction()
    allModules.dynamiccontentmodule.stopRendering() ##########\
    sortedSelection = generateSelectionMap(currentSelection)
    pasteClipboardToSelection(sortedSelection)
    allModules.actionhistorymodule.endAction()
    allModules.dynamiccontentmodule.displayCurrentProgram()
    allModules.dynamiccontentmodule.continueRendering() #####/
    allModules.messageboxmodule.showInfoMessage("Contents have been successfully pasted!")
    
selectmodule.cutSelection = (arg) ->
    log "selectmodule.cutSelection"
    selectmodule.copySelection(arg)
    selectmodule.deleteSelection(arg)

selectmodule.deleteSelection = (arg) ->
    log "deleteSelection"
    allModules.actionhistorymodule.startAction()
    allModules.dynamiccontentmodule.stopRendering() ##########\
    selectionMap = generateSelectionMap(currentSelection)
    deleteSelection(selectionMap)
    # resetSelection() # temporary pfusch
    # currentSelection.length = 0
    allModules.dynamiccontentmodule.continueRendering() #####/
    allModules.actionhistorymodule.endAction()
    allModules.dynamiccontentmodule.displayCurrentProgram()
    allModules.messageboxmodule.showInfoMessage("Selection successfully deleted!")

selectmodule.pauseSelection = (arg) ->
    log "selectmodule.pauseSelection"
    allModules.actionhistorymodule.startAction()
    allModules.dynamiccontentmodule.stopRendering() ##########\

    for valueline in currentSelection
        valueline.togglePause()
    
    allModules.dynamiccontentmodule.continueRendering() #####/
    allModules.actionhistorymodule.endAction()

selectmodule.passArrowDownEvent = ->
    log "selectmodule.passKeyDownEvent"
    allModules.actionhistorymodule.startAction()
    allModules.dynamiccontentmodule.stopRendering() ##########\

    for valueline in currentSelection
        valueline.arrowDown()
    
    allModules.dynamiccontentmodule.continueRendering() #####/
    allModules.actionhistorymodule.endAction()

selectmodule.passArrowUpEvent = ->
    log "selectmodule.passKeyUpEvent"
    allModules.actionhistorymodule.startAction()
    allModules.dynamiccontentmodule.stopRendering() ##########\

    for valueline in currentSelection
        valueline.arrowUp()
    
    allModules.dynamiccontentmodule.continueRendering() #####/
    allModules.actionhistorymodule.endAction()

#endregion

export default selectmodule