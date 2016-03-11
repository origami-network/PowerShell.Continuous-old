$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'New-ContinuousDrives'

Describe 'New-ContinuousDrives' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	Context "Full directory structure" {
		New-Item 'TestDrive:\Workspace' -ItemType directory
		New-Item 'TestDrive:\Workspace\Action' -ItemType directory
		New-Item 'TestDrive:\Workspace\.Artifacts' -ItemType directory

		& $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts'
		
		It 'Creates new PSDrive for Worspace' {
			Get-PSDrive Workspace | Should Not BeNullOrEmpty
		}
		It 'Creates new PSDrive for Action' {
			Get-PSDrive Action | Should Not BeNullOrEmpty
		}
		It 'Creates new PSDrive for Artifacts' {
			Get-PSDrive Artifacts | Should Not BeNullOrEmpty
		}
	}

	Context "No Workspace directory" {
		It 'Reports error if Workspace directory is not found' {
			$invoke = { & $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts' -ErrorAction Stop }

			$invoke | Should Throw 'Workspace'
			Get-PSDrive Workspace | Should BeNullOrEmpty
		}
	}

	Context "No Action directory" {
		It 'Reports error if Action directory is not found' {
			New-Item 'TestDrive:\Workspace' -ItemType directory

			$invoke = { & $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts' -ErrorAction Stop }

			$invoke | Should Throw 'Action'
			Get-PSDrive Action | Should BeNullOrEmpty
		}
	}

	Context "No Artifacts directory" {
		New-Item 'TestDrive:\Workspace' -ItemType directory
		New-Item 'TestDrive:\Workspace\Action' -ItemType directory

		It 'Creates Artifacts directory if does not exists' {
			& $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts'

			Get-Item 'Workspace:\.Artifacts' | Should Not BeNullOrEmpty
			Get-PSDrive Artifacts | Should Not BeNullOrEmpty
		}
	}
}
