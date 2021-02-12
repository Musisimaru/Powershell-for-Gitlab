function Get-GitlabUser{
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Int32]
        $Id,

        # Is Current User
        [Parameter()]
        [Switch]
        $CurrentUser
    )
    if($CurrentUser){
        $ret = Get-GitlabItems -EntityName user
        return $ret
    }
    
    $ret = Get-GitlabItems -EntityName users -EntityId $Id
    return $ret
}

function Get-GitlabSSHKey {
    param (
        # Is Current User
        [Parameter()]
        [Switch]
        $CurrentUser,

        [Parameter()]
        [System.Int32]
        $UserId,

        [Parameter()]
        [System.Int32]
        $KeyId
    )
    if($CurrentUser){
        if($KeyId){
            $ret = Get-GitlabItems -EntityName user -SubPath "keys/$KeyId"
            return $ret    
        }

        $ret = Get-GitlabItems -EntityName user -SubPath keys
        return $ret
    }

    $ret = Get-GitlabAllSubItems -EntityName users -EntityId $UserId -SubEntityName keys
    return $ret
}

function Get-GitlabGPGKey {
    param (
        # Is Current User
        [Parameter()]
        [Switch]
        $CurrentUser,

        [Parameter()]
        [System.Int32]
        $UserId,

        [Parameter()]
        [System.Int32]
        $KeyId
    )
    if($CurrentUser){
        if($KeyId){
            $ret = Get-GitlabItems -EntityName user -SubPath "gpg_keys/$KeyId"
            return $ret    
        }

        $ret = Get-GitlabItems -EntityName user -SubPath gpg_keys
        return $ret
    }

    $ret = Get-GitlabAllSubItems -EntityName users -EntityId $UserId -SubEntityName gpg_keys
    return $ret
}

function Get-GitlabUserActivities {
    Get-GitlabItems -EntityName user -SubPath activities
}