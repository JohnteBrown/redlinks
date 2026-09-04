param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('initialize','add','remove','list','lookup')]
    [string]$Action,

    [string]$Name,
    [string]$Path,
    [string]$OutputFile
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$dbPath = Join-Path $repoRoot 'keys\keys.sqlite3'
$sqlDir = Join-Path $repoRoot 'keys\sql'

if (-not (Test-Path $dbPath)) {
    New-Item -ItemType File -Path $dbPath -Force | Out-Null
}

$createTable = Join-Path $sqlDir 'create-links-table.sql'
if (Test-Path $createTable) {
    & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath ".read '$createTable'" | Out-Null
}

function Escape-SqlValue {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

switch ($Action) {
    'add' {
        $sql = Get-Content (Join-Path $sqlDir 'add-link.sql') -Raw
        $sql = $sql.Replace('__NAME__', (Escape-SqlValue $Name))
        $sql = $sql.Replace('__PATH__', (Escape-SqlValue $Path))
        & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-Null
    }
    'remove' {
        $sql = Get-Content (Join-Path $sqlDir 'remove-link.sql') -Raw
        $sql = $sql.Replace('__NAME__', (Escape-SqlValue $Name))
        & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-Null
    }
    'list' {
        $sql = Get-Content (Join-Path $sqlDir 'list-links.sql') -Raw
        if ($OutputFile) {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-File -Encoding utf8 $OutputFile
        } else {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql
        }
    }
    'lookup' {
        $sql = Get-Content (Join-Path $sqlDir 'find-link.sql') -Raw
        $sql = $sql.Replace('__NAME__', (Escape-SqlValue $Name))

        if ($OutputFile) {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-File -Encoding utf8 $OutputFile
        } else {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql
        }
    }
}
