<#
.SYNOPSIS
    Removes the "Convert to MP4" right-click context menu entry
    installed by install-context-menu.ps1.
#>

$ErrorActionPreference = "Stop"
$regBase = "HKCU:\Software\Classes\SystemFileAssociations\.mov\shell\ConvertToMP4"

if (Test-Path $regBase) {
    Remove-Item -Path $regBase -Recurse -Force
    Write-Host "Uninstalled the 'Convert to MP4' context menu entry." -ForegroundColor Green
} else {
    Write-Host "Context menu entry not found; nothing to do."
}
