# ProbeDriver Refactoring: Removing Entity Duplication

## Overview

This document describes the refactoring changes made to remove the duplicate `CustomWrapper` entity that was causing compilation conflicts with MCC (Moku Cloud Compiler).

## Problem

The original `ProbeDriver_Top.vhd` file contained a `CustomWrapper` entity, which duplicated the interface that MCC provides. This caused compilation conflicts when trying to synthesize the design with MCC.

## Solution

The refactoring consolidates everything into a single, well-named file:

1. **`ProbeDriver.vhd`** - Contains the complete probe driver implementation as an architecture for MCC's `CustomWrapper` entity
2. **`ProbeDriver_Top.vhd`** - **REMOVED** (no longer needed)
3. **`CustomWrapper.vhd`** - **REMOVED** (renamed to ProbeDriver.vhd)
4. **`Makefile-MCC`** - **REMOVED** (consolidated into single Makefile)

**Important**: The build system now references `../MokuModules/CustomWrapper.vhd` which provides the entity declaration that `ProbeDriver.vhd` implements.

## File Structure

```
ProbeDriver/
├── ProbeDriver.vhd              # COMPLETE: Integrated probe driver implementation
├── wrapper/
│   └── probe_driver_wrapper.vhd  # Alternative wrapper (not used for MCC)
├── core/
│   └── probe_driver_core.vhd     # Core state machine
├── common/
│   ├── probe_driver_pkg.vhd      # Shared package
│   └── intensity_lut_pkg.vhd     # Intensity lookup table
├── Makefile                      # SINGLE: Simplified build system
└── README-REFACTORING.md         # This file

Dependencies:
└── ../MokuModules/
    └── CustomWrapper.vhd         # Entity declaration (referenced by Makefile)
```

## Build System

### Single, Simplified Makefile

The build system has been simplified to a single Makefile that includes the necessary entity declaration:

```bash
make                    # Default: Build ProbeDriver for MCC
make build             # Explicit build
make check_package     # Check package files
make check_main        # Check core files
make check_top         # Check top-level files (includes CustomWrapper.vhd)
make clean             # Clean up
```

### Build Dependencies

The build process now includes:
1. **Clock divider module** - `../clk-divider/clk_divider.vhd`
2. **Intensity lookup table package** - `common/intensity_lut_pkg.vhd`
3. **Probe driver package** - `common/probe_driver_pkg.vhd`
4. **Core state machine** - `core/probe_driver_core.vhd`
5. **CustomWrapper entity** - `../MokuModules/CustomWrapper.vhd` (entity declaration)
6. **ProbeDriver implementation** - `ProbeDriver.vhd` (architecture)

### MCC Synthesis (Primary)

Use `ProbeDriver.vhd` for MCC synthesis:

```bash
make                    # Build ProbeDriver for MCC
make build             # Build ProbeDriver for MCC
```

## Key Changes

### ProbeDriver.vhd (CONSOLIDATED & RENAMED)
- **BEFORE**: Generic `CustomWrapper.vhd` name
- **AFTER**: Clear, descriptive `ProbeDriver.vhd` name
- **INCLUDES**: All control register mapping, LED logic, clock divider, and core instantiation
- **DESIGN**: Architecture-only file for MCC's CustomWrapper entity

### Files Removed
- **`ProbeDriver_Top.vhd`** - Completely eliminated
- **`CustomWrapper.vhd`** - Renamed to ProbeDriver.vhd
- **`Makefile-MCC`** - Consolidated into single Makefile

### Makefile (SIMPLIFIED & ENHANCED)
- **BEFORE**: Dual-mode complexity with multiple targets
- **AFTER**: Single, clean build system with proper entity reference
- **ENHANCEMENT**: Now includes `../MokuModules/CustomWrapper.vhd` for entity declaration
- **BENEFIT**: Easier to understand, maintain, and actually compiles successfully

## Benefits

1. **No More Duplication** - Single file contains all probe driver logic
2. **Clear Naming** - `ProbeDriver.vhd` clearly indicates the file's purpose
3. **MCC Compatibility** - Can now be synthesized with MCC without conflicts
4. **Preserved Functionality** - All existing functionality remains intact
5. **Simplified Structure** - Fewer files to maintain and manage
6. **Single Build System** - One Makefile instead of two
7. **Proper Dependencies** - Build system now includes necessary entity declaration

## Usage Examples

### For MCC Synthesis
```bash
cd moku-dev-vhdl/ProbeDriver
make                    # Build ProbeDriver for MCC
make build             # Build ProbeDriver for MCC
```

### For Development
```bash
cd moku-dev-vhdl/ProbeDriver
make check_package     # Check package files
make check_main        # Check core files
make check_top         # Check top-level files (includes CustomWrapper.vhd)
```

### Clean Build
```bash
make clean             # Remove all generated files
```

## Important Notes

### Standalone Compilation
- **`ProbeDriver.vhd` can now be compiled successfully** because the Makefile includes the `CustomWrapper.vhd` entity declaration
- The build system properly resolves the entity-architecture relationship
- For standalone development, use the individual component files or the full build

### MCC Integration
- MCC will provide the `CustomWrapper` entity declaration
- Our file provides the `Behavioural` architecture implementation
- This creates a clean separation without duplication
- The build system now properly supports both standalone and MCC workflows

## Verification

To verify the refactoring works correctly:

1. **Full Build**: `make build` now completes successfully with all files
2. **Individual Components**: `make check_package`, `make check_main` work correctly
3. **Top-Level Check**: `make check_top` includes CustomWrapper.vhd and ProbeDriver.vhd
4. **No Conflicts**: File structure is clean and ready for MCC synthesis
5. **Functionality**: All probe driver features are preserved in the consolidated file

## Migration Notes

- Existing testbenches and simulations will need to be updated if they referenced removed files
- No changes needed to control register mappings or functionality
- The refactoring is purely structural - no behavioral changes
- MCC synthesis path is now the primary and only build path
- Build system is simplified to a single Makefile with proper dependencies

## Future Considerations

- The consolidated approach makes it easier to maintain and modify probe driver functionality
- All logic is in one place, reducing the chance of inconsistencies
- Clean architecture-only approach is ideal for MCC integration
- Single Makefile reduces maintenance overhead
- Clear naming convention makes the codebase more intuitive
- Proper dependency management ensures successful builds
