$pathes = [Environment]::GetEnvironmentVariable("PSModulePath");
$path = $pathes -split [IO.Path]::PathSeparator | Where-Object { $_.ToLower().contains('users') }

if($path -is [array]){
  $path = $path[0]
}

$path = Join-Path $path "powershell-for-gitlab"
Remove-Item -Recurse -Force $path -ErrorAction Ignore -Verbose

$root = Join-Path $PSScriptRoot ".."
Copy-Item -Path (Join-Path $root "Scripts") -Destination (Join-Path $path "Scripts") -Recurse -Verbose
Copy-Item -Path (Join-Path $root "powershell-for-gitlab.psd1") -Destination $path -Verbose
