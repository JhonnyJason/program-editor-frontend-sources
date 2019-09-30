debugmodule = {name: "debugmodule", uimodule: false}


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
debugmodule.initialize = () ->
    # console.log "debugmodule.initialize - nothing to do"
    return

debugmodule.modulesToDebug = 
    ## UI modules
    appstatemodule: true
    configmodule: true
    datahandlermodule: true
    maincontentmodule: true
    networkmodule: true
    pageheadermodule: true
    startupmodule: true
    utilmodule: true


export default debugmodule
