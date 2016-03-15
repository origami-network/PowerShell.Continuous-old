$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'Get-AssemblyVersion'

Describe 'Get-AssemblyVersion' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	$filePath = 'TestDrive:\AssemblyInfo.Version.cs'

	Context "All versions in AssemblyInfo file" {
		@(
			'[assembly: AssemblyVersion("1.0.0.0")]'
			'[assembly: AssemblyFileVersion("2.0.0.0")]'
			'[assembly: AssemblyInformationalVersion("3.0.0.0-local")]'
		) | Out-File $filePath
		
		It 'finds AssemblyVersion' {
			$version = & $sut $filePath

			$version | should be '1.0.0.0'
		}

		It 'finds AssemblyFileVersion' {
			$version = & $sut $filePath -Kind File

			$version | should be '2.0.0.0'
		}

		It 'finds AssemblyInformationalVersion' {
			$version = & $sut $filePath -Kind Informational

			$version | should be '3.0.0.0-local'
		}
	}

	Context "No versions in AssemblyInfo file" {
		@(
			'// No Assembly*Version'
		) | Out-File $filePath
		
		It 'does not find AssemblyVersion' {
			$version = & $sut $filePath

			$version | should beNullOrEmpty
		}

		It 'does not find AssemblyFileVersion' {
			$version = & $sut $filePath -Kind File

			$version | should beNullOrEmpty
		}

		It 'does not find AssemblyInformationalVersion' {
			$version = & $sut $filePath -Kind Informational

			$version | should beNullOrEmpty
		}
	}
}
