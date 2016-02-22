#Requires -Version 3.0
[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Action,
	[Parameter(Position = 1)]
	[string[]] $Tasks = @('.'),

	[string] $ToolsBasePath = $env:APPDATA,

	[string] $WorkspacePath = (Resolve-Path '.').Path,
	[string] $ProjectPath = (Join-Path $WorkspacePath '_Continuous' -Resolve),
	[string] $ArtifactsPath = (Join-Path $WorkspacePath '.Artifacts'),

	[switch] $SkipExitOnError
)

$_ErrorActionPreference = $ErrorActionPreference

try {
	$ErrorActionPreference = 'Stop'
	Write-Verbose "Set default error action to '$($ErrorActionPreference)'."
	
	# 'TODO: search nuget in workspace or bootstrap it'

	$continuousModuleName = 'PowerShell.Continuous'
	$continuousModulePath = Join-Path $WorkspacePath $continuousModuleName -Resolve -ErrorAction Ignore
	if (-not $continuousModulePath) {
		if (Test-Path $ProjectPath) {
			Write-Verbose "Search '$($continuousModuleName)' module in '$(ProjectPath)' NuGet packages references."

			$packagesPath = Join-Path $WorkspacePath 'packages' -Resolve -ErrorAction Ignore
			$packagesFile = Join-Path $continuousModulePath 'packages.config' -Resolve -ErrorAction Ignore
			if ($packagesPath -and $packagesFile) {
				$packageName = $continuousModuleName
				$packageVersion = Select-Xml "//package[@id='Invoke-Builda']/@version" $packagesFile | 
					% { $_.Node.Value }
				
				$continuousModulePath = Join-Path $packagesPath (Join-Path "$($packageName).$($packageVersion)" $continuousModuleName) -Resolve -ErrorAction Ignore
			}
		}

		# TBD: It is good idea to bootsrap module by downloading it?

		if (-not $continuousModulePath) {
			Write-Error "Module '$($continuousModuleName)' can't be found."
		}
	}
		
	Import-Module $continuousModulePath -Force
	
	Write-Verbose "Invoke Continuous $($Action) with tasks $(($Tasks | % { ""'$_'"" } ) -join ', ')."
	Invoke-Continuous $Action $Tasks

	Write-Verbose "Continuous $($Action) finished succesfully."

} catch {
	Write-Verbose "Continuous $($Action) failed."
	Write-Error "'$($Action) failed: $($_.Exception)"
	
	if ($SkipExitOnError) {
		exit 1
	}
} finally {
	if ($ErrorActionPreference -ne $_ErrorActionPreference) {
		Write-Verbose "Restore error action to '$($_ErrorActionPreference)'."
		$ErrorActionPreference = $_ErrorActionPreference
	}
}
