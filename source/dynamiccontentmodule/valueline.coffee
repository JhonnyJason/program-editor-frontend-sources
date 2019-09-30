absorbEvent = (event) -> 
    event.stopPropagation()
    console.log("valueline - event absorbed!")

fgHeight = 2
bgHeight = 30
foHeight = 25
foWidth = 120

class Valueline
    constructor: (@index, @buffer, @topOffset, @spaceHeight, @DOMElement, @chartObject, @timesegment, @channelId) ->
        @editInput = @DOMElement.querySelector(".valueline-edit-input")
        @foreignObject = @DOMElement.querySelector("foreignObject")
        @backgroundRect = @DOMElement.querySelector(".valueline-background")
        @lineRect = @DOMElement.querySelector(".valueline-line")
        @timesegmentRect = @timesegment.querySelector(".timesegment-background")
        @foreignObject.setAttribute("width", foWidth)
        @foreignObject.setAttribute("height", foHeight)
        @backgroundRect.setAttribute("height", bgHeight)
        @lineRect.setAttribute("height", fgHeight)
        @displayCurrentValue()
        @adjustPosition()
        @foreignObject.addEventListener("click", absorbEvent)
        @foreignObject.addEventListener("keydown", absorbEvent)        

        preservedThisReference = this
        valueChangedFunction = -> preservedThisReference.valueChanged()
        # valueChangedFunction = -> @valueChanged()
        @editInput.addEventListener("change", valueChangedFunction)
        @id = @channelId + "-" + @index

    valueChanged: -> return
    displayCurrentValue: -> return
    adjustPosition: -> return
    togglePause: -> return

    setSelected: (selected) ->
        console.log("setSelected:" + selected)
        if selected
            @DOMElement.classList.add("selected")
        else
            @DOMElement.classList.remove("selected")

    arrowDown: -> return
    arrowUp: -> return

    print: ->
        console.log("Valueline Object containing:\n index: " + @index + "\n topOffset: " + @topOffset + "\n spaceHeight: " + @spaceHeight)

