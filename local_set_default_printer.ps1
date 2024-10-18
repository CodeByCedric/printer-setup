param (
    [string]$displayMacAddress,
    [string]$printerNameUpstairs,
    [string]$printerNameDownstairs
)

if (-not $DisplayMacAddres) {
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
$printerConfig = "C:\Users\"+$currentUser+"\OneDrive - Office 365 GPI\printer\printerConfig.txt"
$networkAdapters = Get-NetAdapter
$macAddressFound = $false

if (-not (Test-Path $printerConfig)) {
    Write-Host "The file $printerConfig does not exist."
    exit
}

foreach ($adapter in $networkAdapters) {
    if ($adapter.MacAddress -eq $displayMacAddress) {
        $macAddressFound = $true
        break
    }
}

if ($macAddressFound) {
    Set-Content $printerConfig $printerNameUpstairs
} else {
    Set-Content $printerConfig $printerNameDownstairs
}