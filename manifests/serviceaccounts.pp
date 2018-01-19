class scvmm::serviceaccounts inherits scvmm {
  
  #Needed for ActiveDirectory remote management using Powershell
	dsc_windowsfeature{ 'RSAT-AD-Powershell':
	 dsc_ensure => 'Present',
	 dsc_name => 'RSAT-AD-Powershell'
	}
	
	#VMM service account creation
	dsc_xaduser{'SvcVMMAccount':
		dsc_domainname => $domainName,
		dsc_domainadministratorcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		dsc_username => $vmm_svc_username,
		dsc_password => {'user' => $vmm_svc_username, 'password' => $vmm_svc_password},
		dsc_ensure => 'Present',
		require => Dsc_windowsfeature['RSAT-AD-Powershell']
	}
	
	#Add service accounts to local admins on VMM Servers
	dsc_xgroup{'SvcVMMLocalAdminGroup':
		dsc_groupname => 'Administrators',
		dsc_ensure => 'Present',
		dsc_memberstoinclude => "$domainNetbiosName\\$vmm_svc_username",
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		require => Dsc_xaduser['SvcVMMAccount']
	}
	
	#Add service accounts to DCOM Users group on VMM Servers
	dsc_xgroup{'SvcVMMDCOMUsersGroup':
		dsc_groupname => 'Distributed COM Users',
		dsc_ensure => 'Present',
		dsc_memberstoinclude => "$domainNetbiosName\\$vmm_svc_username",
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
    require => Dsc_xaduser['SvcVMMAccount']
	}
  
}