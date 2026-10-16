#ifndef KEYKIT_MIDI_LOOPBACKS_H
#define KEYKIT_MIDI_LOOPBACKS_H

#include "cpp/rtmidi_c.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Ensure the shared KeyKit loopbacks before enumerating ports. WinMM is a no-op.
 * Returns 0 on success, -1 with a diagnostic on failure. Never removes ports.
 */
int keykit_ensure_midi_loopbacks(enum RtMidiApi api, char *message, size_t message_size);

#ifdef __cplusplus
}
#endif

#endif
