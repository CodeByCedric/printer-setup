param (
    [string]$displayMacAddress,
    [string]$printerNameUpstairs,
    [string]$printerNameDownstairs
)

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
}

foreach ($adapter in $networkAdapters) {
    if ($adapter.MacAddress -eq $displayMacAddress) {
        $macAddressFound = $true
        break
    }
}

if ($macAddressFound) {
    Set-Content -Path $printerConfigDirectoryPath\printerConfig.txt -Value $printerNameDownstairs
} else {
    Set-Content -Path $printerConfigDirectoryPath\printerConfig.txt -Value $printerNameDownstairs
}