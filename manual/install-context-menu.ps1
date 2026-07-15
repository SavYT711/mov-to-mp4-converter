<#
.SYNOPSIS
    Installs a "Convert to MP4" right-click context menu entry for .mov files,
    without using the packaged installer. Useful if you just cloned the repo
    and want to run the scripts directly.
.DESCRIPTION
    Adds registry entries under HKEY_CURRENT_USER, so it works without
    administrator rights and only affects the current Windows user.
#>

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$batPath = Join-Path $scriptDir "..\src\convert-to-mp4.bat"
$batPath = (Resolve-Path $batPath).Path

$menuName = "ConvertToMP4"
$menuLabel = "Convert to MP4"
$regBase = "HKCU:\Software\Classes\SystemFileAssociations\.mov\shell\$menuName"

New-Item -Path $regBase -Force | Out-Null
Set-ItemProperty -Path $regBase -Name "(default)" -Value $menuLabel
Set-ItemProperty -Path $regBase -Name "Icon" -Value "shell32.dll,-16769"

$commandPath = "$regBase\command"
New-Item -Path $commandPath -Force | Out-Null
$commandValue = "`"$batPath`" `"%1`""
Set-ItemProperty -Path $commandPath -Name "(default)" -Value $commandValue

Write-Host ""
Write-Host "Installed successfully." -ForegroundColor Green
Write-Host "Right-click any .mov file in Explorer and choose 'Convert to MP4'."
Write-Host "(Run uninstall-context-menu.ps1 to remove it.)"
