# TODO Event 4107 does not always trigger, refactor to filesystemwatcher

$currentUser = (whoami).Split('\\')[1]

$printerSyncDirectory = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\"
$printerSyncFileName= "printerSyncConfig.txt"
$printerSyncFilePath = $printerSyncDirectory + $printerSyncFileName 

$validPrinters = Get-Printer | Select-Object -ExpandProperty Name

# Validate filepath
if (Test-Path $printerSyncFilePath)  {
    Write-Verbose "printerSyncFilePath.txt file path OK"
} else {
    Write-Verbose "Error: the printerSyncFilePath.txt file does not exist ($printerSyncFilePath)"
    return
}

# Get printername
$defaultPrinter = Get-Content $printerSyncFilePath

# Validate printer
if ($validPrinters -contains $defaultPrinter) {
    Write-Verbose "Provided default printer is installed"
} else {
    $stringOfValidPrinterNames = ($validPrinters | ForEach-Object {"`"$($_)`""}) -join ', '
    Write-Verbose "Provided default printer from $printerSyncFileName ($defaultPrinter) does not exist, i.e.: $stringOfValidPrinterNames"
    return
}

# Set default printer or run gpupdate to set printer based on policy
try {
    if ($defaultPrinter -eq "Display Not Found") {
        gpupdate /force

    } else {
        (New-Object -ComObject WScript.Network).SetDefaultPrinter($defaultPrinter)
    }
    
}
catch {
    Write-Verbose "Error setting default printer: $_"
}