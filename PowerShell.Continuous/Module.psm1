[CmdletBinding()]
param (
	[string] $WorkspaceDriveRoot = (Get-Location).Path,
	[string] $ProjectDriveRoot,
	[string] $ArtifactsDriveRoot
)

$module = $ExecutionContext.SessionState.Module
$data = $module.PrivateData

Set-Drives $WorkspaceDriveRoot $ProjectDriveRoot $ArtifactsDriveRoot -Scope 2
Add-ModulesPath $data.Modules.Path

function Invoke-Continous {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string] $Action,

		[Parameter()]
		[string[]] $Task = '.'
	)

	$actionFile = Join-Path $data.Project.Path "$($Action).action.ps1"
	if (-not (Test-Path $actionFile)) {
		throw "Can't find action file '$($actionFile)'."
	}
	Write-Verbose "Found action file '$($actionFile)'."

	throw 'TODO: bootstrap Invoke-Build'

	throw 'TODO: Invoke-Build with specific action'
}