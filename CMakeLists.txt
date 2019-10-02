cmake_minimum_required(VERSION 3.14)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

message(STATUS "Finding nlohmann JSON library config package")
find_package(nlohmann_json 3.2.0 REQUIRED)

message(STATUS "Finding Fusion 360 library module package")
find_package(Fusion360 2.0.6263 REQUIRED)

option(IS_ADDIN "defines if this is a Fusion 360 script or addin" ON)

project(
        HelloContext
        VERSION 0.1.2
        DESCRIPTION "Fusion 360 Addin that integrates JSON parser to parse entry point context argument."
)

message(STATUS "Configuring .manifest file with project variables")
set(PROJECT_AUTHOR "Sean McVeigh")
set(PROJECT_GUID "c75fbb06-fe13-4a14-8c9c-2a056bd8cd5d")
if (IS_ADDIN)
    set(PROJECT_TYPE "addin")
else ()
    set(PROJECT_TYPE "script")
endif ()

configure_file(
        ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.manifest.in
        ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.manifest
)

message(STATUS "Adding target shared library to project")
add_library(${PROJECT_NAME} SHARED HelloContext.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

message(STATUS "Linking JSON library to project")
target_link_libraries(${PROJECT_NAME} PRIVATE "nlohmann_json::nlohmann_json")

message(STATUS "Linking Fusion 360 API library to primary shared library")
target_link_libraries(${PROJECT_NAME} PRIVATE "autodesk::Fusion360")

message(STATUS "Setting install location for library and manifest")
if (IS_ADDIN)
    set(PROJECT_INSTALL_DIR ${FUSION360_API_ADDINS_DIR}/${PROJECT_NAME})
else ()
    set(PROJECT_INSTALL_DIR ${FUSION360_API_SCRIPTS_DIR}/${PROJECT_NAME})
endif()
install (TARGETS ${PROJECT_NAME} DESTINATION ${PROJECT_INSTALL_DIR})
install (FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}.manifest DESTINATION ${PROJECT_INSTALL_DIR})
