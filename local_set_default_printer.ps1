[CmdletBinding()]
param (
    [string]$displayMacAddress,
    [string]$printerNameUpstairs,
    [string]$printerNameDownstairs
)

Write-Verbose "Starting script with parameters:
Display MAC-Address: $displayMacAddress
Printer name upstairs: $printerNameUpstairs
Printer name downstairs: $printerNameDownstairs"

if (-not $displayMacAddress) {
    Write-Host "Please provide a MAC address as an argument."
    exit
}

if (-not $printerNameUpstairs) {
    Write-Host "Please provide the upstairs printer's name as an argument."
    exit
}

if (-not $printerNameDownstairs) {
    Write-Host "Please provide the downstairs printer's name as an argument."
    exit
}

$currentUser = (whoami).Split('\\')[1]
$printerConfigDirectoryPath = "C:\Users\"+$currentUser+"\OneDrive - Office 365 GPI\printer\"
$networkAdapters = Get-NetAdapter
$macAddressFound = $false

if (-not (Test-Path $printerConfigDirectoryPath)) {
    New-Item -Path $printerConfigDirectoryPath -ItemType Directory
    $printerConfigDirectory = Get-Item $printerConfigDirectoryPath
    $printerConfigDirectory.Attributes = $printerConfigDirectory.Attributes -bor 'Hidden'
    Write-Verbose "Printer Config Directory created at $printerConfigDirectory and set to hidden"
} else {
    Write-Verbose "Printer Config Directory found at $printerConfigDirectoryPath"
}

foreach ($adapter in $networkAdapters) {
    if ($adapter.MacAddress -eq $displayMacAddress) {
        $macAddressFound = $true
        break
    } else {    }
}

if ($macAddressFound) {
    Set-Content -Path $printerConfigDirectoryPath\printerConfig.txt -Value $printerNameDownstairs
    Write-Verbose "Printer set to $printerNameDownstairs"
} else {
    Set-Content -Path $printerConfigDirectoryPath\printerConfig.txt -Value $printerNameDownstairs
    Write-Verbose "Printer set to $printerNameUpstairs"
}