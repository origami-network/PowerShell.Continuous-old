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
			Position = 1
		)]
		[string] $ActionDriveRoot,
		[Parameter(
			Mandatory = $true,
			Position = 2
		)]
		[string] $ArtifactsDriveRoot
	)

	try {
		New-PSDrive Workspace -Root $WorkspaceDriveRoot -PSProvider FileSystem -Scope global -ErrorAction $ErrorActionPreference | Out-Null
		New-PSDrive Action -Root $ActionDriveRoot -PSProvider FileSystem -Scope global -ErrorAction $ErrorActionPreference | Out-Null
		if (-not (Test-Path $ArtifactsDriveRoot)) {
			New-Item $ArtifactsDriveRoot -ItemType Directory -ErrorAction $ErrorActionPreference | Out-Null
		}
		New-PSDrive Artifacts -Root $ArtifactsDriveRoot -PSProvider FileSystem -Scope global -ErrorAction $ErrorActionPreference | Out-Null
	} catch {
		Remove-PSDrive Workspace -Force -ErrorAction SilentlyContinue
		Remove-PSDrive Action -Force -ErrorAction SilentlyContinue
		Remove-PSDrive Artifacts -Force -ErrorAction SilentlyContinue

		throw
	}
}
