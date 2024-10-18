[CmdletBinding()]
param (
    [string]$displayMacAddress,
    [string]$printerNameUpstairs,
    [string]$printerNameDownstairs
)

# Variables
$currentUser = (whoami).Split('\\')[1]
$printerSyncDirectory = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\"
$printerSyncFileName = "printerSyncConfig.txt"
$networkAdapters = Get-NetAdapter
$macAddressFound = $false
$regexMacAddressPattern = '^[0-9A-Fa-f]{2}([-:])[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}$'
$validPrinters = Get-Printer | Select-Object -ExpandProperty Name
$stringOfValidPrinterNames = (Get-Printer | Select-Object -ExpandProperty Name| ForEach-Object {"`"$($_)`""}) -join ', '
$validMacAddresses = (Get-NetAdapter | Select-Object -Property Name, MacAddress | ForEach-Object {"$($_.Name): $($_.MacAddress)"}) -join "`n"

function Validate-MacAddress {
    param (
        [string]$macAddress
    )
    return $macAddress -match $regexMacAddressPattern
}

function Validate-PrinterName {
    param (
        [string]$printerName
    )
    return $validPrinters -contains $printerName
}

Write-Verbose "Starting script with parameters:"

# Paramater validation
if (-not (Validate-MacAddress -macAddress $displayMacAddress)) {
    do {
        $displayMacAddress = Read-Host "$($validMacAddresses)`nPlease provide a valid MAC-Address from the list above"
    } while (-not (Validate-MacAddress -macAddress $displayMacAddress))
}

Write-Verbose "Display MAC-Address: $displayMacAddress"

if (-not (Validate-PrinterName -printerName $printerNameUpstairs)) {
    do {
        $printerNameUpstairs = Read-Host "Please enter a valid upstairs printer name ($($stringOfValidPrinterNames))"
    } while (-not (Validate-PrinterName -printerName $printerNameUpstairs))
}

Write-Verbose "Printer name upstairs: $printerNameUpstairs"

if (-not (Validate-PrinterName -printerName $printerNameDownstairs)) {
    do {
        $printerNameDownstairs = Read-Host "Please enter a valid downstairs printer name ($($stringOfValidPrinterNames))"
    } while (-not (Validate-PrinterName -printerName $printerNameDownstairs))
}

Write-Verbose "Printer name downstairs: $printerNameDownstairs"


# Script execution
try {
    if (-not (Test-Path $printerSyncDirectory)) {
        [void](New-Item -Path $printerSyncDirectory -ItemType Directory -ErrorAction Stop)
        $printerSyncDirectory = Get-Item $printerSyncDirectory
        $printerSyncDirectory.Attributes = $printerSyncDirectory.Attributes -bor 'Hidden'
        Write-Verbose "Printer Config Directory created at $printerSyncDirectory and set to hidden"
    } else {
        Write-Verbose "Printer Config Directory found at $printerSyncDirectory"
    }
} catch {
    Write-Host "Error creating the printer config directory: $_"
    exit
}

foreach ($adapter in $networkAdapters) {
    if ($adapter.MacAddress -eq $displayMacAddress) {
        $macAddressFound = $true
        break
    }
}

if ($macAddressFound) {
    Set-Content -Path $printerSyncDirectory\$printerSyncFileName -Value $printerNameDownstairs
    Write-Verbose "Printer sync file content set to '$printerNameDownstairs'"
} else {
    Set-Content -Path $printerSyncDirectory\$printerSyncFileName -Value $printerNameUpstairs
    Write-Verbose "Printer sync file content set to '$printerNameUpstairs'"
}