if (-not (Get-PSDrive | ? {$_.Name -eq 'workspace'} )) {
	Write-Host "New Drive 'workspace'"
	New-PSDrive -Name 'workspace' -PSProvider FileSystem -Root (Get-Location).Path -Scope global
}