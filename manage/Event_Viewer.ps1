# 筛选事件：允许用户根据日期、事件级别、关键字等条件筛选事件。
# 导出事件：允许用户将事件导出到文件中，以便后续分析。
# 监控事件：允许用户实时监控特定日志中的事件，并在发生特定事件时触发操作。
# 事件订阅：允许用户订阅特定类型的事件，并将这些事件发送到指定的目标（如邮件、数据库等）。
# 事件转发：允许用户将事件转发到其他计算机或设备，以实现集中化管理和监控。
# 列出所有日志
function Get-AllLogs {
    Get-WinEvent -ListLog *
}

# 列出特定日志中的事件
function Get-EventsInLog {
    param (
        [string]$LogName,
        [int]$MaxEvents = 10
    )
    Get-WinEvent -LogName $LogName -MaxEvents $MaxEvents
}

# 根据 ID 列出特定日志中的事件
function Get-EventsById {
    param (
        [string]$LogName,
        [int]$Id
    )
    Get-WinEvent -LogName $LogName | Where-Object { $_.Id -eq $Id }
}

# 创建自定义事件
function New-CustomEvent {
    param (
        [string]$LogName,
        [string]$Source,
        [int]$EventId,
        [string]$Message
    )
    $event = [System.Diagnostics.EventLog]::new()
    $event.Log = $LogName
    $event.Source = $Source
    $event.WriteEntry($Message, [System.Diagnostics.EventLogEntryType]::Information, $EventId)
}

# 删除特定日志中的特定事件（仅限自定义事件）
function Remove-EventById {
    param (
        [string]$LogName,
        [int]$Id
    )
    Get-WinEvent -LogName $LogName | Where-Object { $_.Id -eq $Id } | Remove-WinEvent
}

# 备份事件日志
function Backup-Log {
    param (
        [string]$LogName,
        [string]$BackupPath
    )
    wevtutil epl $LogName $BackupPath
}

# 恢复事件日志
function Restore-Log {
    param (
        [string]$LogName,
        [string]$BackupPath
    )
    wevtutil il $LogName $BackupPath
}

# 清除特定日志中的所有事件
function Clear-Log {
    param (
        [string]$LogName
    )
    Clear-EventLog -LogName $LogName
}

# 筛选事件
function Get-FilteredEvents {
    param (
        [string]$LogName,
        [int]$MaxEvents = 10,
        [string]$StartTime,
        [string]$EndTime,
        [string]$Level,
        [string]$Keyword
    )
    $filter = @{LogName=$LogName; StartTime=$StartTime; EndTime=$EndTime}
    if ($Level) { $filter.Add("Level", $Level) }
    if ($Keyword) { $filter.Add("FilterXPath", "*[System[EventID=$Keyword]]") }
    Get-WinEvent -FilterHashtable $filter -MaxEvents $MaxEvents
}

# 导出事件
function Export-Events {
    param (
        [string]$LogName,
        [string]$ExportPath
    )
    Get-WinEvent -LogName $LogName | Export-Csv -Path $ExportPath -NoTypeInformation
}

# 监控事件
function Monitor-Events {
    param (
        [string]$LogName,
        [int]$MaxEvents = 10
    )
    $lastEvent = Get-WinEvent -LogName $LogName | Sort-Object -Property TimeCreated -Descending | Select-Object -First 1
    $startTime = $lastEvent.TimeCreated
    do {
        $events = Get-WinEvent -LogName $LogName -MaxEvents $MaxEvents | Where-Object { $_.TimeCreated -gt $startTime }
        if ($events) {
            Write-Host "New events detected:"
            $events
        }
        Start-Sleep -Seconds 10
    } while ($true)
}

# 事件订阅
function Subscribe-Events {
    param (
        [string]$LogName,
        [string]$Query,
        [string]$Target
    )
    $xml = @"
    <QueryList>
      <Query Id="0" Path="$LogName">
        <Select Path="$LogName">*$Query*</Select>
      </Query>
    </QueryList>
"@
    $subscription = New-WinEvent -Query $xml -Action "Start" -Verbose
    $subscription | Out-File -FilePath $Target -Force
}

