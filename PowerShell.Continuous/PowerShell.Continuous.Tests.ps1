$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'PowerShell.Continuous'

Describe 'PowerShell.Continuous Module' -Tags "Scope-Black" {
	Import-Module "$here\$sut.psd1"

	It "exports Invoke-Continuous command" {
		Get-Command -Module $sut | ? { $_.Name -eq 'Invoke-Continuous' } | should not beNullOrEmpty
	}

	Context "Invoke-Continuous" {
		New-Item 'TestDrive:\Workspace' -ItemType directory
		New-Item 'TestDrive:\Workspace\Continuous.Integration' -ItemType directory

		It 'invokes action script with proper environmnet' {
			In 'TestDrive:\Workspace' {
				Invoke-Continuous Workspace:\Continuous.Integration {
					Get-PSDrive Workspace | % { $_.Root } | should be (Get-Item 'TestDrive:\Workspace').FullName
					Get-PSDrive Action | % { $_.Root } | should be (Get-Item 'TestDrive:\Workspace\Continuous.Integration').FullName
					Get-PSDrive Artifacts | % { $_.Root } | should be (Get-Item 'TestDrive:\Workspace\.Artifacts').FullName

					($env:PSModulePath -split ';') | Select-Object -First 1 | should be (Get-Item 'TestDrive:\Workspace\').FullName

					'Executed' | Add-Content 'Artifacts:\Result.txt'
				}
			}

			'TestDrive:\Workspace\.Artifacts\Result.txt' | should Contain 'Executed'
		}

		It 'cleans up environmnet after action script was invoked' {
			$orginal = $env:PSModulePath

			In 'TestDrive:\Workspace' {
				Invoke-Continuous Workspace:\Continuous.Integration {}
			}

			$env:PSModulePath | should be $orginal
			Get-PSDrive Workspace | % { $_.Root } | should not be (Get-Item 'TestDrive:\Workspace').FullName
			Get-PSDrive Action | % { $_.Root } | should not be (Get-Item 'TestDrive:\Workspace\Continuous.Integration').FullName
			Get-PSDrive Artifacts | % { $_.Root } | should not be (Get-Item 'TestDrive:\Workspace\.Artifacts').FullName
		}

		It 'propagates error from action script' {
			$orginal = $env:PSModulePath

			$invoke = {
				Invoke-Continuous Workspace:\Continuous.Integration {
					throw 'error from action script'
				}
			}

			In 'TestDrive:\Workspace' {
				$invoke | Should Throw 'error from action script'
			}
			$env:PSModulePath | Should be $orginal
			Get-PSDrive Workspace | % { $_.Root } | should not be (Get-Item 'TestDrive:\Workspace').FullName
			Get-PSDrive Action | % { $_.Root } | should not be (Get-Item 'TestDrive:\Workspace\Continuous.Integration').FullName
			Get-PSDrive Artifacts | % { $_.Root } | should not be (Get-Item 'TestDrive:\Workspace\.Artifacts').FullName
		}
	}
}
