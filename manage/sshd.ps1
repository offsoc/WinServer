# 安装 OpenSSH 服务器（如果尚未安装）
Add-WindowsFeature -Name OpenSSH.Server

# 设置 SSH 服务为自动启动
Set-Service -Name sshd -StartupType Automatic

# 启动 SSH 服务
Start-Service sshd

# 添加防火墙规则允许 SSH 连接
New-NetFirewallRule -DisplayName "Allow SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow

# 显示防火墙规则
Get-NetFirewallRule -DisplayName "Allow SSH"
