@echo off
TITLE AquaRelay Proxy for Minecraft: Bedrock Edition
cd /d %~dp0

set PHP_BINARY=

where /q php.exe
if %ERRORLEVEL%==0 (
	set PHP_BINARY=php
)

if exist bin\php\php.exe (
	set PHPRC=""
	set PHP_BINARY=bin\php\php.exe
)

if "%PHP_BINARY%"=="" (
	echo Couldn't find a PHP binary in system PATH or "%~dp0bin\php"
	echo Please download it from https://github.com/pmmp/PHP-Binaries/releases/tag/pm5-php-8.2-latest
	pause
	exit 1
)

if exist AquaRelay.phar (
	set AQUARELAY_FILE=AquaRelay.phar
) else if exist src\AquaRelay.php (
	set AQUARELAY_FILE=src\AquaRelay.php
) else (
	echo AquaRelay not found
	echo Please download it from https://github.com/AquaRelay/AquaRelay/releases
	pause
	exit 1
)

if exist bin\mintty.exe (
	start "" bin\mintty.exe ^
		-o Columns=100 ^
		-o Rows=30 ^
		-o AllowBlinking=0 ^
		-o FontQuality=3 ^
		-o Font="Consolas" ^
		-o FontHeight=10 ^
		-o CursorType=0 ^
		-o CursorBlinks=1 ^
		-h error ^
		-t "AquaRelay Proxy" ^
		-w max ^
		%PHP_BINARY% %AQUARELAY_FILE% --enable-ansi %*
) else (
	%PHP_BINARY% %AQUARELAY_FILE% %* || pause
)