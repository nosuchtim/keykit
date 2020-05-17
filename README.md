KeyKit - Musical Fun with Windows, Tasks, and Objects

by Tim Thompson (me@timthompson.com)

For use on Windows, just unzip the dist/key_nt.zip and execute the bin/key.exe you find inside.

Other platforms that should work: dist/key_raspbian.zip (Raspberry Pi/ARM) and dist/key_linux_alsa (Linux/Intel).

See top-level makefile for instructions on compiling.  See the doc directory
for other documentation.  In particular, see doc/porting for details
on the machine-dependent support needed for a given platform.

Other than for the distributions above, much of the machine-dependent support in the mdep directory
is probably obsolete and will no longer work without modification, but is being retained
for future use.

BTW, when you see "nt" in names - e.g. the key_nt.zip file, mdep/nt directory, or the install_nt target
in the makefile - it refers to the Windows version.  The fact that it refers to Windows NT
indicates just how ancient KeyKit is.  :-)

