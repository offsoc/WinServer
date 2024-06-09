# 安装 AD DS 角色和 DNS 角色。
# 创建新的 AD 域和森林。
# 配置多个站点和子网。
# 配置组策略对象 (GPO)。
# 创建并配置域信任关系。
# 设置操作主机角色 (FSMO)。
# 创建组织单位 (OU) 和用户、组。
# 配置访问控制列表 (ACL)。
# 启用和配置审核和监控。

# 定义变量
$DomainName = "yourdomain.com"
$ForestName = "yourforest.com"
$NetBIOSName = "YOURDOMAIN"
$AdminPassword = ConvertTo-SecureString "YourPassword" -AsPlainText -Force
$DomainControllerName = "DC01"
$SiteName1 = "MainSite"
$SiteName2 = "BranchSite"
$Subnet1 = "192.168.0.0/24"
$Subnet2 = "192.168.1.0/24"
$TrustedDomain = "trusted.domain.com"
$TrustPassword = ConvertTo-SecureString "TrustPassword" -AsPlainText -Force

# 安装 AD DS 和 DNS 角色
Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementTools

# 创建新的森林和域
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetBIOSName `
    -ForestMode Win2016 `
    -DomainMode Win2016 `
    -SafeModeAdministratorPassword $AdminPassword `
    -Force

# 等待域控制器重启
Restart-Computer -Force

# 配置站点和子网
Import-Module ActiveDirectory
New-ADReplicationSite -Name $SiteName1
New-ADReplicationSite -Name $SiteName2
New-ADReplicationSubnet -Name $Subnet1 -Site $SiteName1
New-ADReplicationSubnet -Name $Subnet2 -Site $SiteName2

# 创建并链接组策略对象 (GPO)
$GPO1 = New-GPO -Name "Default Domain Policy" -Comment "Default policy for domain."
$GPO2 = New-GPO -Name "Default Domain Controllers Policy" -Comment "Default policy for domain controllers."
New-GPLink -Name $GPO1.DisplayName -Target "DC=$NetBIOSName,DC=yourforest,DC=com"
New-GPLink -Name $GPO2.DisplayName -Target "OU=Domain Controllers,DC=$NetBIOSName,DC=yourforest,DC=com"

# 配置域信任关系（双向信任）
New-ADTrust `
    -Name $TrustedDomain `
    -SourceForestName $ForestName `
    -TargetForestName $TrustedDomain `
    -Direction Bidirectional `
    -TrustType External `
    -AuthenticationType Forest `
    -TrustPassword $TrustPassword

# 配置域控制器的操作主机角色 (FSMO)
Move-ADDirectoryServerOperationMasterRole `
    -Identity $DomainControllerName `
    -OperationMasterRole SchemaMaster, DomainNamingMaster, RIDMaster, PDCEmulator, InfrastructureMaster

# 创建组织单位 (OU) 和用户、组
$OUPath = "OU=Sales,DC=$NetBIOSName,DC=yourforest,DC=com"
New-ADOrganizationalUnit -Name "Sales" -Path "DC=$NetBIOSName,DC=yourforest,DC=com"
New-ADGroup -Name "SalesGroup" -Path $OUPath -GroupScope Global -GroupCategory Security
New-ADUser -Name "JohnDoe" -GivenName "John" -Surname "Doe" -UserPrincipalName "johndoe@$DomainName" -Path $OUPath -AccountPassword $AdminPassword -Enabled $true
Add-ADGroupMember -Identity "SalesGroup" -Members "JohnDoe"

# 配置访问控制列表 (ACL)
$acl = Get-Acl "AD:$OUPath"
$permission = "NT AUTHORITY\SELF","Read, Write","Allow"
$ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $permission
$acl.AddAccessRule($ace)
Set-Acl "AD:$OUPath" $acl

# 配置审核和监控
$AuditOUPath = "OU=Audit,DC=$NetBIOSName,DC=yourforest,DC=com"
New-ADOrganizationalUnit -Name "Audit" -Path "DC=$NetBIOSName,DC=yourforest,DC=com"
$AuditUser = "AuditUser"
New-ADUser -Name $AuditUser -GivenName "Audit" -Surname "User" -UserPrincipalName "$AuditUser@$DomainName" -Path $AuditOUPath -AccountPassword $AdminPassword -Enabled $true
Set-ADUser -Identity $AuditUser -PasswordNeverExpires $true
Add-ADGroupMember -Identity "Domain Admins" -Members $AuditUser

# 启用审核策略
$GPO3 = New-GPO -Name "Audit Policy" -Comment "Policy for auditing."
New-GPLink -Name $GPO3.DisplayName -Target "DC=$NetBIOSName,DC=yourforest,DC=com"
Set-GPRegistryValue -Name $GPO3.DisplayName -Key "HKLM\Software\Policies\Microsoft\Windows\EventLog\Security" -ValueName "MaxSize" -Type DWord -Value 32768
Invoke-GPUpdate -Force

Write-Host "Complex AD environment setup complete."
