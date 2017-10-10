cmake_minimum_required(VERSION 3.9)

include("cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/ruslo/hunter/archive/v0.19.23.tar.gz"
    SHA1 "a9e131540f2d057e53374ffc10c62c19a8df5ff8"
)

project(project_template)

#project name config
set(STATIC_LIB_NAME example_static)
set(SHARED_LIB_NAME example_shared)
set(TEST_EXE_NAME test_example)

#use C++11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message(STATUS "C++11 support has been enabled by default.")

#include hunter package

include(cmake/ExternalModules.cmake)
ExternalModules("git@github.com:j-thomsen/example-module.git" "tags/v0.1.0" "example")

#build libraries
include_directories(src)

add_library( ${STATIC_LIB_NAME} STATIC
    src/example.cpp
)

add_library( ${SHARED_LIB_NAME} SHARED
  src/example.cpp
)

add_dependencies(${SHARED_LIB_NAME} external_module_example)
#target_link_libraries( ${SHARED_LIB_NAME} /usr/local/lib/libexample.a)
message("johndebug root")
message("${CMAKE_AR}")
message("${CMAKE_RANLIB}")
target_link_libraries( ${SHARED_LIB_NAME} example)

#build demo app
#add_executable(example_demo src/main.cpp)
#target_link_libraries(example_demo ${STATIC_LIB_NAME})

#set up library flags
foreach(library ${STATIC_LIB_NAME} ${SHARED_LIB_NAME} )
  set_target_properties( ${library} PROPERTIES

    #basic library settings should optimize for size without aggressively de-optimizing or compromising safety
    COMPILE_FLAGS "-W -Wall -Werror -fno-rtti -fno-unwind-tables -flto -Os"

    #Switch to these flags for maximum size optimization
    #COMPILE_FLAGS "-W -Wall -fvisibility-inlines-hidden -fno-unroll-loops -fno-ident -ffast-math -fno-math-errno -fomit-frame-pointer -fno-stack-protector -fno-rtti -fno-unwind-tables -ffunction-sections -fdata-sections -flto -Os"
    )
endforeach()

#build gtest unit tests - run ${TEST_EXE_NAME} to run tests
#add_executable(${TEST_EXE_NAME} test/example_unit_test.cpp)
#define global test hook for make - run 'make test' from build directory
#add_definitions(-DDATA_DIR="${CMAKE_SOURCE_DIR}/test/data")
#enable_testing()
#add_test(NAME AllUnitTests COMMAND ${TEST_EXE_NAME})
