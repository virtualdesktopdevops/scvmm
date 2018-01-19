# Class: scvmm
#
# This module manages scvmm
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class scvmm (
  $setup_svc_username, #Administrator account authorized for VMM setup and AD account creation
  $setup_svc_password,
  $vmm_svc_username, #VMM service account
  $vmm_svc_password,
  $sourcePath, #UNC path to the root of the source files for installation
  $productkey = '',
  $databaseserver,
  $sqlalwayson = false,
  $sqlavailabilitygroup = '', #Name of the SQL Server Availability group
  $sqldbbackuppath = '',
)

{
  contain scvmm::serviceaccounts
  contain scvmm::install
  contain scvmm::rollupinstall
  contain scvmm::databasehighavailability

  Class['::scvmm::serviceaccounts']->
  Class['::scvmm::install']->
  Class['::scvmm::rollupinstall']
}
