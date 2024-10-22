[CmdletBinding()]
param (
    [string]$printerNameUpstairs,
    [string]$printerNameDownstairs
)

$currentUser = (whoami).Split('\\')[1]
$printerSyncFilePath = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\printerSyncConfig.txt"
$defaultPrinter = ''
$printerLocationDownstairs = "onthaal"
$printerLocationUpstairs = "bureau"
$validPrinters = Get-Printer | Select-Object -ExpandProperty Name
$stringOfValidPrinterNames = (Get-Printer | Select-Object -ExpandProperty Name| ForEach-Object {"`"$($_)`""}) -join ', '

function IsValidPrinter {
    param (
        [string]$printerName
    )
    return $validPrinters -contains $printerName
}

# 1. Validate printer name arguments
if (-not (IsValidPrinter -printerName $printerNameUpstairs)) {
    do {
        $printerNameUpstairs = Read-Host "Please enter a valid printer name for $printerLocationUpstairs ($($stringOfValidPrinterNames))"
    } while (-not (IsValidPrinter -printerName $printerNameUpstairs))
}

if (-not (IsValidPrinter -printerName $printerNameDownstairs)) {
    do {
        $printerNameDownstairs = Read-Host "Please enter a valid printer name for $printerLocationDownstairs ($($stringOfValidPrinterNames))"
    } while (-not (IsValidPrinter -printerName $printerNameDownstairs))
}

# 2. Validate filepath
if (Test-Path $printerSyncFilePath)  {
    Write-Verbose "printerSyncFilePath.txt file path OK"
} else {
    Write-Verbose "Error: the printerSyncFilePath.txt file does not exist ($printerSyncFilePath)"
    exit
}

# 3. Retrieve printer name from printerSyncFile and set default Printer
$printerLocation = Get-Content $printerSyncFilePath
if ($printerLocation -eq $printerLocationDownstairs) {
    $defaultPrinter = $printerNameDownstairs 

} elseif ($printerLocation -eq $printerLocationUpstairs) {
    $defaultPrinter = $printerNameUpstairs
} else {
    Write-Verbose "Printer location from SyncConfig.txt does not match printerLocation variables in script"
    return
}

(New-Object -ComObject WScript.Network).SetDefaultPrinter($defaultPrinter)
