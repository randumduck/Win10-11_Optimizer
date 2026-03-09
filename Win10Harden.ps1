# Disable unnecessary services
$services = @(
    "DiagTrack", "dmwappushservice", "WMPNetworkSvc", "Fax", "XblGameSave", "XboxNetApiSvc"
)
foreach ($service in $services) {
    Stop-Service -Name $service -Force
    Set-Service -Name $service -StartupType Disabled
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
    Get-AppxPackage -Name $app | Remove-AppxPackage
}

# Apply security settings
# Disable SMBv1
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
# Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
# Enable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Disable remote assistance
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0

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
    Disable-ScheduledTask -TaskPath $task
}

Write-Output "System hardening complete. Please review the changes and restart your machine."