# RtMidi in KeyKit

The four files in `cpp/`, `LICENSE`, the two find modules in `cmake/`, and
`WINDOWS.upstream.md` come from RtMidi 6.1.0. The only local change to those
upstream files is removal of trailing whitespace on one line in `RtMidi.cpp`:

- Release: https://github.com/thestk/rtmidi/releases/tag/6.1.0
- Commit: `7e31b5bfcc9350058fbaf81d62a8eb39dd29c5f7`
- Source archive SHA-256:
  `83c4bb79ae813020873b87e09de8dad979ff0994597cfd33f4a6c416e8c7fcd5`

KeyKit's Windows build uses the local `CMakeLists.txt` and `build-windows.ps1`
to build a static library. The x64 build includes WinMM and Windows MIDI
Services (WMS). The legacy Win32 configuration includes WinMM only because
Microsoft supplies no 32-bit WMS API. The runtime policy lives in
`keykit_backend.cpp`, outside the upstream sources.

WinMM remains the default even when WMS is available. Set `KEYKIT_MIDI_API=wms`
before starting KeyKit to request WMS, or `KEYKIT_MIDI_API=winmm` to explicitly
select WinMM. Values are case insensitive. Unset or empty means WinMM. Unknown
values and unavailable WMS produce a diagnostic and use WinMM. `Devmidi` is
`"winmm"` or `"wms"` according to the backend actually initialized.

## Shared WMS loopbacks

When WMS is selected, `keykit_loopbacks.cpp` uses the native
`Windows.Devices.Midi2.Transports.Loopback.MidiLoopbackManager` before RtMidi
enumerates ports. It ensures three pairs named `KeyKit Loopback N output` and
`KeyKit Loopback N input`, for N = 1, 2, 3. Send to `output` and receive from
`input`. Internally these are A and B respectively. These use Windows' built-in
paired loopback transport, rather than the separately installed BasicLoopback transport
or a third-party driver. Each endpoint also has a MIDI 1.0 view for WinMM apps.

In KeyKit, each pair appears as one logical port named `KeyKit Loopback 1`,
`KeyKit Loopback 2`, or `KeyKit Loopback 3` in both the input and output lists.
Selecting the same name in two instances routes output A to input B. The
reverse sides are hidden. This presentation applies to both WinMM and WMS;
other Windows applications see the native input/output names. Native endpoints
remain bidirectional; the names indicate intended use, not a transport restriction.
Only the three exact reserved input/output names and previous A/B names are
adapted; custom or renamed endpoints keep their native presentation. Saved
selections using the A/B names or the previous merged AB names need updating.

Stable endpoint IDs and an interprocess startup mutex avoid creating duplicates.
Existing pairs with the expected names are also reused. The code preserves
existing configuration and muted state. Previous default A/B names are migrated
in place with `MidiLoopbackManager.UpdateLoopback`, preserving pair association
and endpoint IDs. Custom names are left alone. Setup waits briefly for MIDI 1.0
ports and names to be published, and leaves pairs alive on exit for other applications. They are
transient service resources: after a service restart the next WMS startup
recreates them. The setup does not write the service's persistent configuration.
Failure to create loopbacks is logged to stderr/Windows debug output and does
not disable other MIDI ports or open a startup dialog. WinMM selection is a no-op.
Older services that reject in-place renaming keep existing A/B pairs usable and
log a diagnostic; new input/output names take effect when those transient pairs
are recreated after a service restart. Startup never removes active pairs.

## Port names

KeyKit builds RtMidi with `RTMIDI_DO_NOT_ENSURE_UNIQUE_PORTNAMES` to get the
driver's WinMM names without RtMidi's appended enumeration indices. Both input
and output labels come through the selected RtMidi backend. Thus an endpoint
named `loopMIDI Port 1` appears as `loopMIDI Port 1` in both directions, even
when a synth shifts output indices relative to input indices. Original digits
in driver names are never stripped or guessed.

`keykit_port_names.cpp` preserves unique names and labels only actual duplicates
within one direction as `Name [duplicate N]`. All literal driver names are
reserved before labels are generated, avoiding collisions with a driver whose
name already includes such a suffix. Duplicate labels are occurrence numbers,
not persistent identities or a way to pair same-named hardware across directions.
`keykit_midi_port_list` filters and aliases the reserved loopback sides before
duplicate labeling and KeyKit's device limit. Each visible entry carries its
original native index for opening the correct endpoint. KeyKit's compact
device numbers are used independently for callbacks and message delivery.

