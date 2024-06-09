# 查找安全策略：允许用户查找特定安全策略的当前设置。
# 重置安全策略：允许用户将安全策略重置为默认设置。
# 安全策略历史记录：允许用户查看安全策略的修改历史记录。
# 比较安全策略：允许用户比较两个安全策略文件之间的差异。
# 生成安全策略报告：生成当前安全策略的报告，包括详细信息和建议。
# 查找安全策略
function Find-SecurityOption {
    param (
        [string]$PolicyName
    )
    secedit /export /areas SECURITYPOLICY /cfg C:\temp\secoptions.inf
    $policy = Get-Content C:\temp\secoptions.inf | Select-String -Pattern "$PolicyName = .*"
    $policy
}

# 重置安全策略
function Reset-SecurityPolicy {
    secedit /configure /db $null /cfg C:\Windows\inf\defltbase.inf /overwrite /areas SECURITYPOLICY
}

# 安全策略历史记录
function Get-SecurityPolicyHistory {
    $history = Get-WinEvent -LogName Security -MaxEvents 50 | Where-Object { $_.EventID -eq 4956 }
    $history
}

# 比较安全策略
function Compare-SecurityPolicies {
    param (
        [string]$Path1,
        [string]$Path2
    )
    $policy1 = Get-Content $Path1
    $policy2 = Get-Content $Path2
    Compare-Object $policy1 $policy2
}

# 生成安全策略报告
function Generate-SecurityPolicyReport {
    secedit /export /areas SECURITYPOLICY /cfg C:\temp\secoptions.inf
    $report = Get-Content C:\temp\secoptions.inf
    $report
}

# 交互式菜单
do {
    Write-Host "=== Local Security Policy Management ==="
    Write-Host "1. Export security policy"
    Write-Host "2. Import security policy"
    Write-Host "3. Get security options"
    Write-Host "4. Set security options"
    Write-Host "5. Add security option"
    Write-Host "6. Remove security option"
    Write-Host "7. Find security option"
    Write-Host "8. Reset security policy"
    Write-Host "9. Security policy history"
    Write-Host "10. Compare security policies"
    Write-Host "11. Generate security policy report"
    Write-Host "0. Exit"
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "1" { $exportPath = Read-Host "Enter export path"; Export-SecurityPolicy -ExportPath $exportPath }
        "2" { $importPath = Read-Host "Enter import path"; Import-SecurityPolicy -ImportPath $importPath }
        "3" { Get-SecurityOptions }
        "4" { $policyName = Read-Host "Enter policy name"; $newValue = Read-Host "Enter new value"; Set-SecurityOption -PolicyName $policyName -NewValue $newValue }
        "5" { $policyName = Read-Host "Enter policy name"; $value = Read-Host "Enter value"; Add-SecurityOption -PolicyName $policyName -Value $value }
        "6" { $policyName = Read-Host "Enter policy name"; Remove-SecurityOption -PolicyName $policyName }
        "7" { $policyName = Read-Host "Enter policy name"; Find-SecurityOption -PolicyName $policyName }
        "8" { Reset-SecurityPolicy }
        "9" { Get-SecurityPolicyHistory }
        "10" { $path1 = Read-Host "Enter path to first policy"; $path2 = Read-Host "Enter path to second policy"; Compare-SecurityPolicies -Path1 $path1 -Path2 $path2 }
        "11" { Generate-SecurityPolicyReport }
        "0" { break }
        default { Write-Host "Invalid choice. Please try again." }
    }
} while ($true)

Remove-TemporaryFiles
