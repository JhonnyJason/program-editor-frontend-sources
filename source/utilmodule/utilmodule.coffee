utilmodule = {name: "utilmodule", uimodule: true}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["utilmodule"]?  then console.log "[utilmodule]: " + arg
    return

#region internal variables

#endregion internal variables

##initialization function -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
utilmodule.initialize = () ->
    log "utilmodule.initialize"
    

#region internal functions

#endregion internal functions

#region exposed variables

#endregion exposed variables

#region exposed functions
utilmodule.buf2hex = (buffer) ->
    return Array.prototype.map.call(new Uint8Array(buffer), ((x) -> ('00' + x.toString(16)).slice(-2))).join('')

utilmodule.bufferByteToCelsiusTemperature = (byte) ->
    log "utilmodule.bufferByteToTemperatureInt"
    return 0.5 * ((byte << 24) >> 24)  ## signed shift operators retrieve the 1 at the edge if there is a 1 and fill it all up

utilmodule.bufferBytesToUint16 = (byte1, byte2) ->
    log "utilmodule.bufferBytesToUint16"
    return (byte2 << 8) | byte1
    
utilmodule.bufferBytesToInt16 = (byte1, byte2) ->
    log "utilmodule.bufferBytesToInt16"
    return ((byte2 << 24) >> 16) | byte1 

utilmodule.dateToStringKey = (date) ->
    log "utilmodule.dateToStringKey"
    resultString = ""
    number = date.getFullYear()
    if number < 1000
        resultString += "0"
    if number < 100
        resultString += "0"
    if number < 10
        resultString += "0"
    resultString += number
    resultString += "-"
    number = date.getMonth()
    if number < 10
        resultString += "0"
    resultString += number
    resultString += "-"
    number  = date.getDate()
    if number < 10
        resultString += "0"
    resultString += number
    return resultString    

utilmodule.stringKeyToDate = (stringKey) ->
    parts = stringKey.split("-")
    year = parseInt(parts[0])
    month = parseInt(parts[1])
    day = parseInt(parts[2])
    return new Date(year, month, day)

utilmodule.bufferToHexString = (arrayBuffer) ->
    log "utilmodule.bufferToHexString"
    array = new Uint8Array(arrayBuffer)
    outputString = "("
    for byte in array
        outputString += " 0x" + byte.toString(16)
    outputString += " )"
    return outputString

utilmodule.getDayLanguageKey = (dayIndex) ->
    log "utilmodule.getDayLanguageKey"
    switch dayIndex
        when 0 then return "forecastLabelSunday"
        when 1 then return "forecastLabelMonday"
        when 2 then return "forecastLabelTuesday"
        when 3 then return "forecastLabelWednesday"
        when 4 then return "forecastLabelThursday"
        when 5 then return "forecastLabelFriday"
        when 6 then return "forecastLabelSaturday"


utilmodule.msToMinString = (msValue) ->
    log 'utilmodule.msToMinString'
    log msValue
    result = '' + Math.floor(Math.round(msValue) / 1000 / 60)
    return result

utilmodule.msToSecString = (msValue) ->
    log 'utilmodule.msToMinString'
    log msValue
    totalSeconds = Math.round(msValue / 1000 )
    nonMinuteSeconds = totalSeconds % 60
    if nonMinuteSeconds < 10
        result = '0' + nonMinuteSeconds
    else 
        result = '' + nonMinuteSeconds
    return result

utilmodule.sToMinString = (sValue) ->
    log 'utilmodule.sToMinString'
    log sValue
    result = '' + Math.floor(Math.round(sValue) / 60)
    result

utilmodule.sToSecString = (sValue) ->
    log 'utilmodule.sToMinString'
    log sValue
    nonMinuteSeconds = Math.round(sValue) % 60
    if nonMinuteSeconds < 10
        result = '0' + nonMinuteSeconds
    else 
        result = '' + nonMinuteSeconds
    result

utilmodule.isEmail = (email) ->
    log 'utilmodule.isEmail'
    log 'email: ' + email
    if typeof email != 'string'
        return false
    regex = new RegExp('[a-z0-9._%+-]+@[a-z0-9.-]+.[a-z]{2,3}$')
    regex.test email

utilmodule.isReasonableBirthYear = (year) ->
    log 'utilmodule.isReasonableBirthYear'
    log 'year: ' + year
    date = new Date
    if !year or year < 1900 or year > date.getFullYear()
        return false
    true

utilmodule.getClockString = (msTime) ->
    log "utilmodule.getClockString"
    seconds = Math.floor(msTime / 1000)
    minutes = Math.floor(seconds / 60)
    seconds = seconds - (minutes * 60)
    clockString = ''
    if minutes < 10
        clockString += '0'
    clockString += minutes
    clockString += ':'
    if seconds < 10
        clockString += '0'
    clockString += seconds
    clockString

utilmodule.getChartLegendTimeString = (sTime) ->
    log "utilmodule.getChartLegendTimeString"
    mins = Math.floor(sTime / 60)
    secs = sTime % 60
    secs = Math.floor(secs)
    result = "" + mins + "'" + secs + "''"
    return result 

utilmodule.jsonToHTMLTableString = (json) ->
    log "utilmodule.jsonToHTMLTable"
    return "null" unless json
    HTMLString = "<table>"
    for key, value of json
        HTMLString += "<tr>"
        HTMLString += '<td class="left-cell">'
        HTMLString += key
        HTMLString += "</td>"
        HTMLString += '<td class="right-cell">'
        HTMLString += value
        HTMLString += "</td>"
        HTMLString += "</tr>"
    HTMLString += "</table>"
    return HTMLString

#endregion exposed functions

export default utilmodule