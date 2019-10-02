cmake_minimum_required(VERSION 3.14)

##
##  CMake Variables
##  Must include project package directory in module search path.
##

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

##
##  Build Options
##  Controls automatic code generation and install destination.
##

option(TARGET_IS_ADDIN "Shared library target is an Addin" ON)

##
##  Find Dependencies
##  Sets up an interface libraries for linking to project.
##

message(STATUS "Finding required library packages")
find_package(Fusion360 2.0.6263 REQUIRED)
find_package(nlohmann_json 3.2.0 REQUIRED)

##
##  Define Project
##  Using project name to define build target for shared library
##

project(
        HelloContext
        VERSION 0.1.2
        DESCRIPTION "Fusion 360 Addin that integrates JSON parser to parse entry point context argument."
)

##
##  Manifest Variables
##  Defines more project properties used for configuring manifest file.
##

message(STATUS "Configuring .manifest file with project variables")
if (${TARGET_IS_ADDIN})
    set(MANIFEST_TYPE addin)
else ()
    set(MANIFEST_TYPE script)
endif ()
set(MANIFEST_AUTHOR "Sean McVeigh")
set(MANIFEST_VERSION ${PROJECT_VERSION})
set(MANIFEST_DESCRIPTION ${PROJECT_DESCRIPTION})
set(MANIFEST_GUID "c75fbb06-fe13-4a14-8c9c-2a056bd8cd5d")

##
##  Generate Manifest
##  Configure the manifest file for installing.
##

set(MANIFEST_INPUT_FILE "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.manifest.in")
set(MANIFEST_OUPUT_FILE "${PROJECT_BINARY_DIR}/${PROJECT_NAME}.manifest")
configure_file(${MANIFEST_INPUT_FILE} ${MANIFEST_OUPUT_FILE})

##
##  Add Shared Library
##  Defines the shared library to be built (with no library prefix)
##

message(STATUS "Adding target shared library to project")
add_library(${PROJECT_NAME} SHARED ${PROJECT_NAME}.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

##
##  Link Interface Libraries
##  Include headers and link shared librares to the project library.
##

message(STATUS "Linking interface libraries to target shared library")
target_link_libraries(${PROJECT_NAME} PRIVATE "autodesk::fusion360")
target_link_libraries(${PROJECT_NAME} PRIVATE "nlohmann_json::nlohmann_json")

##
##  Install Targets
##  Set install destinations to appropriate API directory
##

message(STATUS "Setting install location for library and manifest")
if (TARGET_IS_ADDIN)
    set(PROJECT_INSTALL_DIR ${FUSION360_API_ADDINS_DIR}/${PROJECT_NAME})
else ()
    set(PROJECT_INSTALL_DIR ${FUSION360_API_SCRIPTS_DIR}/${PROJECT_NAME})
endif()
install (TARGETS ${PROJECT_NAME} DESTINATION ${PROJECT_INSTALL_DIR})
install (FILES ${MANIFEST_OUPUT_FILE} DESTINATION ${PROJECT_INSTALL_DIR})
