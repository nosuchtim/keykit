KeyKit - Musical Fun with Windows, Tasks, and Objects

by Tim Thompson (me@timthompson.com)

For use on Windows, unzip [dist/key88_win.zip](dist/key88_win.zip) and execute
the bin/key.exe you find inside.

KeyKit 8.8 keeps WinMM as the default Windows MIDI backend and adds optional
Windows MIDI Services (WMS) support. Set `KEYKIT_MIDI_API=wms` before launching
to request WMS; unavailable WMS falls back to WinMM. WMS startup creates or
reuses three shared KeyKit loopback pairs for routing between applications.
See [README.windows](README.windows) for setup, runtime requirements, loopback
usage, and migration of saved MIDI port names, and
[rtmidi/README.keykit.md](rtmidi/README.keykit.md) for build and test details.
The Windows package does not include Microsoft's preview WMS runtime.

Linux continues to use its direct ALSA sequencer backend. The shared MIDI
port lookup now prefers exact names before partial/regular-expression matches;
see [README.linux](README.linux) for the effect on saved selections.

Other platforms that should work: dist/key_raspbian.zip (Raspberry Pi/ARM) and dist/key_linux.zip (Linux/Intel).

You'll find formatted documentation in:
<ul>
<li>
doc/tutorial.html (Tutorial)
<li>
doc/language.html (Language Reference)
<li>
lib/index.html (GUI Tools in the lib directory)
<li>
doc/faq.html (FAQ)
<li>
doc/keyvar.html (Special Variables)
<li>
doc/libdoc.html (Library functions)
<li>
doc/hacking.html (Hacking guidance)
</ul>

See the README.* files for platform-specific info on compiling.
See the doc directory for other documentation.  In particular,
see doc/porting for details on the machine-dependent support
needed for a given platform.

Other than for the distributions mentioned above, much of the machine-dependent support
in the mdep directory is probably obsolete and will no longer work without modification,
but is being retained for future use.

BTW, when you see "nt" in names - e.g. the mdep/nt directory, or the install_nt target
in the makefile - it refers to the Windows version.  The fact that it refers to Windows NT
indicates just how ancient KeyKit is.  :-)

