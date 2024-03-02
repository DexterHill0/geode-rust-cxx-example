function(setup_geode_cxx)
    set(ONE_VALUE_KEYWORDS GEODE_PROJ_NAME RUST_CRATE_DIR RUST_CRATE_NAME CARGO_MANIFEST CARGO_TARGET_DIR CARGO_BIN RUSTC_TARGET_TRIPLE CARGO_BUILD_PROFILE)

    cmake_parse_arguments(GXX "" "${ONE_VALUE_KEYWORDS}" "" ${ARGN})

    if(DEFINED GXX_UNPARSED_ARGUMENTS)
        message("Unexpected arguments: " ${GXX_UNPARSED_ARGUMENTS})
    endif()

    if (NOT DEFINED GXX_GEODE_PROJ_NAME)
        message(FATAL_ERROR "GEODE_PROJ_NAME is a required argument to setup_geode_cxx")
    endif()
    if (NOT DEFINED GXX_RUST_CRATE_DIR)
        message(FATAL_ERROR "RUST_CRATE_DIR is a required argument to setup_geode_cxx")
    endif()
    if(NOT DEFINED GXX_RUSTC_TARGET_TRIPLE)
        message(FATAL_ERROR "RUSTC_TARGET_TRIPLE is a required argument to setup_geode_cxx. RUSTC_TARGET_TRIPLE must match the target in .cargo/config.toml")
    endif()
    if(NOT DEFINED GXX_RUST_CRATE_NAME)
        message(FATAL_ERROR "RUST_CRATE_NAME is a required argument to setup_geode_cxx.")
    endif()

    if(NOT DEFINED GXX_CARGO_MANIFEST)
        set(GXX_CARGO_MANIFEST "${GXX_RUST_CRATE_DIR}/Cargo.toml")
    endif()
    if(NOT DEFINED GXX_CARGO_TARGET_DIR)
        set(GXX_CARGO_TARGET_DIR "${GXX_RUST_CRATE_DIR}/target")
    endif()
    if(NOT DEFINED GXX_CARGO_BIN)
        set(GXX_CARGO_BIN "cargo")
    endif()

    if (NOT DEFINED GXX_CARGO_BUILD_PROFILE)
        set(RUST_PROFILE "release")
    else()
        set(RUST_PROFILE "${GXX_CARGO_BUILD_PROFILE}")
    endif ()

    set(TARGET_DIR_WITH_TARGET_TRIPLE ${GXX_CARGO_TARGET_DIR}/${GXX_RUSTC_TARGET_TRIPLE})

    
    # CMAKE_STATIC_LIBRARY_PREFIX is seemingly empty
    set(STATIC_LIBRARY_PREFIX "")
    if(UNIX)
        set(STATIC_LIBRARY_PREFIX "lib")
    endif()
    # CMAKE_STATIC_LIBRARY_SUFFIX also suffers the same
    if(WIN32)
        set(STATIC_LIBRARY_SUFFIX ".lib")
    elseif(UNIX)
        set(STATIC_LIBRARY_SUFFIX ".a")
    endif()

    # rust silently converts hyphens into underscores in crate names which
    # can cause some confusion
    string(REPLACE "-" "_" LIB_OUTPUT_NAME "${GXX_RUST_CRATE_NAME}")
    
    set(RUST_SOURCE_FILE ${GXX_RUST_CRATE_DIR}/src/lib.rs)
    set(RUST_BRIDGE_CPP ${TARGET_DIR_WITH_TARGET_TRIPLE}/cxxbridge/${GXX_RUST_CRATE_NAME}/src/lib.rs.cc)
    set(RUST_LIB ${TARGET_DIR_WITH_TARGET_TRIPLE}/${RUST_PROFILE}/${STATIC_LIBRARY_PREFIX}${LIB_OUTPUT_NAME}${STATIC_LIBRARY_SUFFIX})
    
    add_custom_command(
        OUTPUT ${RUST_BRIDGE_CPP} ${RUST_LIB}
        COMMAND ${GXX_CARGO_BIN} build --profile ${RUST_PROFILE} --manifest-path ${GXX_CARGO_MANIFEST}
        DEPENDS ${RUST_SOURCE_FILE}
        USES_TERMINAL
        COMMENT "Building ${GXX_RUST_CRATE_NAME}..."
    )

    target_include_directories(
        ${GXX_GEODE_PROJ_NAME}
        PUBLIC
        ${TARGET_DIR_WITH_TARGET_TRIPLE}/cxxbridge/${GXX_RUST_CRATE_NAME}/src/
        ${TARGET_DIR_WITH_TARGET_TRIPLE}/cxxbridge
        # cxx will reference "rust_lib" as the root for the include so
        # we need to include the parent in order for it to resolve
        ${CMAKE_SOURCE_DIR}/../
    )

    set_target_properties(
        ${GXX_GEODE_PROJ_NAME}
        PROPERTIES ADDITIONAL_CLEAN_FILES ${TARGET_DIR_WITH_TARGET_TRIPLE}
    )

    include(${CMAKE_SOURCE_DIR}/cmake/NativeStaticLibs.cmake)

    unset(REQUIRED_NATIVE_LIBS)
    _get_native_static_libs(${GXX_RUSTC_TARGET_TRIPLE} ${RUST_PROFILE} ${GXX_CARGO_BIN} REQUIRED_NATIVE_LIBS)

    if(DEFINED REQUIRED_NATIVE_LIBS)
        message("Required static libs for target ${GXX_RUSTC_TARGET_TRIPLE}: ${REQUIRED_NATIVE_LIBS}")
    endif()

    set_target_properties(
        ${GXX_GEODE_PROJ_NAME}
        PROPERTIES
        MSVC_RUNTIME_LIBRARY "MultiThreadedDLL"
    )

    target_link_libraries(${GXX_GEODE_PROJ_NAME} ${RUST_LIB} ${REQUIRED_NATIVE_LIBS})
    target_sources(${GXX_GEODE_PROJ_NAME} PUBLIC ${RUST_BRIDGE_CPP})
endfunction()