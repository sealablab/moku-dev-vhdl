# SigGen Module

## Overview
The SigGen module is a **modular signal generator** that provides configurable waveform generation capabilities. It was refactored from the monolithic `BestSlotBlinker` design to follow a clean, maintainable 3-tier architecture.

## Architecture

### 3-Tier Modular Design
```
SigGen/
├── common/                    # Shared packages and utilities
│   ├── pattern_generator_pkg.vhd  # Pattern generation functions
│   └── siggen_pkg.vhd            # Main package with types and utilities
├── core/                     # Core signal generation logic
│   └── siggen_core.vhd          # Main signal generation engine
├── wrapper/                  # Interface layer
│   └── siggen_wrapper.vhd       # Control parsing and core instantiation
└── SigGen_Top.vhd           # Top-level CustomWrapper interface
```

### Design Philosophy
- **Separation of Concerns**: Each module has a single, well-defined responsibility
- **Reusability**: Pattern functions can be used independently
- **Maintainability**: Easy to modify patterns or add new functionality
- **Testability**: Individual components can be tested in isolation
- **Scalability**: Simple to extend with new patterns or features

## Module Responsibilities

### 1. `pattern_generator_pkg.vhd` (Common)
- **Purpose**: Pattern generation utilities and functions
- **Contains**: 
  - 8 predefined waveform patterns (square, sawtooth, triangle, sine, etc.)
  - Pattern validation and utility functions
  - Constants for amplitude levels
- **Benefits**: Centralized pattern logic, easy to add new patterns

### 2. `siggen_pkg.vhd` (Common)
- **Purpose**: Main package with shared types, constants, and utilities
- **Contains**:
  - Configuration record types
  - Control register parsing functions
  - Validation and safe default functions
  - Utility functions for signal processing
- **Benefits**: Type safety, consistent configuration handling

### 3. `siggen_core.vhd` (Core)
- **Purpose**: Core signal generation logic and pipeline processing
- **Contains**:
  - Main counter and timing logic
  - 3-stage pipeline for pattern generation
  - Amplitude scaling and sign control
  - Frequency division and phase offset
- **Benefits**: Optimized performance, clean pipeline design

### 4. `siggen_wrapper.vhd` (Wrapper)
- **Purpose**: Interface layer and control register parsing
- **Contains**:
  - Control register parsing logic
  - Configuration validation
  - Core module instantiation
- **Benefits**: Clean interface, easy to modify control logic

### 5. `SigGen_Top.vhd` (Top-Level)
- **Purpose**: CustomWrapper interface for MCC synthesis
- **Contains**:
  - Platform-compatible interface
  - Wrapper instantiation
  - Output signal routing
- **Benefits**: Platform compatibility, easy integration

## Pattern Types

The module supports 8 configurable waveform patterns:

| Pattern | Code | Description |
|---------|------|-------------|
| Square Wave | 0000 | 50% duty cycle square wave |
| Sawtooth | 0001 | Linear ramp from 0 to 32767 |
| Triangle | 0010 | Symmetric triangle wave |
| Sine Approx | 0011 | 16-step sine approximation |
| LFSR Random | 0100 | Pseudo-random pattern |
| Staircase | 0101 | 4-level staircase |
| Pulse Train | 0110 | Narrow pulse train |
| Alternating | 0111 | Alternating level pattern |

## Control Register Layout

### Control0: Global Control
- **Bit 31**: Global Enable (active-low)
- **Bit 30**: Sign Control (0=unsigned, 1=signed)
- **Bits 28-24**: Global Clock Divider (1-32)
- **Bits 15-0**: Bit Mask for pattern modification

### Control1-4: Output Configuration (per output)
- **Bits 31-24**: Frequency Divider (1-256)
- **Bits 23-16**: Amplitude Scale (0-255)
- **Bits 15-8**: Extended Pattern Type (if > 0)
- **Bits 7-4**: Phase Offset (0-15)
- **Bits 3-0**: Local Pattern Type (if extended = 0)

## Usage

### Basic Compilation
```bash
cd SigGen
make analyze      # Analyze all VHDL files
make elaborate    # Elaborate the design
make clean        # Clean generated files
```

### Adding New Patterns
1. Add pattern function to `pattern_generator_pkg.vhd`
2. Update pattern constants and validation
3. Add to main `generate_pattern` function
4. Update documentation

### Modifying Control Logic
1. Edit parsing functions in `siggen_pkg.vhd`
2. Update wrapper logic in `siggen_wrapper.vhd`
3. Ensure type compatibility across modules

## Benefits of Refactoring

### Before (Monolithic BestSlotBlinker)
- **345 lines** in single file
- **Mixed responsibilities** (patterns, timing, control, output)
- **Hard to maintain** and extend
- **Difficult to test** individual components
- **Code duplication** across outputs

### After (Modular SigGen)
- **Separated concerns** into logical modules
- **Reusable components** (pattern functions, utilities)
- **Easy to maintain** and extend
- **Testable components** in isolation
- **Clean interfaces** between modules
- **Consistent architecture** with ProbeDriver

## Dependencies

- **VHDL-2008** standard
- **IEEE libraries** (Std_Logic_1164, Numeric_Std)
- **GHDL** for simulation and synthesis
- **Make** for build automation

## Future Enhancements

- **Additional patterns**: More complex waveforms, user-defined patterns
- **Advanced timing**: Variable duty cycles, burst modes
- **Memory patterns**: Load patterns from external memory
- **Synchronization**: Multiple output synchronization features
- **Real-time control**: Dynamic pattern switching

## Migration Notes

This module maintains **100% compatibility** with the original BestSlotBlinker functionality while providing a much cleaner, more maintainable architecture. All existing control register configurations will work identically.
