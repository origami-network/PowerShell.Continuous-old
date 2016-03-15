function Get-AssemblyVersion {
	[CmdletBinding()] 
	param (
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $FilePath,

		[Parameter(
			Position = 1
		)]
		[ValidateSet('','File','Informational')]
		[string] $Kind
	)

	$pattern = "Assembly$($Kind)Version\(""(.*)""\)"

	Get-Content $FilePath |
		? { $_ -match $pattern } |
		% { $Matches[1] }
		Select-Object -First 1
}
