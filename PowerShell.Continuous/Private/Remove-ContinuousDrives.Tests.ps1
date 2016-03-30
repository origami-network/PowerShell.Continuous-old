$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'Remove-ContinuousDrives'

Describe 'Remove-ContinuousDrives' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	Context "All continous drives" {
		New-PSDrive Workspace -Root 'TestDrive:\' -PSProvider FileSystem -Scope global
		New-PSDrive Action -Root 'TestDrive:\' -PSProvider FileSystem -Scope global
		New-PSDrive Artifacts -Root 'TestDrive:\' -PSProvider FileSystem -Scope global

		& $sut
		
		It 'removes PSDrive for Workspace' {
			Get-PSDrive Workspace | should beNullOrEmpty
		}
		It 'removes PSDrive for Action' {
			Get-PSDrive Action | should beNullOrEmpty
		}
		It 'removes PSDrive for Artifacts' {
			Get-PSDrive Artifacts | should beNullOrEmpty
		}
	}

	Context "No Workspace directory" {
		New-PSDrive Action -Root 'TestDrive:\' -PSProvider FileSystem -Scope global
		New-PSDrive Artifacts -Root 'TestDrive:\' -PSProvider FileSystem -Scope global

		It 'does not report error if Workspace directory is not found' {
			$invoke = { & $sut -ErrorAction Stop }

			$invoke | should not throw
			Get-PSDrive Workspace | should beNullOrEmpty
			Get-PSDrive Artifacts | should beNullOrEmpty
		}
	}

	Context "No Action directory" {
		New-PSDrive Workspace -Root 'TestDrive:\' -PSProvider FileSystem -Scope global
		New-PSDrive Artifacts -Root 'TestDrive:\' -PSProvider FileSystem -Scope global

		It 'does not report if Action directory is not found' {
			$invoke = { & $sut -ErrorAction Stop }

			$invoke | should not throw
			Get-PSDrive Workspace | should beNullOrEmpty
			Get-PSDrive Artifacts | should beNullOrEmpty
		}
	}

	Context "No Artifacts directory" {
		New-PSDrive Workspace -Root 'TestDrive:\' -PSProvider FileSystem -Scope global
		New-PSDrive Action -Root 'TestDrive:\' -PSProvider FileSystem -Scope global

		It 'does not report if Artifacts directory is not found' {
			$invoke = { & $sut -ErrorAction Stop }

			$invoke | should not throw
			Get-PSDrive Workspace | should beNullOrEmpty
			Get-PSDrive Action | should beNullOrEmpty
		}
	}
}
