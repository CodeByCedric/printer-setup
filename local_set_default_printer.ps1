    [CmdletBinding()]
    param (
        [string]$displayMacAddress
    )

    # Variables
    $currentUser = (whoami).Split('\\')[1]
    $printerSyncDirectory = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\"
    $printerSyncFileName = "printerSyncConfig.txt"
    $printerLocationDownstairs = "onthaal"
    $printerLocationUpstairs = "bureau"
    $networkAdapters = Get-NetAdapter
    $macAddressFound = $false
    $regexMacAddressPattern = '^[0-9A-Fa-f]{2}([-:])[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}\1[0-9A-Fa-f]{2}$'
    $validMacAddresses = (Get-NetAdapter | Select-Object -Property Name, MacAddress | ForEach-Object {"$($_.Name): $($_.MacAddress)"}) -join "`n"

    function Test-MacAddress {
        param (
            [string]$macAddress
        )
        return $macAddress -match $regexMacAddressPattern
    }

    Write-Verbose "Starting script with parameters:"

    # Paramater validation
    if (-not (Test-MacAddress -macAddress $displayMacAddress)) {
        do {
            $displayMacAddress = Read-Host "$($validMacAddresses)`nPlease provide a valid MAC-Address from the list above"
        } while (-not (Test-MacAddress -macAddress $displayMacAddress))
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
        Write-Verbose "Error creating the printer config directory: $_"
        exit
    }

    foreach ($adapter in $networkAdapters) {
        if ($adapter.MacAddress -eq $displayMacAddress) {
            $macAddressFound = $true
            break
        }
    }
        Write-Verbose "MAC-Address found: $macAddressFound"

    if ($macAddressFound) {
        Set-Content -Path $printerSyncDirectory\$printerSyncFileName -Value $printerLocationDownstairs
        Write-Verbose "Printer sync file content set to '$printerLocationDownstairs'"
    } else {
        Set-Content -Path $printerSyncDirectory\$printerSyncFileName -Value $printerLocationUpstairs
        Write-Verbose "Printer sync file content set to '$printerLocationUpstairs'"
    }