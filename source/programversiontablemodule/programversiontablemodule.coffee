programversiontablemodule = {name: "programversiontablemodule", uimodule: true}
############################################################
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["programversiontablemodule"]?  then console.log "[programversiontablemodule]: " + arg
    return
ostr = (o) -> JSON.stringify(o, null, 4)
olog = (o) -> log "\n" + ostr(o)

############################################################
programVersionTableSection  = null

############################################################
programversiontablemodule.initialize = () ->
    log "programversiontablemodule.initialize"
    programVersionTableSection = document.getElementById("program-version-table-section")
    programversiontablemodule.buildTable()
    return

############################################################
#region internalFunctions
tableElementClick = (event) ->
    target = event.target
    id = target.getAttribute("programs-dynamic-id")    
    if id
        allModules.actionhistorymodule.startAction()
        allModules.datahandlermodule.selectProgramById(id)
        allModules.actionhistorymodule.endAction()
################################################################################
# Layer 0 UI Event Handler Functions
################################################################################

#endregion

############################################################
#region exposedFunctions
programversiontablemodule.indicateCurrentChosenProgram = (id) ->
    log "programversiontablemodule.indicateCurrentChosenProgram"
    id = parseInt(id)
    allProgramCells = programVersionTableSection.querySelectorAll("[programs-dynamic-id]");
    for cell in allProgramCells
        cell.classList.remove("chosen")
        if id == parseInt(cell.getAttribute("programs-dynamic-id"))
            cell.classList.add("chosen")
         

programversiontablemodule.buildTable = ->
    log "programversiontablemodule.buildTable"    
    
    try
        programsOverview = await allModules.datahandlermodule.getProgramsOverview()
        # log "received ProgramsOverview"
        # olog programsOverview
        staticProgramData = await allModules.datahandlermodule.getStaticProgramData()
        # log "recevied StaticProgramData"
        # olog staticProgramData
        # await allModules.datahandlermodule.getLangStrings()
        # log "returned from getting the langstrings ;-)"
    catch e
        log e
        return 

    # log JSON.stringify(programsOverview)

    programRows = {}
    programNames = {}
    rowsIndex = 0
    version = 0

    for program in programsOverview
        # log JSON.stringify(program)
        rowsIndex = program.programs_static_id
        rowObject = programRows[rowsIndex]
        if !rowObject?
            programRows[rowsIndex] = {}
            rowObject = programRows[rowsIndex]
        
        version = program.version
        columnObject = rowObject[version]
        if columnObject? 
            alert("double version! wtf?")
            throw "up"
        rowObject[version] = program


    for data in staticProgramData
        key = data.programs_static_id
        programNames[key] = data.namekey

    htmlTable = "<table>"
    htmlTable += "<thead>"
    htmlTable += "<tr><th>Name</th><th class='actives'> aktiv</th></tr>"
    htmlTable += "</thead>"
    htmlTable += "<tbody>"
    tableInner = ""
    for key,versions of programRows
        programName = allModules.datahandlermodule.languageTextForKey(programNames[key])
        tableInner += "<tr><td>" + programName + ": </td>" #TODO print here recognizable label 
        activeCell = ""
        rowData = ""
        #for static program
        for innerKey,program of versions
            # log JSON.stringify(program)
            if program.version_label?
                versionLabel = program.version_label
            else
                versionLabel = "" + program.version

            rowData += "<td programs-dynamic-id='" + program.programs_dynamic_id + "'>" + versionLabel + "</td>"
            if program.is_active
                activeCell += "<td class='actives'>" + versionLabel + "</td>"


        tableInner += activeCell
        tableInner += rowData
        tableInner += "</tr>"

    htmlTable += tableInner
    htmlTable += "</tbody>"
    htmlTable += "</table>"

    programVersionTableSection.innerHTML = htmlTable

    ##add click Event to specific program version
    tableElements = programVersionTableSection.getElementsByTagName("td")
    for el in tableElements
        el.addEventListener("click", tableElementClick)

    if allModules.appstatemodule.currentProgram? and allModules.appstatemodule.currentProgram.id?
        chosenId = parseInt(allModules.appstatemodule.currentProgram.id) 
        programversiontablemodule.indicateCurrentChosenProgram(chosenId)

#endregion

export default programversiontablemodule
