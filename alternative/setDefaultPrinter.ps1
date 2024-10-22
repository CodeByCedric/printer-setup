# Variables
$currentUser = (whoami).Split('\\')[1]
$networkAdapters = Get-NetAdapter

$scriptName = "setDefaultPrinter.ps1"
$scriptDirectory = "c:\psscripts\"
$scriptFilePath = $scriptDirectory + $scriptName

$printerSyncDirectory = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\"
$printerSyncFilename= "printerSyncConfig.txt"
$printerSyncFilePath = $printerSyncDirectory + $printerSyncFilename 

$printerToMacAddressTable = @{
    "OneNote" = @("AC-DE-48-00-11-22", "A4-7B-9C-93-A9-FG")
    "Fax" = @("00-14-22-01-23-45", "08-00-27-12-34-56")
    "\\sp-5452-snlx\Verhoor-2" = @("F4-6B-8C-92-B8-FD")
    "\\sp-5452-cm00801.bpolb.eu\PRINTWG49" = @("")
    "\\sp-5452-cm00801.bpolb.eu\PRINTWG51" = @("")
    "\\sp-5452-cm00801.bpolb.eu\PRINTWI49" = @("")
    "\\sp-5452-cm00801.bpolb.eu\PRINTWI51" = @("")
    "\\sp-5452-cm00801.bpolb.eu\PRINTWJ49" = @("")
    "\\sp-5452-cm00801.bpolb.eu\PRINTWJ51" = @("")
}

# Test directories and filepaths
try {
    if (-not (Test-Path $scriptFilePath)) {
        Write-Verbose "Error with $scriptFilePath"
        return
    }
    if (-not (Test-Path $printerSyncDirectory)) {
        [void](New-Item -Path $printerSyncDirectory -ItemType Directory -ErrorAction Stop)
        $printerSyncDirectory.Attributes = $printerSyncDirectory.Attributes -bor 'Hidden'
    }
} catch {
    Write-Verbose "Error in filedirectory/filedirectories: $_"
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