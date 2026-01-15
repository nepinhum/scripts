[CmdletBinding(PositionalBinding = $false)]
param (
	[string]$php = "",
	[switch]$Loop = $false,
	[string]$file = "",
	[string][Parameter(ValueFromRemainingArguments)]$extraAquaRelayArgs
)

if ($php -ne "") {
	$binary = $php
}
elseif (Test-Path "bin\php\php.exe") {
	$env:PHPRC = ""
	$binary = "bin\php\php.exe"
}
elseif (Get-Command php -ErrorAction SilentlyContinue) {
	$binary = "php"
}
else {
	Write-Host "Couldn't find a PHP binary in system PATH or $pwd\bin\php" -ForegroundColor Red
	Write-Host "Please download it from https://github.com/pmmp/PHP-Binaries/releases/tag/pm5-php-8.2-latest"
	pause
	exit 1
}

if ($file -eq "") {
	if (Test-Path "AquaRelay.phar") {
		$file = "AquaRelay.phar"
	}
	elseif (Test-Path "src\AquaRelay.php") {
		$file = "src\AquaRelay.php"
	}
	else {
		Write-Host "AquaRelay not found" -ForegroundColor Red
		Write-Host "Please download it from https://github.com/AquaRelay/AquaRelay/releases"
		pause
		exit 1
	}
}

function Start-AquaRelay {
	& $binary $file @extraAquaRelayArgs
}

$loops = 0

Start-AquaRelay

while ($Loop) {
	if ($loops -ne 0) {
		Write-Host ("Restarted {0} times" -f $loops) -ForegroundColor Yellow
	}

	$loops++
	Write-Host "To escape the loop, press CTRL+C now. Otherwise, wait 5 seconds for the server to restart."
	Write-Host ""
	Start-Sleep -Seconds 5
	Start-AquaRelay
}
