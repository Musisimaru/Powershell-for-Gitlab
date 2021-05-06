function Get-GitlabAllEnvironments {
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId
  )

  $ret = Get-GitlabAllSubItems -EntityName projects -EntityId $ProjectId -SubEntityName 'environments'

  return $ret
}

function Get-GitlabAvailableEnvironments {
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId
  )

  $ret = Get-GitlabAllSubItems -EntityName projects -EntityId $ProjectId -SubEntityName 'environments' -Filters @('states=available')

  return $ret
}

function Get-GitlabStoppedEnvironments {
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId
  )

  $ret = Get-GitlabAllSubItems -EntityName projects -EntityId $ProjectId -SubEntityName 'environments' -Filters @('states=stopped')

  return $ret
}

function Stop-GitlabEnvironment {
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId,

    [Parameter(Mandatory)]
    [System.Int32]
    $EnvironmentId
  )

  $ret = Push-GitlabSubItemsAction -EntityName projects -EntityId $ProjectId -SubEntityName 'environments' -SubEntityId $EnvironmentId -ActionName stop

  return $ret
}
