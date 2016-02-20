function Add-ModulesPath {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string[]] $Path
	)

	Remove-ModulesPath $Path

	$ModulesPath = $env:PSModulePath -split ';'
	$ModulesPath = $Path + $ModulesPath
	$env:PSModulePath = $ModulesPath -join ';'
}

function Remove-ModulesPath {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string[]] $Path
	)

	$ModulesPath = $env:PSModulePath -split ';'

	$ModulesPath = $ModulesPath |
		? { $Path -notcontains $_ }

	$env:PSModulePath = $ModulesPath -join ';'
}