class TemperatureValueline extends Valueline
    constructor: (a, b, c, d, e, f, g, h) ->
        super(a,b,c,d,e,f, g, h)
        # pause-play Stuff
        @playPauseBlock = @foreignObject.querySelector(".play-pause-block")
        @playPauseBlock.style.display = "inline-block"
        @pauseButton = @playPauseBlock.querySelector(".pause-block")
        @playButton = @playPauseBlock.querySelector(".play-block")
        preservedThisReference = this
        pauseClickFunction = -> preservedThisReference.pauseButtonActivated()
        playClickFunction = -> preservedThisReference.playButtonActivated()
        @pauseButton.addEventListener("click", pauseClickFunction)
        @playButton.addEventListener("click", playClickFunction)
        # configurations for the input line
        @DOMElement.querySelector(".unit").textContent = "°C"
        @editInput.setAttribute("step", "0.5")
        @editInput.setAttribute("min", "" + @chartObject.minTempC)
        @editInput.setAttribute("max", "" + @chartObject.maxTempC)

    valueChanged: ->
        allModules.actionhistorymodule.startAction()
        if !@statePaused
            value = parseFloat(@editInput.value)
            if !value || value < @chartObject.minTempC
                value = @chartObject.minTempC
                @editInput.value = @chartObject.minTempC
            if value > @chartObject.maxTempC
                value =  @chartObject.maxTempC
                @editInput.value = @chartObject.maxTempC
            @buffer[@index] = 2 * value
        @adjustPosition()
        allModules.actionhistorymodule.endAction()
        allModules.datahandlermodule.dataChanged()
        return

    displayCurrentValue: ->
        if (@buffer[@index] == 128) or (@buffer[@index] == 255) 
            @setStatePaused()
            console.log("set state pause because buffer was: " + @buffer[@index])
        else 
            @unsetStatePaused()
            tempValueC = 0.5 * @buffer[@index]
            @editInput.value = tempValueC
            console.log("state active because buffer was: " + @buffer[@index])
        return

    arrowDown: ->
        return if @statePaused
        value = parseFloat(@editInput.value)
        @editInput.value = value - 0.5
        @valueChanged()

    arrowUp: ->
        return if @statePaused
        value = parseFloat(@editInput.value)
        @editInput.value = value + 0.5
        @valueChanged()

    adjustPosition: ->
        # console.log(" - ---- adjust position")
        xOffset = @timesegmentRect.getAttribute("x")
        # console.log("retrieved xOffset from timesegmentRect: " + xOffset)
        width = @timesegmentRect.getAttribute("width")

        # we might not be redy yet for positioning        
        if xOffset == null then return
        if width == null then return
        
        # console.log("retrieved width from timesegmentRect: " + width)
        tempRangeC = @chartObject.maxTempC - @chartObject.minTempC
        tempValueC = (0.5 * @buffer[@index]) - @chartObject.minTempC
        if @statePaused then tempValueC = 0
        fraction = tempValueC / tempRangeC
        complement = 1 - fraction
        yDelta = complement * @spaceHeight
        yBase = @topOffset + yDelta
        yForeground = yBase - (0.5 * (fgHeight))
        yBackground = yBase - (0.5 * (bgHeight))
        yForeignObject = yBase - foHeight
        # console.log("calculated yBase: " +  yBase)
        # console.log("calculated yBackground: " + yBackground)
        # console.log("calculated yForeignObject: " + yForeignObject)        
        @foreignObject.setAttribute("x", xOffset)
        @foreignObject.setAttribute("y", yForeignObject)
        @backgroundRect.setAttribute("x", xOffset)
        @backgroundRect.setAttribute("y", yBackground)
        @backgroundRect.setAttribute("width", width)
        @lineRect.setAttribute("x",  xOffset)
        @lineRect.setAttribute("y", yForeground)
        @lineRect.setAttribute("width", width)
        return

    setStatePaused: ->
        @DOMElement.classList.add("paused")
        @statePaused = true
        @editInput.value = ""
        @buffer[@index] = 128

    unsetStatePaused: ->
        @DOMElement.classList.remove("paused")
        @statePaused = false
        if (@buffer[@index] == 128) or (@buffer[@index] == 255)
            @editInput.value = @chartObject.minTempC
            @buffer[@index] = 2 * @chartObject.minTempC
    
    pauseButtonActivated: -> 
        allModules.actionhistorymodule.startAction()
        @setStatePaused()
        @valueChanged()
        allModules.actionhistorymodule.endAction()
        return

    playButtonActivated: -> 
        allModules.actionhistorymodule.startAction()
        @unsetStatePaused()
        @valueChanged()
        allModules.actionhistorymodule.endAction()
        return

    togglePause: ->
        if @statePaused then @playButtonActivated()
        else @pauseButtonActivated()

