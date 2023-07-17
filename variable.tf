variable "custom_automation_account_name" {
    type=string
    default="automation-acc"
  
}
variable "automation_account_runbook_name"{
    type=string
    default="runbook"
}
variable "location"{
    type=string
    default="eastus2"
}
variable "custom_rg_name" {
  type=string
  default="1chrg"
}