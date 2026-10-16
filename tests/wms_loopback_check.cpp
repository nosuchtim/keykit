// Explicit integration check: --ensure creates KeyKit's shared loopback pairs.
// --roundtrip / --roundtrip-winmm send test SysEx through all three logical ports.
// Only --winmm is registered with CTest; it never calls a WMS API or creates ports.
#include "keykit_loopbacks.h"
#include "keykit_port_names.h"
#include <windows.h>
#include <winrt/base.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Devices.Midi2.h>
#include <winrt/Windows.Devices.Midi2.Transports.Loopback.h>
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <cstring>
#include <map>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

namespace midi = winrt::Windows::Devices::Midi2;
namespace loops = midi::Transports::Loopback;
using Manager = loops::MidiLoopbackManager;

using Snapshot = std::map<std::wstring, std::pair<winrt::guid, bool>>;
static Snapshot snapshot()
{
    Snapshot result;
    for (auto const &entry : Manager::GetActiveLoopbackEntries()) {
        const auto key = std::wstring(entry.EndpointA().Name()) + L"|" + std::wstring(entry.EndpointB().Name());
        if (result.count(key)) throw std::runtime_error("Duplicate loopback pair names.");
        result.emplace(key, std::make_pair(entry.AssociationId(), entry.IsMuted()));
    }
    return result;
}

static void verify_pairs()
{
    const auto entries = snapshot();
    for (int number = 1; number <= 3; ++number) {
        const auto base = L"KeyKit Loopback " + std::to_wstring(number);
        const auto id = L"keykit-loopback-" + std::to_wstring(number);
        const auto entry = entries.find(base + L" output|" + base + L" input");
        if (entry == entries.end() || !Manager::DoesLoopbackAExist(id + L"-a")
            || !Manager::DoesLoopbackBExist(id + L"-b"))
            throw std::runtime_error("A KeyKit loopback pair is missing.");
        std::printf("%s output/input: %s\n", winrt::to_string(base).c_str(),
            winrt::to_string(winrt::to_hstring(entry->second.first)).c_str());
    }
}

static unsigned int find_port(RtMidiPtr device, const char *name, int input)
{
    const auto count = rtmidi_get_port_count(device);
    if (!device->ok) throw std::runtime_error("Cannot enumerate ports.");
    auto *ports = keykit_midi_port_list(device, count, input);
    if (!ports) throw std::runtime_error("Cannot read port names.");
    struct Cleanup {
        KeykitMidiPortList *ports;
        ~Cleanup() { keykit_free_midi_port_list(ports); }
    } cleanup{ports};
    for (unsigned int i = 0; i < ports->count; ++i) {
        const std::string label(ports->names[i]);
        for (int number = 1; number <= 3; ++number) {
            const auto base = "KeyKit Loopback " + std::to_string(number);
            if (label == base + " A" || label == base + " B"
                || label == base + " input" || label == base + " output")
                throw std::runtime_error("A native loopback side leaked into KeyKit's port list.");
        }
        if (label == name) return ports->native_indices[i];
    }
    throw std::runtime_error(std::string("Port not visible: ") + name);
}

static void roundtrip(enum RtMidiApi api, int number)
{
    const unsigned char bytes[] = {0xf0, 0x7d, 'K', 'e', 'y', 'K', 'i', 't', 1, 2, 3, 0xf7};
    const auto name = "KeyKit Loopback " + std::to_string(number);
    RtMidiInPtr input = rtmidi_in_create(api, "KeyKit loopback test receiver", 100);
    RtMidiOutPtr output = rtmidi_out_create(api, "KeyKit loopback test sender");
    struct Cleanup {
        RtMidiInPtr input; RtMidiOutPtr output;
        ~Cleanup() {
            if (input->ptr) rtmidi_close_port(input);
            rtmidi_in_free(input);
            if (output->ptr) rtmidi_close_port(output);
            rtmidi_out_free(output);
        }
    } cleanup{input, output};
    if (!input->ok || !output->ok) throw std::runtime_error("Cannot create test MIDI objects.");
    rtmidi_in_ignore_types(input, false, false, false);
    rtmidi_open_port(input, find_port(input, name.c_str(), 1), "KeyKit test receiver");
    if (!input->ok) throw std::runtime_error(input->msg);
    rtmidi_open_port(output, find_port(output, name.c_str(), 0), "KeyKit test sender");
    if (!output->ok) throw std::runtime_error(output->msg);
    if (rtmidi_out_send_message(output, bytes, sizeof(bytes)) != 0 || !output->ok)
        throw std::runtime_error("Loopback test send failed.");
    const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(3);
    while (std::chrono::steady_clock::now() < deadline) {
        unsigned char received[256];
        size_t length = sizeof(received);
        rtmidi_in_get_message(input, received, &length);
        if (!input->ok) throw std::runtime_error(input->msg);
        if (length == sizeof(bytes) && std::equal(bytes, bytes + sizeof(bytes), received)) {
            std::printf("%s SysEx roundtrip passed: %s output -> input.\n", rtmidi_api_name(api), name.c_str());
            return;
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
    throw std::runtime_error("No matching test message arrived at " + name);
}

int main(int argc, char **argv)
{
    char message[1024];
    if (argc != 2) return 2;
    if (std::strcmp(argv[1], "--winmm") == 0) {
        return keykit_ensure_midi_loopbacks(RTMIDI_API_WINDOWS_MM, message, sizeof(message)) != 0 || *message;
    }
    const bool ensure = std::strcmp(argv[1], "--ensure") == 0;
    const bool winmm = std::strcmp(argv[1], "--roundtrip-winmm") == 0;
    const bool send = std::strcmp(argv[1], "--roundtrip") == 0 || winmm;
    if (!ensure && !send && std::strcmp(argv[1], "--verify") != 0) return 2;
    try {
        winrt::init_apartment();
        if (!midi::MidiApi::EnsureServiceAvailable()) throw std::runtime_error("WMS service unavailable.");
        const auto before = snapshot();
        if (ensure && keykit_ensure_midi_loopbacks(RTMIDI_API_WINDOWS_MIDI_SERVICES, message, sizeof(message)) != 0)
            throw std::runtime_error(message);
        verify_pairs();
        const auto after = snapshot();
        if (ensure) {
            if (keykit_ensure_midi_loopbacks(RTMIDI_API_WINDOWS_MIDI_SERVICES, message, sizeof(message)) != 0)
                throw std::runtime_error(message);
            if (after != snapshot()) throw std::runtime_error("Repeated startup changed existing loopbacks.");
            for (auto const &entry : before) {
                auto key = entry.first;
                for (int number = 1; number <= 3; ++number) {
                    const auto base = L"KeyKit Loopback " + std::to_wstring(number);
                    if (key == base + L" A|" + base + L" B") key = base + L" output|" + base + L" input";
                }
                if (after.at(key) != entry.second)
                    throw std::runtime_error("Startup changed an existing loopback's identity or muted state.");
            }
            std::puts("Idempotent creation/reuse passed.");
        }
        if (send) for (int number = 1; number <= 3; ++number)
            roundtrip(winmm ? RTMIDI_API_WINDOWS_MM : RTMIDI_API_WINDOWS_MIDI_SERVICES, number);
    } catch (winrt::hresult_error const &error) {
        std::fprintf(stderr, "WMS HRESULT 0x%08x: %s\n", static_cast<unsigned>(error.code().value), winrt::to_string(error.message()).c_str());
        return 1;
    } catch (std::exception const &error) {
        std::fprintf(stderr, "%s\n", error.what());
        return 1;
    }
}
