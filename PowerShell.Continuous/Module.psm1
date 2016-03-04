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
		[scriptblock] $Action,

		[string] $WorkspaceDriveRoot = (Get-Location).Path,
		[string] $ActionDriveRoot = "workspace:\Action",
		[string] $ArtifactsDriveRoot = "workspace:\.Artifacts",
		[string[]] $ModulesPaths = @(),
		[string[]] $Modules = @() 
	)

	begin {
		$ErrorActionPreference = Stop

		New-ContinuousDrives $WorkspaceDriveRoot $ActionDriveRoot $ArtifactsDriveRoot
		$env:PSModulePath = Join-PsModulePath $ModulesPaths
	}

	process {
		Invoke-Command $Action -NoNewScope
	}
}

function New-ContinuousDrives {
	[CmdletBinding()]
	param (
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $WorkspaceDriveRoot,
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $ActionDriveRoot,
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $ArtifactsDriveRoot
	)

	process {
		New-PSDrive Workspace -Root $WorkspaceDriveRoot -PSProvider FileSystem | Out-Null
		New-PSDrive Action -Root $WorkspaceDriveRoot -PSProvider FileSystem | Out-Null
		if (-not (Test-Path $ArtifactsDriveRoot)) {
			New-Item $ArtifactsDriveRoot -ItemType Directory | Out-Null
		}
		New-PSDrive Artifacts -Root $ArtifactsDriveRoot -PSProvider FileSystem | Out-Null
	}
}
