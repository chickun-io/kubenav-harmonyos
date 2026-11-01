cmake_minimum_required(VERSION 3.5.0)
project(kubenav_ffi)

add_library(kubenav_ffi SHARED napi_init.cpp)

# Link by library name. An imported absolute path is written into DT_NEEDED,
# so the phone looks for the library on the build machine and the module
# never loads.
set(KUBENAV_PREBUILT ${CMAKE_CURRENT_SOURCE_DIR}/prebuilt/${OHOS_ARCH})
target_link_directories(kubenav_ffi PRIVATE ${KUBENAV_PREBUILT})
target_link_libraries(kubenav_ffi PUBLIC libace_napi.z.so -l:libkubenav.so)
set_target_properties(kubenav_ffi PROPERTIES
    SKIP_BUILD_RPATH TRUE
    BUILD_RPATH ""
    INSTALL_RPATH "")
