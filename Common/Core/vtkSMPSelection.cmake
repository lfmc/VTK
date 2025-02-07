set(VTK_SMP_IMPLEMENTATION_TYPE "Sequential"
  CACHE STRING "Which multi-threaded parallelism implementation to use. Options are Sequential, STDThread, OpenMP or TBB")
set_property(CACHE VTK_SMP_IMPLEMENTATION_TYPE
  PROPERTY
    STRINGS Sequential OpenMP TBB STDThread)

if (NOT (VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "OpenMP" OR
         VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "TBB" OR
         VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "STDThread"))
  set_property(CACHE VTK_SMP_IMPLEMENTATION_TYPE
    PROPERTY
      VALUE "Sequential")
endif ()

set(vtk_smp_headers_to_configure)
set(vtk_smp_defines)
set(vtk_smp_use_default_atomics ON)

if (VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "TBB")
  vtk_module_find_package(PACKAGE TBB)
  list(APPEND vtk_smp_libraries
    TBB::tbb)

  set(vtk_smp_use_default_atomics OFF)
  set(vtk_smp_implementation_dir "${CMAKE_CURRENT_SOURCE_DIR}/SMP/TBB")
  list(APPEND vtk_smp_sources
    "${vtk_smp_implementation_dir}/vtkSMPTools.cxx")
  list(APPEND vtk_smp_headers_to_configure
    vtkSMPToolsInternal.h
    vtkSMPThreadLocal.h)

elseif (VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "OpenMP")
  vtk_module_find_package(PACKAGE OpenMP)

  list(APPEND vtk_smp_libraries
    OpenMP::OpenMP_CXX)

  set(vtk_smp_implementation_dir "${CMAKE_CURRENT_SOURCE_DIR}/SMP/OpenMP")
  list(APPEND vtk_smp_sources
    "${vtk_smp_implementation_dir}/vtkSMPTools.cxx"
    "${vtk_smp_implementation_dir}/vtkSMPThreadLocalImpl.cxx")
  list(APPEND vtk_smp_headers_to_configure
    vtkSMPThreadLocal.h
    vtkSMPThreadLocalImpl.h
    vtkSMPToolsInternal.h)

  if (OpenMP_CXX_SPEC_DATE AND NOT "${OpenMP_CXX_SPEC_DATE}" LESS "201107")
    set(vtk_smp_use_default_atomics OFF)
  else()
    message(WARNING
      "Required OpenMP version (3.1) for atomics not detected. Using default "
      "atomics implementation.")
  endif()

elseif (VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "STDThread")
  set(vtk_smp_implementation_dir "${CMAKE_CURRENT_SOURCE_DIR}/SMP/STDThread")

  list(APPEND vtk_smp_sources
    "${vtk_smp_implementation_dir}/vtkSMPTools.cxx"
    "${vtk_smp_implementation_dir}/vtkSMPThreadLocalImpl.cxx"
    "${vtk_smp_implementation_dir}/vtkSMPThreadPool.cxx")
  list(APPEND vtk_smp_headers_to_configure
    vtkSMPThreadLocal.h
    vtkSMPThreadLocalImpl.h
    vtkSMPThreadPool.h
    vtkSMPToolsInternal.h)

elseif (VTK_SMP_IMPLEMENTATION_TYPE STREQUAL "Sequential")
  set(vtk_smp_implementation_dir "${CMAKE_CURRENT_SOURCE_DIR}/SMP/Sequential")
  list(APPEND vtk_smp_sources
    "${vtk_smp_implementation_dir}/vtkSMPTools.cxx")
  list(APPEND vtk_smp_headers_to_configure
    vtkSMPThreadLocal.h
    vtkSMPToolsInternal.h)
endif()

if (vtk_smp_use_default_atomics)
  include(CheckSymbolExists)

  include("${CMAKE_CURRENT_SOURCE_DIR}/vtkTestBuiltins.cmake")

  set(vtk_atomics_default_impl_dir "${CMAKE_CURRENT_SOURCE_DIR}/SMP/Sequential")
endif()

foreach (vtk_smp_header IN LISTS vtk_smp_headers_to_configure)
  configure_file(
    "${vtk_smp_implementation_dir}/${vtk_smp_header}"
    "${CMAKE_CURRENT_BINARY_DIR}/${vtk_smp_header}"
    COPYONLY)
  list(APPEND vtk_smp_headers
    "${CMAKE_CURRENT_BINARY_DIR}/${vtk_smp_header}")
endforeach()

list(APPEND vtk_smp_sources
  vtkSMPTools.cxx)

list(APPEND vtk_smp_templates
  vtkSMPTools.txx)

list(APPEND vtk_smp_headers
  vtkSMPTools.h
  vtkSMPToolsInternalCommon.h
  vtkSMPThreadLocalObject.h)
