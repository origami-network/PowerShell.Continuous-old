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

	New-PSDrive Workspace -Root $WorkspaceDriveRoot -PSProvider FileSystem | Out-Null
	New-PSDrive Action -Root $WorkspaceDriveRoot -PSProvider FileSystem | Out-Null
	if (-not (Test-Path $ArtifactsDriveRoot)) {
		New-Item $ArtifactsDriveRoot -ItemType Directory | Out-Null
	}
	New-PSDrive Artifacts -Root $ArtifactsDriveRoot -PSProvider FileSystem | Out-Null
}
