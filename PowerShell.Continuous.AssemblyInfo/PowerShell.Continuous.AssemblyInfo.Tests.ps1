$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'PowerShell.Continuous.AssemblyInfo'

Describe 'PowerShell.Continuous.AssemblyInfo Module' -Tags "Scope-Black" {
	Import-Module "$here\$sut.psd1"

	It "exports Get-AssemblyInfoVersion command" {
		Get-Command -Module $sut | ? { $_.Name -eq 'Get-AssemblyInfoVersion' } | should not beNullOrEmpty
	}
	It "exports Edit-AssemblyInfoVersion command" {
		Get-Command -Module $sut | ? { $_.Name -eq 'Edit-AssemblyInfoVersion' } | should not beNullOrEmpty
	}

	# TODO: define black box tests
}
