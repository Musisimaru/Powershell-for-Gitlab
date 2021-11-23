﻿function Get-GitlabIssues {
  [CmdletBinding()]
  param (
    [Parameter()]
    [System.Int32]
    $ProjectId,

    [Parameter()]
    [System.Int32]
    $UserId,

    [Parameter()]
    [ValidateSet('closed', 'opened')]
    [System.String]
    $State
  )

  BEGIN {
    $projects = New-Object 'System.Collections.Generic.HashSet[PSCustomObject]'
    $filters = New-Object 'System.Collections.Generic.HashSet[System.String]'

    if ($ProjectId -ne $null -and $ProjectId -ne 0) {
      Write-Debug "Project `"$ProjectId`""
      $project = $null
      $project = Get-GitlabProject -Id $ProjectId
      if ($null -eq $project) { throw "Project with id $ProjectId is doesn't exist"; }
      $quiet = $projects.Add($project);
    }
    else {
      $projects = Get-GitlabProject
    }

    if (-not [System.String]::IsNullOrEmpty($State)) {
      Write-Debug "State `"$State`""
      $quiet = $filters.Add("state=$State");
    }

    if ($UserId -ne $null -and $UserId -ne 0) {
      Write-Debug "User `"$UserId`""
      $quiet = $filters.Add("assignee_id=$UserId");
    }



    $ret = New-Object System.Collections.Generic.HashSet[PSCustomObject]
  }
  PROCESS {
    foreach ($project in $projects.GetEnumerator()) {
      Write-Debug "$($project.id) - $($project.name)";
      if ($filters.Count -eq 0) {
        [System.Collections.Generic.HashSet[PSCustomObject]] $issues = Get-GitlabAllSubItems -EntityName projects -EntityId $($project.id) -SubEntityName issues
      }
      else {
        [System.Collections.Generic.HashSet[PSCustomObject]] $issues = Get-GitlabAllSubItems -EntityName projects -EntityId $($project.id) -SubEntityName issues -Filters $filters
      }
      if ($issues.Count -ne 0) {
        $ret.UnionWith($issues);
      }
    }
  }
  END {
    return $ret;
  }
}
