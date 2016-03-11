function Get-AssemblyInfoFiles {
	[CmdletBinding()] 
	param (
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $FilePath
	)

	$files = Get-Item $FilePath |
		? { ! $_.PSIsContainer } |
		% { $_.FullName }

	if (-not $files) {
		Write-Error "No Assembly Info files ware found at '$($FilePath)'" -ErrorAction $ErrorActionPreference
	}

	$files
}
