$currentUser = (whoami).Split('\\')[1]
$printerSyncFilePath = "C:\Users\$currentUser\OneDrive - Office 365 GPI\printer\printerSyncConfig.txt"


try {
    $printer = Get-Content -Path $printerSyncFilePath
} catch {
    Write-Host "Error: $_"
}

if (-not [string]::IsNullOrEmpty($printerConfig) -and (Test-Path $printerConfig)) {
    if ($printerConfig -eq "OneNote") {
        (New-Object -ComObject WScript.Network).SetDefaultPrinter($printer)
    } elseif ($printerConfig -eq "Fax") {
        (New-Object -ComObject WScript.Network).SetDefaultPrinter($printer)
    } else {
        Write-Debug "Incorrect printer"
    }
}
