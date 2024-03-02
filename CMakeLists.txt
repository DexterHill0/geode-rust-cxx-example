
cmake_minimum_required(VERSION 3.21)

set(GEODE_PROJECT_NAME geode_mod)
set(RUST_CRATE_NAME rust_lib)

project(geode-cxx-rust  VERSION 1.0.0)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/${GEODE_PROJECT_NAME}/)