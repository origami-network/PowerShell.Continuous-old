
function Edit-AssemblyVersion {
	[CmdletBinding()] 
	param (
		[Parameter(
			Mandatory = $true,
			Position = 0
		)]
		[string] $FilePath,

		[Parameter(
			Mandatory = $true,
			Position = 1
		)]
		[string] $Version,

		[Parameter(
			Position = 3
		)]
		[ValidateSet('','File','Informational')]
		[string] $Kind
	)

	$fileContent = (Get-Content $FilePath -ErrorAction $ErrorActionPreference)

	$pattern = "Assembly$($Kind)Version\("".*""\)"
	$value = "Assembly$($Kind)Version(""$($Version)"")"

	$newFileContent = $fileContent |
		%{ $_ -replace $pattern, $value }

	if (Compare-Object $fileContent $newFileContent) {
		$newFileContent |
			Out-File $FilePath -Force -ErrorAction $ErrorActionPreference
	}
}
