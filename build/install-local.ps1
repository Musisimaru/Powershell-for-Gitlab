$pathes = [Environment]::GetEnvironmentVariable("PSModulePath");
$path = $pathes -split ";" | Where-Object { $_.ToLower().contains('users') }

if($path -is [array]){
  $path = $path[0]
}

$path = "$path\powershell-for-gitlab";
Write-Host "Removing folder $path"
Remove-Item -Recurse -Force $path -ErrorAction Ignore

Write-Host "Copying from  $PSScriptRoot\..\Scripts"
Copy-Item ".\Scripts" -Destination "$path\Scripts" -Recurse
Copy-Item ".\powershell-for-gitlab.psd1" -Destination "$path"
