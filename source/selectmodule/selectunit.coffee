################################################################################
# Base Class SelectUnit
################################################################################
class SelectUnit
    constructor: (@a,@b,@c,@d,@e,@f,@g) ->
        console.log("SelectUnit constructor")
        #Implement SelectUnit Constructor


export default SelectUnit

################################################################################
#region sample Code
# class SelectUnit
#     constructor: (@index, @durationBuffer, @chartObject, @DOMElement) ->
#         @valueLines = []
#         @chartObject.timelineLayer.appendChild(@DOMElement)
#         @foreignObject = @DOMElement.querySelector("foreignObject")
#         @backgroundRect = @DOMElement.querySelector(".timesegment-background")
#         @editInputLine = @DOMElement.querySelector(".timesegment-edit-input-line")
#         @editInput = @DOMElement.querySelector(".timesegment-edit-input")
#         @addLine = @DOMElement.querySelector(".timesegment-add-line")
#         @addButton = @DOMElement.querySelector(".timesegment-add-button")
#         @addInput = @DOMElement.querySelector(".timesegment-add-input")
#         @editInput.value = 0.1 * @durationBuffer[@index] 
#         @foreignObject.setAttribute("y", 0)
#         @foreignObject.setAttribute("width", foWidth)
#         @foreignObject.setAttribute("height", foHeight)
#         @backgroundRect.setAttribute("y", 0)

#     calculateGeometry: ->
#         # console.log(" - - - calculateGeometry")
#         startMS = @getStartMS()
#         durationMS = @durationBuffer[@index] * 100
#         start = 100.0 * startMS / @chartObject.totalDurationMS
#         left = "" + start + "%"
#         length = 100.0 * durationMS / @chartObject.totalDurationMS
#         width = "" + length + "%"
#         @backgroundRect.setAttribute("width", width)
#         @backgroundRect.setAttribute("height", "100%")
#         @backgroundRect.setAttribute("x", left)
#         @foreignObject.setAttribute("x", left)
#         # console.log("we have so many valuelines: " + @valueLines.length)
#         for valueLine in @valueLines
#             # console.log("valuline adjust position is being called!")
#             valueLine.adjustPosition()
#         return    

#     cleanAddLine: ->
#         @addInput.value = ""
#         @addInput.blur()
#         @addLine.classList.remove("open")
#         @addLine.focus()

#     destroy: ->
#         @DOMElement.parentNode.removeChild(@DOMElement)

#     getStartMS: ->
#         sum = 0
#         i = 0
#         while i < @index
#             sum += @durationBuffer[i++]
#         return sum * 100 
#endregion
################################################################################
