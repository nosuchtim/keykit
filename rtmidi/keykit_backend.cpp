//go:build ignore

#include "keykit_backend.h"
#include "cpp/RtMidi.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>

enum RtMidiApi keykit_midi_api(char *message, size_t message_size)
{
    if (message_size) message[0] = '\0';
    const char *requested = std::getenv("KEYKIT_MIDI_API");
    if (!requested || !*requested || _stricmp(requested, "winmm") == 0)
        return RTMIDI_API_WINDOWS_MM;

    if (_stricmp(requested, "wms") != 0) {
        std::snprintf(message, message_size,
            "Unknown KEYKIT_MIDI_API '%s' (use winmm or wms); using WinMM.", requested);
        return RTMIDI_API_WINDOWS_MM;
    }

    const auto availability = rt::midi::RtMidi::checkApiAvailability(
        rt::midi::RtMidi::WINDOWS_MIDI_SERVICES);
    if (!availability.available) {
        std::snprintf(message, message_size,
            "KEYKIT_MIDI_API=wms: %s Using WinMM.", availability.message.c_str());
        return RTMIDI_API_WINDOWS_MM;
    }
    return RTMIDI_API_WINDOWS_MIDI_SERVICES;
}
