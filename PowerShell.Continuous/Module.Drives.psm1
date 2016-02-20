$module = $ExecutionContext.SessionState.Module
$data = $module.PrivateData

function Set-Drives {
	[CmdletBinding()]
	param (
		[string] $WorkspaceDriveRoot = (Get-Location).Path,
		[string] $ProjectDriveRoot,
		[string] $ArtifactsDriveRoot,

		[string] $Scope = 1
	)

	Remove-Drives

	$data.Drives | 
		% {
			$rootVariable = Get-Variable "$($_.Name)DriveRoot" -ErrorAction SilentlyContinue
			$root = if ($rootVariable -and $rootVariable.Value) { $rootVariable.Value } else { $_.Root }

			if ($_.Create -and -not (Test-Path $root)) {
				New-Item $root -ItemType directory -Force
			}

			New-PSDrive -Name $_.Name -Root $root -Scope $Scope -PSProvider FileSystem 
		}
}

function Remove-Drives {
	[CmdletBinding()]
	param ()

	$data.Drives |
		% { Get-PSDrive -Name $_.Name -ErrorAction SilentlyContinue } |
		? { $_ } |
		% { $_ | Remove-PSDrive -Force }
}
