#Requires -Version 3.0
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Action,
	[Parameter(Position = 1)]
	[string[]] $Tasks = @('.'),

	[string] $ToolsBasePath = $env:APPDATA,

	[string] $NuGetVersion = '2.8.6',

	[string] $WorkspacePath = (Resolve-Path '.').Path,
	[string] $ActionPath = (Join-Path $WorkspacePath "Continuous.$($Action)" -Resolve),
	[string] $ArtifactsPath = (Join-Path $WorkspacePath '.Artifacts'),

	[switch] $SkipExitOnError
)

Push-Location
try {
	Write-Verbose "Set default error action to '$($ErrorActionPreference)'."
	$ErrorActionPreference = 'Stop'
	
	Write-Verbose "Set location to '$($WorkspacePath)'."
	Set-Location $WorkspacePath
	
	$nugetFileName = 'NuGet.exe'
	$nuGetPath = Join-Path $WorkspacePath '.nuget'
	$nuGetFile = Join-Path $nuGetPath $nugetFileName -Resolve -ErrorAction Ignore 
	if (-not $nuGetFile) {
		$nuGetPath = Join-Path $ToolsBasePath (Join-Path 'NuGet' $NuGetVersion)
		$nuGetFile = Join-Path $nuGetPath $nugetFileName
		if (-not (Test-Path $nuGetFile)) {
			New-Item $nuGetPath -ItemType Directory -Force | Out-Null

			$nuGetFileUrl = "https://dist.nuget.org/win-x86-commandline/v$($NuGetVersion)/nuget.exe"

			Write-Verbose "Download '$($nugetFileName)' ($($NuGetVersion)) in '$($nuGetPath)' from '$($nuGetFileUrl)'."
			(New-Object system.net.WebClient).DownloadFile($nuGetFileUrl, $nuGetFile)
		}
	}

	$nuGetCommand = $nuGetFile
	if (-not $nuGetCommand) {
		Write-Error "Command '$($nugetFileName)' can't be found in '$($nuGetPath)' path."
	}
	Write-Verbose "Restoring NuGet packages."
	& $nuGetCommand restore -Verbosity detailed -NonInteractive 

	$continuousModuleName = 'PowerShell.Continuous'
	$continuousModulePath = Join-Path $WorkspacePath $continuousModuleName -Resolve -ErrorAction Ignore
	if (-not $continuousModulePath) {
		if (Test-Path $ActionPath) {
			Write-Verbose "Search '$($continuousModuleName)' module in '$(ProjectPath)' NuGet packages references."

			$packagesPath = Join-Path $WorkspacePath 'packages' -Resolve -ErrorAction Ignore
			$packagesFile = Join-Path $continuousModulePath 'packages.config' -Resolve -ErrorAction Ignore
			if ($packagesPath -and $packagesFile) {
				$packageName = $continuousModuleName
				$packageVersion = Select-Xml "//package[@id='$($packageName)']/@version" $packagesFile | 
					% { $_.Node.Value }
				
				$continuousModulePath = Join-Path $packagesPath (Join-Path "$($packageName).$($packageVersion)" $continuousModuleName) -Resolve -ErrorAction Ignore
			}
		}

		if (-not $continuousModulePath) {
			Write-Error "Module '$($continuousModuleName)' can't be found."
		}
	}
		
	Import-Module $continuousModulePath -Force
	
	Write-Verbose "Invoke Continuous $($Action) with tasks $(($Tasks | % { ""'$_'"" } ) -join ', ')."
	# FIXME: Invoke-Continuous $Action $Tasks -Verbose

	Write-Verbose "Continuous $($Action) finished succesfully."
} catch {
	Write-Verbose "Continuous $($Action) failed."
	Write-Error "'$($Action) failed: $($_.Exception)"
	
	if (-not $SkipExitOnError) {
		exit 1
	}
} finally {
	if ((Get-Location).Path -ne (Pop-Location -PassThru).Path) {
		Write-Verbose "Restored location to '$(Get-Location)'."
	}
}
