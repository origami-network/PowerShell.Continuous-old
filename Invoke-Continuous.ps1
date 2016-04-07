#Requires -Version 3.0
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Action,
	[Parameter(Position = 1)]
	[string[]] $Tasks = @('.'),

	[switch] $SkipExitOnError,

	[string] $WorkspacePath = (Resolve-Path '.').Path,
	[string] $ActionPath = (Join-Path $WorkspacePath "Continuous.$($Action)" -Resolve),
	[string] $ArtifactsPath = (Join-Path $WorkspacePath '.Artifacts'),
	[string] $ToolsPath = $env:APPDATA,

	[string] $NuGetFileName = 'NuGet.exe',
	[string] $NuGetVersion = '2.8.6'
)

Write-Verbose "Continuous action: $($Action)"

$ErrorActionPreference = 'Stop'
Write-Verbose "Error action: $($ErrorActionPreference)"

function Invoke-Activity {
	[CmdletBinding()]
	param (
		[string] $Name,
		[scriptblock] $Action
	)

	Write-Progress -Activity $Name
	Invoke-Command -ScriptBlock $Action
	Write-Progress -Activity $Name -Completed
}

function Get-NuGetWorkspaceCommand {
	[CmdletBinding()]
	param ()

	$nuGetPath = Join-Path $WorkspacePath '.nuget'
	$nuGetFile = Join-Path $nuGetPath $NuGetFileName -Resolve -ErrorAction Ignore

	return $nuGetFile
}
function Get-NuGetToolCommand {
	[CmdletBinding()]
	param (
		[string] $NuGetFileUrl = "https://dist.nuget.org/win-x86-commandline/v$($NuGetVersion)/nuget.exe"
	)

	$nuGetPath = Join-Path $ToolsPath (Join-Path 'NuGet' $NuGetVersion)
	$nuGetFile = Join-Path $nuGetPath $NuGetFileName
	if (-not (Test-Path $nuGetFile)) {
		New-Item $nuGetPath -ItemType Directory -Force | Out-Null

		Invoke-Activity "Downloading '$($nuGetFileUrl)'" {
			(New-Object system.net.WebClient).DownloadFile($NuGetFileUrl, $nuGetFile)
		}
	}
	Resolve-Path $nuGetFile | Out-Null
	
	return $nuGetFile
}
function Restore-NuGetPackages {
	[CmdletBinding()]
	param()

	$command = Get-NuGetWorkspaceCommand
	if (-not $command) {
		$command = Get-NuGetToolCommand
	}
	Write-Verbose "NuGet command: $($command)"
	
	Invoke-Activity "Restoring packages..." {
		& $command restore -Verbosity detailed -NonInteractive | Write-Verbose
	}
	$packagesPath = Join-Path $WorkspacePath 'packages' -Resolve

	return $packagesPath
}
function Find-NuGetPackagePath {
	[CmdletBinding()]
	param(
		[string] $PackageName,
		[string] $PackagesPath
	)

	$packagesFile = Join-Path $ActionPath 'packages.config' -Resolve
	$packageVersion = Select-Xml "//package[@id='$($packageName)']/@version" $packagesFile | 
		% { $_.Node.Value }

	$packagePath = Join-Path $PackagesPath (Join-Path "$($PackageName).$($packageVersion)") -Resolve
	
	return $packagePath
}

function Get-SolutionModulePath {
	[CmdletBinding()]
	param (
		[string] $ModuleName
	)

	$modulePath = Join-Path $WorkspacePath $ModuleName -Resolve -ErrorAction Ignore

	return $modulePath
}
function Get-PackageModulePath {
	[CmdletBinding()]
	param (
		[string] $ModuleName,
		[string] $PackagesPath
	)

	$modulesPath = Join-Path (Find-NuGetPackagePath $PackagesPath $ModuleName) "Modules"
	$modulePath = Join-Path $modulesPath $ModuleName -Resolve

	return $modulePath
}
function Find-ModulePath {
	[CmdletBinding()]
	param (
		[string] $ModuleName,
		[string] $PackagesPath
	)

	$modulePath = Get-SolutionModulePath $ModuleName
	if (-not $modulePath) {
		$modulePath = Get-PackageModulePath $ModuleName $PackagesPath
	}

	$modulePath = Join-Path $modulePath "$($ModuleName).psd1"

	return $modulePath
}

Push-Location
try {
	Set-Location $WorkspacePath
	Write-Verbose "Workspace path: $($WorkspacePath)"
		
	$nuGetPackagesPath = Restore-NuGetPackages
	Write-Verbose "Packages path: $($nuGetPackagesPath)"

	$continuousModulePath = Find-ModulePath 'PowerShell.Continuous' $nuGetPackagesPath
	Import-Module $continuousModulePath -Force
	
	Write-Verbose "Action path: $($ActionPath)"

	Invoke-Continuous -ActionDriveRoot $ActionPath -WorkspaceDriveRoot $WorkspacePath -ArtifactsDriveRoot $ArtifactsPath {
		. 'Action:\Invoke-Action.ps1'
	}

	Write-Verbose "Continuous status: success"
} catch {
	Write-Error "Continuous status: $($_.Exception)"
	
	if (-not $SkipExitOnError) {
		exit 1
	}
} finally {
	if ((Get-Location).Path -ne (Pop-Location -PassThru).Path) {
		Write-Verbose "Restored location to '$(Get-Location)'."
	}
}
