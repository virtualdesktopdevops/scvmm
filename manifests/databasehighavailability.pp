class scvmm::databasehighavailability inherits scvmm {
  
	if $sqlalwayson {
		#Recovery mode configuration
		dsc_xsqlserverdatabaserecoverymodel{'VirtualManagerDBRecoveryModel':
			dsc_name => 'VirtualManagerDB',
			dsc_recoverymodel => 'Full',
			dsc_sqlserver => $databaseserver,
			dsc_sqlinstancename => 'MSSQLSERVER',
			dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
			require => Dsc_xscvmmmanagementserversetup['VMMSetup']
		}
		
		#AlwaysOn cluster database membership activation
		dsc_xsqlserveralwaysonavailabilitygroupdatabasemembership{'VirtualManagerDBAlwaysOn':
			dsc_databasename => 'VirtualManagerDB',
			dsc_availabilitygroupname => $sqlavailabilitygroup,
			dsc_sqlserver => $databaseserver,
			dsc_sqlinstancename => 'MSSQLSERVER',
			dsc_backuppath => $sqldbbackuppath,
			dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
			#require => Dsc_xsqlserverdatabaserecoverymodel['VirtualManagerDBRecoveryModel']
		}
	}  
}
