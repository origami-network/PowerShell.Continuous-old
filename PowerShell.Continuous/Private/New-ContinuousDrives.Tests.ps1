$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'New-ContinuousDrives'

Describe 'New-ContinuousDrives' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	Context "Full directory structure" {
		New-Item 'TestDrive:\Workspace' -ItemType directory
		New-Item 'TestDrive:\Workspace\Action' -ItemType directory
		New-Item 'TestDrive:\Workspace\.Artifacts' -ItemType directory

		& $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts'
		
		It 'creates new PSDrive for Worspace' {
			Get-PSDrive Workspace | should Not beNullOrEmpty
		}
		It 'creates new PSDrive for Action' {
			Get-PSDrive Action | should Not beNullOrEmpty
		}
		It 'creates new PSDrive for Artifacts' {
			Get-PSDrive Artifacts | should Not beNullOrEmpty
		}
	}

	Context "No Workspace directory" {
		It 'reports error if Workspace directory is not found' {
			$invoke = { & $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts' -ErrorAction Stop }

			$invoke | should throw 'Workspace'
			Get-PSDrive Workspace | should beNullOrEmpty
		}
	}

	Context "No Action directory" {
		It 'reports error if Action directory is not found' {
			New-Item 'TestDrive:\Workspace' -ItemType directory

			$invoke = { & $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts' -ErrorAction Stop }

			$invoke | should throw 'Action'
			Get-PSDrive Action | should beNullOrEmpty
		}
	}

	Context "No Artifacts directory" {
		New-Item 'TestDrive:\Workspace' -ItemType directory
		New-Item 'TestDrive:\Workspace\Action' -ItemType directory

		It 'Creates Artifacts directory if does not exists' {
			& $sut 'TestDrive:\Workspace' 'Workspace:\Action' 'Workspace:\.Artifacts'

			Get-Item 'Workspace:\.Artifacts' | should Not beNullOrEmpty
			Get-PSDrive Artifacts | should Not beNullOrEmpty
		}
	}
}
