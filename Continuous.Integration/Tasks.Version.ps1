
# TBD: Mayby some better name than Runner for TeamCity, Jenkins etc.
task Get-RunnerVersion -Condition (Test-TeamCity) {
	$Script:RunnerVersion = @{
		Build = Get-TeamCityProperty adasdsa.sdsds.ds
		Revision = Get-TeamCityProperty adasdsa.sdsds.ds
		Branch = Get-TeamCityProperty adasdsa.sdsds.ds
	}
}
	
task Set-VersionDrives {

}

task Get-AssemblyInfoVersion {

}

task Merge-Version {

}

task Edit-AssemblyInfoVersion {

}

task Publish-Version -Condition (Test-TeamCity) {

}