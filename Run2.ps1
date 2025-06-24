Add-Type -AssemblyName System.Windows.Forms


# Ensure full (long) path
function Get-LongPath {
    param ([string]$path)
    $shell = New-Object -ComObject Scripting.FileSystemObject
    if ($shell.FileExists($path)) {
        return $shell.GetFile($path).Path
    }
    elseif ($shell.FolderExists($path)) {
        return $shell.GetFolder($path).Path
    }
    else {
        return $path  # fallback
    }
}


function Safe-Delete {
    param (
        [string]$Path,
        [int]$MaxRetries = 5,
        [int]$DelaySeconds = 2
    )

    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            if (Test-Path $Path) {
                Remove-Item -Path $Path -Force -ErrorAction Stop
            }
            return
        } catch {
            Start-Sleep -Seconds $DelaySeconds
        }
    }

}

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


# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Options"
$form.Width = 300
$form.Height = 350
$form.StartPosition = "CenterScreen"

# Create checkboxes
$checkbox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.Text = "Install 7Zip"
$checkbox1.AutoSize = $true
$checkbox1.Location = New-Object System.Drawing.Point(30,30)

$checkbox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.Text = "Install AnyDesk"
$checkbox2.AutoSize = $true
$checkbox2.Location = New-Object System.Drawing.Point(30,60)

$checkbox3 = New-Object System.Windows.Forms.CheckBox
$checkbox3.Text = "Install Firefox"
$checkbox3.AutoSize = $true
$checkbox3.Location = New-Object System.Drawing.Point(30,90)

$checkbox4 = New-Object System.Windows.Forms.CheckBox
$checkbox4.Text = "Install Google Chrome"
$checkbox4.AutoSize = $true
$checkbox4.Location = New-Object System.Drawing.Point(30,120)

$checkbox5 = New-Object System.Windows.Forms.CheckBox
$checkbox5.Text = "Install Qnap Qsync"
$checkbox5.AutoSize = $true
$checkbox5.Location = New-Object System.Drawing.Point(30,150)

$checkbox6 = New-Object System.Windows.Forms.CheckBox
$checkbox6.Text = "Run Windows Debloater"
$checkbox6.AutoSize = $true
$checkbox6.Location = New-Object System.Drawing.Point(30,210)

$checkbox7 = New-Object System.Windows.Forms.CheckBox
$checkbox7.Text = "Run Windows Debloater with Options"
$checkbox7.AutoSize = $true
$checkbox7.Location = New-Object System.Drawing.Point(30,240)

$checkbox8 = New-Object System.Windows.Forms.CheckBox
$checkbox8.Text = "Install Adobe Reader"
$checkbox8.AutoSize = $true
$checkbox8.Location = New-Object System.Drawing.Point(30,180)





# Create OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "OK"
$okButton.Location = New-Object System.Drawing.Point(30,270)
$okButton.Add_Click({
    $form.Close()
})




# Add controls to form
$form.Controls.Add($checkbox1)
$form.Controls.Add($checkbox2)
$form.Controls.Add($checkbox3)
$form.Controls.Add($checkbox4)
$form.Controls.Add($checkbox5)
$form.Controls.Add($checkbox6)
$form.Controls.Add($checkbox7)
$form.Controls.Add($checkbox8)
$form.Controls.Add($okButton)

# Show the form
$form.ShowDialog() | Out-Null







#####################################################
# Execute code based on selections

######################################################








if ($checkbox1.Checked) {
    Write-Output "Installing 7Zip"
# Download and silently install latest 7-Zip (exe version)
$zipUrl = "https://www.7-zip.org/a/7z2200-x64.exe"  # Update as needed
$tempZip = Join-Path $env:TEMP "7z_setup.exe"

Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip

Start-Process -FilePath $tempZip -ArgumentList "/S" -Wait

$longTempPath = Get-LongPath $tempZip
Safe-Delete -Path $longTempPath -Force

}







if ($checkbox2.Checked) {
    Write-Output "Installing Anydesk"
# --- AnyDesk Install ---
$anydeskUrl = "https://download.anydesk.com/AnyDesk.exe"
$tempExe = Join-Path $env:TEMP "AnyDesk.exe"

Invoke-WebRequest -Uri $anydeskUrl -OutFile $tempExe

Start-Process -FilePath $tempExe -ArgumentList "--install `"C:\Program Files (x86)\AnyDesk`" --start-with-win --create-desktop-icon --silent" -Wait

Safe-Delete -Path $tempExe -Force

}






if ($checkbox3.Checked) {
    Write-Output "Installing Firefox"
    # --- Firefox Install ---
$installerUrl = "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US"
$tempExe = Join-Path $env:TEMP "FirefoxSetup.exe"
$installExe = "$env:ProgramFiles\Mozilla Firefox\firefox.exe"

Invoke-WebRequest -Uri $installerUrl -OutFile $tempExe

Start-Process -FilePath $tempExe -ArgumentList "/S" -Wait

# Wait for install to finish
for ($i = 0; $i -lt 60; $i++) {
  Start-Sleep -Seconds 2
  if (Test-Path $installExe) { break }
}
Safe-Delete -Path $tempExe -Force

}
 






if ($checkbox4.Checked) {
    Write-Output "Installing Google Chrome"
# --- Chrome Install ---
$msiUrl = "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
$tempMsi = Join-Path $env:TEMP "chrome_installer.msi"

Invoke-WebRequest -Uri $msiUrl -OutFile $tempMsi

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempMsi`" /qn /norestart" 

Safe-Delete -Path $tempMsi -Force

}







