[CmdletBinding()]
param (
    [string]$printerNameUpstairs,
    [string]$printerNameDownstairs
)

$currentUser = (whoami).Split('\\')[1]
$printerSyncFilePath = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\printerSyncConfig.txt"
$printer = ''
$validPrinters = Get-Printer | Select-Object -ExpandProperty Name
$stringOfValidPrinterNames = (Get-Printer | Select-Object -ExpandProperty Name| ForEach-Object {"`"$($_)`""}) -join ', '

# 1. Validate filepath
# 2. Retrieve printer name from file
# 3. Verify if printer name from file equals installed printers
# 4. 


# Optional: modify syncfile to contain existing VM printers

function Validate-PrinterName {
    param (
        [string]$printerName
    )
    return $validPrinters -contains $printerName
}

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


# Check if printerSyncFilePath.txt exists and set printer variable
try {
    if (Test-Path $printerSyncFilePath) {
        Write-Verbose "printerSyncFilePath.txt file path OK"
        $printer = Get-Content $printerSyncFilePath
    } else {
        Write-Verbose "Error: the printerSyncFilePath.txt file does not exist ($printerSyncFilePath)"
        return
    }
} catch {
    Write-Output "Error retrieving the printerSyncFilePath.txt file: $_"
    return
}

# Check printerSyncFilePath.txt content
try {
    if (-not [string]::IsNullOrEmpty($printer)) {
        $printer = Get-Content $printerSyncFilePath
        Write-Verbose "Printer name retrieved: $printer"
    } else {
        Write-Verbose "printerSyncFilePath.txt isNullOrEmpty: $_"
    }} catch {
        Write-Verbose "Error retrieving printerSyncFilePath.txt content: $_"
        return
    }

# Check if printer exists
if ((Get-CimInstance -Class Win32_Printer -Filter "Name='$printer'") -and ($printer -eq $printerNameUpstairs -or $printer -eq $printerNameDownstairs)) {
    Write-Verbose "Printer $printer exists"
} else {
    Write-Verbose "Incorrect Printer Provided: $printer'"
}


# Start FileSystemWatcher
Write-Verbose "Starting FileSystemWatcher:"

# Try to create the FileSystemWatcher
try {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = Split-Path $printerSyncFilePath
    $watcher.Filter = "printerSyncFilePath.txt"
    $watcher.EnableRaisingEvents = $true
    Write-Verbose "FileSystemWatcher created successfully."
} catch {
    Write-Verbose "Error creating FileSystemWatcher: $_"
    return
}

# Define the action to take when the file changes
$action = {
    Write-Verbose "File change detected! Preparing to check content..."
    Start-Sleep -Seconds 1
    try {
        if (-not [string]::IsNullOrEmpty($printerSyncFilePath) -and (Test-Path $printerSyncFilePath)) {
            $newContent = Get-Content $printerSyncFilePath
            Write-Verbose "New file content: $newContent"
            if ($newContent -eq "OneNote") {
                Write-Verbose "Setting OneNote printer as default."
                (New-Object -ComObject WScript.Network).SetDefaultPrinter($newContent)
            } elseif ($newContent -eq "Fax") {
                Write-Verbose "Setting Fax printer as default."
                (New-Object -ComObject WScript.Network).SetDefaultPrinter($newContent)
            } else {
                Write-Verbose "Error: Unrecognized printer name in file content."
            }
        } else {
            Write-Verbose "Error: File path is null or does not exist."
        }
    } catch {
        Write-Verbose "Error reading file content or setting printer: $_"
    }
}


# Register the event for the Changed event
try {
    $job = Register-ObjectEvent $watcher Changed -Action $action
    Write-Verbose "Event registered successfully. Job ID: $($job.Id)"
} catch {
    Write-Verbose "Error with event registration: $_"
    return
}

# Check the job status periodically
while ($true) {
    $jobStatus = Get-Job -Id $job.Id
    Write-Verbose "Monitoring file changes... (Job Status: $($jobStatus.State))"
    
    if ($jobStatus.State -eq 'Running') {
        Write-Verbose "Event job is running."
    } elseif ($jobStatus.State -eq 'NotStarted') {
        Write-Verbose "Event job is not started yet."
    } elseif ($jobStatus.State -eq 'Completed' -or $jobStatus.State -eq 'Failed') {
        Write-Verbose "Event job has stopped or failed. Exiting..."
        break
    }

    Start-Sleep -Seconds 5
}