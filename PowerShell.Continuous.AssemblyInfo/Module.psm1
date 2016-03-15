$moduleRootPath = Split-Path -Path $MyInvocation.MyCommand.Path
Resolve-Path "$moduleRootPath\Private\*.ps1" |
	? { -not ($_.ProviderPath.ToLower().Contains(".tests.")) } |
	% { . $_.ProviderPath }

function Get-AssemblyInfoVersion {
	[CmdletBinding()] 
	param (
		[Parameter(
			Position = 0
		)]
		[string] $FilePath = 'Action:\Properties\AssemblyInfo*.cs'
	)

	Get-AssemblyInfoFiles $FilePath |
		% { @(
			Get-AssemblyVersion $_ -Kind Informational
			Get-AssemblyVersion $_ -Kind File
			Get-AssemblyVersion $_
		) } |
		Select-Object -First 1
}

function Edit-AssemblyInfoVersion {
	[CmdletBinding()]
	param (
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $Version,
		[Parameter(
			Position = 1
		)]
		[string] $FileVersion = $Version,
		[Parameter(
			Position = 2
		)]
		[string] $InformationalVersion = $FileVersion,

		[Parameter(
			Position = 3
		)]
		[string] $FilePath = 'Action:\Properties\AssemblyInfo*.cs'
	)

	Get-AssemblyInfoFiles $FilePath | % {
		Edit-AssemblyVersion $_ $Version
		Edit-AssemblyVersion $_ $Version -Kind File
		Edit-AssemblyVersion $_ $Version -Kind Informational
	}
}
