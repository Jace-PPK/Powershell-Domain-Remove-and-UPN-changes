
<#
.SYNOPSIS
Rollback Script: Reset UPN to default & remove custom domain
.DESCRIPTION
- Connects to Microsoft Graph
- Reverts user UPN suffix back to onmicrosoft.com
- Removes custom domain safely
.AUTHOR
Pyae Phyoe Kyaw
#>
# ==============================
# 🔧 CONFIGURATION
# ==============================
$DomainName = "xxxx.com"
$DefaultDomain = "xxxxx.onmicrosoft.com"
$CsvPath = "C:\xxxxx"
# ==============================
# 🔐 CONNECT
# ==============================
Connect-MgGraph -Scopes "User.ReadWrite.All","Directory.ReadWrite.All","Domain.ReadWrite.All"

# ==============================
# 📄 IMPORT USERS
# ==============================
$Users = Import-Csv $CsvPath
Write-Host "Users loaded: $($Users.Count)" -ForegroundColor Green

# ==============================
# 👤 REVERT UPN
# ==============================
foreach ($User in $Users) {
    $CurrentUPN = $User.UserPrincipalName
    # Replace custom domain → default
    $NewUPN = $CurrentUPN -replace $DomainName, $DefaultDomain
    try {
        Update-MgUser -UserId $CurrentUPN -UserPrincipalName $NewUPN
        Write-Host "Reverted: $CurrentUPN → $NewUPN" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed: $CurrentUPN"
    }
}
Write-Host "UPN rollback completed ✅" -ForegroundColor Cyan

# ==============================
# 🧹 REMOVE DOMAIN
# ==============================
try {
    Write-Host "Removing domain..." -ForegroundColor Yellow
    Remove-MgDomain -DomainId $DomainName
    Write-Host "Domain removed ✅" -ForegroundColor Green
}
catch {
    Write-Warning "Domain removal failed. Some objects may still use this domain."
}
