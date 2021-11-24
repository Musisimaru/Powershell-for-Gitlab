function Get-GitlabMergeRequests {
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
    $AuthorId,

    [Parameter()]
    [ValidateSet('closed', 'opened', 'locked', 'merged')]
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

    if ($AuthorId -ne $null -and $AuthorId -ne 0) {
      Write-Debug "Author `"$AuthorId`""
      $quiet = $filters.Add("author_id=$AuthorId");
    }


    $ret = New-Object System.Collections.Generic.HashSet[PSCustomObject]
  }
  PROCESS {
    foreach ($project in $projects.GetEnumerator()) {
      Write-Debug "$($project.id) - $($project.name)";
      if ($filters.Count -eq 0) {
        [System.Collections.Generic.HashSet[PSCustomObject]] $mrs = Get-GitlabAllSubItems -EntityName projects -EntityId $($project.id) -SubEntityName merge_requests
      }
      else {
        [System.Collections.Generic.HashSet[PSCustomObject]] $mrs = Get-GitlabAllSubItems -EntityName projects -EntityId $($project.id) -SubEntityName merge_requests -Filters $filters
      }
      if ($mrs.Count -ne 0) {
        $ret.UnionWith($mrs);
      }
    }
  }
  END {
    return $ret;
  }
}

function Get-GitlabMergeRequestNotes {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId,

    [Parameter()]
    [System.Int32]
    $MergeRequestId,

    [Parameter()]
    [System.Int32]
    $NoteId
  )

  BEGIN {
    $projects = New-Object 'System.Collections.Generic.HashSet[PSCustomObject]'
    $mrs = New-Object 'System.Collections.Generic.HashSet[PSCustomObject]'

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

    if ($MergeRequestId -ne $null -and $MergeRequestId -ne 0) {
      Write-Debug "Merge Request `"$MergeRequestId`""
      $mr = $null
      $mr = Get-GitlabSubItems -EntityName projects -EntityId $ProjectId -SubEntityName merge_requests -SubEntityId $MergeRequestId
      if ($null -eq $mr) { throw "Merge request with id $MergeRequestId in project $ProjectId is doesn't exist"; }
      $quiet = $mrs.Add($mr);
    }
    else {
      foreach ($project in $projects.GetEnumerator()) {
        Write-Debug "$($project.id) - $($project.name)";
        if ($filters.Count -eq 0) {
          [System.Collections.Generic.HashSet[PSCustomObject]] $projectMRs = Get-GitlabAllSubItems -EntityName projects -EntityId $($project.id) -SubEntityName merge_requests
        }
        else {
          [System.Collections.Generic.HashSet[PSCustomObject]] $projectMRs = Get-GitlabAllSubItems -EntityName projects -EntityId $($project.id) -SubEntityName merge_requests -Filters $filters
        }
        if ($projectMRs.Count -ne 0) {
          $mrs.UnionWith($projectMRs);
        }
      }
    }

    $ret = New-Object System.Collections.Generic.HashSet[PSCustomObject]
  }
  PROCESS {
    foreach ($mr in $mrs.GetEnumerator()) {
      Write-Debug "$($mr.iid) - $($mr.title)";
      [System.Collections.Generic.HashSet[PSCustomObject]] $notes = Get-GitlabSubSubItems -EntityName projects -EntityId $($mr.project_id) -SubEntityName merge_requests -SubEntityId $($mr.iid) -SubSubEntityName notes

      if ($notes.Count -ne 0) {
        $ret.UnionWith($notes);
      }
    }
  }
  END {
    return $ret;
  }
}
