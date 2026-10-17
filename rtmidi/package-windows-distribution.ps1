param(
    [Parameter(Mandatory = $true)][string]$PackageRoot,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../dist')
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$packageRootPath = (Resolve-Path -LiteralPath $PackageRoot).Path
$version = (Get-Content -LiteralPath (Join-Path $packageRootPath 'VERSION') -Raw).Trim()
if ($version -notmatch '^\d+\.\d+$') { throw 'Invalid package VERSION.' }
foreach ($required in @('bin/key.exe', 'bin/lowkey.exe', 'bin/keylib.exe', 'lib/keylib.k')) {
    if (!(Test-Path -LiteralPath (Join-Path $packageRootPath $required))) { throw "Missing $required" }
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$outputPath = (Resolve-Path -LiteralPath $OutputDirectory).Path

# RtMidi and the WMS DLL also need the Microsoft C++ runtime. Reuse an existing
# staged runtime, or obtain the app-local redistributables from Visual Studio.
$crtMissing = @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') | Where-Object {
    !(Test-Path -LiteralPath (Join-Path $packageRootPath "bin/$_"))
}
if ($crtMissing) {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
    $installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    $redist = Get-ChildItem (Join-Path $installation 'VC/Redist/MSVC/*/x64/Microsoft.VC*.CRT') -Directory |
        Sort-Object FullName -Descending | Select-Object -First 1
    if (!$redist) { throw 'Cannot locate the Visual C++ x64 redistributable DLLs.' }
    Get-ChildItem -LiteralPath $redist.FullName -Filter '*.dll' | Copy-Item -Destination (Join-Path $packageRootPath 'bin')
}

# Use the same pinned Microsoft package as build-windows.ps1. Extract from the
# verified archive, rather than trusting DLLs in a developer's bin directory.
$sdkVersion = '0.99.92-preview.11'
$cache = Join-Path $PSScriptRoot "build/Windows.Devices.Midi2.$sdkVersion"
$sdkArchive = Join-Path $cache 'package.zip'
$expectedHash = '13afc6e6da2adac309ab8c174352f46f1c0ebe2d79e65475bd6274defb73df74'
if (!(Test-Path -LiteralPath $sdkArchive)) {
    New-Item -ItemType Directory -Force -Path $cache | Out-Null
    Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/microsoft/MIDI/releases/download/inbox-preview-11/Windows.Devices.Midi2.$sdkVersion.nupkg" -OutFile $sdkArchive
}
if ((Get-FileHash -LiteralPath $sdkArchive -Algorithm SHA256).Hash -ne $expectedHash) {
    throw 'Windows MIDI Services package SHA-256 mismatch.'
}
$sdkZip = [IO.Compression.ZipFile]::OpenRead($sdkArchive)
try {
    foreach ($file in @('Windows.Devices.Midi2.dll', 'Windows.Devices.Midi2.pri')) {
        $entry = $sdkZip.GetEntry("runtimes/win-x64/native/$file")
        if (!$entry) { throw "Microsoft package is missing $file" }
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $packageRootPath "bin/$file"), $true)
    }
} finally { $sdkZip.Dispose() }
New-Item -ItemType Directory -Force -Path (Join-Path $packageRootPath 'rtmidi') | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'WINDOWS-MIDI-SERVICES-RUNTIME.txt'), (Join-Path $PSScriptRoot 'LICENSE.windows-midi-services') -Destination (Join-Path $packageRootPath 'rtmidi')

$commonReadme = @"
KeyKit $version for Windows (x64)

Extract the entire key folder, then run bin\key.exe. Keep its DLLs alongside it.
The console interpreter is bin\lowkey.exe. To rebuild the library index after
editing it, run bin\keylib.exe with lib as the working directory.

WinMM is the default MIDI backend. Set KEYKIT_MIDI_API=wms before starting
KeyKit to request Windows MIDI Services. See README.windows for details.
Documentation is in doc, library/tools in lib, and sample music in music.
Licenses and WMS preview/runtime information are in LICENSE.txt and rtmidi.
"@
$bundledReadme = $commonReadme + @"


This archive requires Windows 11 25H2 or later. It includes Microsoft's
Windows MIDI Services preview API $sdkVersion (DLL and PRI); no SDK
installation is needed. The Windows MIDI service must be present and enabled.
This is a preview API. See rtmidi\WINDOWS-MIDI-SERVICES-RUNTIME.txt.

For older Windows systems, use key$($version.Replace('.', ''))_win_winmm.zip,
which does not contain the preview API binaries.
"@
$legacyReadme = $commonReadme + @"


This WinMM edition supports Windows 10 or later and excludes the Windows MIDI
Services preview API. Use the default WinMM backend. On supported Windows 11
systems, use key$($version.Replace('.', ''))_win.zip for the bundled WMS API.
"@

function Write-DistributionZip([string]$path, [bool]$includeWms, [string]$readme) {
    $stream = [IO.File]::Open($path, [IO.FileMode]::Create)
    $zip = New-Object IO.Compression.ZipArchive($stream, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in Get-ChildItem -LiteralPath $packageRootPath -File -Recurse) {
            $relative = $file.FullName.Substring($packageRootPath.Length + 1).Replace('\', '/')
            if ($relative -eq 'README.txt') { continue }
            if (!$includeWms -and $relative -in @('bin/Windows.Devices.Midi2.dll', 'bin/Windows.Devices.Midi2.pri')) { continue }
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, "key/$relative", [IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
        $entry = $zip.CreateEntry('key/README.txt')
        $writer = New-Object IO.StreamWriter($entry.Open(), (New-Object Text.UTF8Encoding($false)))
        try { $writer.Write($readme) } finally { $writer.Dispose() }
    } finally { $zip.Dispose(); $stream.Dispose() }
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText("$path.sha256", "$hash  $([IO.Path]::GetFileName($path))`n")
    Write-Host "Created $path"
}

$stem = 'key' + $version.Replace('.', '') + '_win'
Write-DistributionZip (Join-Path $outputPath "$($stem)_winmm.zip") $false $legacyReadme
Write-DistributionZip (Join-Path $outputPath "$stem.zip") $true $bundledReadme
