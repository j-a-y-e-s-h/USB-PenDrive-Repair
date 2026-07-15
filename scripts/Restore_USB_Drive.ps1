# Self-elevate to Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   Wiping and Restoring USB PenDrive"
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Wait for the USB drive to be detected dynamically
Write-Host "Waiting for USB drive to be plugged in..." -ForegroundColor Yellow
$usbDisk = $null
while ($null -eq $usbDisk) {
    $usbDisk = Get-Disk | Where-Object { $_.FriendlyName -like "*USB*" -or $_.Model -like "*USB*" -or $_.UniqueId -like "*USBSTOR*" } | Select-Object -First 1
    if ($null -eq $usbDisk) {
        Start-Sleep -Seconds 1
    }
}

$diskNumber = $usbDisk.Number
$diskPath = "\\.\PhysicalDrive$diskNumber"
Write-Host "Found USB drive: Disk $diskNumber ($($usbDisk.FriendlyName))" -ForegroundColor Green
Write-Host ""

# Close Windows Explorer to release locks
Write-Host "Stopping Windows Explorer to release file handles..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

try {
    Write-Host "Opening raw connection to Disk $diskNumber..." -ForegroundColor Yellow
    # Open file handle to raw physical disk to zero out the MBR (Sector 0)
    $fileStream = [System.IO.File]::Open($diskPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
    $buffer = New-Object Byte[] 1048576 # 1MB of zeros
    $fileStream.Write($buffer, 0, $buffer.Length)
    $fileStream.Close()
    Write-Host "Success: Zeroed out MBR sector headers!" -ForegroundColor Green
} catch {
    Write-Host "Error writing raw sectors: $_" -ForegroundColor Red
    Write-Host "Restarting Windows Explorer..."
    Start-Process explorer
    Read-Host "Press Enter to exit"
    exit
}

# Re-initialize the disk cleanly
try {
    Write-Host "Re-initializing partition layout..." -ForegroundColor Yellow
    Clear-Disk -Number $diskNumber -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    Initialize-Disk -Number $diskNumber -PartitionStyle MBR -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    Write-Host "Creating new primary partition..." -ForegroundColor Yellow
    $partition = New-Partition -DiskNumber $diskNumber -UseMaximumSize -AssignDriveLetter
    $driveLetter = $partition.DriveLetter
    Write-Host "Assigned Drive Letter: $driveLetter" -ForegroundColor Green
    Start-Sleep -Seconds 2
    
    Write-Host "Formatting volume to exFAT (Quick)..." -ForegroundColor Yellow
    Format-Volume -DriveLetter $driveLetter -FileSystem exFAT -NewFileSystemLabel "PenDrive" -Force
    Write-Host "Success: Drive formatted to exFAT!" -ForegroundColor Green
} catch {
    Write-Host "Error initializing disk: $_" -ForegroundColor Red
}

# Restart Windows Explorer
Write-Host "Restarting Windows Explorer..." -ForegroundColor Yellow
Start-Process explorer

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "   SUCCESS: USB drive formatted and ready for use!"
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to finish"
