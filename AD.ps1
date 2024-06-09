# 用户管理：创建、删除、修改用户。
# 组管理：创建、删除、修改组，管理组成员。
# 组织单位 (OU) 管理：创建、删除、修改 OU。
# 组策略管理：创建、删除、修改组策略对象 (GPO)。
# 域控制器管理：管理 FSMO 角色，检查域控制器状态。
# 域信任管理：创建和管理域信任关系。
# 审计和监控：启用和配置审核策略，实时监控 AD 活动。
# 站点和服务管理：管理站点和子网。
# 备份和恢复：AD 数据的备份和恢复。
# 密码策略管理：设置密码策略。
# 锁定策略管理：设置账户锁定策略。
# 审核策略管理：配置审核策略。

# Import Active Directory Module
Import-Module ActiveDirectory

# Function to create a new AD User
function New-ADUserAccount {
    param (
        [string]$UserName,
        [string]$GivenName,
        [string]$Surname,
        [string]$OU,
        [string]$Password
    )
    $SecPassword = ConvertTo-SecureString $Password -AsPlainText -Force
    New-ADUser -Name $UserName -GivenName $GivenName -Surname $Surname -UserPrincipalName "$UserName@yourdomain.com" -Path $OU -AccountPassword $SecPassword -Enabled $true
    Write-Host "User $UserName created successfully."
}

# Function to delete an AD User
function Remove-ADUserAccount {
    param (
        [string]$UserName
    )
    Remove-ADUser -Identity $UserName -Confirm:$false
    Write-Host "User $UserName removed successfully."
}

# Function to modify an AD User
function Set-ADUserAccount {
    param (
        [string]$UserName,
        [string]$GivenName,
        [string]$Surname
    )
    Set-ADUser -Identity $UserName -GivenName $GivenName -Surname $Surname
    Write-Host "User $UserName modified successfully."
}

# Function to create a new AD Group
function New-ADGroupAccount {
    param (
        [string]$GroupName,
        [string]$OU
    )
    New-ADGroup -Name $GroupName -Path $OU -GroupScope Global -GroupCategory Security
    Write-Host "Group $GroupName created successfully."
}

# Function to delete an AD Group
function Remove-ADGroupAccount {
    param (
        [string]$GroupName
    )
    Remove-ADGroup -Identity $GroupName -Confirm:$false
    Write-Host "Group $GroupName removed successfully."
}

# Function to add a member to an AD Group
function Add-ADGroupMember {
    param (
        [string]$GroupName,
        [string]$UserName
    )
    Add-ADGroupMember -Identity $GroupName -Members $UserName
    Write-Host "User $UserName added to group $GroupName successfully."
}

# Function to remove a member from an AD Group
function Remove-ADGroupMember {
    param (
        [string]$GroupName,
        [string]$UserName
    )
    Remove-ADGroupMember -Identity $GroupName -Members $UserName
    Write-Host "User $UserName removed from group $GroupName successfully."
}

# Function to create a new OU
function New-ADOrganizationalUnit {
    param (
        [string]$OUName,
        [string]$Path
    )
    New-ADOrganizationalUnit -Name $OUName -Path $Path
    Write-Host "OU $OUName created successfully."
}

# Function to delete an OU
function Remove-ADOrganizationalUnit {
    param (
        [string]$OUName,
        [string]$Path
    )
    Remove-ADOrganizationalUnit -Identity "OU=$OUName,$Path" -Confirm:$false
    Write-Host "OU $OUName removed successfully."
}

# Function to create a new GPO
function New-ADGroupPolicy {
    param (
        [string]$GPOName,
        [string]$Comment
    )
    $GPO = New-GPO -Name $GPOName -Comment $Comment
    Write-Host "GPO $GPOName created successfully."
    return $GPO
}

# Function to delete a GPO
function Remove-ADGroupPolicy {
    param (
        [string]$GPOName
    )
    Remove-GPO -Name $GPOName
    Write-Host "GPO $GPOName removed successfully."
}

# Function to link GPO to OU
function Link-GPOToOU {
    param (
        [string]$GPOName,
        [string]$OU
    )
    New-GPLink -Name $GPOName -Target $OU
    Write-Host "GPO $GPOName linked to OU $OU successfully."
}

