param(
    $noDirCheck = $false
)

#Waits for any key to be pressed
function Wait-KeyPress($prompt = $null)
{
    if($null -ne $prompt)
    {   
        $prompt
    }
    
    "Press Any Key to Continue"
    [System.Console]::ReadKey() > $null
      
}

$currentDir = (Get-Location).path

if(($noDirCheck -eq $false) -and $currentDir -notmatch "\\CaiCache$")
{
    Wait-KeyPress "[ERROR] Please run this script from CAB's CaiCache folder"
    return
}

Push-Location -StackName "working"

#find directories with git repositores
gci -Recurse -Directory -Hidden .git | %{ 
    cd $_.FullName
    cd ..\
    pwd | %{Write-Host -NoNewline $_.Path " "}
    git.exe pull
    Write-Output ""
}

Pop-Location -StackName "working"

Wait-KeyPress