function global:Get-GitlabProject {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Int32]
        $Id,
        [Parameter()]
        [ValidateSet('user', 'group')]
        [System.String]
        $NamespaceKind  
    )    
    
    $ret = Get-GitlabItems -EntityName projects -EntityId $Id
    if ($NamespaceKind) {
        $ret = $ret | where { $_.namespace.kind -eq $NamespaceKind }
    }
    
    return $ret
}

function global:Set-GitlabProjectVisibility {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Int32]
        $Id,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('private', 'internal', 'public')]
        [System.String]
        $visibility
    )

    BEGIN {
        Write-Debug "GITLAB_API_URL: $GITLAB_API_URL"

        $headers = @{
            "PRIVATE-TOKEN" = $GITLAB_PRIVATE_TOKEN;
        }
    
        $getParams = @(
            "visibility=$visibility"
        )

        $EntityName = 'projects'

        if ($null -ne $Filters -and $Filters.Count -ne 0) {
            $getParams = $getParams + $Filters
        }

        $uri = New-Object System.UriBuilder("$GITLAB_API_URL/$EntityName")
        if ($Id) {
            $uri.Path += "/$Id";
        }
        Write-Debug "Path $($uri.Path)"

        $uri.Query = [System.String]::Join("&", $getParams)

        
    }
    PROCESS {
        Write-Debug $($uri.ToString())
        $resp = Invoke-RestMethod -Method Put  -Uri $uri.ToString() -Headers $headers;
    }
    END {
        return $resp;
    }

}



