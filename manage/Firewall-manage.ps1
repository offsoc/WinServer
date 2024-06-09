# 禁用防火墙
function Disable-Firewall {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
}

# 启用防火墙
function Enable-Firewall {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
}

# 阻止应用程序访问网络
function Block-Application {
    param (
        [string]$AppName
    )
    New-NetFirewallRule -DisplayName "Block $AppName" -Direction Outbound -Program $AppName -Action Block
}

# 允许应用程序访问网络
function Allow-Application {
    param (
        [string]$AppName
    )
    New-NetFirewallRule -DisplayName "Allow $AppName" -Direction Outbound -Program $AppName -Action Allow
}

# 监控网络活动
function Monitor-NetworkActivity {
    Get-NetFirewallPortFilter | Select-Object LocalPort, RemoteAddress, Direction, Action
}

# 检查防火墙状态
function Check-FirewallStatus {
    Get-NetFirewallProfile | Select-Object Name, Enabled
}

# 导出防火墙规则
function Export-FirewallRules {
    Get-NetFirewallRule | Export-Csv -Path "C:\temp\firewall_rules.csv" -NoTypeInformation
}

# 导入防火墙规则
function Import-FirewallRules {
    Import-Csv -Path "C:\temp\firewall_rules.csv" | ForEach-Object {
        New-NetFirewallRule -DisplayName $_.DisplayName -Direction $_.Direction -Action $_.Action -Protocol $_.Protocol -LocalPort $_.LocalPort -RemoteAddress $_.RemoteAddress -Description $_.Description
    }
}

# 查看防火墙日志
function Get-FirewallLog {
    Get-NetFirewallSecurityFilter | Get-NetFirewallRule | Get-NetFirewallApplicationFilter | Get-NetFirewallPortFilter | Get-NetFirewallAddressFilter | Select-Object Name, DisplayName, Action, Direction, LocalPort, RemoteAddress, Protocol
}

# 排序防火墙规则
function Sort-FirewallRules {
    Get-NetFirewallRule | Sort-Object -Property DisplayName
}

# 监控网络连接
function Monitor-NetworkConnections {
    Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State
}

# 导出防火墙规则为脚本
function Export-FirewallRulesAsScript {
    Get-NetFirewallRule | ForEach-Object { $_.ScriptBlock } | Out-File -FilePath "C:\temp\firewall_rules.ps1"
}

# 备份防火墙规则
function Backup-FirewallRules {
    Export-FirewallRules | Export-Clixml -Path "C:\temp\firewall_rules_backup.xml"
}

# 还原防火墙规则
function Restore-FirewallRules {
    $backup = Import-Clixml -Path "C:\temp\firewall_rules_backup.xml"
    $backup | New-NetFirewallRule
}

# 交互式菜单
do {
    Write-Host "=== Windows Firewall Management ==="
    Write-Host "1. Get firewall rules"
    Write-Host "2. Add firewall rule"
    Write-Host "3. Remove firewall rule"
    Write-Host "4. Disable firewall"
    Write-Host "5. Enable firewall"
    Write-Host "6. Block application"
    Write-Host "7. Allow application"
    Write-Host "8. Monitor network activity"
    Write-Host "9. Check firewall status"
    Write-Host "10. Export firewall rules"
    Write-Host "11. Import firewall rules"
    Write-Host "12. View firewall log"
    Write-Host "13. Sort firewall rules"
    Write-Host "14. Monitor network connections"
    Write-Host "15. Export firewall rules as script"
    Write-Host "16. Backup firewall rules"
    Write-Host "17. Restore firewall rules"
    Write-Host "0. Exit"
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "1" { Get-FirewallRule }
        "2" { 
            $name = Read-Host "Enter rule name"
            $displayName = Read-Host "Enter display name"
            $direction = Read-Host "Enter direction (Inbound/Outbound)"
            $action = Read-Host "Enter action (Allow/Block)"
            $protocol = Read-Host "Enter protocol (TCP/UDP/ICMP)"
            $localPort = Read-Host "Enter local port (e.g., 80)"
            $remoteAddress = Read-Host "Enter remote address (e.g., 192.168.1.1)"
            $description = Read-Host "Enter description"
            Add-FirewallRule -Name $name -DisplayName $displayName -Direction $direction -Action $action -Protocol $protocol -LocalPort $localPort -RemoteAddress $remoteAddress -Description $description
        }
        "3" { $name = Read-Host "Enter rule name"; Remove-FirewallRule -Name $name }
        "4" { Disable-Firewall }
        "5" { Enable-Firewall }
        "6" { $appName = Read-Host "Enter application name"; Block-Application -AppName $appName }
        "7" { $appName = Read-Host "Enter application name"; Allow-Application -AppName $appName }
        "8" { Monitor-NetworkActivity }
        "9" { Check-FirewallStatus }
        "10" { Export-FirewallRules }
        "11" { Import-FirewallRules }
        "12" { Get-FirewallLog }
        "13" { Sort-FirewallRules }
        "14" { Monitor-NetworkConnections }
        "15" { Export-FirewallRulesAsScript }
        "16" { Backup-FirewallRules }
        "17" { Restore-FirewallRules }
        "0" { break }
        default { Write-Host "Invalid choice. Please try again." }
    }
} while ($true)
