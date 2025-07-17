<#
.SYNOPSIS
    Generates a Fluent Bit-compatible sid_map.json file from local or domain user accounts.

.DESCRIPTION
    Queries local or domain-joined user accounts via CIM and exports a JSON dictionary mapping:
        SID → DOMAIN\Username
    This format is used by Fluent Bit's Lua filter to replace raw SIDs with human-readable names in logs.

.OUTPUTS
    Creates sid_map.json in the specified output directory (default: C:\FluentBit)

.EXAMPLE
    .\generate_sid_map.ps1
    Creates or overwrites C:\FluentBit\sid_map.json

    .\generate_sid_map.ps1 -OutputPath "D:\ForgeDemo\sid_map.json"
    Writes sid_map.json to the custom path
#>

param (
    [string]$OutputPath = "C:\FluentBit\sid_map.json"
)

# Ensure the output directory exists
$parentDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $parentDir)) {
    New-Item -Path $parentDir -ItemType Directory -Force | Out-Null
}

Write-Host "Generating SID map file at: $OutputPath"

# Create an empty hash table for the SID map
$map = @{}

# Query all user accounts (local and domain)
Get-CimInstance Win32_UserAccount | ForEach-Object {
    try {
        $sid = $_.SID
        $name = "$($_.Domain)\$($_.Name)"
        $map[$sid] = $name
    } catch {
        Write-Warning "Failed to process user account: $_"
    }
}

# Convert hash to JSON and write it out
$map | ConvertTo-Json -Depth 2 | Set-Content -Encoding UTF8 $OutputPath

Write-Host "✔ SID map created successfully."
