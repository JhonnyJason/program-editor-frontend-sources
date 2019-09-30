actionhistorymodule = {name: "actionhistorymodule", uimodule: false}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["actionhistorymodule"]?  then console.log "[actionhistorymodule]: " + arg
    return

#region internal variables
actionHistory = []
currentAction = null
currentIndex = 0
startActionCallStack = 0

alertTimeout = null
#endregion internal variables


##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
actionhistorymodule.initialize = () ->
    log "actionhistorymodule.initialize"
    
#region internal functions
fuckupAlert = ->
    m = "Error: there is still an open and unresolved action - obviously Lenny fucked up so please tell him :-)"
    alert m
    throw m

applyStateBefore = ->
    log "applyStateBefore"
    action = actionHistory[currentIndex]
    program = JSON.parse(action.before)
    setCurrentStateProgram(program)
    
applyStateAfter = ->
    log "applyStateAfter"
    action = actionHistory[currentIndex]
    program = JSON.parse(action.after)
    setCurrentStateProgram(program)
    
setCurrentStateProgram = (program) ->
    log "setCurrentStateProgram"
    return unless program
    programId = program.id
    allModules.datahandlermodule.setProgram(program)
    allModules.datahandlermodule.selectProgramById(programId)

#endregion internal functions
    
#region exposed functions
actionhistorymodule.actionBack = ->
    log "actionhistorymodule.actionBack"
    return unless currentIndex
    currentIndex--
    applyStateBefore()

actionhistorymodule.actionForward = ->
    log "actionhistorymodule.actionForward"
    return unless currentIndex < actionHistory.length
    applyStateAfter()
    currentIndex++


actionhistorymodule.startAction = ->
    log "actionhistorymodule.startAction"
    startActionCallStack++

    if startActionCallStack == 1
        alertTimeout = setTimeout(fuckupAlert, 1000)
        action = 
            before: JSON.stringify(allModules.appstatemodule.currentProgram)
            after: null

        currentAction = action

actionhistorymodule.endAction = ->
    log "actionhistorymodule.endAction"
    startActionCallStack--

    if startActionCallStack == 0
        clearTimeout(alertTimeout)
        alertTimeout = null

        currentAction.after = JSON.stringify(allModules.appstatemodule.currentProgram)
        
        actionHistory[currentIndex] = currentAction
        currentIndex++
        actionHistory.length = currentIndex
        
        currentAction = null

    if startActionCallStack < 0 then throw "Error! You have too many endAction calls!"

#endregion

export default actionhistorymodule