$currentUser = (whoami).Split('\\')[1]
$printerSyncFilePath = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\printerSyncConfig.txt"
$printer = ''

# Check if printerSyncFilePath.txt exists and set printer variable
try {
    if (Test-Path $printerSyncFilePath) {
        Write-Output "printerSyncFilePath.txt file path OK"
        $printer = Get-Content $printerSyncFilePath
    } else {
        Write-Host "Error: the printerSyncFilePath.txt file does not exist ($printerSyncFilePath)"
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
        Write-Host "Printer name retrieved: $printer"
    } else {
        Write-Host "printerSyncFilePath.txt isNullOrEmpty: $_"
    }} catch {
        Write-Host "Error retrieving printerSyncFilePath.txt content: $_"
        return
    }

# Check if printer exists
if ((Get-CimInstance -Class Win32_Printer -Filter "Name='$printer'") -and ($printer -eq 'Fax' -or $printer -eq 'OneNote')) {
   
    Write-Host "Printer $printer exists"
} else {
    Write-Host "Incorrect Printer Provided: $printer'"
}


# Start FileSystemWatcher
Write-Host "Starting FileSystemWatcher:"

# Try to create the FileSystemWatcher
try {
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = Split-Path $printerSyncFilePath
    $watcher.Filter = "printerSyncFilePath.txt"
    $watcher.EnableRaisingEvents = $true
    Write-Host "FileSystemWatcher created successfully."
} catch {
    Write-Host "Error creating FileSystemWatcher: $_"
    return
}

# Define the action to take when the file changes
$action = {
    Write-Host "File change detected! Preparing to check content..."
    Start-Sleep -Seconds 1
    try {
        # Using Get-Content in a safe way with a check for null or empty
        if (-not [string]::IsNullOrEmpty($printerSyncFilePath) -and (Test-Path $printerSyncFilePath)) {
            $newContent = Get-Content $printerSyncFilePath
            Write-Host "New file content: $newContent"
            if ($newContent -eq "OneNote") {
                Write-Host "Setting OneNote printer as default."
                (New-Object -ComObject WScript.Network).SetDefaultPrinter($newContent)
            } elseif ($newContent -eq "Fax") {
                Write-Host "Setting Fax printer as default."
                (New-Object -ComObject WScript.Network).SetDefaultPrinter($newContent)
            } else {
                Write-Host "Error: Unrecognized printer name in file content."
            }
        } else {
            Write-Host "Error: File path is null or does not exist."
        }
    } catch {
        Write-Host "Error reading file content or setting printer: $_"
    }
}


# Register the event for the Changed event
try {
    $job = Register-ObjectEvent $watcher Changed -Action $action
    Write-Host "Event registered successfully. Job ID: $($job.Id)"
} catch {
    Write-Host "Error with event registration: $_"
    return
}

# Check the job status periodically
while ($true) {
    $jobStatus = Get-Job -Id $job.Id
    Write-Host "Monitoring file changes... (Job Status: $($jobStatus.State))"
    
    if ($jobStatus.State -eq 'Running') {
        Write-Host "Event job is running."
    } elseif ($jobStatus.State -eq 'NotStarted') {
        Write-Host "Event job is not started yet."
    } elseif ($jobStatus.State -eq 'Completed' -or $jobStatus.State -eq 'Failed') {
        Write-Host "Event job has stopped or failed. Exiting..."
        break
    }

    Start-Sleep -Seconds 5
}