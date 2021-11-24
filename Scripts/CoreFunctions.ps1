if (-not $(Test-Path "Variable:GITLAB_API_URL")) {
  $Global:GITLAB_API_URL = [System.String]::Empty;
}
if (-not $(Test-Path "Variable:GITLAB_PRIVATE_TOKEN")) {
  $Global:GITLAB_PRIVATE_TOKEN = [System.String]::Empty;
}

function Get-Encoded([System.Object] $inputObject) {
  #Write-Debug "Input object count: $($inputObject.Count)"
  $jsonString = ($inputObject | ConvertTo-Json)
  #Write-Debug $jsonString

  $encodedJsonString = [System.Text.Encoding]::Utf8.GetString([System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($jsonString)).replace("�", "x").replace("\u0085", "")
  #Write-Debug $encodedJsonString

  $outputObject = ConvertFrom-Json $encodedJsonString
  return $outputObject
}

function Get-GitlabItemsCount {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits')]
    [System.String]
    $EntityName,

    # Filter for request
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [System.String[]]
    $Filters
  )

  BEGIN {
    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }

    $getParams = @(
      "all=true"
      , "per_page=1"
    )

    if ($null -ne $Filters -and $Filters.Count -ne 0) {
      $getParams = $getParams + $Filters
    }

    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/$EntityName/")
    $uri.Query = [System.String]::Join("&", $getParams)

  }
  PROCESS {
    $response = Invoke-WebRequest -Method Get -Uri $uri.ToString() -Headers $headers
  }
  END {
    if ($response.StatusCode -ne 200) { return $null; }
    $countTotal = $response.Headers.'X-Total'

    return [System.Int32]::Parse($countTotal);
  }
}


function Get-GitlabItems {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'user', 'merge_requests', 'commits')]
    [System.String]
    $EntityName,

    # Id sigle entity in System
    [Parameter()]
    [System.Int32]
    $EntityId,

    # SubPath for query string
    [Parameter()]
    [System.String]
    $SubPath,

    # Filter for request
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [System.String[]]
    $Filters
  )

  BEGIN {
    Write-Debug "GITLAB_API_URL: $GITLAB_API_URL"
    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/$EntityName");

    if ($EntityId) {
      $uri.Path += "/$EntityId";
    }

    if (-not [System.String]::IsNullOrWhiteSpace($SubPath)) {
      $uri.Path += "/$SubPath"
    }

    Write-Debug "Path $($uri.Path)"

    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }

    $page = 1
    $pagesCount = 1

    $ret = New-Object System.Collections.Generic.HashSet[PSObject]
  }
  PROCESS {
    do {
      Write-Debug "Page: $page; Count: $pagesCount;"
      $getParams = @(
        "all=true"
        , "per_page=100"
        , "page=$page"
      )

      if ($null -ne $Filters -and $Filters.Count -ne 0) {
        $getParams = $getParams + $Filters
      }

      $uri.Query = [System.String]::Join("&", $getParams)

      $response = Invoke-WebRequest -Method Get -Uri $uri.ToString() -Headers $headers
      if ($response.StatusCode -ne 200) { return $null; }

      $projectsOnPage = Get-Encoded $response.Content | ConvertFrom-Json
      $projectsOnPage | ForEach-Object {
        $q = $ret.Add($_)
      }

      $pagesCount = $response.Headers.'X-Total-Pages'

    }while (++$page -le $pagesCount)
  }
  END {
    return $ret
  }
}

function Get-GitlabAllSubItems {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits')]
    [System.String]
    $EntityName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits', 'keys', 'gpg_keys', 'memberships', 'repository/branches', 'environments')]
    [System.String]
    $SubEntityName,

    [Parameter(Mandatory)]
    [System.Int32]
    $EntityId,

    # Filter for request
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [System.String[]]
    $Filters
  )

  BEGIN {
    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/$entityName/$EntityId/$SubEntityName")
    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }

    $page = 1
    $pagesCount = 1

    $ret = New-Object System.Collections.Generic.HashSet[PSObject]
  }
  PROCESS {
    do {
      Write-Debug "Page: $page; Count: $pagesCount;"
      $getParams = @(
        "all=true"
        , "per_page=100"
        , "page=$page"
      )

      if ($null -ne $filters -and $filters.Count -ne 0) {
        $getParams = $getParams + $filters
      }

      $uri.Query = [System.String]::Join("&", $getParams)

      Write-Debug "uri: $($uri.ToString())"

      $response = Invoke-WebRequest -Method Get -Uri $uri.ToString() -Headers $headers
      if ($response.StatusCode -ne 200) { return $null; }

      $projectsOnPage = Get-Encoded $response.Content | ConvertFrom-Json
      $projectsOnPage | % {
        $q = $ret.Add($_)
      }

      $pagesCount = $response.Headers.'X-Total-Pages'

    }while (++$page -le $pagesCount)
  }
  END {
    return $ret
  }
}

