#ifndef KEYKIT_MIDI_BACKEND_H
#define KEYKIT_MIDI_BACKEND_H

#include "cpp/rtmidi_c.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Select once at startup. A nonempty message explains a fallback to WinMM. */
enum RtMidiApi keykit_midi_api(char *message, size_t message_size);

#ifdef __cplusplus
}
#endif

#endif
