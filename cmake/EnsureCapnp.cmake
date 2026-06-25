function(qucs_ensure_capnp)
    if(CAPNP_ROOT AND EXISTS "${CAPNP_ROOT}/include/capnp/message.h")
        return()
    endif()

    foreach(_subdir IN ITEMS capnp-install-linux capnp-install)
        set(_sibling_commondb
            "${CMAKE_SOURCE_DIR}/../CommonDB/third_party/${_subdir}/include/capnp/message.h")
        if(EXISTS "${_sibling_commondb}")
            get_filename_component(_capnp_root "${_sibling_commondb}/../../.." ABSOLUTE)
            set(CAPNP_ROOT "${_capnp_root}" CACHE PATH "Cap'n Proto install prefix" FORCE)
            message(STATUS "Using Cap'n Proto from CommonDB: ${CAPNP_ROOT}")
            return()
        endif()
    endforeach()

    set(_sibling_libman "${CMAKE_SOURCE_DIR}/../LibMan/capnp-install/include/capnp/message.h")
    if(EXISTS "${_sibling_libman}")
        get_filename_component(_capnp_root "${_sibling_libman}/../../.." ABSOLUTE)
        set(CAPNP_ROOT "${_capnp_root}" CACHE PATH "Cap'n Proto install prefix" FORCE)
        message(STATUS "Using Cap'n Proto from LibMan: ${CAPNP_ROOT}")
        return()
    endif()

    set(_local_capnp "${CMAKE_SOURCE_DIR}/capnp-install/include/capnp/message.h")
    if(EXISTS "${_local_capnp}")
        set(CAPNP_ROOT "${CMAKE_SOURCE_DIR}/capnp-install" CACHE PATH "Cap'n Proto install prefix" FORCE)
        return()
    endif()

    message(FATAL_ERROR
        "Cap'n Proto not found. Set CAPNP_ROOT or build LibMan capnp-install "
        "(../LibMan/capnp-install).")
endfunction()
