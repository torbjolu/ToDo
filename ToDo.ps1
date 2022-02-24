#'C:\todo\Todo.json' must be created befor you run the application
# Remember to save your work with option "5: Save ToDo-list."

#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

$FilePath = 'C:\todo\ToDo.json'
$Today = Get-Date -Format "dd/MM/yyyy"

function ImportFile ($FilePath){
$Data = Get-Content -Path $FilePath -Force
Return [PSCustomObject] ($Data | ConvertFrom-Json)
}

function ValidateResponse([String]$String,[Hashtable]$Choice){

If($Choice.GetEnumerator().Name.contains($String)){

    Return [ScriptBlock]::create('{0}' -f ($Choice.$String))
}

else {
 Return [ScriptBlock]{Write-Host "Choose a number from the menu" -ForegroundColor Red; ShowMenu}
    }
}
#Shows a menu of choices. Possible choices are create, change, and delete a task, and show the ToDo-list and save the ToDo-list to file. 
function ShowMenu(){
    param ()

    Write-Host "1: Create a new task."
    Write-Host "2: Change a task."
    Write-Host "3: Delete a task."
    Write-Host "4: Show ToDo-list."
    Write-Host "5: Save ToDo-list."
    
    $Response = Read-Host -Prompt 'Select a number from the menu'
    Invoke-Command -ScriptBlock (ValidateResponse -String $Response -Choice $Choice)
}
#Create a new task, prompts for Name, Description, Due Date, Importance and if it's complete.
function NewTask(){

 $TaskName = Read-Host -Prompt 'Task Name'
 $TaskDesc = Read-Host -Prompt 'Decription'
 $TaskDueDate = Read-Host -Prompt 'Due Date (dd.mm.yyyy)'
 $TaskImportance = Read-Host -Prompt 'Importance (Low - Med - High)'
 $Complete = Read-Host -Prompt 'Complete?'

 [PSCustomObject[]]$ToDoList = $Global:ToDoList

 $ToDoList += [PsCustomObject]@{
 
 'Task Name' = $TaskName
 'Description' = $TaskDesc
 'Due Date' = $TaskDueDate
 'Importance' = $TaskImportance
 'Created' = $CreatedDate = $Today
 'Complete'= $Complete
 }
 Set-Variable -Name ToDoList -Value $ToDoList -Scope Global

 ShowMenu
}
#Change the attributes of a task, prompts for which task to change, and prompts for the new values
function ChangeTask(){

 $OldTaskName = Read-Host -Prompt 'Which task do you want to change?'
 $TaskName = Read-Host -Prompt 'Task Name'
 $TaskDesc = Read-Host -Prompt 'Decription'
 $TaskDueDate = Read-Host -Prompt 'Due Date (dd.mm.yyyy)'
 $TaskImportance = Read-Host -Prompt 'Importance'
 $Complete = Read-Host -Prompt 'Complete'


 If
($Global:ToDoList.'Task Name'.Contains($OldTaskName)){
    [PSCustomObject[]]$ToDoList = $Global:ToDoList.where{$_.'Task Name' -ne $OldTaskName}

    $ToDoList += [PsCustomObject]@{
 
     'Task Name' = $TaskName
     'Description' = $TaskDesc
     'Due Date' = $TaskDueDate
     'Importance' = $TaskImportance
     'Created' = $CreatedDate = $Today
     'Complete'= $Complete
}

Set-Variable -Name ToDoList -Value $ToDoList -Scope Global
}
Else
{Write-Host ('Change task failed. Could not find taskname {0} ' -f ($OldTaskName)) -ForegroundColor Red}


ShowMenu
} 

#Delete task, prompts the user for the name of the task
function DeleteTask(){
$TaskName = (Read-Host -Prompt 'TaskName')

If
($ToDoList.'Task Name'.Contains($TaskName)){
    [PSCustomObject[]]$ToDoList = $ToDoList.where{$_.'Task Name' -ne $TaskName}

    Set-Variable -Name ToDoList -Value $ToDoList -Scope Global
}

Else
{Write-Host 'Deleta task failed. Could not find task'$TaskName -ForegroundColor Red}

ShowMenu
}

#Output the ToDo-list to terminal
function ShowToDoList(){
$ToDoList | Format-Table

ShowMenu
}

#Save the current ToDo-list with prompt for file path and file name. File type .json must be specified.
function SaveToDoList(){
 $FilePath = Read-Host -Prompt 'File Path'
 $FileName = Read-Host -Prompt 'File Name.json'
 
 New-Item -Path $FilePath -Name $FileName -ItemType File -Force -Value ($ToDoList | ConvertTo-Json -Depth 1)
 
 ShowMenu
 }

 #List of choices 
 $Choice = [Hashtable]@{

 [String]'1' = {NewTask}
 [String]'2' = {ChangeTask}
 [String]'3' = {DeleteTask}
 [String]'4' = {ShowToDoList}
 [String]'5' = {SaveToDoList}
 }
 

 #Create ToDoList

 if(!($FilePath)){
 [PsCustomObject[]]$Global:ToDoList = @()
 }
 else {[PsCustomObject[]]}$Global:ToDoList = (ImportFile  -Filepath $FilePath)

 ShowMenu