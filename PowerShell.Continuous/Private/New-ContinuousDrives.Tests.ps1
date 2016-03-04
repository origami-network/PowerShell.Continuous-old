$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'New-ContinuousDrives'
Describe 'New-ContinuousDrives' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	Context "New PSDrive for" {
		It 'Worspace' {
		}
		It 'Action' {
		}
		It 'Artifacts' {
		}
	}

	It 'Create Artifacts directory if not exists' {
	}

	It 'Report error Action directory is not found' {
	}

}
