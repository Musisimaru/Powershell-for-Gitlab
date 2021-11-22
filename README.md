# Powershell-for-Gitlab
Powershell commands for Gitlab API

## Settings
To work with these cmdlets, you need to set two global variables:
```powershell
$Global:GITLAB_API_URL = "https://gitlab.somedomain.com/api/v4"
$Global:GITLAB_PRIVATE_TOKEN = "you_private_api_token"
```

## Projects commands
* Get-GitlabProject
* Get-GitlabCurrentProject
* Set-GitlabProjectVisibility

## Users Commands
* Get-GitlabUser
* Get-GitlabSSHKey
* Get-GitlabGPGKey
* Get-GitlabUserActivities