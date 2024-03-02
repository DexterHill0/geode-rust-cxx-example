# Taken from corrosion-rs/corrosion
# https://github.com/corrosion-rs/corrosion
# https://github.com/corrosion-rs/corrosion/blob/74fb8cc1be8d188ebd63375a77a1bd0cfc5aeccd/cmake/FindRust.cmake#L136C21-L136C39
function(_get_native_static_libs TARGET_TRIPLE RUST_PROFILE CARGO_BIN OUT_LIBS)
    set(package_dir "${CMAKE_BINARY_DIR}/native-static-libs/required_libs")
    # Cleanup on reconfigure to get a cleans state (in case we change something in the future)
    file(REMOVE_RECURSE "${package_dir}")
    file(MAKE_DIRECTORY "${package_dir}")
    set(manifest "[package]\nname = \"required_libs\"\nedition = \"2021\"\nversion = \"0.1.0\"\n")
    string(APPEND manifest "\n[lib]\ncrate-type=[\"staticlib\"]\npath = \"lib.rs\"\n")
    string(APPEND manifest "\n[workspace]\n")
    file(WRITE "${package_dir}/Cargo.toml" "${manifest}")
    file(WRITE "${package_dir}/lib.rs" "fn lib(){}\n")

    unset(TARGET)
    if(TARGET_TRIPLE EQUAL "")
        set(TARGET "")
    else()
        set(TARGET "--target=${TARGET_TRIPLE}")
    endif()

    execute_process(
        COMMAND ${CARGO_BIN} rustc --profile ${RUST_PROFILE} --verbose --color never ${TARGET} -- --print=native-static-libs
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/native-static-libs/required_libs"
        RESULT_VARIABLE cargo_build_result
        ERROR_VARIABLE cargo_build_error_message
    )
    if(cargo_build_result)
        message("Determining required native libraries - failed: ${cargo_build_result}.")
        message("The cargo build error was: ${cargo_build_error_message}")
        message("Note: This is expected for Rust targets without std support")
        return()
    else()
        # The pattern starts with `native-static-libs:` and goes to the end of the line.
        if(cargo_build_error_message MATCHES "native-static-libs: ([^\r\n]+)\r?\n")
            string(REPLACE " " ";" "libs_list" "${CMAKE_MATCH_1}")
            set(stripped_lib_list "")

            set(was_last_framework OFF)
            foreach(lib ${libs_list})
                # merge -framework;lib -> "-framework lib" as CMake does de-duplication of link libraries, and -framework prefix is required
                if (lib STREQUAL "-framework")
                    set(was_last_framework ON)
                    continue()
                endif()
                if (was_last_framework)
                    list(APPEND stripped_lib_list "-framework ${lib}")
                    set(was_last_framework OFF)
                    continue()
                endif()
                # Strip leading `-l` (unix) and potential .lib suffix (windows)
                string(REGEX REPLACE "^-l" "" "stripped_lib" "${lib}")
                string(REGEX REPLACE "\.lib$" "" "stripped_lib" "${stripped_lib}")
                list(APPEND stripped_lib_list "${stripped_lib}")
            endforeach()
            set(libs_list "${stripped_lib_list}")
            # Special case `msvcrt` to link with the debug version in Debug mode.
            list(TRANSFORM libs_list REPLACE "^msvcrt$" "\$<\$<CONFIG:Debug>:msvcrtd>")
        else()
            message("Determining required native libraries - failed: Regex match failure.")
            message("`native-static-libs` not found in: `${cargo_build_error_message}`")
            return()
        endif()
    endif()
    set("${OUT_LIBS}" "${libs_list}" PARENT_SCOPE)
endfunction()