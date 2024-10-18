# TODO: checking for valid printers on the local machine is not valid... REFACTOR
# TODO: printer selection is not necessary here, only location of laptop

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
$validMacAddresses = (Get-NetAdapter | Select-Object -Property Name, MacAddress | ForEach-Object {"$($_.Name): $($_.MacAddress)"}) -join "`n"

function Validate-MacAddress {
    param (
        [string]$macAddress
    )
    return $macAddress -match $regexMacAddressPattern
}

Write-Verbose "Starting script with parameters:"

# Paramater validation
if (-not (Validate-MacAddress -macAddress $displayMacAddress)) {
    do {
        $displayMacAddress = Read-Host "$($validMacAddresses)`nPlease provide a valid MAC-Address from the list above"
    } while (-not (Validate-MacAddress -macAddress $displayMacAddress))
}

Write-Verbose "Display MAC-Address: $displayMacAddress"


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