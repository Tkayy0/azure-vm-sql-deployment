# check-resources.ps1
# Reports on the virtual machine and SQL resources from the command line, instead of
# clicking through the portal. Read-only: it changes nothing.
#
# Usage (Cloud Shell in PowerShell):
#   ./check-resources.ps1
#   ./check-resources.ps1 -VmResourceGroup myResourceGroup -SqlResourceGroup mySqlResourceGroup

param(
    [string]$VmResourceGroup  = "myResourceGroup",
    [string]$VmName           = "MyLinuxVM",
    [string]$SqlResourceGroup = "mySqlResourceGroup"
)

Write-Host "== Virtual machine =="
Get-AzVM -Name $VmName -ResourceGroupName $VmResourceGroup |
    Format-List Name, Location, ProvisioningState

Write-Host "== VM power state =="
Get-AzVM -Name $VmName -ResourceGroupName $VmResourceGroup -Status |
    Select-Object Name, @{ n = "PowerState"; e = { $_.Statuses[1].DisplayStatus } } |
    Format-Table

Write-Host "== SQL servers =="
Get-AzSqlServer -ResourceGroupName $SqlResourceGroup |
    Format-Table ServerName, Location, FullyQualifiedDomainName

Write-Host "== SQL server firewall rules =="
Get-AzSqlServer -ResourceGroupName $SqlResourceGroup | ForEach-Object {
    Get-AzSqlServerFirewallRule -ResourceGroupName $SqlResourceGroup -ServerName $_.ServerName
} | Format-Table FirewallRuleName, StartIpAddress, EndIpAddress

Write-Host "== SQL databases =="
Get-AzSqlServer -ResourceGroupName $SqlResourceGroup | ForEach-Object {
    Get-AzSqlDatabase -ResourceGroupName $SqlResourceGroup -ServerName $_.ServerName
} | Format-Table DatabaseName, Edition, CurrentServiceObjectiveName, Status

Write-Host "== All resources in the VM resource group =="
Get-AzResource -ResourceGroupName $VmResourceGroup |
    Format-Table Name, ResourceType, Location
