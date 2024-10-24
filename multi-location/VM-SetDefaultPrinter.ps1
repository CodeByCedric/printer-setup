$currentUser = (whoami).Split('\\')[1]

$printerSyncDirectory = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\"
$printerSyncFileName= "printerSyncConfig.txt"
$printerSyncFilePath = $printerSyncDirectory + $printerSyncFileName 

$validPrinters = Get-Printer | Select-Object -ExpandProperty Name

# 1. Validate filepath
if (Test-Path $printerSyncFilePath)  {
    Write-Verbose "printerSyncFilePath.txt file path OK"
} else {
    Write-Verbose "Error: the printerSyncFilePath.txt file does not exist ($printerSyncFilePath)"
    return
}

# 2. Get printername
$defaultPrinter = Get-Content $printerSyncFilePath

# 3. Validate printer
if ($validPrinters -contains $defaultPrinter) {
    Write-Verbose "Provided default printer is installed"
} else {
    $stringOfValidPrinterNames = ($validPrinters | ForEach-Object {"`"$($_)`""}) -join ', '
    Write-Verbose "Provided default printer from $printerSyncFileName ($defaultPrinter) does not exist, i.e.: $stringOfValidPrinterNames"
    return
}

# 4. Set default printer
try {
    (New-Object -ComObject WScript.Network).SetDefaultPrinter($defaultPrinter)
}
catch {
    Write-Verbose "Error setting default printer: $_"
}
