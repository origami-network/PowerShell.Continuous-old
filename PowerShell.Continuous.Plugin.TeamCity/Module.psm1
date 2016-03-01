Remove-Item function:Enter-Build -Force

function Enter-Build {
	Write-Host "Enter build"
}
function Enter-BuildTask {
	Write-Host  "Enter task $($Task.Name)"
}
function Enter-BuildJob($Number) {
	Write-Host "Enter job $($Number) of $($Task.Name)"
}

function Exit-Build {
	Write-Host "Exit build"
}
function Exit-BuildTask {
	Write-Host  "Exit task $($Task.Name)"
}
function Exit-BuildJob($Number) {
	Write-Host "Enter job $($Number) of $($Task.Name)"
}

function Export-Build {}
function Import-Build {}
