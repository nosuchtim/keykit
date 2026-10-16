#include "keykit_backend.h"
#include "keykit_port_names.h"
#include "cpp/RtMidi.h"
#include <windows.h>
#include <mmsystem.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>

static std::string utf8(const char *name)
{
    wchar_t wide[MAXPNAMELEN];
    char converted[4 * MAXPNAMELEN];
    if (!MultiByteToWideChar(CP_ACP, 0, name, -1, wide, MAXPNAMELEN)
        || !WideCharToMultiByte(CP_UTF8, 0, wide, -1, converted, sizeof(converted), nullptr, nullptr))
        std::abort();
    return converted;
}

static void check_names(RtMidiPtr device, unsigned int count, bool input, RtMidiApi api)
{
    char **names = keykit_midi_port_names(device, count);
    if (!names) std::abort();
    for (unsigned int i = 0; i < count; ++i) {
        std::printf("%s %u: %s\n", input ? "Input" : "Output", i, names[i]);
        if (api == RTMIDI_API_WINDOWS_MM) {
            // Check the compiled RtMidi library actually returns literal driver
            // names in both directions, without manufacturing numeric suffixes.
            std::string expected;
            if (input) {
                MIDIINCAPSA caps;
                if (midiInGetDevCapsA(i, &caps, sizeof(caps)) != MMSYSERR_NOERROR) std::abort();
                expected = utf8(caps.szPname);
            } else {
                MIDIOUTCAPSA caps;
                if (midiOutGetDevCapsA(i, &caps, sizeof(caps)) != MMSYSERR_NOERROR) std::abort();
                expected = utf8(caps.szPname);
            }
            int length = 0;
            if (rtmidi_get_port_name(device, i, nullptr, &length) < 0 || !device->ok || length <= 0) std::abort();
            std::vector<char> raw(length);
            if (rtmidi_get_port_name(device, i, raw.data(), &length) < 0 || !device->ok) std::abort();
            if (expected != raw.data()) {
                std::fprintf(stderr, "Driver name '%s' differs from RtMidi name '%s'\n", expected.c_str(), raw.data());
                std::abort();
            }
        }
    }
    keykit_free_midi_port_names(names);
}

int main()
{
    if (std::strcmp(rtmidi_get_version(), "6.1.0") != 0) return 1;
    bool winmm = false, wms = false;
    RtMidiApi apis[RTMIDI_API_NUM];
    const int count = rtmidi_get_compiled_api(apis, RTMIDI_API_NUM);
    for (int i = 0; i < count; ++i) {
        std::printf("Compiled backend: %s\n", rtmidi_api_name(apis[i]));
        winmm |= apis[i] == RTMIDI_API_WINDOWS_MM;
        wms |= apis[i] == RTMIDI_API_WINDOWS_MIDI_SERVICES;
    }
    if (!winmm || (sizeof(void *) == 8 && !wms)) return 1;

    // Never open a port or send MIDI in this probe.
    for (const char *setting : {"", "winmm", "wms", "invalid"}) {
        _putenv_s("KEYKIT_MIDI_API", setting);
        char message[1024];
        const auto api = keykit_midi_api(message, sizeof(message));
        std::printf("KEYKIT_MIDI_API='%s': %s %s\n", setting, rtmidi_api_name(api), message);
        if (std::strcmp(setting, "wms") != 0 && api != RTMIDI_API_WINDOWS_MM) return 1;
        if (std::strcmp(setting, "wms") == 0) {
            const auto availability = rt::midi::RtMidi::checkApiAvailability(
                rt::midi::RtMidi::WINDOWS_MIDI_SERVICES);
            if ((api == RTMIDI_API_WINDOWS_MIDI_SERVICES) != availability.available) return 1;
        }
        RtMidiInPtr input = rtmidi_in_create(api, "keykit test", 1000);
        RtMidiOutPtr output = rtmidi_out_create(api, "keykit test");
        if (!input->ok || !output->ok) return 1;
        if (rtmidi_in_get_current_api(input) != api || rtmidi_out_get_current_api(output) != api) return 1;
        unsigned int inputs = rtmidi_get_port_count(input);
        unsigned int outputs = rtmidi_get_port_count(output);
        if (!input->ok || !output->ok) return 1;
        std::printf("Input ports: %u; output ports: %u\n", inputs, outputs);
        check_names(input, inputs, true, api);
        check_names(output, outputs, false, api);
        rtmidi_in_free(input);
        rtmidi_out_free(output);
    }
}
