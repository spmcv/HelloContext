cmake_minimum_required(VERSION 3.14)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

message(STATUS "Finding nlohmann JSON library config package")
find_package(nlohmann_json 3.2.0 REQUIRED)

message(STATUS "Finding Fusion 360 library module package")
find_package(Fusion360 2.0.6263 REQUIRED)

project(
        HelloContext
        VERSION 0.1.0
        DESCRIPTION "Fusion 360 Addin that integrates JSON parser to parse entry point context argument."
)

add_library(${PROJECT_NAME} SHARED HelloContext.cpp)
set_target_properties(${PROJECT_NAME} PROPERTIES PREFIX "")

message(STATUS "Linking nlohmann JSON library to project")
target_link_libraries(${PROJECT_NAME} PRIVATE "nlohmann_json::nlohmann_json")

message(STATUS "Linking Fusion 360 API library to project")
target_link_libraries(${PROJECT_NAME} PRIVATE "autodesk::Fusion360")

message(STATUS "Setting install location for target shared library")
install (TARGETS ${PROJECT_NAME} DESTINATION ${PROJECT_SOURCE_DIR})
