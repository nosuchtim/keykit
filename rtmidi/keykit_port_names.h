#ifndef KEYKIT_MIDI_PORT_NAMES_H
#define KEYKIT_MIDI_PORT_NAMES_H

#include "cpp/rtmidi_c.h"

#ifdef __cplusplus
extern "C" {
#endif

/* NULL-terminated UTF-8 names, or NULL on failure. Free with the function below.
 * Unique driver names are unchanged. Only duplicates receive explicit labels.
 * Each array describes one direction; duplicate labels do not identify devices
 * across directions or survive changes in enumeration order.
 */
char **keykit_midi_port_names(RtMidiPtr device, unsigned int count);
void keykit_free_midi_port_names(char **names);

/* KeyKit's directional view of the native ports. Owned loopback pairs appear
 * once per direction, with the same name: output A -> input B. Other ports
 * retain their driver names. Native indices must be used when opening ports;
 * the compact list position remains KeyKit's device/callback number.
 */
typedef struct KeykitMidiPortList {
    unsigned int count;
    char **names;
    unsigned int *native_indices;
} KeykitMidiPortList;
KeykitMidiPortList *keykit_midi_port_list(RtMidiPtr device, unsigned int count, int input);
void keykit_free_midi_port_list(KeykitMidiPortList *ports);

#ifdef __cplusplus
}
#endif

#endif
