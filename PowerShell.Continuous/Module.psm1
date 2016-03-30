$moduleRootPath = Split-Path -Path $MyInvocation.MyCommand.Path
Resolve-Path "$moduleRootPath\Private\*.ps1" |
	? { -not ($_.ProviderPath.ToLower().Contains(".tests.")) } |
	% { . $_.ProviderPath }

function Invoke-Continuous {
	[CmdletBinding()]
	param (
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $ActionDriveRoot,
		[Parameter(
			Mandatory = $true,
			Position = 1
		)]
		[scriptblock] $ActionScript,

		[string] $WorkspaceDriveRoot = (Get-Location).Path,		
		[string] $ArtifactsDriveRoot = "workspace:\.Artifacts",

		[string[]] $ModulesPaths = @('workspace:\')
	)

	$private:PSModulePath = $env:PSModulePath
	try {
		$ErrorActionPreference = 'Stop'

		New-ContinuousDrives $WorkspaceDriveRoot $ActionDriveRoot $ArtifactsDriveRoot
		$env:PSModulePath = Join-PsModulePath $ModulesPaths

		& ([scriptblock]::Create($ActionScript.ToString()))
	} catch {
		throw 
	} finally {
		Remove-ContinuousDrives

		$env:PSModulePath = $private:PSModulePath
	} 
}
