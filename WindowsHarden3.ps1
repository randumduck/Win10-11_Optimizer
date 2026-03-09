# Disable unnecessary services
$services = @(
    "DiagTrack", "dmwappushservice", "WMPNetworkSvc", "Fax", "XblGameSave", "XboxNetApiSvc"
)
foreach ($service in $services) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Stop-Service -Name $service -Force
        Set-Service -Name $service -StartupType Disabled
        Write-Output "Stopped and disabled service: $service"
    } else {
        Write-Output "Service not found: $service"
    }
}

# Remove bloatware apps
$bloatwareApps = @(
    "Microsoft.3DBuilder", "Microsoft.BingWeather", "Microsoft.GetHelp", "Microsoft.Getstarted",
    "Microsoft.Messaging", "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection", "Microsoft.MicrosoftStickyNotes", "Microsoft.MixedReality.Portal",
    "Microsoft.Office.OneNote", "Microsoft.OneConnect", "Microsoft.People", "Microsoft.Print3D",
    "Microsoft.SkypeApp", "Microsoft.StorePurchaseApp", "Microsoft.WindowsAlarms", "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI", "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay", "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo"
)
foreach ($app in $bloatwareApps) {
    $package = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
    if ($package) {
        Remove-AppxPackage -Package $package.PackageFullName -ErrorAction SilentlyContinue
        Write-Output "Removed app: $app"
    } else {
        Write-Output "App not found: $app"
    }
}

# Apply security settings
# Disable SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Write-Output "Disabled SMBv1"

# Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Write-Output "Enabled Windows Defender"

# Enable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Write-Output "Enabled firewall"

# Disable remote assistance
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0
Write-Output "Disabled remote assistance"

# Disable unnecessary scheduled tasks
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
)
foreach ($task in $tasks) {
    if (Get-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue) {
        Disable-ScheduledTask -TaskPath $task
        Write-Output "Disabled scheduled task: $task"
    } else {
        Write-Output "Scheduled task not found: $task"
    }
}

Write-Output "System hardening complete. Please review the changes and restart your machine."