# Function to create a new site
function New-ADSite {
    param (
        [string]$SiteName
    )
    New-ADReplicationSite -Name $SiteName
    Write-Host "Site $SiteName created successfully."
}

# Function to delete a site
function Remove-ADSite {
    param (
        [string]$SiteName
    )
    Remove-ADReplicationSite -Identity $SiteName
    Write-Host "Site $SiteName removed successfully."
}

# Function to create a new subnet
function New-ADSubnet {
    param (
        [string]$Subnet,
        [string]$SiteName
    )
    New-ADReplicationSubnet -Name $Subnet -Site $SiteName
    Write-Host "Subnet $Subnet linked to Site $SiteName successfully."
}

# Function to delete a subnet
function Remove-ADSubnet {
    param (
        [string]$Subnet
    )
    Remove-ADReplicationSubnet -Identity $Subnet
    Write-Host "Subnet $Subnet removed successfully."
}

# Function to create a new trust
function New-ADTrustRelationship {
    param (
        [string]$TrustedDomain,
        [string]$Direction,
        [string]$TrustType,
        [SecureString]$TrustPassword
    )
    New-ADTrust -Name $TrustedDomain -Direction $Direction -TrustType $TrustType -TrustPassword $TrustPassword
    Write-Host "Trust with $TrustedDomain created successfully."
}

# Function to delete a trust
function Remove-ADTrustRelationship {
    param (
        [string]$TrustedDomain
    )
    Remove-ADTrust -Identity $TrustedDomain
    Write-Host "Trust with $TrustedDomain removed successfully."
}

# Function to enable auditing
function Enable-AuditPolicy {
    param (
        [string]$GPOName
    )
    Set-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Policies\Microsoft\Windows\EventLog\Security" -ValueName "MaxSize" -Type DWord -Value 32768
    Write-Host "Audit policy enabled for GPO $GPOName."
}

# Function to disable auditing
function Disable-AuditPolicy {
    param (
        [string]$GPOName
    )
    Remove-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Policies\Microsoft\Windows\EventLog\Security" -ValueName "MaxSize"
    Write-Host "Audit policy disabled for GPO $GPOName."
}

# Function to backup AD
function Backup-AD {
    param (
        [string]$BackupPath
    )
    wbadmin start systemstatebackup -backuptarget:$BackupPath
    Write-Host "Backup started, target path: $BackupPath."
}

# Function to restore AD
function Restore-AD {
    param (
        [string]$BackupPath
    )
    wbadmin start systemstaterecovery -version:$BackupPath
    Write-Host "Restoration started, source path: $BackupPath."
}

# Function to set password policy
function Set-PasswordPolicy {
    param (
        [int]$MinLength,
        [int]$MaxAge,
        [int]$MinAge,
        [int]$HistorySize,
        [bool]$ComplexityEnabled
    )
    Set-ADDefaultDomainPasswordPolicy -MinPasswordLength $MinLength -MaxPasswordAge (New-TimeSpan -Days $MaxAge) -MinPasswordAge (New-TimeSpan -Days $MinAge) -PasswordHistorySize $HistorySize -ComplexityEnabled $ComplexityEnabled
    Write-Host "Password policy set successfully."
}

# Function to set account lockout policy
function Set-AccountLockoutPolicy {
    param (
        [int]$Threshold,
        [int]$ObservationWindow,
        [int]$LockoutDuration
    )
    Set-ADAccountLockoutPolicy -LockoutThreshold $Threshold -LockoutObservationWindow (New-TimeSpan -Minutes $ObservationWindow) -LockoutDuration (New-TimeSpan -Minutes $LockoutDuration)
    Write-Host "Account lockout policy set successfully."
}

