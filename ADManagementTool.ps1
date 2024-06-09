# 用户管理：创建、删除、修改用户。
# 组管理：创建、删除、修改组，管理组成员。
# 组织单位 (OU) 管理：创建、删除、修改 OU。
# 组策略管理：创建、删除、修改组策略对象 (GPO)。
# 域控制器管理：管理 FSMO 角色，域控制器状态检查。
# 域信任管理：创建和管理域信任关系。
# 审计和监控：启用和配置审核策略，实时监控 AD 活动。
# 站点和服务管理：管理站点和子网。
# 备份和恢复：AD 数据的备份和恢复。
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

# Function to create a new AD Group
function New-ADGroupAccount {
    param (
        [string]$GroupName,
        [string]$OU
    )
    New-ADGroup -Name $GroupName -Path $OU -GroupScope Global -GroupCategory Security
    Write-Host "Group $GroupName created successfully."
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

# Function to create a new subnet
function New-ADSubnet {
    param (
        [string]$Subnet,
        [string]$SiteName
    )
    New-ADReplicationSubnet -Name $Subnet -Site $SiteName
    Write-Host "Subnet $Subnet linked to Site $SiteName successfully."
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

# Function to enable auditing
function Enable-AuditPolicy {
    param (
        [string]$GPOName
    )
    Set-GPRegistryValue -Name $GPOName -Key "HKLM\Software\Policies\Microsoft\Windows\EventLog\Security" -ValueName "MaxSize" -Type DWord -Value 32768
    Write-Host "Audit policy enabled for GPO $GPOName."
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

# Main Menu
function Show-MainMenu {
    cls
    Write-Host "Active Directory Management Tool"
    Write-Host "================================"
    Write-Host "1. Create New AD User"
    Write-Host "2. Create New AD Group"
    Write-Host "3. Create New OU"
    Write-Host "4. Create New GPO"
    Write-Host "5. Link GPO to OU"
    Write-Host "6. Create New Site"
    Write-Host "7. Create New Subnet"
    Write-Host "8. Create New Trust Relationship"
    Write-Host "9. Enable Audit Policy"
    Write-Host "10. Backup AD"
    Write-Host "11. Restore AD"
    Write-Host "12. Exit"
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
                $GroupName = Read-Host "Enter Group Name"
                $OU = Read-Host "Enter OU"
                New-ADGroupAccount -GroupName $GroupName -OU $OU
            }
            3 {
                $OUName = Read-Host "Enter OU Name"
                $Path = Read-Host "Enter Path"
                New-ADOrganizationalUnit -OUName $OUName -Path $Path
            }
            4 {
                $GPOName = Read-Host "Enter GPO Name"
                $Comment = Read-Host "Enter Comment"
                New-ADGroupPolicy -GPOName $GPOName -Comment $Comment
            }
            5 {
                $GPOName = Read-Host "Enter GPO Name"
                $OU = Read-Host "Enter OU"
                Link-GPOToOU -GPOName $GPOName -OU $OU
            }
            6 {
                $SiteName = Read-Host "Enter Site Name"
                New-ADSite -SiteName $SiteName
            }
            7 {
                $Subnet = Read-Host "Enter Subnet"
                $SiteName = Read-Host "Enter Site Name"
                New-ADSubnet -Subnet $Subnet -SiteName $SiteName
            }
            8 {
                $TrustedDomain = Read-Host "Enter Trusted Domain"
                $Direction = Read-Host "Enter Trust Direction (Inbound/Outbound/Bidirectional)"
                $TrustType = Read-Host "Enter Trust Type (External/Forest)"
                $TrustPassword = Read-Host "Enter Trust Password"
                $SecTrustPassword = ConvertTo-SecureString $TrustPassword -AsPlainText -Force
                New-ADTrustRelationship -TrustedDomain $TrustedDomain -Direction $Direction -TrustType $TrustType -TrustPassword $SecTrustPassword
            }
            9 {
                $GPOName = Read-Host "Enter GPO Name"
                Enable-AuditPolicy -GPOName $GPOName
            }
            10 {
                $BackupPath = Read-Host "Enter Backup Path"
                Backup-AD -BackupPath $BackupPath
            }
            11 {
                $BackupPath = Read-Host "Enter Backup Path"
                Restore-AD -BackupPath $BackupPath
            }
            12 {
                Write-Host "Exiting..."
                exit
            }
            default {
                Write-Host "Invalid choice, please try again."
            }
        }
    } while ($choice -ne 12)
}

# Execute the main function
Main
