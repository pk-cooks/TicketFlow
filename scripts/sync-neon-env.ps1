#Requires -Version 5.1
<#
.SYNOPSIS
    Derives Spring Boot datasource variables from Neon's connection URL.

.DESCRIPTION
    `neon env pull` writes DATABASE_URL and DATABASE_URL_UNPOOLED into the
    gitignored .env.local (or .env) file. Spring Boot needs a JDBC URL plus
    credentials in separate properties, so this script converts the direct
    (non-pooled) URL into DB_URL, DB_USERNAME and DB_PASSWORD and updates the
    same file. Run it again whenever the Neon password or branch changes.

.EXAMPLE
    .\scripts\sync-neon-env.ps1

.EXAMPLE
    .\scripts\sync-neon-env.ps1 -UsePooled
#>
[CmdletBinding()]
param(
    [string]$EnvFile,
    [switch]$UsePooled
)

$root = Split-Path -Parent $PSScriptRoot

if (-not $EnvFile) {
    foreach ($candidate in @((Join-Path $root '.env.local'), (Join-Path $root '.env'))) {
        if (Test-Path $candidate) {
            $EnvFile = $candidate
            break
        }
    }
}

if (-not $EnvFile -or -not (Test-Path $EnvFile)) {
    throw "No .env.local or .env found in $root. Run 'neon env pull' first."
}

function Get-EnvValue {
    param([string]$Name)

    $match = Select-String -Path $EnvFile -Pattern ("^{0}=(.*)$" -f [regex]::Escape($Name)) | Select-Object -First 1
    if (-not $match) {
        return $null
    }

    $value = $match.Matches[0].Groups[1].Value.Trim()
    if ($value.Length -ge 2 -and
        (($value.StartsWith('"') -and $value.EndsWith('"')) -or
         ($value.StartsWith("'") -and $value.EndsWith("'")))) {
        $value = $value.Substring(1, $value.Length - 2)
    }
    return $value
}

$sourceKey = if ($UsePooled) { 'DATABASE_URL' } else { 'DATABASE_URL_UNPOOLED' }
$rawUrl = Get-EnvValue $sourceKey
if (-not $rawUrl) {
    $sourceKey = 'DATABASE_URL'
    $rawUrl = Get-EnvValue $sourceKey
}
if (-not $rawUrl) {
    throw "No DATABASE_URL(_UNPOOLED) found in $EnvFile."
}

$uri = [Uri]$rawUrl
$port = if ($uri.Port -gt 0) { ':' + $uri.Port } else { '' }
$query = if ($uri.Query) { $uri.Query } else { '' }
$jdbcUrl = 'jdbc:postgresql://{0}{1}{2}{3}' -f $uri.Host, $port, $uri.AbsolutePath, $query

$separator = $uri.UserInfo.IndexOf(':')
if ($separator -lt 1) {
    throw 'DATABASE_URL is missing credentials (user:password@host).'
}

$username = [Uri]::UnescapeDataString($uri.UserInfo.Substring(0, $separator))
$password = [Uri]::UnescapeDataString($uri.UserInfo.Substring($separator + 1))

$derived = [ordered]@{
    DB_URL      = $jdbcUrl
    DB_USERNAME = $username
    DB_PASSWORD = $password
}

$lines = @(Get-Content -Path $EnvFile) |
    Where-Object { $_ -notmatch '^(DB_URL|DB_USERNAME|DB_PASSWORD)=' }
foreach ($name in $derived.Keys) {
    $lines += '{0}={1}' -f $name, $derived[$name]
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($EnvFile, $lines, $utf8NoBom)

Write-Host "Wrote DB_URL, DB_USERNAME and DB_PASSWORD to $EnvFile (source: $sourceKey)"
