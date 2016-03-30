function Remove-ContinuousDrives {
	[CmdletBinding()]
	param (
	)

	Remove-PSDrive Workspace -Force -ErrorAction SilentlyContinue
	Remove-PSDrive Action -Force -ErrorAction SilentlyContinue
	Remove-PSDrive Artifacts -Force -ErrorAction SilentlyContinue
}
