function Get-GitlabIssues {
  [CmdletBinding()]
  param (
    [Parameter()]
    [System.Int32]
    $ProjectId,

    [Parameter()]
    [System.Int32]
    $UserId,

    [Parameter()]
    [System.Int32]
    $IterationId,

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

    if ($IterationId -ne $null -and $IterationId -ne 0) {
      Write-Debug "Iteration `"$IterationId`""
      $quiet = $filters.Add("iteration_id=$IterationId");
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


function Get-GitlabIssueRelatedMRs {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId,

    [Parameter(Mandatory)]
    [System.Int32]
    $issueId
  )

  Write-Debug "$ProjectId - $issueId";
  $ret = Get-GitlabSubSubItems -EntityName projects -EntityId $ProjectId -SubEntityName issues -SubEntityId $issueId -SubSubEntityName related_merge_requests
  return $ret;
}

function Get-GitlabIssueClosedByMRs {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId,

    [Parameter(Mandatory)]
    [System.Int32]
    $issueId
  )

  Write-Debug "$ProjectId - $issueId";
  $ret = Get-GitlabSubSubItems -EntityName projects -EntityId $ProjectId -SubEntityName issues -SubEntityId $issueId -SubSubEntityName closed_by
  return $ret;
}

function Push-NewGitlabIssue(){
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId,

    [Parameter(Mandatory)]
    [System.Object]
    $newIssue
  )

  BEGIN {
    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/projects/$ProjectId/issues")
    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }
    $ret = $null
  }
  PROCESS {
    Write-Debug "uri: $($uri.ToString())"
    $ret = Invoke-WebRequest -Method Post -Uri $uri.ToString() -Body $newIssue -Headers $headers
  }
  END{
    return $($ret.Content | ConvertFrom-Json);
  }
}