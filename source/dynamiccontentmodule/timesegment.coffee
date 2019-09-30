absorbEvent = (event) -> 
    event.stopPropagation()
    console.log("timesegment - event absorbed!")

foHeight = 70
foWidth = 100

class Timesegment
    constructor: (@index, @durationBuffer, @chartObject, @DOMElement) ->
        @valueLines = {}
        @chartObject.timelineLayer.appendChild(@DOMElement)
        @foreignObject = @DOMElement.querySelector("foreignObject")
        @backgroundRect = @DOMElement.querySelector(".timesegment-background")
        @editInputLine = @DOMElement.querySelector(".timesegment-edit-input-line")
        @editInput = @DOMElement.querySelector(".timesegment-edit-input")
        @addLine = @DOMElement.querySelector(".timesegment-add-line")
        @addButton = @DOMElement.querySelector(".timesegment-add-button")
        @addInput = @DOMElement.querySelector(".timesegment-add-input")
        @editInput.value = 0.1 * @durationBuffer[@index] 
        @foreignObject.setAttribute("y", 0)
        @foreignObject.setAttribute("width", foWidth)
        @foreignObject.setAttribute("height", foHeight)
        @foreignObject.addEventListener("click", absorbEvent)
        @foreignObject.addEventListener("keydown", absorbEvent)
        @backgroundRect.setAttribute("y", 0)
        
#region Exposed Functions        
    calculateGeometry: ->
        # console.log(" - - - calculateGeometry")
        startMS = @getStartMS()
        durationMS = @durationBuffer[@index] * 100
        if !@durationBuffer[@index]? then return
        start = 100.0 * startMS / @chartObject.totalDurationMS
        left = "" + start + "%"
        length = 100.0 * durationMS / @chartObject.totalDurationMS
        width = "" + length + "%"
        @backgroundRect.setAttribute("width", width)
        @backgroundRect.setAttribute("height", "100%")
        @backgroundRect.setAttribute("x", left)
        @foreignObject.setAttribute("x", left)
        # console.log("we have so many valuelines: " + @valueLines.length)
        for channel, valueLine of @valueLines
            # console.log("valuline adjust position is being called!")
            valueLine.adjustPosition()
        return    
    
    setSelected: (selected) ->
        if selected
            @DOMElement.classList.add("selected")
        else
            @DOMElement.classList.remove("selected")

    getStartXCoord: ->
        return @DOMElement.getBBox().x

    cleanAddLine: ->
        @addInput.value = ""
        @addInput.blur()
        @addLine.classList.remove("open")
        @addLine.focus()

    destroy: ->
        @DOMElement.parentNode.removeChild(@DOMElement)
#endregion

#region Internal Functions
    getStartMS: ->
        sum = 0
        i = 0
        while i < @index
            sum += @durationBuffer[i++]
        return sum * 100 
#endregion

export default Timesegment