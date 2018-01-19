class scvmm::install inherits scvmm {
  
  #Prerequisites directory
  dsc_file{ 'SCVMMPrerequisitesDirectory':
    dsc_destinationpath => 'C:\SCVMMPrerequisites',
    dsc_type => 'Directory',
    dsc_ensure => 'Present'
  }
  
  #Download and install ADK Deployment Tools and ADK Preinstallation Environment
  #adksetup /quiet /layout c:\temp\ADKoffline
  file{ 'C:\\SCVMMPrerequisites\adksetup.exe':
    source => 'puppet:///modules/scvmm/adksetup.exe',
    source_permissions => ignore,
    require => Dsc_file['SCVMMPrerequisitesDirectory'] 
  }
  
    #ADK Deployment Tools
	dsc_package{'WindowsDeploymentTools81':
		dsc_ensure => 'Present',
		dsc_name => 'Windows Deployment Tools',
		dsc_productid => '',
		dsc_path => 'C:\SCVMMPrerequisites\adksetup.exe',
		dsc_arguments => '/quiet /features OptionId.DeploymentTools',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		require => File['C:\\SCVMMPrerequisites\adksetup.exe']
	}
	
	#ADK Preinstallation Environment
	dsc_package{'WindowsPreinstallationEnvironment81':
		dsc_ensure => 'Present',
		dsc_name => 'Windows PE x86 x64',
		dsc_productid => '',
		dsc_path => 'C:\SCVMMPrerequisites\adksetup.exe',
		dsc_arguments => '/quiet /features OptionId.WindowsPreinstallationEnvironment',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		require => [ File['C:\\SCVMMPrerequisites\adksetup.exe'], Dsc_package['WindowsDeploymentTools81'] ]
	}
	
	#ODBC Driver download and install. Product ID necessary, to be changed if required.
	file{ 'C:\\SCVMMPrerequisites\msodbcsql.msi':
		source => 'puppet:///modules/scvmm/msodbcsql.msi',
		source_permissions => ignore,
		require => Dsc_file['SCVMMPrerequisitesDirectory'] 
	}
  
	dsc_package{'WindowsODBCDriversforSQL':
		dsc_ensure => 'Present',
		dsc_name => 'Microsoft ODBC Driver 13 for SQL Server',
		dsc_arguments => 'IACCEPTMSODBCSQLLICENSETERMS=YES ALLUSERS=2 /passive /qn',
		dsc_productid => '2D98CD18-5754-4D94-B7E8-E6E11DAA56B1',
		dsc_path => 'C:\SCVMMPrerequisites\msodbcsql.msi',
		dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		require => File['C:\\SCVMMPrerequisites\msodbcsql.msi']
	}
	
	#SQL CLI Utils download and install
	file{ 'C:\\SCVMMPrerequisites\SqlCmdLnUtils.msi':
		source => 'puppet:///modules/scvmm/SqlCmdLnUtils.msi',
		source_permissions => ignore,
		require => Dsc_file['SCVMMPrerequisitesDirectory'] 
	}
	
	#dsc_package{'SQLServer2012CommandLineUtilities':
	#	dsc_ensure => 'Present',
	#	#dsc_name => 'Microsoft Command Line Utilities 13 for SQL Server',
	#	dsc_name => 'Microsoft SQL Server 2012 Command Line Utilities ',
	#	dsc_productid => '9198AD57-6396-4DF8-8D0C-20EA764F7986',
	#	dsc_path => 'C:\\SCVMMPrerequisites\SqlCmdLnUtils.msi',
	#	dsc_arguments => 'ALLUSERS=2 IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES /passive /qn',
	#	dsc_psdscrunascredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
	#	require => File['C:\\SCVMMPrerequisites\SqlCmdLnUtils.msi']
	#}
	
	#SQLSERVER powershell module deployment.
  #Required for database high awailability setup (always on VirtualManagerDB database membership)
  file{ "C:\\Program Files\\WindowsPowerShell\\Modules\\sqlserver_powershell_21.0.17199.zip":
      source => 'puppet:///modules/xd7mastercontroller/sqlserver_powershell_21.0.17199.zip',
      source_permissions => ignore,
  }
  
  #Function provided by the reidmv-unzip
  unzip{'UnzipSqlserverModule':
    source  => 'C:\\Program Files\WindowsPowerShell\Modules\sqlserver_powershell_21.0.17199.zip',
    destination => 'C:\\Program Files\WindowsPowerShell\Modules',
    creates => 'C:\\Program Files\WindowsPowerShell\Modules\SqlServer',
    require => File["C:\\Program Files\\WindowsPowerShell\\Modules\\sqlserver_powershell_21.0.17199.zip"]
  }
	
	#SCVMM Setup
	dsc_xscvmmmanagementserversetup{'VMMSetup':
		dsc_ensure => 'Present',
		dsc_sourcepath => $sourcePath,
		dsc_setupcredential => {'user' => $setup_svc_username, 'password' => $setup_svc_password},
		dsc_vmmservice => {'user' => "$domainNetbiosName\\$vmm_svc_username", 'password' => $vmm_svc_password},
		dsc_productkey => $productkey,
		#dsc_firstmanagementserver => true,
		dsc_createnewsqldatabase => 1,
		dsc_sqlmachinename => $databaseserver,
		dsc_sqlinstancename => 'MSSQLSERVER',
		dsc_sqldatabasename => 'VirtualManagerDB',
		dsc_createnewlibraryshare => 1,
		dsc_sqmoptin => 0,
		dsc_muoptin => 0,
		require => [ 
		  Dsc_package['WindowsODBCDriversforSQL'], 
		  Dsc_package['WindowsPreinstallationEnvironment81'], 
		  Dsc_package['WindowsDeploymentTools81'] 
    ]
	}
  
}