include_guard()

set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)

set(CMAKE_C_STANDARD 90)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(USE_CCACHE)
  message(STATUS "USE_CCACHE is ON")
  set(CMAKE_CXX_COMPILER_LAUNCHER buildcache)

  set(CMAKE_C_FLAGS_DEBUG   "/W3 /Z7 /Ob0 /Od /RTC1")
  set(CMAKE_CXX_FLAGS_DEBUG "/W3 /Z7 /Ob0 /Od /RTC1")

  set(CMAKE_C_FLAGS_RELWITHDEBINFO   "/W3 /Z7 /O2 /Ob2 /DNDEBUG")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/W3 /Z7 /O2 /Ob2 /DNDEBUG")
  
  set(CMAKE_EXE_LINKER_FLAGS_DEBUG    "/INCREMENTAL:NO")
  set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "/INCREMENTAL:NO")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/INCREMENTAL:NO")
else()
  message(STATUS "USE_CCACHE is OFF")
  set(CMAKE_C_FLAGS_DEBUG   "/W3 /ZI /Ob0 /Od /RTC1")
  set(CMAKE_CXX_FLAGS_DEBUG "/W3 /ZI /Ob0 /Od /RTC1")

  set(CMAKE_C_FLAGS_RELWITHDEBINFO   "/W3 /Zi /O2 /Ob2 /DNDEBUG")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "/W3 /Zi /O2 /Ob2 /DNDEBUG")

  set(CMAKE_EXE_LINKER_FLAGS_DEBUG    "/INCREMENTAL")
  set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "/INCREMENTAL")
  set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "/INCREMENTAL")
endif()


set(CMAKE_EXE_LINKER_FLAGS_DEBUG    "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /DEBUG /LTCG:OFF")
set(CMAKE_MODULE_LINKER_FLAGS_DEBUG "${CMAKE_MODULE_LINKER_FLAGS_DEBUG} /DEBUG /LTCG:OFF")
set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /DEBUG /LTCG:OFF")

set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO    "/DEBUG /INCREMENTAL:NO")
set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "/DEBUG /INCREMENTAL:NO")
set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "/DEBUG /INCREMENTAL:NO")

# ---------- MSVC warning suppressions MAP ----------
# /Zc:char8_t-       - Disable u8 strings in C++20
# /wd4250            - Inherits via dominance (diamond inheritance)
# /wd4251            - STL or non-exported type in exported class
# /wd4275            - Non-dll-interface base used in dll-interface class

# ---------- Enabled W4 warnings in W3 ----------
# /w34099            - Deprecated functions (e.g. strcpy)
# /w34101            - Missing return (DEBUG only)
# /w34240            - Risky structured bindings
# /w34267            - Misuse of [[nodiscard]]
# /w34390            - Shadowing warnings
# /w34996            - Unsafe use of std::function (DEBUG only)

# ---------- /ANALYZE ----------
# these were found mainly in third party libraries
# /wd6294:           - Ill-defined for-loop: loop body might not execute.
# /wd6201:           - Index out of valid range for buffer.
# /wd6326:           - Potential comparison of different types (constant vs variable).
# /wd6269:           - Possible incorrect order of operations (bitwise vs comparison).
# /wd6101:           - Returning uninitialized memory.
# /wd28301:          - Missing SAL annotation (_Out_, _In_, etc.).
# /wd6246:           - Local declaration shadows outer declaration.

# tescan explicit
# /wd6011:           - Dereferencing NULL pointer 'demonPointer'.
# /wd6262:           - Function uses 'xxxxx' bytes of stack.  Consider moving some data to heap.

# ---------------------- Misc --------------------
# /FS                - Fix for PDB file locking issues (e.g. Mantis 0019813)
# /Zc:__cplusplus    - Ensure correct __cplusplus value

add_compile_options(
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/Zc:char8_t->"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/wd4250>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/wd4251>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/wd4275>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/w34099>"
  "$<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:DEBUG>>:-Xcompiler=/w34101>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/w34240>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/w34267>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/w34390>"
  "$<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:DEBUG>>:-Xcompiler=/w34996>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/FS>"
  "$<$<COMPILE_LANGUAGE:CUDA>:-Xcompiler=/Zc:__cplusplus>"
)

if(PROJECT_NAME STREQUAL "Essence")
  add_compile_options(
    "$<$<COMPILE_LANGUAGE:CXX>:/Zc:char8_t->"
    "$<$<COMPILE_LANGUAGE:CXX>:/wd4250>"
    "$<$<COMPILE_LANGUAGE:CXX>:/wd4251>"
    "$<$<COMPILE_LANGUAGE:CXX>:/wd4275>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34099>"
    "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:/w34101>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34240>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34267>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34390>"
    "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:/w34244>"
    "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:/w34996>"
    "$<$<COMPILE_LANGUAGE:CXX>:/FS>"
    "$<$<COMPILE_LANGUAGE:CXX>:/Zc:__cplusplus>"
  )
  if(NOT USE_CCACHE AND CMAKE_SET_ANALYZE)
    add_compile_options(
      "$<$<COMPILE_LANGUAGE:CXX>:/analyze>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6294>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6201>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6326>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6269>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6101>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd28301>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6246>"

      "$<$<COMPILE_LANGUAGE:CXX>:/wd6011>"
      "$<$<COMPILE_LANGUAGE:CXX>:/wd6262>"
    )
  endif()
else()
  add_compile_options(
    "$<$<COMPILE_LANGUAGE:CXX>:/Zc:char8_t->"
    "$<$<COMPILE_LANGUAGE:CXX>:/wd4250>"
    "$<$<COMPILE_LANGUAGE:CXX>:/wd4251>"
    "$<$<COMPILE_LANGUAGE:CXX>:/wd4275>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34099>"
    "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:/w34101>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34240>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34267>"
    "$<$<COMPILE_LANGUAGE:CXX>:/w34390>"
    "$<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:/w34996>"
    "$<$<COMPILE_LANGUAGE:CXX>:/FS>"
    "$<$<COMPILE_LANGUAGE:CXX>:/Zc:__cplusplus>"
  )
endif()

add_compile_definitions(UNICODE _UNICODE)
