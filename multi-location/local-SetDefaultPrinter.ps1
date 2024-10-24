#TODO hoe printer terug naar de policy default plaatsen als mac-address niet gevonden is? 

[CmdletBinding()]
param ()

# Variables
$currentUser = (whoami).Split('\\')[1]
$networkAdapters = Get-NetAdapter

# Set script location in scriptDirectory variable (and scriptName if you have changed it)
$scriptName = "local-SetDefaultPrinter.ps1"
$scriptDirectory = "c:\psscripts\"
$scriptFilePath = $scriptDirectory + $scriptName

$printerSyncDirectory = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\"
$printerSyncFilename= "printerSyncConfig.txt"
$printerSyncFilePath = $printerSyncDirectory + $printerSyncFilename 

# Set the key to which printer needs to be set as the default with the corresponding MAC-Address of the display's MAC-Address
# Set the value to the MAC-Address of the display per printer.  
$printerToMacAddressTable = @{
    "OneNote" = @("AC-DE-48-00-11-22", "A4-7B-9C-93-A9-FG")
    "Fax" = @("00-14-22-01-23-45", "08-00-27-12-34-56")
}

# Test directories and filepaths
try {
    if (-not (Test-Path $scriptFilePath)) {
        Write-Verbose "Error with the script file path or script name: $scriptFilePath`n Does the folder exist and are the variable names correct?"
        return
    }
    else {
        Write-Verbose "Script file path OK"
    }

    if (-not (Test-Path $printerSyncDirectory)) {
        [void](New-Item -Path $printerSyncDirectory -ItemType Directory -ErrorAction Stop)
        $printerSyncDirectory.Attributes = $printerSyncDirectory.Attributes -bor 'Hidden'
    } else {
        Write-Verbose "PrinterSyncDirectory OK"
    }
} catch {
    Write-Verbose "Error in creating directory or setting its attributes: $_"
    return
}

# Iterate over hashtable and find corresponding key for macaddress
foreach ($adapter in $networkAdapters) {
    $macAddress = $adapter.MacAddress.ToUpper()

    foreach ($printer in $printerToMacAddressTable.Keys) {
        if($printerToMacAddressTable[$printer] -contains $macAddress) {
            Set-Content -Path $printerSyncFilePath -Value $printer
            break
        }
    }
}