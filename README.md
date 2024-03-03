# Geode Rust CXX

This is an example repo of a project that implements interop between Rust and C++ within a Geode mod. Rust can be called from C++ and vice versa.

It makes use of [CXX](https://cxx.rs/index.html) to handle the bindings and codegen.

## Prerequisites

Before this project will build, there are a few things required.

NOTE:

-   This project has only been tested on windows so for the time being the prerequisites only target windows.

It compiles with both MSVC and Clang (tested on Clang 17.0.1).

### Windows

-   [Windows 10/11 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/) (depends on your current OS)

-   Adding the `i686-pc-windows-msvc` toolchain:
    ```sh
    rustup target add --toolchain stable-x86_64-pc-windows-msvc i686-pc-windows-msvc
    ```

## Usage

Building the mod works like building a normal Geode mod. CMake should automatically handle building the Rust crate and linking, and the `build.rs` inside the crate invokes CXX which takes care of the rest.

NOTE:

-   If you get linker errors on the first build, you may need to manually build the crate first in which case run the command below:
    ```sh
    cargo build --release
    ```
    Subsequent builds should then compile without issue.

## Configuration

-   Inside the root `CMakeLists.txt` are two variables: `GEODE_PROJECT_NAME` and `RUST_CRATE_NAME`. These are pretty self explanatory but make sure to change them to whatever you name the folders.
-   Don't forget to update the neccessary information in the `mod.json`, `about.md` and other files, for your geode mod.
-   **If you plan to change the folder structure, don't forget to change everywhere that would be affected, especially the call to `setup_geode_cxx`**

## Potential issues

### `Mismatch detected for 'RuntimeLibrary': value 'MDd_DynamicDebug' doesn't match value 'MD_DynamicRelease' in cmake_pch.obj` / `lld-link: error: /failifmismatch: mismatch detected for 'RuntimeLibrary':`

This means you haven't selected `RelWithDebInfo` as the build variant for the Geode mod.

## `setup_geode_cxx`

This is the function that handles building the crate, linking the static Rust library with the Geode library, as well as linking all the required static native libraries, and other bits and pieces.

The arguments to this function are as follows:
| Name | Required | Description |
|---------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GEODE_PROJ_NAME | Yes | Name of the Geode mod folder |
| RUST_CRATE_DIR | Yes | Directory of the Rust crate |
| RUSTC_TARGET_TRIPLE | Yes | Rust compilation target. **Must match the one used in `.cargo/config.toml`** |
| RUST_CRATE_NAME | Yes | Name of the Rust crate. |
| CARGO_MANIFEST | No | Path to the `Cargo.toml` beloning to the crate. |
| CARGO_TARGET_DIR | No | Path to the output target folder of the crate. |
| CARGO_BIN | No | Path to the `cargo` executable. |
| CARGO_BUILD_PROFILE | No | The profile to build the crate with. Defaults to `release`. Any custom profile still needs to build like release would as a Geode mod is always built in release. |