# Function to configure audit policy
function Configure-AuditPolicy {
param (
    [string]$Category,
    [string]$Subcategory,
    [string]$Type,
    [string]$AuditedObject,
    [string]$AccessMask,
    [string]$Principal,
    [string]$Level,
    [string]$MatchType,
    [string]$RuleId,
    [string]$FailureAction,
    [string]$SuccessAction
)
    $AuditPolicy = @{
        'Category' = $Category
        'Subcategory' = $Subcategory
        'Type' = $Type
        'AuditedObject' = $AuditedObject
        'AccessMask' = $AccessMask
        'Principal' = $Principal
        'Level' = $Level
        'MatchType' = $MatchType
        'RuleId' = $RuleId
        'FailureAction' = $FailureAction
        'SuccessAction' = $SuccessAction
    }
    Set-AdlAuditPolicy -AuditPolicy $AuditPolicy
    Write-Host "Audit policy configured successfully."
}

# Main Menu
function Show-MainMenu {
    cls
    Write-Host "Active Directory Management Tool"
    Write-Host "================================"
    Write-Host "1. Create New AD User"
    Write-Host "2. Remove AD User"
    Write-Host "3. Modify AD User"
    Write-Host "4. Create New AD Group"
    Write-Host "5. Remove AD Group"
    Write-Host "6. Add Member to AD Group"
    Write-Host "7. Remove Member from AD Group"
    Write-Host "8. Create New OU"
    Write-Host "9. Remove OU"
    Write-Host "10. Create New GPO"
    Write-Host "11. Remove GPO"
    Write-Host "12. Link GPO to OU"
    Write-Host "13. Create New Site"
    Write-Host "14. Remove Site"
    Write-Host "15. Create New Subnet"
    Write-Host "16. Remove Subnet"
    Write-Host "17. Create New Trust Relationship"
    Write-Host "18. Remove Trust Relationship"
    Write-Host "19. Enable Audit Policy"
    Write-Host "20. Disable Audit Policy"
    Write-Host "21. Backup AD"
    Write-Host "22. Restore AD"
    Write-Host "23. Set Password Policy"
    Write-Host "24. Set Account Lockout Policy"
    Write-Host "25. Configure Audit Policy"
    Write-Host "26. Exit"
    $choice = Read-Host "Enter your choice"
    return $choice
}

