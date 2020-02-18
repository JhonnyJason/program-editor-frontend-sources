debugmodule = {name: "debugmodule", uimodule: false}


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
debugmodule.initialize = () ->
    # console.log "debugmodule.initialize - nothing to do"
    return

debugmodule.modulesToDebug = 
    unbreaker: true
    ## UI modules
    # configmodule: true
    # appstatemodule: true
    datahandlermodule: true
    # pageheadermodule: true
    # maincontentmodule: true
    programversiontablemodule: true
    # runhistorymodule: true
    # dynamiccontentmodule: true
    # websocketmodule: true
    # keycommandmodule: true
    # controlboardmodule: true
    # selectmodule: true
    # messageboxmodule: true
    # actionhistorymodule: true

export default debugmodule
