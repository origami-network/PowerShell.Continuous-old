$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'Get-AssemblyInfoFiles'

Describe 'Get-AssemblyInfoFiles' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	It 'expands path for PSDrive' {
		new-Item 'TestDrive:\Properties\AssemblyInfo.cs' `
			-ItemType file -Force -ErrorAction Stop

		$result = & $sut 'TestDrive:\Properties\AssemblyInfo*.cs'

		$result | should match ([regex]::Escape((Get-PSDrive TestDrive).Root))
		$result | should not match 'TestDrive'
	}

	It 'allows to use ''*'' for matching' {
		New-Item 'TestDrive:\Properties\AssemblyInfo.cs', 'TestDrive:\Properties\AssemblyInfo.Version.cs' `
			-ItemType file -Force -ErrorAction Stop

		$result = & $sut 'TestDrive:\Properties\AssemblyInfo*.cs'

		$result | Measure-Object | % { $_.Count } | should be 2 
		$result | ? { $_ -match 'AssemblyInfo.cs' } | should not beNullOrEmpty
		$result | ? { $_ -match 'AssemblyInfo.Version.cs' } | should not beNullOrEmpty
	}
	
	It 'skips the directories' {
		Remove-Item 'TestDrive:\Properties\AssemblyInfo.Version.cs' -Force -ErrorAction SilentlyContinue
		New-Item 'TestDrive:\Properties\AssemblyInfo.cs' `
			-ItemType file -Force -ErrorAction Stop
		New-Item 'TestDrive:\Properties\AssemblyInfo.Version.cs' `
			-ItemType directory -Force -ErrorAction Stop

		$result = & $sut 'TestDrive:\Properties\AssemblyInfo*.cs'

		$result | Measure-Object | % { $_.Count } | should be 1 
		$result | ? { $_ -match 'AssemblyInfo.cs' } | should not beNullOrEmpty
		$result | ? { $_ -match 'AssemblyInfo.Version.cs' } | should beNullOrEmpty
	}	 

	It 'reports error if there is no existing paths' {
		$invoke = {
			& $sut 'TestDrive:\not-exists' -ErrorAction Stop
		}

		$invoke | should throw 'not-exists' 
	}
}
