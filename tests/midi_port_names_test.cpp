#include "keykit_port_names.h"
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

struct Ports {
    std::vector<std::string> names;
    int failing_port = -1;
    bool grow = false;
};

// Simulate the C API, including variable-size names and enumeration failures.
int rtmidi_get_port_name(RtMidiPtr device, unsigned int port, char *buffer, int *length)
{
    const auto &ports = *static_cast<Ports *>(device->ptr);
    device->ok = static_cast<int>(port) != ports.failing_port;
    if (!device->ok) return -1;
    const auto &name = ports.names.at(port);
    if (!buffer) {
        *length = static_cast<int>(name.size() + 1);
        return 0;
    }
    if (ports.grow) return *length + 10;
    return std::snprintf(buffer, *length, "%s", name.c_str());
}

static void check(const std::vector<std::string> &raw, const std::vector<std::string> &expected)
{
    Ports ports;
    ports.names = raw;
    RtMidiWrapper device{};
    device.ptr = &ports;
    char **names = keykit_midi_port_names(&device, static_cast<unsigned int>(raw.size()));
    if (!names) std::abort();
    for (size_t i = 0; i < expected.size(); ++i) {
        if (expected[i] != names[i]) {
            std::fprintf(stderr, "Port %zu: expected '%s', got '%s'\n", i, expected[i].c_str(), names[i]);
            std::exit(1);
        }
    }
    if (names[expected.size()]) std::abort();
    keykit_free_midi_port_names(names);
}

static void check_direction(const std::vector<std::string> &raw, int input,
    const std::vector<std::string> &expected, const std::vector<unsigned int> &indices)
{
    Ports ports;
    ports.names = raw;
    RtMidiWrapper device{};
    device.ptr = &ports;
    auto *list = keykit_midi_port_list(&device, static_cast<unsigned int>(raw.size()), input);
    if (!list || list->count != expected.size() || indices.size() != expected.size()) std::abort();
    for (size_t i = 0; i < expected.size(); ++i) {
        if (expected[i] != list->names[i] || indices[i] != list->native_indices[i]) {
            std::fprintf(stderr, "Direction %d port %zu: unexpected name or native index\n", input, i);
            std::exit(1);
        }
    }
    if (list->names[list->count]) std::abort();
    keykit_free_midi_port_list(list);
}

int main()
{
    // The synth shifts output indices but must not alter the loopMIDI names.
    check({"loopMIDI Port", "loopMIDI Port 1", "loopMIDI Port 2"},
          {"loopMIDI Port", "loopMIDI Port 1", "loopMIDI Port 2"});
    check({"Microsoft GS Wavetable Synth", "loopMIDI Port", "loopMIDI Port 1", "loopMIDI Port 2"},
          {"Microsoft GS Wavetable Synth", "loopMIDI Port", "loopMIDI Port 1", "loopMIDI Port 2"});
    check({"Keyboard", "Keyboard", "Another device"},
          {"Keyboard [duplicate 1]", "Keyboard [duplicate 2]", "Another device"});
    check({"Keyboard", "Keyboard [duplicate 1]", "Keyboard"},
          {"Keyboard [duplicate 2]", "Keyboard [duplicate 1]", "Keyboard [duplicate 3]"});
    check({"Keyboard [duplicate 1]", "Keyboard [duplicate 1]", "Keyboard", "Keyboard"},
          {"Keyboard [duplicate 1] [duplicate 1]", "Keyboard [duplicate 1] [duplicate 2]",
           "Keyboard [duplicate 2]", "Keyboard [duplicate 3]"});
    check({std::string(2048, 'x'), "MIDI \xc3\xa9"}, {std::string(2048, 'x'), "MIDI \xc3\xa9"});
    check({}, {});

    const std::vector<std::string> paired = {"Other device", "KeyKit Loopback 1 A", "KeyKit Loopback 1 B",
        "KeyKit Loopback 2 B", "KeyKit Loopback 2 A", "KeyKit Loopback 3 A", "KeyKit Loopback 3 B",
        "loopMIDI Port 1", "KeyKit Loopback 4 A", "KeyKit Loopback 1 A renamed"};
    check_direction(paired, 1, {"Other device", "KeyKit Loopback 1", "KeyKit Loopback 2", "KeyKit Loopback 3",
        "loopMIDI Port 1", "KeyKit Loopback 4 A", "KeyKit Loopback 1 A renamed"}, {0, 2, 3, 6, 7, 8, 9});
    check_direction(paired, 0, {"Other device", "KeyKit Loopback 1", "KeyKit Loopback 2", "KeyKit Loopback 3",
        "loopMIDI Port 1", "KeyKit Loopback 4 A", "KeyKit Loopback 1 A renamed"}, {0, 1, 4, 5, 7, 8, 9});
    check_direction({"KeyKit Loopback 1", "KeyKit Loopback 1 A", "KeyKit Loopback 1 B",
        "KeyKit Loopback 1 [duplicate 1]"}, 0,
        {"KeyKit Loopback 1 [duplicate 2]", "KeyKit Loopback 1 [duplicate 3]", "KeyKit Loopback 1 [duplicate 1]"}, {0, 1, 3});
    check_direction({"KeyKit Loopback 1 A"}, 1, {}, {});
    check_direction({"KeyKit Loopback 1 B"}, 0, {}, {});
    check_direction({}, 1, {}, {});
    const std::vector<std::string> descriptive = {"Synth", "KeyKit Loopback 1 output", "KeyKit Loopback 1 input",
        "KeyKit Loopback 2 input", "KeyKit Loopback 2 output", "KeyKit Loopback 3 output", "KeyKit Loopback 3 input",
        "KeyKit Loopback 4 input", "KeyKit Loopback 1 input renamed"};
    check_direction(descriptive, 1, {"Synth", "KeyKit Loopback 1", "KeyKit Loopback 2", "KeyKit Loopback 3",
        "KeyKit Loopback 4 input", "KeyKit Loopback 1 input renamed"}, {0, 2, 3, 6, 7, 8});
    check_direction(descriptive, 0, {"Synth", "KeyKit Loopback 1", "KeyKit Loopback 2", "KeyKit Loopback 3",
        "KeyKit Loopback 4 input", "KeyKit Loopback 1 input renamed"}, {0, 1, 4, 5, 7, 8});
    // Ports after many hidden sides must remain available before the app limit.
    std::vector<std::string> many(70, "KeyKit Loopback 1 A");
    many.push_back("Last input");
    check_direction(many, 1, {"Last input"}, {70});

    Ports ports;
    ports.names = {"One", "Two"};
    ports.failing_port = 1;
    RtMidiWrapper device{};
    device.ptr = &ports;
    if (keykit_midi_port_names(&device, 2)) std::abort();
    if (keykit_midi_port_list(&device, 2, 1)) std::abort();
    ports.failing_port = -1;
    ports.grow = true;
    if (keykit_midi_port_names(&device, 2)) std::abort();
    keykit_free_midi_port_names(nullptr);
    keykit_free_midi_port_list(nullptr);
    std::puts("MIDI port name tests passed.");
}