function Get-GitlabSubItems {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits')]
    [System.String]
    $EntityName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits', 'keys', 'gpg_keys', 'memberships', 'repository/branches', 'environments')]
    [System.String]
    $SubEntityName,

    [Parameter(Mandatory)]
    [System.Int32]
    $EntityId,

    [Parameter()]
    [System.Int32]
    $SubEntityId,

    # Filter for request
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [System.String[]]
    $Filters
  )

  BEGIN {
    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/$entityName/$EntityId/$SubEntityName")
    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }

    if ($SubEntityId) {
      $uri.Path += "/$SubEntityId";
    }

    $page = 1
    $pagesCount = 1

    $ret = New-Object System.Collections.Generic.HashSet[PSObject]
  }
  PROCESS {
    do {
      Write-Debug "Page: $page; Count: $pagesCount;"
      $getParams = @(
        "all=true"
        , "per_page=100"
        , "page=$page"
      )

      if ($null -ne $filters -and $filters.Count -ne 0) {
        $getParams = $getParams + $filters
      }

      $uri.Query = [System.String]::Join("&", $getParams)

      Write-Debug "uri: $($uri.ToString())"

      $response = Invoke-WebRequest -Method Get -Uri $uri.ToString() -Headers $headers
      if ($response.StatusCode -ne 200) { return $null; }

      $projectsOnPage = Get-Encoded $response.Content | ConvertFrom-Json
      $projectsOnPage | % {
        $q = $ret.Add($_)
      }

      $pagesCount = $response.Headers.'X-Total-Pages'

    }while (++$page -le $pagesCount)
  }
  END {
    return $ret
  }
}



function Push-GitlabSubItemsAction {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits')]
    [System.String]
    $EntityName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'merge_requests', 'commits', 'keys', 'gpg_keys', 'memberships', 'repository/branches', 'environments')]
    [System.String]
    $SubEntityName,

    [Parameter(Mandatory)]
    [System.Int32]
    $EntityId,

    [Parameter(Mandatory)]
    [object]
    $SubEntityId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('stop')]
    [System.String]
    $ActionName
  )

  BEGIN {
    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/$entityName/$EntityId/$SubEntityName")
    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }

    if($SubEntityId -and -not ($SubEntityId -is [System.Int32] -or $SubEntityId -is [System.String])){
      throw "SubEntityId must be have type Int32 or String";
    }

    if ($SubEntityId) {
      $uri.Path += "/$SubEntityId";
    }

    $uri.Path += "/$ActionName";

    $ret = New-Object System.Collections.Generic.HashSet[PSObject]
  }
  PROCESS {
    do {
      Write-Debug "uri: $($uri.ToString())"

      $response = Invoke-WebRequest -Method Post -Uri $uri.ToString() -Headers $headers
      if ($response.StatusCode -ne 200) { return $null; }

      $projectsOnPage = Get-Encoded $response.Content | ConvertFrom-Json
      $projectsOnPage | ForEach-Object {
        $q = $ret.Add($_)
      }

      $pagesCount = $response.Headers.'X-Total-Pages'

    }while (++$page -le $pagesCount)
  }
  END {
    return $ret
  }
}


function Set-GitlabApiUrl([System.String] $url) {
  $uri = New-Object System.URI($url);
  if (-not ($uri.LocalPath.Contains('/api/v4'))) {
    throw "Url $url is not correct. Must contain `"/api/v4`"";
  }

  $Global:GITLAB_API_URL = $url;
}

function Set-Token([System.String] $token) {
  $Global:GITLAB_PRIVATE_TOKEN = $token;
}

function Test-GitCmdEnvPath {
  $path = $env:Path.Split(";") | where { $_.ToLower().Contains('git\cmd') }
  return $path.Length -gt 0;
}


function Find-GitlabItems {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('projects', 'groups', 'epics', 'issues', 'milestones', 'todos', 'events', 'users', 'user', 'merge_requests', 'commits')]
    [System.String]
    $Scope,

    # Filter for request
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [System.String[]]
    $SearchString
  )

  BEGIN {
    Write-Debug "GITLAB_API_URL: $GITLAB_API_URL"
    $uri = New-Object System.UriBuilder("$GITLAB_API_URL/search");

    Write-Debug "Path $($uri.Path)"

    $headers = @{
      "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
    }

    $getParams = @(
      "scope=$Scope"
      , "search=$SearchString"
    )

    $ret = New-Object System.Collections.Generic.HashSet[PSObject]
  }
  PROCESS {
    $uri.Query = [System.String]::Join("&", $getParams)

    $response = Invoke-WebRequest -Method Get -Uri $uri.ToString() -Headers $headers
    if ($response.StatusCode -ne 200) { return $null; }

    $responseItems = Get-Encoded $response.Content | ConvertFrom-Json
    $responseItems | ForEach-Object {
      $q = $ret.Add($_)
    }
  }
  END {
    return $ret
  }
}

