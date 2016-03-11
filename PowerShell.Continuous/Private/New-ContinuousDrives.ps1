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

	New-PSDrive Workspace -Root $WorkspaceDriveRoot -PSProvider FileSystem -Scope 1 -ErrorAction $ErrorActionPreference | Out-Null
	New-PSDrive Action -Root $ActionDriveRoot -PSProvider FileSystem -Scope 1 -ErrorAction $ErrorActionPreference | Out-Null
	if (-not (Test-Path $ArtifactsDriveRoot)) {
		New-Item $ArtifactsDriveRoot -ItemType Directory -ErrorAction $ErrorActionPreference | Out-Null
	}
	New-PSDrive Artifacts -Root $ArtifactsDriveRoot -PSProvider FileSystem -Scope 1 -ErrorAction $ErrorActionPreference | Out-Null
}
