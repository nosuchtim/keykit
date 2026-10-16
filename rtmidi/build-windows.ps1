param(
    [ValidateSet('Debug', 'Release')][string]$Configuration = 'Release',
    [ValidateSet('x64', 'Win32')][string]$Platform = 'x64',
    [switch]$Test
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

# Keep generated headers, downloaded metadata, and binaries out of the source tree.
$buildDir = Join-Path $PSScriptRoot "build/$Platform"
$cmake = Get-Command cmake -ErrorAction SilentlyContinue
if ($cmake) {
    $cmakePath = $cmake.Source
} else {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
    $installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    $cmakePath = Join-Path $installation 'Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/cmake.exe'
}
if (!(Test-Path -LiteralPath $cmakePath)) {
    throw 'CMake 3.24 or later is required (available from the Visual Studio Installer).'
}

# Microsoft supplies no 32-bit WMS API. Keep the legacy Win32 configuration WinMM-only.
$withWms = $Platform -eq 'x64'
$configureArgs = @('-S', $PSScriptRoot, '-B', $buildDir, '-A', $Platform,
    "-DKEYKIT_RTMIDI_WMS=$($withWms.ToString().ToUpperInvariant())", '-DBUILD_TESTING=ON')

if ($withWms) {
    # Prefer explicitly supplied metadata or a Windows SDK with the API included.
    $sdkRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits/10'
    if ($env:WindowsSdkDir) { $sdkRoot = $env:WindowsSdkDir }
    $sdkProjection = Get-ChildItem (Join-Path $sdkRoot 'Include/*/cppwinrt/winrt/Windows.Devices.Midi2.h') -ErrorAction SilentlyContinue
    if (!$env:WindowsMidiServices_ROOT -and !$env:WindowsMidiServices_WINMD -and !$sdkProjection) {
        # Pinned metadata only; this does not install or redistribute the preview runtime.
        $packageDir = Join-Path $PSScriptRoot 'build/Windows.Devices.Midi2.0.99.92-preview.11'
        $metadata = Join-Path $packageDir 'ref/native/Windows.Devices.Midi2.winmd'
        if (!(Test-Path -LiteralPath $metadata)) {
            New-Item -ItemType Directory -Force -Path $packageDir | Out-Null
            $archive = Join-Path $packageDir 'package.zip'
            $url = 'https://github.com/microsoft/MIDI/releases/download/inbox-preview-11/Windows.Devices.Midi2.0.99.92-preview.11.nupkg'
            Write-Host 'Downloading Windows MIDI Services preview metadata for compilation...'
            Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $archive
            $expected = '13afc6e6da2adac309ab8c174352f46f1c0ebe2d79e65475bd6274defb73df74'
            if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expected) {
                throw 'Windows MIDI Services package SHA-256 mismatch.'
            }
            Expand-Archive -LiteralPath $archive -DestinationPath $packageDir -Force
        }
        $configureArgs += "-DWindowsMidiServices_WINMD=$metadata"
    } elseif ($env:WindowsMidiServices_WINMD) {
        $configureArgs += "-DWindowsMidiServices_WINMD=$env:WindowsMidiServices_WINMD"
    } elseif ($env:WindowsMidiServices_ROOT) {
        # Clear a previously cached metadata file when the user changes packages.
        $configureArgs += @('-UWindowsMidiServices_WINMD', "-DWindowsMidiServices_ROOT=$env:WindowsMidiServices_ROOT")
    } else {
        $configureArgs += '-UWindowsMidiServices_WINMD'
    }
}

& $cmakePath @configureArgs
if ($LASTEXITCODE) { throw 'RtMidi CMake configuration failed.' }
$targets = @('rtmidi')
if ($Test) { $targets += @('backend_selection_test', 'port_names_test', 'rtmidi_probe') }
if ($Test -and $withWms) { $targets += 'wms_loopback_check' }
& $cmakePath --build $buildDir --config $Configuration --target @targets
if ($LASTEXITCODE) { throw 'RtMidi build failed.' }
if ($Test) {
    $ctestPath = Join-Path (Split-Path $cmakePath) 'ctest.exe'
    & $ctestPath --test-dir $buildDir -C $Configuration --output-on-failure
    if ($LASTEXITCODE) { throw 'RtMidi tests failed.' }
}
