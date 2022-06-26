Param(
    [string] $compareHash = $null
)

#Computes the hash of the CAB directories
# and then computes a summary has based on those hashes.
# The results are written to the Hash.txt and AllHash.txt files.


Set-StrictMode -Version  3.0

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

#Checks if folders exist.  If not, writes out the missing files to the console.
function Test-FoldersExist($folders) {

    $i=0

    $pathTestResult = Test-Path $folders | % {
        [PSCustomObject]@{
            Exists = $_
            Folder = $folders[$i]
        }
        $i++
    } | ? {$_.Exists -eq $false }

    if($pathTestResult)
    {
        foreach($pathResult in $pathTestResult)
        {
            Write-Host "[ERROR] Missing Folder: " $pathResult.Folder
        }
        return $false
    }
    return $true
}

#Check script is running in the Battletech\Mods folder
if((Get-Location).path -notmatch ".+\\BATTLETECH\\Mods$")
{
    Wait-KeyPress "[ERROR] Please run this script from the Battletech\Mods folder"
    return
    
}

#Check ModTek exists
if((Test-Path ModTek) -ne $true)
{
    Wait-KeyPress "[ERROR] The ModTek folder cannot be found.  Ensure this script is executed from the BATTLETECH\Mods directory"
    return
}

$stopWatch = New-Object "System.Diagnostics.Stopwatch"
$stopWatch.Start()

$rootPath = ""
$hashFileName = $rootPath + "Hash.txt"
$allHashFileName = $rootPath + "AllHash.txt"

#reset the output files
Out-File $hashFileName
Out-File $allHashFileName

$cabFolders = @('.\CAB-Clan Mech\', '.\CAB-CU\', '.\CAB-IS Mech\', '.\CAB-Misc\')

#Check for all cab folders exists
if((Test-FoldersExist $cabFolders)  -eq $false)
{
    Wait-KeyPress
    return
}

"Collecting CAB file names..."

$currentDirectory = (Get-Location).Path + "\"

#Get the hash of all the files
gci -Recurse -File -Path $cabFolders | Sort-Object -property FullName | % {
    

        #Only show the user updates every 100 ms
        if($stopWatch.ElapsedMilliseconds -gt 100)
        {
            Write-Host $_.FullName.Replace($currentDirectory, "") " " $_.Length
            $stopWatch.Restart()
        }

        #Hash the file, return the hash and the file relative to the current directory.  Otherwise the full has will be different for each user.
        return $_ | Get-FileHash | %{$_.Hash + "`t" + $_.Path.Replace($currentDirectory, "")} 
} >> $hashFileName

#Create the hash summary based on the hashes of all files.
$allFilesHash = Get-FileHash -Path $hashFileName | %{$_.Hash} 
$allFilesHash > $allHashFileName

#Show results
"Summary Hash"
$allFilesHash

if($compareHash -and ($compareHash -ne $allFilesHash)) {
    "[ERROR] Hash does not match."
    $compareHash + " expected"
}
else {
    "[Success] Hash matched"
}

Wait-KeyPress

