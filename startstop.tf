resource "azurerm_automation_runbook" "runbook" {
  name                    = var.automation_account_runbook_name
  resource_group_name     = var.custom_rg_name
  location                 = var.location
  automation_account_name = var.custom_automation_account_name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "PowerShell"
depends_on = [ azurerm_resource_group.main_rg, azurerm_automation_account.this]
  content = <<-EOT
workflow newshutdownstartbytag
{
  Param(
    [Parameter(Mandatory=$true)]
    [String]
    $TagName,
    [Parameter(Mandatory=$true)]
    [String]
    $TagValue,
    [Parameter(Mandatory=$true)]
    [Boolean]
    $Shutdown
  )

  try {
    "Logging in to Azure..."
    Connect-AzAccount -Identity
  }
  catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
  }

  $vms = Get-AzResource -TagName $TagName -TagValue $TagValue | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines"}

  Foreach -Parallel ($vm in $vms) {
    if (!($Notify)) {
      if ($Shutdown) {
        Write-Output "Stopping $($vm.Name)"
        Stop-AzVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force
      }
      else {
        Write-Output "Starting $($vm.Name)"
        Start-AzVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
      }
    }
    $pvmlist += $vm.Name
  }
}
  EOT
}
