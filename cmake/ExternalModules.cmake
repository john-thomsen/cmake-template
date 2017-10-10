# MIT License

# Copyright (c) 2017 John Thomsen

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
 
# Macro that wraps an ExternalProject_Add function configured for External CMake projects
# v1.0.0
# Build Type (${CMAKE_BUILD_TYPE}), Platform (IOS, Android, Linux, OSX), 
# and Generator (${CMAKE_GENERATOR}) must be defined by project that calls the macro. 
# Additional CMake configuration must be defined in the module project being handled by external project

macro(ExternalModules git-ssh git-id module-name)

	set(MODULE_ROOT ${CMAKE_SOURCE_DIR}/.external_modules/${module-name})
	if(OSX)
		set(EP_PLATFORM osx)
		if(${CMAKE_GENERATOR} STREQUAL "Xcode")
			set(EP_CMDLINE_ARG1 "-DOSX=True")
			set(EP_BUILD_CMD xcodebuild -target ${module-name} -configuration ${CMAKE_BUILD_TYPE} ENABLE_BITCODE=NO)
		elseif(${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
			set(EP_CMDLINE_ARG1 "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
			set(EP_BUILD_CMD "make")
		else()
			message(SEND_ERROR "CMake generator not supported by ExternalModules for this platform")
		endif()
	elseif(Linux)
		if(${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
			set(EP_PLATFORM linux)
			set(EP_CMDLINE_ARG1 "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
			set(EP_BUILD_CMD "make")
		else()
			message(SEND_ERROR "CMake generator not supported by ExternalModules for this platform")
		endif()
	endif()

	include(ExternalProject)
	ExternalProject_Add(
	  external_module_${module-name}
	  PREFIX ${MODULE_ROOT}
	  DOWNLOAD_COMMAND git clone ${git-ssh} external_module_${module-name} || true
	  UPDATE_COMMAND git fetch && git checkout ${git-id}
	  CONFIGURE_COMMAND ""
	  BUILD_COMMAND mkdir -p <BINARY_DIR>/${EP_PLATFORM} && cd <BINARY_DIR>/${EP_PLATFORM} && ${CMAKE_COMMAND} -G${CMAKE_GENERATOR} ${EP_CMDLINE_ARG1} ${EP_CMDLINE_ARG2} ${EP_CMDLINE_ARG3} <SOURCE_DIR> && ${EP_BUILD_CMD}
	  INSTALL_COMMAND ""
	)

	ExternalProject_Get_Property(external_module_${module-name} BINARY_DIR)
	add_library(${module-name} STATIC IMPORTED)
	if(${CMAKE_GENERATOR} STREQUAL "Xcode")
		set_property(TARGET ${module-name} PROPERTY IMPORTED_LOCATION ${BINARY_DIR}/${EP_PLATFORM}/MinSizeRel/${module-name}.framework/${module-name})
	else()
		set_property(TARGET ${module-name} PROPERTY IMPORTED_LOCATION ${BINARY_DIR}/${EP_PLATFORM}/lib${module-name}.a)
	endif()
	include_directories(${INSTALL_DIR}/include)
endmacro(ExternalModules)
