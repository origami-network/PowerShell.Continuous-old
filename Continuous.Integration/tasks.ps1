# TODO: This shoudl be extracted from this file
New-PSDrive Workspace -Root .. -PSProvider FileSystem
New-PSDrive Action -Root . -PSProvider FileSystem
if (-not (Test-Path Workspace:\.Artifacts)) {
	New-Item Workspace:\.Artifacts -ItemType Directory
	New-PSDrive Actions -Root . -PSProvider FileSystem
}

Action:\Tasks.Version.ps1
task Version @(
	Get-RunnerVersion
	Set-VersionDrives
	Get-AssemblyInfoVersion
	Merge-Version
	Edit-AssemblyInfoVersion
	Publish-Version
)