$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'Join-PsModulePath'

Describe 'Join-PsModulePath' -Tags "Scope-White" {
	. "$here\$sut.ps1"

	It 'does not change the order of orginal path if nothing was added' {
		$orginal = $env:PSModulePath

		$result = & $sut @()

		$env:PSModulePath | Should Be $orginal
		$result | should be $orginal
	}

	It 'expands path for PSDrive' {
		$result = & $sut 'TestDrive:\'

		$result | should match ([regex]::Escape((Get-PSDrive TestDrive).Root))
		$result | should not match 'TestDrive'
	}

	It 'uses '';'' character as seperator' {
		$orginal = $env:PSModulePath

		$result = & $sut 'TestDrive:\'

		($result -split ';').Count | should be (($orginal -split ';').Count + 1)
	}

	It 'adds new one as first' {
		New-Item 'TestDrive:\as-first-directory' `
			-ItemType directory -Force -ErrorAction Stop
		$orginal = $env:PSModulePath -split ';'

		$result = (& $sut 'TestDrive:\as-first-directory') -split ';'

		$result | Select-Object -First 1 | should match 'as-first-directory'
	}

	It 'preserves the order of apperance' {
		New-Item 'TestDrive:\directory1',
			'TestDrive:\directory2\subdirectory',
			'TestDrive:\directory3\subdirectory',
			'TestDrive:\directory4' `
			-ItemType directory -Force -ErrorAction Stop

		$result = (Join-PsModulePath 'TestDrive:\directory1',
			'TestDrive:\*\subdirectory',
			'TestDrive:\directory4'
		) -split ';'

		$result | Select-Object -First 1 | should match 'directory1'
		$result | Select-Object -Skip 1 -First 1 | should match 'subdirectory'
		$result | Select-Object -Skip 2 -First 1 | should match 'subdirectory'
		$result | Select-Object -Skip 3 -First 1 | should match 'directory4'
	}

	It 'allows to use ''*'' for matching' {
		New-Item 'TestDrive:\directory1\subdirectory', 'TestDrive:\directory2\subdirectory' `
			-ItemType directory -Force -ErrorAction Stop

		$result = & $sut 'TestDrive:\*\subdirectory'

		$result | should match 'directory1'
		$result | should match 'directory2'
	}
	
	It 'Skip the files' {
		New-Item 'TestDrive:\directory1',
			'TestDrive:\directory2' `
			-ItemType directory -Force -ErrorAction Stop
		New-Item 'TestDrive:\file1',
			'TestDrive:\directory2\file2' `
			-ItemType file -Force -ErrorAction Stop		

		$result = & $sut 'TestDrive:\*',
			'TestDrive:\directory2\file2'

		$result | should match 'directory1'
		$result | should match 'directory2'
		$result | should not match 'file1'
		$result | should not match 'file2'
	}	 

	It 'reports error if try to add not existed path' {
		$orginal = $Error.Count

		$result = & $sut 'TestDrive:\not-exists'

		$Error.Count | should be ($orginal + 1)
		$result | should not match 'not-exists'
	}
}