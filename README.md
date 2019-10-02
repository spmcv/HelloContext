# HelloContext 

This project is a proof of concept of using a library dependency to enable [Fusion 360 Addin and Script development][1]
using a [CMake][2] build system. This enables support of development environments other than Visual Studio and Xcode,
such as [CLion][3].

## Motivation

Upon the creation of a new script or add-in, Fusion 360 generates a template project with both a Visual Studio and XCode
project file containing the relevant build settings. This unnecessarily complicates cross-platform C++ development and
dependency management. 

## Solution

A straightforward solution is to support the CMake build system. Visual Studio already has [built-in support][4] for
CMake and CMake can [generate Xcode project files][5]. CMake also has [robust package management][6] for including
dependencies on other CMake projects.

## Approach

Since Fusion 360 API does not have built-in support for the CMake [package system][6], the approach this project takes
is to use the **MODULE** signature of [`find_package()`][7] to import a versioned package of the Fusion 360 API.

Internally, the CMake module finds and links the headers and shared libraries into an interface library and derives the 
interface library version from the `version.txt` file specified in the Fusion 360 API directory. This enables the script
or add-in to specify API version requirements, a future not currently not supported by AutoDesk.

## Features

This project includes a derivation of the default project with the following differences:

1. All the features previously described.
2. Provides a CMake option to configure building for a script or add-in.
3. Generates entry point source code based upon the build option. This is accomplished by configuring 
function macros inspired by [Better Macros, Better Flags][10]. 
3. Generates a `.manifest` JSON with project variables. This ensures that the manifest describing the project
is consistent with source code.
4. Configures the install destination for the script or add-in shared library and `.manifest`. This allowing
seamless support of either cohabiting source and install targets (Fusion 360 default) or separation of the project
directory from the Fusion 360 API directory. The later is especially attractive in the context of the build option
previously described.
5. Includes a dependency on JSON parsing library [nlohmann json][8]. This demonstrate the ease of integrating external
libraries in script or add-in development.
6. Entry points parse the `context` argument passed using the JSON parsing library. This provides an example for using
external libraries to provide functionality not included in the [Fusion 360 API][1].


[1]: https://autodeskfusion360.github.io/
[2]: https://cmake.org/cmake/help/latest/
[3]: https://www.jetbrains.com/clion/
[4]: https://docs.microsoft.com/en-us/cpp/build/cmake-projects-in-visual-studio
[5]: https://cmake.org/cmake/help/latest/generator/Xcode.html
[6]: https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html
[7]: https://cmake.org/cmake/help/latest/command/find_package.html
[8]: https://github.com/nlohmann/json
[9]: http://help.autodesk.com/view/fusion360/ENU/?guid=WritingDebugging_UM 
[10]: https://www.fluentcpp.com/2019/05/28/better-macros-better-flags/