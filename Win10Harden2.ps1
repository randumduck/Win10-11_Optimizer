# List of unwanted services to stop and disable
$unwantedServices = @(
    "DiagTrack",  # Connected User Experiences and Telemetry
    "dmwappushservice",  # dmwappushsvc
    "MapsBroker",  # Downloaded Maps Manager
    "WMPNetworkSvc"  # Windows Media Player Network Sharing Service
)

# Stop and disable unwanted services
foreach ($service in $unwantedServices) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled
    Write-Output "Stopped and disabled service: $service"
}

# List of unwanted apps to remove
$unwantedApps = @(
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

# Remove unwanted apps
foreach ($app in $unwantedApps) {
    Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
    Write-Output "Removed app: $app"
}

Write-Output "Cleanup completed."