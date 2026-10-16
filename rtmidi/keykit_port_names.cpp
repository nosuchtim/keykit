//go:build ignore

#include "keykit_port_names.h"
#include <cstdlib>
#include <cstring>
#include <exception>
#include <map>
#include <set>
#include <string>
#include <vector>

void keykit_free_midi_port_names(char **names)
{
    if (!names) return;
    for (size_t i = 0; names[i]; ++i) std::free(names[i]);
    std::free(names);
}

void keykit_free_midi_port_list(KeykitMidiPortList *ports)
{
    if (!ports) return;
    keykit_free_midi_port_names(ports->names);
    std::free(ports->native_indices);
    std::free(ports);
}

// Match the three reserved names and the previous A/B defaults, so WinMM can
// still use old pairs before a WMS startup migrates their names in place.
static bool present_port(std::string &name, int input)
{
    if (input < 0) return true;
    for (int number = 1; number <= 3; ++number) {
        const auto base = "KeyKit Loopback " + std::to_string(number);
        if (name == base + (input ? " output" : " input")
            || name == base + (input ? " A" : " B")) return false;
        if (name == base + (input ? " input" : " output")
            || name == base + (input ? " B" : " A")) {
            name = base;
            return true;
        }
    }
    return true;
}

static KeykitMidiPortList *port_list(RtMidiPtr device, unsigned int count, int input)
{
    auto *result = static_cast<KeykitMidiPortList *>(std::calloc(1, sizeof(KeykitMidiPortList)));
    if (!result) return nullptr;
    result->names = static_cast<char **>(std::calloc(static_cast<size_t>(count) + 1, sizeof(char *)));
    result->native_indices = static_cast<unsigned int *>(std::calloc(static_cast<size_t>(count) + 1, sizeof(unsigned int)));
    if (!result->names || !result->native_indices) {
        keykit_free_midi_port_list(result);
        return nullptr;
    }
    try {
        std::vector<std::string> raw;
        std::map<std::string, unsigned int> occurrences, next_duplicate;
        std::set<std::string> reserved;
        for (unsigned int i = 0; i < count; ++i) {
            int length = 0;
            if (rtmidi_get_port_name(device, i, nullptr, &length) < 0 || !device->ok || length <= 0) {
                keykit_free_midi_port_list(result);
                return nullptr;
            }
            std::vector<char> buffer(length);
            int written = rtmidi_get_port_name(device, i, buffer.data(), &length);
            if (written < 0 || !device->ok || static_cast<size_t>(written) >= buffer.size()) {
                keykit_free_midi_port_list(result);
                return nullptr;
            }
            std::string name(buffer.data());
            if (!present_port(name, input)) continue;
            result->native_indices[raw.size()] = i;
            raw.push_back(name);
            ++occurrences[raw.back()];
            reserved.insert(raw.back());
        }

        // Reserve every driver's literal name before generating labels. This
        // also handles devices literally named e.g. "Keyboard [duplicate 1]".
        result->count = static_cast<unsigned int>(raw.size());
        for (unsigned int i = 0; i < result->count; ++i) {
            std::string name = raw[i];
            if (occurrences[name] > 1) {
                do {
                    name = raw[i] + " [duplicate " + std::to_string(++next_duplicate[raw[i]]) + "]";
                } while (reserved.count(name));
                reserved.insert(name);
            }
            result->names[i] = static_cast<char *>(std::malloc(name.size() + 1));
            if (!result->names[i]) {
                keykit_free_midi_port_list(result);
                return nullptr;
            }
            std::memcpy(result->names[i], name.c_str(), name.size() + 1);
        }
        return result;
    } catch (const std::exception &) {
        keykit_free_midi_port_list(result);
        return nullptr;
    }
}

KeykitMidiPortList *keykit_midi_port_list(RtMidiPtr device, unsigned int count, int input)
{
    return port_list(device, count, input != 0);
}

char **keykit_midi_port_names(RtMidiPtr device, unsigned int count)
{
    auto *ports = port_list(device, count, -1);
    if (!ports) return nullptr;
    char **names = ports->names;
    ports->names = nullptr;
    keykit_free_midi_port_list(ports);
    return names;
}