# 事件转发
function Forward-Events {
    param (
        [string]$LogName,
        [string]$TargetComputer
    )
    $xml = @"
    <Subscription xmlns="http://schemas.microsoft.com/win/2004/08/events/event">
      <SubscriptionId>1</SubscriptionId>
      <SubscriptionType>Forwarding</SubscriptionType>
      <Enabled>true</Enabled>
      <Uri>http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog</Uri>
      <ConfigurationMode>Normal</ConfigurationMode>
      <Delivery Mode="Push">
        <Batching MaxItems="100" MaxLatencyTime="900000"/>
        <PushSettings>
          <Heartbeat Interval="900000"/>
        </PushSettings>
        <Auth>
          <Negotiate/>
        </Auth>
        <Destinations>
          <WsmanDestination>
            <Address>$TargetComputer</Address>
            <Transport>HTTP</Transport>
            <Port>5985</Port>
            <Locale Language="en-US"/>
            <IPVersions>IPv4,IPv6</IPVersions>
          </WsmanDestination>
        </Destinations>
      </Delivery>
    </Subscription>
"@
    $subscription = New-WinEvent -Query $xml -Action "Start" -Verbose
}

# 交互式菜单
do {
    Write-Host "=== Event Viewer Management ==="
    Write-Host "1. List all logs"
    Write-Host "2. List events in a log"
    Write-Host "3. Get event by ID"
    Write-Host "4. Create custom event"
    Write-Host "5. Remove event by ID"
    Write-Host "6. Backup log"
    Write-Host "7. Restore log"
    Write-Host "8. Clear log"
    Write-Host "9. Filter events"
    Write-Host "10. Export events"
    Write-Host "11. Monitor events"
    Write-Host "12. Subscribe to events"
    Write-Host "13. Forward events"
    Write-Host "0. Exit"
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "1" { Get-AllLogs }
        "2" { $log = Read-Host "Enter log name"; Get-EventsInLog -LogName $log }
        "3" { $log = Read-Host "Enter log name"; $id = Read-Host "Enter event ID"; Get-EventsById -LogName $log -Id $id }
        "4" { $log = Read-Host "Enter log name"; $source = Read-Host "Enter event source"; $id = Read-Host "Enter event ID"; $message = Read-Host "Enter event message"; New-CustomEvent -LogName $log -Source $source -EventId $id -Message $message }
        "5" { $log = Read-Host "Enter log name"; $id = Read-Host "Enter event ID"; Remove-EventById -LogName $log -Id $id }
        "6" { $log = Read-Host "Enter log name"; $backupPath = Read-Host "Enter backup path"; Backup-Log -LogName $log -BackupPath $backupPath }
        "7" { $log = Read-Host "Enter log name"; $backupPath = Read-Host "Enter backup path"; Restore-Log -LogName $log -BackupPath $backupPath }
        "8" { $log = Read-Host "Enter log name"; Clear-Log -LogName $log }
        "9" { $log = Read-Host "Enter log name"; $startTime = Read-Host "Enter start time (optional)"; $endTime = Read-Host "Enter end time (optional)"; $level = Read-Host "Enter event level (optional)"; $keyword = Read-Host "Enter event keyword (optional)"; Get-FilteredEvents -LogName $log -StartTime $startTime -EndTime $endTime -Level $level -Keyword $keyword }
        "10" { $log = Read-Host "Enter log name"; $exportPath = Read-Host "Enter export path"; Export-Events -LogName $log -ExportPath $exportPath }
        "11" { $log = Read-Host "Enter log name"; Monitor-Events -LogName $log }
        "12" { $log = Read-Host "Enter log name"; $query = Read-Host "Enter query"; $target = Read-Host "Enter target"; Subscribe-Events -LogName $log -Query $query -Target $target }
        "13" { $log = Read-Host "Enter log name"; $targetComputer = Read-Host "Enter target computer"; Forward-Events -LogName $log -TargetComputer $targetComputer }
        "0" { break }
        default { Write-Host "Invalid choice. Please try again." }
    }
} while ($true)
