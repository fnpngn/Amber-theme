$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Install-WindowsTerminalTheme{
    param(
        [Parameter(Mandatory=$true)]
        [string]$ThemeFileName,
        
        [Parameter(Mandatory=$true)]
        [string]$FragmentFolderName
    )    
    
    # Set up directory paths
    $ThemeFilePath = Join-Path -Path $ScriptDir -ChildPath $ThemeFileName

    if (-not (Test-Path -Path $ThemeFilePath)) {
        Write-Host "ERROR: Theme file '$ThemeFileName' not found next to the script." -ForegroundColor Red
        Write-Host "Expected location: $ThemeFilePath" -ForegroundColor Red
        pause
        exit 1
    }

    $FragmentsRoot = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\Windows Terminal\Fragments"
    $TargetFolder = Join-Path -Path $FragmentsRoot -ChildPath $FragmentFolderName
    $TargetFile = Join-Path -Path $TargetFolder -ChildPath $ThemeFileName

    Write-Host ""
    Write-Host "Theme file : $ThemeFilePath"
    Write-Host "Install to : $TargetFile"
    Write-Host ""

    # Create the Fragments folder structure if it doesn't exist
    try {
        if (-not (Test-Path -Path $TargetFolder)) {
            Write-Host "Creating folder: $TargetFolder"
            New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
        }
    }
    catch {
        Write-Host "ERROR: Could not create folder: $TargetFolder" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        pause
        exit 1
    }

    try {
        Copy-Item -Path $ThemeFilePath -Destination $TargetFile -Force
        Write-Host "Theme installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Could not copy theme file." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        pause
        exit 1
    }

    try {
        $jsonContent = Get-Content -Path $TargetFile -Raw | ConvertFrom-Json
    }
    catch {
        Write-Host "WARNING: The JSON file might be invalid. Windows Terminal may not load it." -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
}


Install-WindowsTerminalTheme -ThemeFileName "Amber-theme.json" -FragmentFolderName "FNV-Amber"
Install-WindowsTerminalTheme -ThemeFileName "Green-theme.json" -FragmentFolderName "FO3-Green"

Write-Host ""
Write-Host "Restart ALL OPEN terminal windows and apply theme in Settings->Profiles/Defaults"
Write-Host ""

pause