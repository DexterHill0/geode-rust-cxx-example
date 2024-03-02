#[cxx::bridge]
mod ffi {
    struct SharedStruct {
        bar: usize,
    }

    extern "Rust" {
        type RustStruct;

        fn rust_get_rust_struct() -> Box<RustStruct>;
        fn rust_get_rust_struct_foo(s: Box<RustStruct>) -> usize;

        fn rust_test_cpp_get_shared();
    }

    unsafe extern "C++" {
        include!("main.h");

        fn cpp_get_shared() -> SharedStruct;
    }
}

struct RustStruct {
    pub foo: usize,
}

pub fn rust_get_rust_struct_foo(s: Box<RustStruct>) -> usize {
    s.foo
}

pub fn rust_get_rust_struct() -> Box<RustStruct> {
    Box::new(RustStruct { foo: 64 })
}

pub fn rust_test_cpp_get_shared() {
    let shared_struct = ffi::cpp_get_shared();

    println!("SharedStruct `bar`: {}", shared_struct.bar)
}
