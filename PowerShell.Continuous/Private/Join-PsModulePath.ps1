function Join-PsModulePath {
	[CmdletBinding()]
	param (
		[Parameter(
			Position = 0
		)]
		[string[]] $Paths,

		[string] $ModulePath = $env:PSModulePath
	)

	$Paths = @(
		$Paths |
			Get-Item |
			? { $_.PSIsContainer } |
			% { $_.FullName }
	)

	$Paths |
		% { Write-Verbose "Adding `$_` to module path " }

	($Paths + $ModulePath) -join ';'
}
