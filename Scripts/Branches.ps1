function CheckOut-GitlabBranch {
  [CmdletBinding()]
  param (
    [Parameter()]
    [System.Int32]
    $MR
  )

  BEGIN {
    if (-not $(Test-GitCmdEnvPath)) {
      throw "You have no git app found in your environment variable.`r`nYou can download the application at the link https://git-scm.com/downloads";
    }

    $project = Get-GitlabCurrentProject
    if (-not $project) {
      throw "No gitlab project"
    }

    $originBranchName = $null
  }
  PROCESS {
    $mergeRequest = Get-GitlabSubItems -EntityName projects -EntityId $($project.id) -SubEntityName merge_requests -SubEntityId 206
    $branchName = $mergeRequest.source_branch
    $originBranchName = "origin/$branchName"
  }
  END {
    git fetch origin
    git checkout -b $branchName $originBranchName
  }
}

function Get-GitlabAllBranches {
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId
  )

  $ret = Get-GitlabAllSubItems -EntityName projects -SubEntityName 'repository/branches' -EntityId $ProjectId

  return $ret
}

function Get-GitlabBranch {
  param (
    [Parameter(Mandatory)]
    [System.Int32]
    $ProjectId,

    [Parameter(Mandatory)]
    [System.String]
    $BranchName
  )

  $ret = Get-GitlabSubItems -EntityName projects -SubEntityName 'repository/branches' -EntityId $ProjectId -SubEntityId 'develop'

  return $ret
}