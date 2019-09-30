runhistorymodule = {name: "runhistorymodule", uimodule: true}

#log Switch
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["runhistorymodule"]?  then console.log "[runhistorymodule]: " + arg
    return

runHistoryTableSection =  null

##initialization function  -> is automatically being called!  ONLY RELY ON DOM AND VARIABLES!! NO PLUGINS NO OHTER INITIALIZATIONS!!
runhistorymodule.initialize = () ->
    log "runhistorymodule.initialize"
    runHistoryTableSection = document.getElementById("run-history-section")
    
#region internal functions
tableElementClick = (event) ->
    target = event.target
    id = target.getAttribute("run-id")
    log "should gather all run data and  then draw the run - having the id: " + id    
    if id
        allModules.datahandlermodule.selectRunById(id)

################################################################################
# Layer 0 UI Event Handler Functions
################################################################################

#endregion

#region Exposed Functions
runhistorymodule.indicateCurrentChosenRun = (id) ->
    log "runhistorymodule.indicateCurrentChosenRun"
    id = parseInt(id)
    allRunCells = runHistoryTableSection.querySelectorAll("[run-id]");
    for cell in allRunCells
        cell.classList.remove("chosen")
        if id == parseInt(cell.getAttribute("run-id"))
            cell.classList.add("chosen")


runhistorymodule.buildTable = ->
    log "programverstiontablemodule.buildTable"

    if allModules.appstatemodule.currentProgram
        id = allModules.appstatemodule.currentProgram.id
    else 
        log "we did not have a currentProgram in the appstatemodule"
        runHistoryTableSection.innerHTML = ""
        return 

    tableInner = "<table>"
    tableInner += "<thead>"
    tableInner += "<tr><th>Run History</th></tr>"
    tableInner += "</thead>"
    tableInner += "<tbody>"
    tableInner += "<tr>"

    try runOverview = await allModules.datahandlermodule.getProgramRunOverview(id)
    catch e 
        log e
        return

    runOverview.sort((a,b) -> a.timestemp - b.timestamp)
    
    for run in runOverview
        tableInner += "<td run-id='" + run.programs_runs_id + "'>"
        if run.run_label
            tableInner += run.run_label
        else
            dateObject = new Date()
            dateObject.setTime(run.timestamp)
            tableInner += dateObject.toString()
        tableInner += "</td>"

    tableInner += "</tr>"
    tableInner += "</tbody>"
    tableInner += "</table>"

    runHistoryTableSection.innerHTML = tableInner

    tableElements = runHistoryTableSection.getElementsByTagName("td")
    for el in tableElements
        el.addEventListener("click", tableElementClick)
    
    ## just for testing
    # runOverviewString = JSON.stringify(runOverview)
    # runHistoryTableSection.textContent = runOverviewString



#endregion

export default runhistorymodule
