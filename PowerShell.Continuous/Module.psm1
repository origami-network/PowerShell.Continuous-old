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

function Invoke-Continuous {
	[CmdletBinding()]
	param (
		[Parameter()]
		[string] $Action,

		[Parameter()]
		[string[]] $Task = '.',

		[string] $InvokeBuildFile
	)

	$actionFile = Join-Path $data.Project.Path "$($Action).action.ps1" -Resolve
	Write-Verbose "Using action file '$($actionFile)'."

	$packagesPath = Join-Path 'workspace:' 'packages' -Resolve -ErrorAction Ignore
	$packagesFile = Join-Path 'project:' 'packages.config' -Resolve -ErrorAction Ignore
	if ($packagesPath -and $packagesFile) {
		$packageName = 'Invoke-Build'
		$packageVersion = Select-Xml "//package[@id='$($packageName)']/@version" $packagesFile | 
			% { $_.Node.Value }

		Write-Verbose "Using package '$($packageName)' ($($packageVersion))."
		$invokeBuildCommand = Join-Path $packagesPath (Join-Path "$($packageName).$($packageVersion)" (Join-Path 'tools' 'Invoke-Build.ps1')) -Resolve -ErrorAction Ignore
	}

	if (-not $invokeBuildCommand) {
		throw 'TODO: bootstrap Invoke-Build'
	}
	Write-Verbose "Invoke tasks $(($Task | % {'''' + $_ + ''''}) -join ', ') using command '$($invokeBuildCommand)'."
	& $invokeBuildCommand $Task $actionFile 
}