if ($checkbox5.Checked) {
    Write-Output "Installing Qnap Qsync"
    # --- CONFIG ---
$downloadPage = "https://www.qnap.com/en-us/utilities/essentials"
$tempDir = "$env:TEMP\QsyncSetup"
$installerExe = "$tempDir\QNAPQsyncClientWindows.exe"
$targetExe = "$env:ProgramFiles\QNAP\Qsync\Qsync.exe"  # typical install path

# Create temp folder
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Download the installer
Write-Host "Downloading Qsync installer..."
Invoke-WebRequest -Uri $downloadPage -OutFile "$tempDir\page.html"

# Extract the installer link
$link = Select-String -Path "$tempDir\page.html" -Pattern "QNAPQsyncClientWindows-.*?\.exe" |
    ForEach-Object { ($_ -split '"')[1] } | Select-Object -First 1

if (-not $link) {
    Write-Error "❌ Could not find Qsync .exe link on the page."
    exit 1
}

Invoke-WebRequest -Uri $link -OutFile $installerExe

# Run installer silently (installer handles background process)
Start-Process -FilePath $installerExe -ArgumentList "/S" -NoNewWindow
Write-Host "Installer started..."

# --- WAIT FOR INSTALL COMPLETION ---
$maxWait = 120
For ($i = 0; $i -lt $maxWait; $i++) {
    if (Test-Path $targetExe) {
        Start-Sleep -Seconds 5
        Write-Host "✅ Qsync installed successfully."
        break
    }
    Start-Sleep -Seconds 1
}

if (-not (Test-Path $targetExe)) {
    Write-Error "❌ Qsync installation did not complete within $maxWait seconds."
}

# --- CLEANUP ---
Safe-Delete -Path $tempDir -Recurse -Force

}







if ($checkbox6.Checked -or $checkbox7.Checked)  {
    Write-Output "Starting Windows Debloater"
    Expand-Archive -path .\Win11Debloat-master.zip -DestinationPath .\Debloat -force
    if ($checkbox6.Checked) {
    .\Debloat\Win11Debloat-master\Win11Debloat.ps1 -Silent -RunDefaults
	}
    if ($checkbox7.Checked) {
    .\Debloat\Win11Debloat-master\Win11Debloat.ps1
	}
    Safe-Delete -Path -Path ".\Debloat" -Recurse -Force
}







if ($checkbox8.Checked) {
# Download and silently install Adobe Reader DC
$readerUrl = "https://get.adobe.com/reader/enterprise/"  # Choose correct exe link
$tempReader = Join-Path $env:TEMP "AcroRdrDC.exe"

Invoke-WebRequest -Uri $readerUrl -OutFile $tempReader

# Silent install flags: /sAll /rs /msi EULA_ACCEPT=YES
Start-Process -FilePath $tempReader -ArgumentList "/sAll", "/rs", "/msi", "EULA_ACCEPT=YES" -Wait

Safe-Delete -Path $tempReader -Force

}
###################################################
pause

if ($checkbox3.Checked -or $checkbox4.Checked)  {
Write-Output "Press any key to add shortcuts to taskbar. Quit otherwise."

#################################################




# --- Config: Add shortcut names here ---
$shortcutNames = @(
    "Google Chrome.lnk",
    "Firefox.lnk"
)








$desktopPath = [Environment]::GetFolderPath('Desktop')

# Localized 'Pin to taskbar' verbs for English and Portuguese
$pinVerbs = @(
    'Pin to Tas&kbar',             # English
    'Fixar na barra de tare&fas'   # Portuguese (Brazil / Portugal)
)

# Create Shell COM object once
$shell = New-Object -ComObject Shell.Application

foreach ($shortcutName in $shortcutNames) {
    $shortcutPath = Join-Path $desktopPath $shortcutName

    # Skip if shortcut doesn't exist
    if (-not (Test-Path $shortcutPath)) {
        continue
    }

    $folder = $shell.Namespace($desktopPath)
    $item = $folder.ParseName($shortcutName)

    foreach ($verbName in $pinVerbs) {
        $verb = $item.Verbs() | Where-Object { $_.Name -eq $verbName }
        if ($verb) {
            $verb.DoIt()
            Write-Host "Pinned '$shortcutName' to taskbar using verb '$verbName'."
            break
        }
    }
}

pause
}