# Main Function
function Main {
    do {
        $choice = Show-MainMenu
        switch ($choice) {
            1 {
                $UserName = Read-Host "Enter Username"
                $GivenName = Read-Host "Enter Given Name"
                $Surname = Read-Host "Enter Surname"
                $OU = Read-Host "Enter OU"
                $Password = Read-Host "Enter Password"
                New-ADUserAccount -UserName $UserName -GivenName $GivenName -Surname $Surname -OU $OU -Password $Password
            }
            2 {
                $UserName = Read-Host "Enter Username"
                Remove-ADUserAccount -UserName $UserName
            }
            3 {
                $UserName = Read-Host "Enter Username"
                $GivenName = Read-Host "Enter Given Name"
                $Surname = Read-Host "Enter Surname"
                Set-ADUserAccount -UserName $UserName -GivenName $GivenName -Surname $Surname
            }
            4 {
                $GroupName = Read-Host "Enter Group Name"
                $OU = Read-Host "Enter OU"
                New-ADGroupAccount -GroupName $GroupName -OU $OU
            }
            5 {
                $GroupName = Read-Host "Enter Group Name"
                Remove-ADGroupAccount -GroupName $GroupName
            }
            6 {
                $GroupName = Read-Host "Enter Group Name"
                $UserName = Read-Host "Enter Username"
                Add-ADGroupMember -GroupName $GroupName -UserName $UserName
            }
            7 {
                $GroupName = Read-Host "Enter Group Name"
                $UserName = Read-Host "Enter Username"
                Remove-ADGroupMember -GroupName $GroupName -UserName $UserName
            }
            8 {
                $OUName = Read-Host "Enter OU Name"
                $Path = Read-Host "Enter Path"
                New-ADOrganizationalUnit -OUName $OUName -Path $Path
            }
            9 {
                $OUName = Read-Host "Enter OU Name"
                $Path = Read-Host "Enter Path"
                Remove-ADOrganizationalUnit -OUName $OUName -Path $Path
            }
            10 {
                $GPOName = Read-Host "Enter GPO Name"
                $Comment = Read-Host "Enter Comment"
                New-ADGroupPolicy -GPOName $GPOName -Comment $Comment
            }
            11 {
                $GPOName = Read-Host "Enter GPO Name"
                Remove-ADGroupPolicy -GPOName $GPOName
            }
            12 {
                $GPOName = Read-Host "Enter GPO Name"
                $OU = Read-Host "Enter OU"
                Link-GPOToOU -GPOName $GPOName -OU $OU
            }
            13 {
                $SiteName = Read-Host "Enter Site Name"
                New-ADSite -SiteName $SiteName
            }
            14 {
                $SiteName = Read-Host "Enter Site Name"
                Remove-ADSite -SiteName $SiteName
            }
            15 {
                $Subnet = Read-Host "Enter Subnet"
                $SiteName = Read-Host "Enter Site Name"
                New-ADSubnet -Subnet $Subnet -SiteName $SiteName
            }
            16 {
                $Subnet = Read-Host "Enter Subnet"
                Remove-ADSubnet -Subnet $Subnet
            }
            17 {
                $TrustedDomain = Read-Host "Enter Trusted Domain"
                $Direction = Read-Host "Enter Trust Direction (Inbound/Outbound/Bidirectional)"
                $TrustType = Read-Host "Enter Trust Type (External/Forest)"
                $TrustPassword = Read-Host "Enter Trust Password"
                $SecTrustPassword = ConvertTo-SecureString $TrustPassword -AsPlainText -Force
                New-ADTrustRelationship -TrustedDomain $TrustedDomain -Direction $Direction -TrustType $TrustType -TrustPassword $SecTrustPassword
            }
            18 {
                $TrustedDomain = Read-Host "Enter Trusted Domain"
                Remove-ADTrustRelationship -TrustedDomain $TrustedDomain
            }
            19 {
                $GPOName = Read-Host "Enter GPO Name"
                Enable-AuditPolicy -GPOName $GPOName
            }
            20 {
                $GPOName = Read-Host "Enter GPO Name"
                Disable-AuditPolicy -GPOName $GPOName
}
21 {
                $BackupPath = Read-Host "Enter Backup Path"
                Backup-AD -BackupPath $BackupPath
            }
            22 {
                $BackupPath = Read-Host "Enter Backup Path"
                Restore-AD -BackupPath $BackupPath
            }
            23 {
                $MinLength = Read-Host "Enter Minimum Password Length"
                $MaxAge = Read-Host "Enter Maximum Password Age (days)"
                $MinAge = Read-Host "Enter Minimum Password Age (days)"
                $HistorySize = Read-Host "Enter Password History Size"
                $ComplexityEnabled = Read-Host "Enable Password Complexity (True/False)"
                Set-PasswordPolicy -MinLength $MinLength -MaxAge $MaxAge -MinAge $MinAge -HistorySize $HistorySize -ComplexityEnabled $ComplexityEnabled
            }
            24 {
                $Threshold = Read-Host "Enter Lockout Threshold"
                $ObservationWindow = Read-Host "Enter Lockout Observation Window (minutes)"
                $LockoutDuration = Read-Host "Enter Lockout Duration (minutes)"
                Set-AccountLockoutPolicy -Threshold $Threshold -ObservationWindow $ObservationWindow -LockoutDuration $LockoutDuration
            }
            25 {
                $Category = Read-Host "Enter Category"
                $Subcategory = Read-Host "Enter Subcategory"
                $Type = Read-Host "Enter Type"
                $AuditedObject = Read-Host "Enter Audited Object"
                $AccessMask = Read-Host "Enter Access Mask"
                $Principal = Read-Host "Enter Principal"
                $Level = Read-Host "Enter Level"
                $MatchType = Read-Host "Enter Match Type"
                $RuleId = Read-Host "Enter Rule Id"
                $FailureAction = Read-Host "Enter Failure Action"
                $SuccessAction = Read-Host "Enter Success Action"
                Configure-AuditPolicy -Category $Category -Subcategory $Subcategory -Type $Type -AuditedObject $AuditedObject -AccessMask $AccessMask -Principal $Principal -Level $Level -MatchType $MatchType -RuleId $RuleId -FailureAction $FailureAction -SuccessAction $SuccessAction
            }
            26 {
                break
            }
            default {
                Write-Host "Invalid choice, please try again."
            }
        }
        pause
    } while ($true)
}

Main

           
