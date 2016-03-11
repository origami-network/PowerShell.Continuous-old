$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'PowerShell.Continuous'

Describe 'PowerShell.Continuous Module' -Tags "Scope-White" {
	Import-Module "$here\$sut.psd1"

	Context "Invoke-Continuous" {
		New-Item 'TestDrive:\Workspace' -ItemType directory
		New-Item 'TestDrive:\Workspace\Continuous.Integration' -ItemType directory

		It 'Should invoke action script with proper environmnet' {
			In 'TestDrive:\Workspace' {
				Invoke-Continuous Workspace:\Continuous.Integration {
					Get-PSDrive Workspace | % { $_.Root } | Should Be (Get-Item 'TestDrive:\Workspace').FullName
					Get-PSDrive Action | % { $_.Root } | Should Be (Get-Item 'TestDrive:\Workspace\Continuous.Integration').FullName
					Get-PSDrive Artifacts | % { $_.Root } | Should Be (Get-Item 'TestDrive:\Workspace\.Artifacts').FullName

					($env:PSModulePath -split ';') | Select-Object -First 1 | Should Be (Get-Item 'TestDrive:\Workspace\').FullName

					'Executed' | Add-Content 'Artifacts:\Result.txt'
				}
			}

			'TestDrive:\Workspace\.Artifacts\Result.txt' | Should Contain 'Executed'
		}

		It 'Should clean up environmnet after action script was invoked' {
			$orginal = $env:PSModulePath

			In 'TestDrive:\Workspace' {
				Invoke-Continuous Workspace:\Continuous.Integration {}
			}

			$env:PSModulePath | Should Be $orginal
			Get-PSDrive Workspace | % { $_.Root } | Should Not Be (Get-Item 'TestDrive:\Workspace').FullName
			Get-PSDrive Action | % { $_.Root } | Should Not Be (Get-Item 'TestDrive:\Workspace\Continuous.Integration').FullName
			Get-PSDrive Artifacts | % { $_.Root } | Should Not Be (Get-Item 'TestDrive:\Workspace\.Artifacts').FullName
		}

		It 'Should propagate error from action script' {
			$orginal = $env:PSModulePath

			$invoke = {
				Invoke-Continuous Workspace:\Continuous.Integration {
					throw 'error from action script'
				}
			}

			In 'TestDrive:\Workspace' {
				$invoke | Should Throw 'error from action script'
			}
			$env:PSModulePath | Should Be $orginal
			Get-PSDrive Workspace | % { $_.Root } | Should Not Be (Get-Item 'TestDrive:\Workspace').FullName
			Get-PSDrive Action | % { $_.Root } | Should Not Be (Get-Item 'TestDrive:\Workspace\Continuous.Integration').FullName
			Get-PSDrive Artifacts | % { $_.Root } | Should Not Be (Get-Item 'TestDrive:\Workspace\.Artifacts').FullName
		}
	}
}
