# scvmm #

This modules install a fully working Microsoft SystemCenter Virtual Machine Manager, including rollup updates up to rollup 13. It has been developped and fully tested with Microsoft SystemCenter 2012R2.

The following options is available for a production-grade installation :
- Fault tolerance : AlwaysOn database membership activation for the VirtualManagerDB database created by the package


## Integration informations
The VirtualManagerDB database is installed in the default MSSQLSERVER SQL Server instance. This module does not provide the capability to install the databases in another SQL intance.

The database failover mecanism integrated in this module is SQL Server AlwaysOn.

The module can be installed on a Standard, Datacenter, or Core version of Windows 2012R2 or Windows 2016. 

## Usage
- **setup_svc_username** : (string format DOMAIN\username) Privileged account used by Puppet for installing the software and creating the database (SQL server write access, local administrator privilèges needed). Needs to be at **DOMAIN\username** format if the account is a domain account. 
- **setup_svc_password** : (string) Password of the privileged account. Should be encrypted with hiera-eyaml.
- **vmm_svc_username** : (string format username) : SCVMM service account (on which SCVMM services will run). Use **username** format. **DO NOT** use DOMAIN\username format.
- **vmm_svc_password** : Password of the SCVMM service account. Should be encrypted with hiera-eyaml.
- **sourcepath** : (string) Path of a folder containing the SystemCenter 2012R2 installer (unarchive the ISO image in this folder).
- **productkey** : (string)(optionnal) Product key for licensed installations.
- **databaseserver** : (string) FQDN of the SQL server used for SCVMM database hosting. If using a AlwaysOn SQL cluster, use the Listener FQDN.
- **domainName** : (string) Active Directory domain name (full)
- **domainNetbiosName** : (string) : Active Directory domain NETBIOS name.
- **sqlalwayson** : (boolean) : true or false. Activate database AlwaysOn availability group membership ? Default is false. Needs to be true for a production grade environment
- **sqlavailabilitygroup** : (string) (optionnal if sqlalwayson = false) : Name of the SQL AlwaysOn availability group.
- **sqldbbackuppath** :  (string) (optionnal if sqlalwayson = false) : UNC path of a writable network folder to backup/restore databases during AlwaysOn availability group membership configuration. needs to be writable from the sql server nodes.


## Installing a SystemCenter Virtual Machine Manager

~~~puppet
node 'VMM' {
	class{'scvmm':
	  svc_username => 'TESTLAB\svc-puppet',
	  svc_password => 'P@ssw0rd',
	  vmm_svc_username => 'svc-vmm', 
  	  vmm_svc_password => 'P@ssw0rd',
	  sourcepath => '\\fileserver',
	  productkey => 'key-key-key',
	  databaseserver => 'CLSDB01LI.TESTLAB.COM',
	  domainName => 'TESTLAB.COM',
	  domainNetbiosName=> 'TESTLAB',
	  sqlalwayson => true,
	  sqlavailabilitygroup => 'CLSDB01',
	  sqldbbackuppath => '\\fileserver\backup  
	}
}
~~~
