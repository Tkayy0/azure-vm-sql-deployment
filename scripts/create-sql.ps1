# create-sql.ps1
# Creates an Azure SQL server and database with PowerShell (Az module), and opens the
# server firewall to one IP address only.
#
# Usage (Cloud Shell in PowerShell, or any session where you have run Connect-AzAccount):
#   ./create-sql.ps1 -AllowedClientIp "203.0.113.4"
#
# You will be asked for the SQL administrator username and password. The password is
# never stored in this file. Use a long, unique password.

param(
    [string]$ResourceGroup = "mySqlResourceGroup",
    [string]$Location      = "uksouth",
    # SQL server names must be unique across Azure, so a random number is added
    [string]$ServerName    = "mysqlserver$(Get-Random -Minimum 10000 -Maximum 99999)",
    [string]$DatabaseName  = "Demo",
    [string]$Tier          = "Basic",   # Basic is the cheapest option; change it to try others
    [Parameter(Mandatory = $true)]
    [string]$AllowedClientIp
)

$ErrorActionPreference = "Stop"

$credential = Get-Credential -Message "Choose a SQL administrator username and password"

Write-Host "Creating resource group $ResourceGroup in $Location..."
New-AzResourceGroup -Name $ResourceGroup -Location $Location | Out-Null

Write-Host "Creating SQL server $ServerName..."
New-AzSqlServer `
    -ResourceGroupName $ResourceGroup `
    -ServerName $ServerName `
    -Location $Location `
    -SqlAdministratorCredentials $credential | Out-Null

Write-Host "Opening the server firewall to $AllowedClientIp only..."
New-AzSqlServerFirewallRule `
    -ResourceGroupName $ResourceGroup `
    -ServerName $ServerName `
    -FirewallRuleName "AllowMyIp" `
    -StartIpAddress $AllowedClientIp `
    -EndIpAddress $AllowedClientIp | Out-Null

Write-Host "Creating database $DatabaseName ($Tier tier)..."
New-AzSqlDatabase `
    -ResourceGroupName $ResourceGroup `
    -ServerName $ServerName `
    -DatabaseName $DatabaseName `
    -Edition $Tier `
    -RequestedServiceObjectiveName $Tier | Out-Null

Write-Host ""
Write-Host "Done. Connect with a SQL client to:"
Write-Host "  Server:   $ServerName.database.windows.net"
Write-Host "  Database: $DatabaseName"
Write-Host "  Login:    $($credential.UserName)"
