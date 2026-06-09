# Requires -RunAsAdministrator
# Verify Admin Rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script must be run as an Administrator. Exiting."
    exit
}

Write-Output "Starting Advanced Windows VM Optimization..."

# 1. Disable Unnecessary Services (Leaving SysMain/Superfetch ON, as it helps HDDs)
$services = @(
    "DiagTrack", "dmwappushservice", "WMPNetworkSvc", "Fax", "XblGameSave", "XboxNetApiSvc", "MapsBroker", "lfsvc"
)
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Output "Stopped and disabled service: $service"
    }
}

# 2. Remove Bloatware Apps (Current User & Provisioned/Future Users)
$bloatwareApps = @(
    "Microsoft.3DBuilder", "Microsoft.BingWeather", "Microsoft.GetHelp", "Microsoft.Getstarted",
    "Microsoft.Messaging", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MicrosoftStickyNotes", "Microsoft.MixedReality.Portal",
    "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.People", "Microsoft.Print3D",
    "Microsoft.SkypeApp", "Microsoft.StorePurchaseApp", "Microsoft.WindowsAlarms", "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI", "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo",
    "Microsoft.Todos", "Microsoft.BingNews"
)

Write-Output "Removing Bloatware..."
foreach ($app in $bloatwareApps) {
    # Remove for current user
    Get-AppxPackage -Name "*$app*" -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    # Remove from system image (prevents reinstall on new user creation)
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -match $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 3. Apply Security Settings (Core safety intact)
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Set-MpPreference -DisableRealtimeMonitoring $false
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0
Write-Output "Security baselines applied (Defender and Firewall active)."

# 4. Disable Telemetry & Scheduled Tasks
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\DiskCleanup\SilentCleanup"
)
foreach ($task in $tasks) {
    if (Get-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue) {
        Disable-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue
        Write-Output "Disabled telemetry task: $task"
    }
}

# 5. VM Performance Tweaks (Crucial for HDD performance)
Write-Output "Applying VM-Specific Performance Tweaks..."

# Disable Hibernation (Saves disk space and IO)
powercfg.exe /hibernate off

# Set High-Performance Power Plan
powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable Web Search in Start Menu (Stops Start Menu lag)
$SearchKey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
if (-not (Test-Path $SearchKey)) { New-Item -Path $SearchKey -Force | Out-Null }
Set-ItemProperty -Path $SearchKey -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $SearchKey -Name "CortanaConsent" -Value 0 -Type DWord -Force

$PolicySearchKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $PolicySearchKey)) { New-Item -Path $PolicySearchKey -Force | Out-Null }
Set-ItemProperty -Path $PolicySearchKey -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force

# Disable Background Apps (Stops UWP apps from silently thrashing the disk)
$BackgroundAppKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
if (-not (Test-Path $BackgroundAppKey)) { New-Item -Path $BackgroundAppKey -Force | Out-Null }
Set-ItemProperty -Path $BackgroundAppKey -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force

# Disable visual animations for faster UI response over remote connections
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](90,12,03,80)) -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force

Write-Output "System optimization complete. VM is now hardened and streamlined. A restart is required."
