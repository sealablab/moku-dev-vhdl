# ProbeDriver

This directory contains a clean, working copy of the ProbeDriver implementation extracted from the Slot2-ProbeDriver development.

## What This Is

- **Clean Copy**: A working version of the ProbeDriver code, free of development artifacts
- **All Tests Passing**: The implementation has been tested and verified to work correctly
- **Issue Resolved**: The testbench expectation mismatch has been fixed
- **Ready for Use**: This code is ready for deployment and further development

## Source

This code was extracted from the working `Slot2-ProbeDriver` branch at commit `v1.0.0-working` where all tests were passing successfully.

## Contents

- **Core Implementation**: ProbeDriver.vhd, IntensityLut.vhd, ProbeConfig.vhd
- **Integration**: CustomWrapper.vhd, top_probe_driver.vhd
- **Testing**: Complete testbench suite with all tests passing
- **Documentation**: Comprehensive documentation and troubleshooting summary
- **Build System**: Makefiles for easy compilation and testing

## Usage

```bash
# Check syntax
make syntax_check

# Run tests
cd testbench
make all
```

## Status

✅ **Fully Functional**: All core features working as intended  
✅ **Well Tested**: Comprehensive test coverage  
✅ **Documented**: Clear documentation and troubleshooting guide  
✅ **Ready**: Deployable and maintainable code
