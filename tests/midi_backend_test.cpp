#include "keykit_backend.h"
#include "cpp/RtMidi.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>

static bool available;
static int availability_checks;

rt::midi::RtMidi::RtMidiApiAvailability
rt::midi::RtMidi::checkApiAvailability(rt::midi::RtMidi::Api api)
{
    if (api != WINDOWS_MIDI_SERVICES) std::abort();
    ++availability_checks;
    RtMidiApiAvailability result;
    result.available = available;
    result.message = "WMS test runtime unavailable.";
    return result;
}

static void check(const char *setting, bool wms_available, RtMidiApi expected,
                  bool expect_warning, int expected_checks)
{
    _putenv_s("KEYKIT_MIDI_API", setting);
    available = wms_available;
    availability_checks = 0;
    char message[512];
    const auto actual = keykit_midi_api(message, sizeof(message));
    if (actual != expected || (message[0] != '\0') != expect_warning
        || availability_checks != expected_checks) {
        std::fprintf(stderr, "Selection failed for '%s': %d, %s\n", setting, actual, message);
        std::exit(1);
    }
    if (expect_warning && !std::strstr(message, "WinMM")) std::abort();
}

int main()
{
    check("", true, RTMIDI_API_WINDOWS_MM, false, 0);
    check("winmm", true, RTMIDI_API_WINDOWS_MM, false, 0);
    check("WINMM", false, RTMIDI_API_WINDOWS_MM, false, 0);
    check("wms", true, RTMIDI_API_WINDOWS_MIDI_SERVICES, false, 1);
    check("WmS", true, RTMIDI_API_WINDOWS_MIDI_SERVICES, false, 1);
    check("wms", false, RTMIDI_API_WINDOWS_MM, true, 1);
    check("unknown", true, RTMIDI_API_WINDOWS_MM, true, 0);
    char short_message[2] = {'x', 'x'};
    keykit_midi_api(short_message, sizeof(short_message));
    if (short_message[1] != '\0') std::abort();
    keykit_midi_api(nullptr, 0);
    std::puts("Backend selection tests passed.");
}