Saved output selections that used RtMidi's old suffixes must be updated. In the
usual loopMIDI setup, old output `loopMIDI Port 1` becomes `loopMIDI Port`, and
old output `loopMIDI Port 1 2` becomes `loopMIDI Port 1`. These old names cannot
be aliases because they may themselves be valid driver names. KeyKit's
`inport()` / `outport()` lookup now prefers exact literal names, retaining the
existing partial/regular-expression matching as a fallback.

## Building and testing

Install Visual Studio 2022 or newer with Desktop development with C++, CMake
3.24 or newer, and Windows SDK 10.0.22000 or newer. The WMS sources use C++20;
KeyKit's C sources retain their existing compiler settings. Build KeyKit through
`makewindows.bat`, or run the library tests separately from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File rtmidi/build-windows.ps1 -Test
```

The tests cover backend selection, port names and duplicate/collision handling,
and probe the real library, including construction and enumeration of the
selected backend. The WinMM probe compares RtMidi's names directly to driver
capabilities in both directions. When `bin/lowkey.exe` is available, CTest also
runs `tests/midi_port_lookup.k` for exact and partial name selection. The tests
never open a MIDI port or send MIDI. Sending and receiving with physical devices
still requires a manual check on a WMS-capable machine.

The explicit loopback integration check is built for x64 alongside the tests:

```powershell
# Creates missing KeyKit loopbacks and checks repeated and existing-pair reuse.
.\rtmidi\build\x64\Release\wms_loopback_check.exe --ensure
# Reads the current pairs without changing them.
.\rtmidi\build\x64\Release\wms_loopback_check.exe --verify
# Sends test SysEx through each logical loopback (no physical device).
.\rtmidi\build\x64\Release\wms_loopback_check.exe --roundtrip
# Checks the same names and routes through WinMM.
.\rtmidi\build\x64\Release\wms_loopback_check.exe --roundtrip-winmm
```

These explicit checks need the WMS runtime next to the test executable on
systems without a Windows-supplied API. Ordinary CTest runs only the WinMM
no-op branch and does not create loopbacks or send messages.

The build first uses `WindowsMidiServices_WINMD` or `WindowsMidiServices_ROOT`
when set, then SDK-provided API headers. Otherwise it downloads Microsoft's
SHA-256-verified `Windows.Devices.Midi2.0.99.92-preview.11.nupkg` to the ignored
`build/` directory and generates the C++/WinRT projection from its metadata.
The first download is approximately 103 MB. The package is cached for later
builds. The build does not install the preview API or MIDI service, or bundle
preview DLLs into KeyKit's distribution.

## Running Windows MIDI Services

The WMS backend needs Windows 11 25H2 or later with the `Windows.Devices.Midi2`
API available and the MIDI service running in its full mode. Machines without
the API or service continue to use WinMM. Upgrading RtMidi alone does not
activate WMS.

As of October 2026, Microsoft's API is a preview. To test it before Windows
supplies the API, follow Microsoft's preview setup instructions and place
`Windows.Devices.Midi2.dll` and `Windows.Devices.Midi2.pri` from the package's
`runtimes/win-x64/native` directory next to `key.exe` on a supported system.
These files are deliberately not copied automatically. Read Microsoft's
preview distribution terms before shipping them, and remove app-local preview
files when migrating to the Windows-supplied API.

See [RtMidi's Windows guide](WINDOWS.upstream.md) and
[Microsoft's preview release](https://github.com/microsoft/MIDI/releases/tag/inbox-preview-11)
for the runtime requirements and preview instructions.

The standalone Linux build still uses its existing direct ALSA integration;
it does not compile this CMake target or the Windows backend/loopback helpers,
and KEYKIT_MIDI_API does not affect it. The shared KeyKit library's inport() /
outport() exact-name preference also applies on Linux: an exact name can now
win over an earlier partial match. Partial/regular-expression matching remains
the fallback, numeric selections are unchanged, and ALSA port names and routing
are unchanged. See [the Linux guide](../README.linux).
The Go bindings in this directory are separate from KeyKit's Windows C build.
The KeyKit-only helper .cpp files have Go build constraints excluding them
from cgo; cgo compiles RtMidi through rtmidi_stub.cpp using its own platform
flags. The vendored RtMidi update therefore also reaches Go consumers, but
KeyKit's Windows backend selection and loopback setup do not.
