networkmodule = {name: "networkmodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["networkmodule"]?  then console.log "[networkmodule]: " + arg
    return

#region internal variables
sServerURL = ""
uploadIndicator = null
#endregion internal variables

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
networkmodule.initialize = () ->
    log "networkmodule.initialize"
    sServerURL = allModules.configmodule.sServerURL
    

#region internal functions
requestService = (url, data, successCallback, failCallback) ->
    if data then console.log 'sending data' + JSON.stringify(data)
    request = new XMLHttpRequest
    request.open 'POST', url
    request.setRequestHeader 'Content-Type', 'application/json'
    if data 
        request.send JSON.stringify(data)
    else 
        request.send()

    request.onreadystatechange = ->
        if request.readyState == 4
            response = {}
            if request.response
                response = JSON.parse(request.response)
            if request.status == 200
                successCallback response
            if request.status != 200
                failCallback request
        else
            if request.status != 200
                failCallback request
        return
    return

sendFile = (url, filename, fileHandle) ->
    console.log 'sending file' + JSON.stringify(fileHandle) 
    request = new XMLHttpRequest
    request.open 'POST', url
    request.setRequestHeader 'Content-Type', 'image/svg+xml'
    request.setRequestHeader 'Content-Disposition', 'attachment; filename="' + filename + '"'
    request.send fileHandle

    request.onreadystatechange = ->
        if request.readyState == 4
            if request.status == 200
                alert("File Upload Succeeded with response: " + request.response)
                allModules.maincontentmodule.fileUploadSucceeded()
            if request.status != 200
                alert("File Upload Failed with status: " + request.status)
        else
            if request.status != 200
                alert("File Upload Failed with status: " + request.status)
            return
    return

onloadstartHandler = (event) ->
    log "onloadstartHandler"
    if !uploadIndicator
        return
    uploadIndicator.textContent = "Upload Started!"

onprogressHandler = (event) ->
    log "onprogressHandler"
    if !uploadIndicator
        return
    percent = event.loaded/event.total*100
    uploadIndicator.textContent = "Uploaded " + percent + "%"

onloadHandler = (event) ->
    log "onloadHandler"
    if !uploadIndicator
        return
    uploadIndicator.textContent = "Upload finished!"



sendFormData = (url, formData, newUpoadIndicator) ->
    if uploadIndicator
        alert("We are still uploading another file! This will be ignored!")
        return

    uploadIndicator = newUpoadIndicator

    log 'sending formData' + JSON.stringify(formData) 
    request = new XMLHttpRequest
    request.open 'POST', url
  
    request.upload.addEventListener('loadstart', onloadstartHandler);
    request.upload.addEventListener('progress', onprogressHandler);
    request.upload.addEventListener('load', onloadHandler)
  
    request.send(formData)
    
  
    request.onreadystatechange = ->
        if request.readyState == 4
            if request.status == 200
                uploadIndicator.textContent = request.response
                uploadIndicator = null
                allModules.maincontentmodule.fileUploadSucceeded()
            if request.status != 200
                uploadIndicator = null
                uploadIndicator.textContent = "File Upload Failed with status: " + request.status
        else
            if request.status != 200
                alert("what is this case anyways? \n readyState is: " + request.readyState + "\nstatus is: " + request.status)
                uploadIndicator = null
                uploadIndicator.textContent = "File Upload Failed with status: " + request.status
            return
    return

#endregion internal functions

#region exposed functions
networkmodule.uploadFileRaw = (filename, fileHandle) ->
    sendFile sServerURL + "/upload", filename, fileHandle 
    return

networkmodule.uploadFileFormData = (formData, newUploadIndicator) ->
    sendFormData sServerURL + "/upload", formData, newUploadIndicator
    return

networkmodule.requestBackendService = (route, data, successCallback, failCallback) ->
    requestService sServerURL + "/" + route, data, successCallback, failCallback
    return
#endregion

export default networkmodule