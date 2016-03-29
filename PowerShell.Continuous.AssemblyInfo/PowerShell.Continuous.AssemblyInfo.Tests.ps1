$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = 'PowerShell.Continuous.AssemblyInfo'

Describe 'PowerShell.Continuous.AssemblyInfo Module' -Tags "Scope-Black" {
	# TBD: White the scope need to be global in order to exported module function see it 
	New-PSDrive -Name 'Action' -PSProvider FileSystem -Root 'TestDrive:\' -Scope global
	New-Item 'TestDrive:\Properties' -ItemType directory
	Import-Module "$here\$sut.psd1"

	$filePath = 'Action:\Properties\AssemblyInfo.Version.cs'

	It 'exports Get-AssemblyInfoVersion command' {
		Get-Command -Module $sut | ? { $_.Name -eq 'Get-AssemblyInfoVersion' } | should not beNullOrEmpty
	}
	It 'exports Edit-AssemblyInfoVersion command' {
		Get-Command -Module $sut | ? { $_.Name -eq 'Edit-AssemblyInfoVersion' } | should not beNullOrEmpty
	}

	BeforeEach {
		$script:content | Out-File $filePath
	}

	Context 'All versions in AssemblyInfo file' {
		$script:content = @(
			'[assembly: AssemblyVersion("1.0.0.0")]'
			'[assembly: AssemblyFileVersion("2.0.0.0")]'
			'[assembly: AssemblyInformationalVersion("3.0.0.0")]'
		)

		It 'gets Informational version as AssemblyInfo version' {
			Get-AssemblyInfoVersion | should be "3.0.0.0"
		}

		It 'updates all versions to first one' {
			Edit-AssemblyInfoVersion "4.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyFileVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyInformationalVersion("4.0.0.0")]'))
		}

		It 'updates AssemblyVersion to first one and other to seccond' {
			Edit-AssemblyInfoVersion "4.0.0.0" "5.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyFileVersion("5.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyInformationalVersion("5.0.0.0")]'))
		}

		It 'updates aproporate versions in given order' {
			Edit-AssemblyInfoVersion "4.0.0.0" "5.0.0.0" "6.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyFileVersion("5.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyInformationalVersion("6.0.0.0")]'))
		}
	}

	Context 'No informational versions in AssemblyInfo file' {
		$script:content = @(
			'[assembly: AssemblyVersion("1.0.0.0")]'
			'[assembly: AssemblyFileVersion("2.0.0.0")]'
		)

		It 'gets File version as AssemblyInfo version' {
			Get-AssemblyInfoVersion | should be "2.0.0.0"
		}

		It 'updates all versions to first one' {
			Edit-AssemblyInfoVersion "4.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyFileVersion("4.0.0.0")]'))
			$filePath | should not contain ([regex]::Escape('AssemblyInformationalVersion'))
		}

		It 'updates AssemblyVersion to first one and other to seccond' {
			Edit-AssemblyInfoVersion "4.0.0.0" "5.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyFileVersion("5.0.0.0")]'))
			$filePath | should not contain ([regex]::Escape('AssemblyInformationalVersion'))
		}

		It 'updates aproporate versions in given order' {
			Edit-AssemblyInfoVersion "4.0.0.0" "5.0.0.0" "6.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyFileVersion("5.0.0.0")]'))
			$filePath | should not contain ([regex]::Escape('AssemblyInformationalVersion'))
		}
	}

	Context 'No informational and file versions in AssemblyInfo file' {
		$script:content = @(
			'[assembly: AssemblyVersion("1.0.0.0")]'
		)

		It 'gets File version as AssemblyInfo version' {
			Get-AssemblyInfoVersion | should be "1.0.0.0"
		}

		It 'updates all versions to first one' {
			Edit-AssemblyInfoVersion "4.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should not contain ([regex]::Escape('AssemblyFileVersion'))
			$filePath | should not contain ([regex]::Escape('AssemblyInformationalVersion'))
		}

		It 'updates AssemblyVersion to first one and other to seccond' {
			Edit-AssemblyInfoVersion "4.0.0.0" "5.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should not contain ([regex]::Escape('AssemblyFileVersion'))
			$filePath | should not contain ([regex]::Escape('AssemblyInformationalVersion'))
		}

		It 'updates aproporate versions in given order' {
			Edit-AssemblyInfoVersion "4.0.0.0" "5.0.0.0" "6.0.0.0"
			
			$filePath | should contain ([regex]::Escape('[assembly: AssemblyVersion("4.0.0.0")]'))
			$filePath | should not contain ([regex]::Escape('AssemblyFileVersion'))
			$filePath | should not contain ([regex]::Escape('AssemblyInformationalVersion'))
		}
	}
}
