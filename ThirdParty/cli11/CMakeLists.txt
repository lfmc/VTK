vtk_module_third_party(
  INTERNAL
    LICENSE_FILES "vtkcli11/LICENSE"
    VERSION       "1.9.1"
    HEADER_ONLY
    STANDARD_INCLUDE_DIRS
  EXTERNAL
    PACKAGE CLI11
    TARGETS CLI11::CLI11
    STANDARD_INCLUDE_DIRS)

configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/vtk_cli11.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/vtk_cli11.h")

vtk_module_install_headers(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/vtk_cli11.h")
