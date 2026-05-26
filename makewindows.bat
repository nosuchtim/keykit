@echo off
setlocal

cd /d "%~dp0"

call :find_vcvars64
if errorlevel 1 exit /b 1

echo Using Visual Studio environment: %VCVARS64%
call "%VCVARS64%"
if errorlevel 1 exit /b %errorlevel%

nmake distribution_nt
exit /b %errorlevel%

:find_vcvars64
set "VCVARS64="
set "PF=%ProgramFiles%"
set "PF86=%ProgramFiles(x86)%"

set "VSWHERE=%PF86%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%VSWHERE%" (
	for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
		if exist "%%I\VC\Auxiliary\Build\vcvars64.bat" (
			set "VCVARS64=%%I\VC\Auxiliary\Build\vcvars64.bat"
			goto :found_vcvars64
		)
	)
)

for %%Y in (2026 2022 2019 2017) do (
	for %%E in (Community Professional Enterprise BuildTools Preview) do (
		if exist "%PF%\Microsoft Visual Studio\%%Y\%%E\VC\Auxiliary\Build\vcvars64.bat" (
			set "VCVARS64=%PF%\Microsoft Visual Studio\%%Y\%%E\VC\Auxiliary\Build\vcvars64.bat"
			goto :found_vcvars64
		)
		if exist "%PF86%\Microsoft Visual Studio\%%Y\%%E\VC\Auxiliary\Build\vcvars64.bat" (
			set "VCVARS64=%PF86%\Microsoft Visual Studio\%%Y\%%E\VC\Auxiliary\Build\vcvars64.bat"
			goto :found_vcvars64
		)
	)
)

echo Unable to find a Visual Studio vcvars64.bat with C++ build tools.
echo Install Visual Studio Build Tools or run this from a Developer Command Prompt.
exit /b 1

:found_vcvars64
exit /b 0
