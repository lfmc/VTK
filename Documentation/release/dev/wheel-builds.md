## Wheel builds

VTK's Python wheels are now built by CI automatically. This should facilitate
nightly and more regular releases of the wheels. Wheels are automatically built for:

  - Python 3.6
  - Python 3.7
  - Python 3.8
  - Python 3.9

For the following targets on x86\_64:

  - manylinux2014
  - macos10.10
  - windows

Generally, all modules that do not require external libraries are available in
the official wheels.
