include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/EnsureCapnp.cmake")

option(QUCS_ENABLE_CORE "Enable CORE (.core) schematic import/export in Qucs-S" ON)
set(QUCS_CORE_SOURCE_DIR ""
    CACHE PATH "Local CommonDB checkout (skips git fetch)")
set(QUCS_CORE_GIT_URL "https://github.com/IHP-GmbH/CommonDB.git"
    CACHE STRING "CORE Git repository URL")
set(QUCS_CORE_GIT_TAG "main"
    CACHE STRING "CORE Git branch or tag")

function(_qucs_configure_core_subproject)
    qucs_ensure_capnp()
    set(CORE_BOOTSTRAP_CAPNP OFF CACHE BOOL "CORE uses external Cap'n Proto" FORCE)
    set(CORE_BUILD_TESTS OFF CACHE BOOL "Do not build CORE tests inside Qucs-S" FORCE)
    set(CORE_BUILD_OAS_TESTS OFF CACHE BOOL "Do not build CORE OAS tests inside Qucs-S" FORCE)
    set(CORE_BUILD_EXAMPLES OFF CACHE BOOL "Do not build CORE CLI tools inside Qucs-S" FORCE)
endfunction()

function(_qucs_add_core_aliases)
    if(TARGET core AND NOT TARGET CORE::core)
        add_library(CORE::core ALIAS core)
    endif()
    if(TARGET core_utils AND NOT TARGET CORE::core_utils)
        add_library(CORE::core_utils ALIAS core_utils)
    endif()
endfunction()

if(NOT QUCS_ENABLE_CORE)
    message(STATUS "CORE support disabled (QUCS_ENABLE_CORE=OFF)")
    return()
endif()

if(QUCS_CORE_SOURCE_DIR)
    if(NOT IS_DIRECTORY "${QUCS_CORE_SOURCE_DIR}")
        message(FATAL_ERROR "QUCS_CORE_SOURCE_DIR is not a directory: ${QUCS_CORE_SOURCE_DIR}")
    endif()
    message(STATUS "Using local CORE tree: ${QUCS_CORE_SOURCE_DIR}")
    _qucs_configure_core_subproject()
    add_subdirectory("${QUCS_CORE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/_deps/commondb-build")
    _qucs_add_core_aliases()
else()
  set(_default_core "${CMAKE_SOURCE_DIR}/../CommonDB")
  if(IS_DIRECTORY "${_default_core}")
      set(QUCS_CORE_SOURCE_DIR "${_default_core}")
      message(STATUS "Using sibling CORE tree: ${QUCS_CORE_SOURCE_DIR}")
      _qucs_configure_core_subproject()
      add_subdirectory("${QUCS_CORE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/_deps/commondb-build")
      _qucs_add_core_aliases()
  else()
      _qucs_configure_core_subproject()
      FetchContent_Declare(
          commondb
          GIT_REPOSITORY "${QUCS_CORE_GIT_URL}"
          GIT_TAG "${QUCS_CORE_GIT_TAG}"
          GIT_SHALLOW TRUE
          SOURCE_DIR "${CMAKE_SOURCE_DIR}/.deps/CommonDB"
          BINARY_DIR "${CMAKE_BINARY_DIR}/_deps/commondb-build"
      )
      message(STATUS "Fetching CORE from ${QUCS_CORE_GIT_URL} (${QUCS_CORE_GIT_TAG})...")
      FetchContent_MakeAvailable(commondb)
      _qucs_add_core_aliases()
  endif()
endif()

if(NOT TARGET CORE::core)
    message(FATAL_ERROR "CORE target CORE::core is missing after configuration.")
endif()

message(STATUS "CORE linked into Qucs-S")
