//go:build ignore

#include "keykit_loopbacks.h"
#include <cstdio>
#include <exception>

#ifdef RTMIDI_API_WMS
#include <windows.h>
#include <winrt/base.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Devices.Midi2.h>
#include <winrt/Windows.Devices.Midi2.Enumeration.h>
#include <winrt/Windows.Devices.Midi2.Enumeration.Legacy.h>
#include <winrt/Windows.Devices.Midi2.Transports.Loopback.h>
#include <chrono>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

namespace {
namespace midi = winrt::Windows::Devices::Midi2;
namespace loopback = midi::Transports::Loopback;
namespace enumeration = midi::Enumeration;
using Manager = loopback::MidiLoopbackManager;
using PublishedEndpoint = std::pair<winrt::hstring, std::wstring>;

struct StartupLock {
    winrt::handle handle{CreateMutexW(nullptr, FALSE, L"Local\\KeyKit.WMS.Loopbacks.v1")};
    bool owned = false;

    StartupLock() {
        if (!handle) winrt::throw_last_error();
        const DWORD result = WaitForSingleObject(handle.get(), 5000);
        if (result == WAIT_FAILED) winrt::throw_last_error();
        if (result != WAIT_OBJECT_0 && result != WAIT_ABANDONED)
            throw std::runtime_error("Timed out waiting for another KeyKit instance to finish loopback setup.");
        owned = true;
    }
    ~StartupLock() { if (owned) ReleaseMutex(handle.get()); }
};

bool reuse_existing(const std::wstring &base_name, std::vector<PublishedEndpoint> &endpoints,
                    std::string &rename_warning)
{
    const auto name_a = base_name + L" output";
    const auto name_b = base_name + L" input";
    for (auto const &entry : Manager::GetActiveLoopbackEntries()) {
        const bool legacy = entry.EndpointA().Name() == base_name + L" A"
            && entry.EndpointB().Name() == base_name + L" B";
        if (legacy || (entry.EndpointA().Name() == name_a && entry.EndpointB().Name() == name_b)) {
            auto published_a = name_a, published_b = name_b;
            if (legacy) {
                // Rename our previous defaults in place. Do not recreate the
                // pair or alter IDs, muted state, or custom endpoint names.
                loopback::MidiLoopbackUpdateConfig update(entry.AssociationId());
                update.EndpointAName(name_a);
                update.EndpointBName(name_b);
                const auto response = Manager::UpdateLoopback(update);
                if (!response.Success()) {
                    // Older inbox services can create pairs but reject updates.
                    // Keep their ports usable; never disconnect clients during startup.
                    rename_warning = "This MIDI service could not rename existing KeyKit A/B ports. "
                        "They remain usable; new input/output names apply after the MIDI service restarts.";
                    published_a = entry.EndpointA().Name();
                    published_b = entry.EndpointB().Name();
                    for (const auto &current : Manager::GetActiveLoopbackEntries()) {
                        if (current.AssociationId() != entry.AssociationId()) continue;
                        published_a = current.EndpointA().Name();
                        published_b = current.EndpointB().Name();
                        break;
                    }
                }
            }
            endpoints.emplace_back(entry.EndpointA().EndpointDeviceId(), published_a);
            endpoints.emplace_back(entry.EndpointB().EndpointDeviceId(), published_b);
            return true;
        }
    }
    return false;
}

bool ports_published(const PublishedEndpoint &endpoint)
{
    using Ports = enumeration::Legacy::MidiLegacyPortDeviceInformation;
    using Flow = enumeration::Midi1PortFlow;
    for (auto flow : {Flow::MidiMessageSource, Flow::MidiMessageDestination}) {
        bool found = false;
        for (const auto &port : Ports::FindAllForAssociatedEndpoint(endpoint.first, flow)) {
            if (port.Name() == endpoint.second) { found = true; break; }
        }
        if (!found) return false;
    }
    return true;
}

void ensure_loopbacks()
{
    if (!midi::MidiApi::EnsureServiceAvailable())
        throw std::runtime_error("Windows MIDI Services is unavailable.");
    if (!Manager::IsTransportAvailable())
        throw std::runtime_error("The Windows MIDI Services loopback transport is unavailable or disabled.");

    // Serialize same-session startups. Stable unique IDs also prevent duplicate
    // creation across sessions or with another client not holding this mutex.
    StartupLock lock;
    std::vector<PublishedEndpoint> endpoints;
    std::string rename_warning;
    for (int number = 1; number <= 3; ++number) {
        const auto base_name = L"KeyKit Loopback " + std::to_wstring(number);
        const auto name_a = base_name + L" output";
        const auto name_b = base_name + L" input";
        const auto base_id = L"keykit-loopback-" + std::to_wstring(number);
        const auto id_a = base_id + L"-a";
        const auto id_b = base_id + L"-b";

        const bool exists_a = Manager::DoesLoopbackAExist(id_a);
        const bool exists_b = Manager::DoesLoopbackBExist(id_b);
        if (reuse_existing(base_name, endpoints, rename_warning) || (exists_a && exists_b))
            continue; // Preserve custom names, muted state, and configuration.
        if (exists_a || exists_b)
            throw std::runtime_error("An incomplete KeyKit loopback pair already exists; leaving it unchanged.");

        loopback::MidiLoopbackEndpointDefinition a(name_a, L"Send MIDI here; receive from the matching KeyKit loopback input", id_a);
        loopback::MidiLoopbackEndpointDefinition b(name_b, L"Receive MIDI here from the matching KeyKit loopback output", id_b);
        a.CreateOnlyUmpEndpoint(false);
        b.CreateOnlyUmpEndpoint(false);
        const auto response = Manager::CreateTransientLoopback(loopback::MidiLoopbackCreationConfig(a, b));
        if (!response.Success()) {
            // Another session may have won the create race. Confirm both IDs
            // before treating a duplicate-ID response as success.
            if (Manager::DoesLoopbackAExist(id_a) && Manager::DoesLoopbackBExist(id_b)) {
                reuse_existing(base_name, endpoints, rename_warning);
                continue;
            }
            throw std::runtime_error("Could not create " + winrt::to_string(base_name)
                + ": " + winrt::to_string(response.ErrorMessage()));
        }
        endpoints.emplace_back(response.CreatedLoopbackEntry().EndpointA().EndpointDeviceId(), name_a);
        endpoints.emplace_back(response.CreatedLoopbackEntry().EndpointB().EndpointDeviceId(), name_b);
    }

    // The service creates endpoints asynchronously. Let their MIDI 1.0 views
    // settle before RtMidi takes the initial snapshot, with a bounded wait.
    const auto deadline = std::chrono::steady_clock::now() + std::chrono::seconds(3);
    for (;;) {
        bool ready = true;
        for (auto const &endpoint : endpoints) {
            if (!ports_published(endpoint)) { ready = false; break; }
        }
        if (ready) {
            if (!rename_warning.empty()) throw std::runtime_error(rename_warning);
            return;
        }
        if (std::chrono::steady_clock::now() >= deadline)
            throw std::runtime_error("KeyKit loopbacks were created but their MIDI ports are still becoming available.");
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
}
} // namespace
#endif

int keykit_ensure_midi_loopbacks(enum RtMidiApi api, char *message, size_t message_size)
{
    if (message_size) message[0] = '\0';
    if (api != RTMIDI_API_WINDOWS_MIDI_SERVICES) return 0;
#ifdef RTMIDI_API_WMS
    try {
        ensure_loopbacks();
        return 0;
    } catch (winrt::hresult_error const &error) {
        std::snprintf(message, message_size, "WMS loopback setup failed (0x%08x): %s",
            static_cast<unsigned>(error.code().value), winrt::to_string(error.message()).c_str());
    } catch (std::exception const &error) {
        std::snprintf(message, message_size, "WMS loopback setup: %s", error.what());
    }
#else
    std::snprintf(message, message_size, "This build has no Windows MIDI Services loopback support.");
#endif
    return -1;
}
