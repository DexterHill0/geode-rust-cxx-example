cmake_minimum_required(VERSION 3.21)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_OSX_ARCHITECTURES "x86_64")
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_EXPORT_COMPILE_COMMANDS true)

project(${GEODE_PROJECT_NAME} VERSION 1.0.0)

# Geode
add_library(${GEODE_PROJECT_NAME} SHARED
    src/main.cpp
    # Add your cpp files here
)

include(../cmake/GeodeCxx.cmake)

# RUSTC_TARGET_TRIPLE must match `.cargo/config.toml` 
setup_geode_cxx(GEODE_PROJ_NAME ${GEODE_PROJECT_NAME} RUST_CRATE_DIR ${CMAKE_SOURCE_DIR} RUST_CRATE_NAME ${RUST_CRATE_NAME} RUSTC_TARGET_TRIPLE "i686-pc-windows-msvc")

# since our main.h is defined in include/ we add the root folder
# !! change this include to wherever you decide to put the headers !!
target_include_directories(${GEODE_PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR}/geode_mod/src)

if (NOT DEFINED ENV{GEODE_SDK})
    message(FATAL_ERROR "Unable to find Geode SDK! Please define GEODE_SDK environment variable to point to Geode")
else()
    message(STATUS "Found Geode: $ENV{GEODE_SDK}")
endif()

add_subdirectory($ENV{GEODE_SDK} ${CMAKE_CURRENT_BINARY_DIR}/geode)

setup_geode_mod(${GEODE_PROJECT_NAME})