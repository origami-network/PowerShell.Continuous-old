[CmdletBinding()]
param (
	[string] $Action = (Get-Location).Path,
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
		[string] $Action
	)

	throw 'TODO: Search action file *.action.ps1'
	throw 'TODO: Invoke-Build with specific action'
}