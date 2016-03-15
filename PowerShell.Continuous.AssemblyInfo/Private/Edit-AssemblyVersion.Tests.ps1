$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Get-AssemblyVersion.ps1"

$sut = 'Edit-AssemblyVersion'

Describe 'Edit-AssemblyVersion' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	$kinds = @('', 'File', 'Informational')
	$filePath = 'TestDrive:\AssemblyInfo.Version.cs'
	$dateInPast = (Get-Date).Date.AddDays(-1);
	$unmodified = '1.0.0.0'
	$modified = '0.0.0.0'

	BeforeEach {
		$script:content | Out-File $filePath
		(Get-Item $filePath).LastWriteTime = $dateInPast;
	}

	Context "All versions in AssemblyInfo file" {
		$script:content = @(
			'[assembly: AssemblyVersion("1.0.0.0")]'
			'[assembly: AssemblyFileVersion("1.0.0.0")]'
			'[assembly: AssemblyInformationalVersion("1.0.0.0")]'
		)
		
		It 'updates AssemblyVersion to diffrent version' {
			& $sut $filePath $modified

			(Get-Item $filePath).LastWriteTime | should not be $dateInPast
			Get-AssemblyVersion $filePath | should be $modified
			Get-AssemblyVersion $filePath -Kind File | should be $unmodified
			Get-AssemblyVersion $filePath -Kind Informational | should be $unmodified
		}

		It 'updates AssemblyFileVersion to diffrent version' {
			& $sut $filePath -Kind File $modified

			(Get-Item $filePath).LastWriteTime | should not be $dateInPast
			Get-AssemblyVersion $filePath | should be $unmodified
			Get-AssemblyVersion $filePath -Kind File | should be $modified
			Get-AssemblyVersion $filePath -Kind Informational | should be $unmodified
		}

		It 'updates AssemblyInformationalVersion to diffrent version' {
			& $sut $filePath -Kind Informational $modified

			(Get-Item $filePath).LastWriteTime | should not be $dateInPast
			Get-AssemblyVersion $filePath | should be $unmodified
			Get-AssemblyVersion $filePath -Kind File | should be $unmodified
			Get-AssemblyVersion $filePath -Kind Informational | should be $modified
		}

		$kinds | % {
			$kind = $_

			It "does not update Assembly$($kind)Version if same version" {
				$same = Get-FileHash $filePath

				& $sut $filePath -Kind $kind $unmodified

				(Get-Item $filePath).LastWriteTime | should be $dateInPast
				Compare-Object (Get-FileHash $filePath) $same | should beNullOrEmpty
			}
		}
	}

	Context "No versions in AssemblyInfo file" {
		$script:content = @(
			'// No Assembly*Version'
		)
		
		$kinds | % {
			$kind = $_

			It "does not update Assembly$($kind)Version if not found" {
				$same = Get-FileHash $filePath

				$invoke = {
					& $sut $filePath $modified -Kind $kind -ErrorAction Stop
				}

				$invoke | should not throw
				(Get-Item $filePath).LastWriteTime | should be $dateInPast
				Compare-Object (Get-FileHash $filePath) $same | should beNullOrEmpty
			}
		}
	}
}