class VibrationValueline extends Valueline
    constructor: (a, b, c, d, e, f, g, h) ->
        super(a,b,c,d,e,f,g,h)
        @DOMElement.querySelector(".unit").textContent = "x"
        @editInput.setAttribute("step", "1")
        @editInput.setAttribute("min", "" + @chartObject.minVibration)
        @editInput.setAttribute("max", "" + @chartObject.maxVibration)
        @DOMElement.classList.add("vibration")

    valueChanged: ->
        allModules.actionhistorymodule.startAction()
        value = parseFloat(@editInput.value)
        if !value || value < @chartObject.minVibration
            value = @chartObject.minVibration
            @editInput.value = @chartObject.minVibration
        if value > @chartObject.maxVibration
            value =  @chartObject.maxVibration
            @editInput.value = @chartObject.maxVibration
        @buffer[@index] = value
        @adjustPosition()
        allModules.datahandlermodule.dataChanged()
        allModules.actionhistorymodule.endAction()
        return 

    displayCurrentValue: ->
        currentValue = @buffer[@index]
        @editInput.value = currentValue
        return

    arrowDown: ->
        value = parseFloat(@editInput.value)
        @editInput.value = value - 1
        @valueChanged()

    arrowUp: ->
        value = parseFloat(@editInput.value)
        @editInput.value = value + 1
        @valueChanged()

    adjustPosition: ->
        xOffset = @timesegmentRect.getAttribute("x")
        width = @timesegmentRect.getAttribute("width")

        # we might not be redy yet for positioning        
        if xOffset == null then return
        if width == null then return

        vibrationRange = @chartObject.maxVibration - @chartObject.minVibration
        vibration = @buffer[@index] - @chartObject.minVibration
        fraction = vibration / vibrationRange
        complement = 1 - fraction
        yDelta = complement * @spaceHeight

        yBase = @topOffset + yDelta
        yForeground = yBase - (0.5 * (fgHeight))
        yBackground = yBase - (0.5 * (bgHeight))
        yForeignObject = yBase - foHeight
        @foreignObject.setAttribute("x", xOffset)
        @foreignObject.setAttribute("y", yForeignObject)
        @backgroundRect.setAttribute("x", xOffset)
        @backgroundRect.setAttribute("y", yBackground)
        @backgroundRect.setAttribute("width", width)
        @lineRect.setAttribute("x",  xOffset)
        @lineRect.setAttribute("y", yForeground)
        @lineRect.setAttribute("width", width)
        return 

class AgressionValueline extends Valueline
    constructor: (a, b, c, d, e, f, g, h) ->
        super(a,b,c,d,e,f,g,h)
        @DOMElement.querySelector(".unit").textContent = "x"
        @editInput.setAttribute("step", "1")
        @editInput.setAttribute("min", "" + @chartObject.minAgression)
        @editInput.setAttribute("max", "" + @chartObject.maxAgression)
        @DOMElement.classList.add("agression")

    valueChanged: ->
        allModules.actionhistorymodule.startAction()
        value = parseFloat(@editInput.value)
        if !value || value < @chartObject.minAgression
            value = @chartObject.minAgression
            @editInput.value = @chartObject.minAgression
        if value > @chartObject.maxAgression
            value =  @chartObject.maxAgression
            @editInput.value = @chartObject.maxAgression
        @buffer[@index] = value
        @adjustPosition()
        allModules.actionhistorymodule.endAction()
        allModules.datahandlermodule.dataChanged()
        return 

    displayCurrentValue: ->
        currentValue = @buffer[@index]
        @editInput.value = currentValue
        return

    arrowDown: ->
        value = parseFloat(@editInput.value)
        @editInput.value = value - 1
        @valueChanged()

    arrowUp: ->
        value = parseFloat(@editInput.value)
        @editInput.value = value + 1
        @valueChanged()

    adjustPosition: ->
        xOffset = @timesegmentRect.getAttribute("x")
        width = @timesegmentRect.getAttribute("width")

        # we might not be redy yet for positioning        
        if xOffset == null then return
        if width == null then return

        agressionRange = @chartObject.maxAgression - @chartObject.minAgression
        agression = @buffer[@index] - @chartObject.minAgression
        fraction = agression / agressionRange
        complement = 1 - fraction
        yDelta = complement * @spaceHeight
        yBase = @topOffset + yDelta
        
        yBase = @topOffset + yDelta
        yForeground = yBase - (0.5 * (fgHeight))
        yBackground = yBase - (0.5 * (bgHeight))
        yForeignObject = yBase - foHeight
        @foreignObject.setAttribute("x", xOffset)
        @foreignObject.setAttribute("y", yForeignObject)
        @backgroundRect.setAttribute("x", xOffset)
        @backgroundRect.setAttribute("y", yBackground)
        @backgroundRect.setAttribute("width", width)
        @lineRect.setAttribute("x",  xOffset)
        @lineRect.setAttribute("y", yForeground)
        @lineRect.setAttribute("width", width)
        return


export  {
    TemperatureValueline,
    VibrationValueline,
    AgressionValueline
}