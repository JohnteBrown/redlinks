param(
    [string]$InputFile,
    [string]$OutputFile
)

$redCompiler = "redc"

# I fucking guess $args is reserved in powershell, so we have to use a different variable name for the arguments array. What the fuck.
$args1 = @(
    "-o",
    $OutputFile,
    $InputFile
)

$process = Start-Process `
    -FilePath $redCompiler `
    -ArgumentList $args1 `
    -NoNewWindow `
    -Wait `
    -PassThru

if ($process.ExitCode -ne 0) {
    exit $process.ExitCode
}