cmake_minimum_required(VERSION 3.24)
project(KeyKitRtMidi LANGUAGES C CXX)

if(NOT WIN32 OR NOT MSVC)
    message(FATAL_ERROR "This target builds KeyKit's Windows MIDI backends with MSVC.")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
option(KEYKIT_RTMIDI_WMS "Include Windows MIDI Services alongside WinMM" ON)

add_library(rtmidi STATIC cpp/RtMidi.cpp cpp/rtmidi_c.cpp keykit_backend.cpp keykit_port_names.cpp keykit_loopbacks.cpp)
target_compile_features(rtmidi PRIVATE cxx_std_11)
target_compile_definitions(rtmidi PRIVATE RTMIDI_API_WINMM RTMIDI_DO_NOT_ENSURE_UNIQUE_PORTNAMES)
target_link_libraries(rtmidi PUBLIC winmm)

if(KEYKIT_RTMIDI_WMS)
    find_package(CppWinRT REQUIRED)
    find_package(WindowsMidiServices REQUIRED)
    target_compile_features(rtmidi PRIVATE cxx_std_20)
    target_compile_definitions(rtmidi PRIVATE RTMIDI_API_WMS)
    target_include_directories(rtmidi PRIVATE "${CppWinRT_INCLUDE_DIR}")
    target_link_libraries(rtmidi PUBLIC windowsapp runtimeobject ole32)
    if(NOT WindowsMidiServices_SDK_PROJECTION)
        set(projection "${CMAKE_CURRENT_BINARY_DIR}/generated")
        add_custom_command(
            OUTPUT "${projection}/winrt/Windows.Devices.Midi2.h"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${projection}"
            COMMAND "${CppWinRT_EXECUTABLE}" -input "${WindowsMidiServices_WINMD}"
                -reference "${CppWinRT_WINDOWS_WINMD}" -output "${projection}"
            DEPENDS "${WindowsMidiServices_WINMD}"
            VERBATIM)
        target_sources(rtmidi PRIVATE "${projection}/winrt/Windows.Devices.Midi2.h")
        target_include_directories(rtmidi PRIVATE "${projection}")
    endif()
endif()

include(CTest)
if(BUILD_TESTING)
    add_executable(backend_selection_test ../tests/midi_backend_test.cpp keykit_backend.cpp)
    target_include_directories(backend_selection_test PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
    target_compile_features(backend_selection_test PRIVATE cxx_std_11)
    add_test(NAME backend_selection COMMAND backend_selection_test)

    add_executable(port_names_test ../tests/midi_port_names_test.cpp keykit_port_names.cpp)
    target_include_directories(port_names_test PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
    target_compile_features(port_names_test PRIVATE cxx_std_11)
    add_test(NAME port_names COMMAND port_names_test)

    add_executable(rtmidi_probe ../tests/rtmidi_probe.cpp)
    target_include_directories(rtmidi_probe PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
    target_link_libraries(rtmidi_probe PRIVATE rtmidi)
    add_test(NAME rtmidi_probe COMMAND rtmidi_probe)

    if(KEYKIT_RTMIDI_WMS)
        add_executable(wms_loopback_check ../tests/wms_loopback_check.cpp)
        target_compile_features(wms_loopback_check PRIVATE cxx_std_20)
        target_include_directories(wms_loopback_check PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CppWinRT_INCLUDE_DIR}")
        if(NOT WindowsMidiServices_SDK_PROJECTION)
            target_include_directories(wms_loopback_check PRIVATE "${projection}")
        endif()
        target_link_libraries(wms_loopback_check PRIVATE rtmidi)
        add_dependencies(wms_loopback_check rtmidi)
        # Regular tests do not create system MIDI ports or send MIDI traffic.
        add_test(NAME loopback_winmm_noop COMMAND wms_loopback_check --winmm)
    endif()

    find_program(KEYKIT_LOWKEY NAMES lowkey.exe PATHS "${CMAKE_CURRENT_SOURCE_DIR}/../bin" NO_DEFAULT_PATH)
    if(KEYKIT_LOWKEY)
        add_test(NAME port_lookup COMMAND "${KEYKIT_LOWKEY}" -r tests/midi_port_lookup.k)
        set_tests_properties(port_lookup PROPERTIES WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/..")
    endif()
endif()
