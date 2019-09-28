cmake_minimum_required(VERSION 3.14)

set(FUSION360_API_TARGET Fusion360)
set(FUSION360_API_NAMESPACE autodesk)
set(FUSION360_API_DESCRIPTION "External project dependency for Fusion 360 API")
set(FUSION360_API_HOMEPAGE_URL "https://autodeskfusion360.github.io/")

##
## Fusion 360 API Directories
##

if (WIN32)
    string(JOIN "/" USER_APP_DATA_DIR $ENV{HOME} "%appdata%")
elseif (APPLE)
    string(JOIN "/" USER_APP_DATA_DIR $ENV{HOME} "Library" "Application Support")
else ()
    message(FATAL_ERROR " Autodesk does not support Fusion 360 API on this platform")
endif ()

string(JOIN "/" USER_APP_DATA_RELATIVE_PATH "Autodesk" "Autodesk Fusion 360" "API")

function (validate_api_path relativePath pathDescription)
    set(messageDetail "API ${pathDescription} at ${relativePath}")
    if (EXISTS ${relativePath})
        set(messageLevel DEBUG)
        set(testResult "succesfully located")
    else ()
        set(messageLevel FATAL_ERROR)
        set(testResult "failed to locate")
    endif ()
    message(${messageLevel} " " ${testResult} " " ${messageDetail})
endfunction (validate_api_path)

string(JOIN "/" FUSION360_API_DIR ${USER_APP_DATA_DIR} ${USER_APP_DATA_RELATIVE_PATH})
validate_api_path(${FUSION360_API_DIR} "root directory")

string(JOIN "/" FUSION360_API_SCRIPTS_DIR ${FUSION360_API_DIR} "Scripts")
validate_api_path(${FUSION360_API_SCRIPTS_DIR} "Scripts directory")

string(JOIN "/" FUSION360_API_ADDINS_DIR ${FUSION360_API_DIR} "Addins")
validate_api_path(${FUSION360_API_ADDINS_DIR} "Addins directory")

string(JOIN "/" FUSION360_API_INCLUDE_DIR ${FUSION360_API_DIR} "CPP" "include")
validate_api_path(${FUSION360_API_INCLUDE_DIR} "headers directory")

string(JOIN "/" FUSION360_API_LIBRARY_DIR ${FUSION360_API_DIR} "CPP" "lib")
validate_api_path(${FUSION360_API_LIBRARY_DIR} "shared library directory")

string(JOIN "/" FUSION360_API_VERSION_FILE ${FUSION360_API_DIR} "version.txt")
validate_api_path(${FUSION360_API_VERSION_FILE} "version file")

##
## Fusion 360 API Version
##

file(READ ${FUSION360_API_VERSION_FILE} FUSION360_API_VERSION)
message(DEBUG " imported API version number as ${FUSION360_API_VERSION}")

##
## Project Declaration
##

project(
        ${FUSION360_API_TARGET}
        VERSION ${FUSION360_API_VERSION}
        DESCRIPTION ${FUSION360_API_DESCRIPTION}
        HOMEPAGE_URL ${FUSION360_API_HOMEPAGE_URL}
)

##
## Add Interface Library
##

message(DEBUG " adding interface library target '${FUSION360_API_TARGET}'")
add_library(${FUSION360_API_TARGET} INTERFACE)

message(DEBUG " aliasing interface library target with namespace '${FUSION360_API_NAMESPACE}'")
add_library("${FUSION360_API_NAMESPACE}::${FUSION360_API_TARGET}" ALIAS ${FUSION360_API_TARGET})

##
## Fusion 360 API Shared Libraries
##

function (add_api_library libraryTarget)
    message(DEBUG " adding shared library target ${libraryTarget} to interface library target")
    set(fileName "${libraryTarget}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(filePath "${FUSION360_API_LIBRARY_DIR}/${fileName}")
    message(DEBUG " imported location is ${filePath}")
    validate_api_path(${filePath} "${libraryTarget} shared library")
    add_library(${libraryTarget} SHARED IMPORTED)
    set_property(TARGET ${libraryTarget} PROPERTY IMPORTED_LOCATION ${filePath})
endfunction (add_api_library)

set(FUSION_API_LIBRARY_TARGETS "cam" "core" "fusion")

foreach (target IN ITEMS ${FUSION_API_LIBRARY_TARGETS})
    add_api_library(${target})
endforeach ()

##
##  Including directories and linking libraries
##

target_include_directories(${FUSION360_API_TARGET} INTERFACE ${FUSION360_API_INCLUDE_DIR})
target_link_libraries(${FUSION360_API_TARGET} INTERFACE ${FUSION_API_LIBRARY_TARGETS})
