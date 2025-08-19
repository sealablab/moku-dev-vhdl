# BasicBlock Module

## Overview

**BasicBlock** is a modular LED pattern generator designed for the **Moku-Go** platform. It generates simple strobing LED patterns on all outputs, similar to traditional Christmas lights, while maintaining the same control API as the SigGen module.

## 🎯 Purpose

This module serves as a **template and starting point** for future module development. It demonstrates:

- **Modular VHDL design** with clear separation of concerns
- **Integration with existing modules** (clk-divider)
- **Platform compatibility** (Moku-Go CustomWrapper interface)
- **Student-friendly documentation** with extensive explanations
- **Repeatable development workflow** for future projects

## 🏗️ Architecture

BasicBlock follows the **3-tier modular architecture** established by the ProbeDriver module:

```
BasicBlock/
├── common/                    # Shared packages and utilities
│   ├── led_pattern_pkg.vhd   # LED pattern generation functions
│   └── basicblock_pkg.vhd    # Main types and utilities
├── core/                     # Core business logic
│   └── basicblock_core.vhd   # Main LED pattern generation
├── wrapper/                  # Interface layer
│   └── basicblock_wrapper.vhd # Control register parsing
├── BasicBlock_Top.vhd        # Platform interface (CustomWrapper)
├── Makefile                  # Build automation
└── README.md                 # This documentation
```

### Architecture Benefits

- **Separation of Concerns**: Each layer has a specific responsibility
- **Maintainability**: Easy to modify individual components
- **Reusability**: Components can be used in other projects
- **Testability**: Each layer can be tested independently
- **Scalability**: Easy to add new features or patterns

## 🔧 Module Responsibilities

### 1. Common Layer (`common/`)

**Purpose**: Provides shared types, constants, and utility functions

**Files**:
- **`led_pattern_pkg.vhd`**: Contains all LED pattern generation functions
- **`basicblock_pkg.vhd`**: Main package with types and configuration utilities

**Key Features**:
- Pattern type constants (OFF, ALL_ON, ALTERNATE, CHASE, TWINKLE, WAVE, BREATH, CUSTOM)
- Configuration record types for structured data handling
- Validation functions for safe configuration
- Utility functions for common operations

### 2. Core Layer (`core/`)

**Purpose**: Contains the main LED pattern generation logic

**Files**:
- **`basicblock_core.vhd`**: Core pattern generation and timing control

**Key Features**:
- Integration with existing `clk-divider` module
- Individual output timing control
- Synchronization between outputs
- Brightness scaling and pattern generation

### 3. Wrapper Layer (`wrapper/`)

**Purpose**: Handles interface and control register parsing

**Files**:
- **`basicblock_wrapper.vhd`**: Interface between core and platform

**Key Features**:
- Control register parsing and validation
- Configuration structure creation
- Module interconnection management

### 4. Top Layer (`BasicBlock_Top.vhd`)

**Purpose**: Implements the Moku-Go platform interface

**Key Features**:
- CustomWrapper interface implementation
- Platform signal routing
- MCC compatibility

## 🎨 LED Patterns

BasicBlock supports 8 different LED patterns:

| Pattern | Code | Description |
|---------|------|-------------|
| OFF | 0000 | All outputs off |
| ALL_ON | 0001 | All outputs on at full brightness |
| ALTERNATE | 0010 | Classic Christmas light alternating pattern |
| CHASE | 0011 | Moving light effect (Knight Rider style) |
| TWINKLE | 0100 | Random twinkling effect |
| WAVE | 0101 | Wave-like pattern flowing across outputs |
| BREATH | 0110 | Breathing effect (fade in/out) |
| CUSTOM | 0111 | User-defined pattern (placeholder) |

### Pattern Examples

- **ALTERNATE**: Outputs A&C on, B&D off, then switch
- **CHASE**: Light moves from Output A → B → C → D → A...
- **TWINKLE**: Each output twinkles independently
- **WAVE**: Smooth wave effect across all outputs
- **BREATH**: All outputs fade in and out together

## 🎛️ Control Register Layout

BasicBlock uses 5 control registers (Control0-4) with the same API as SigGen:

### Control Register 0: Global Configuration
```
Bits 31: Master Enable (1=on, 0=off)
Bits 30-15: Clock Divider (1-65535)
Bit 14: Sync Mode (1=sync, 0=independent)
Bit 13: Reset Pattern (1=reset, 0=normal)
Bits 12-0: Reserved for future use
```

### Control Registers 1-4: Output Configuration (A, B, C, D)
```
Bits 31-28: Pattern Type (0000-0111)
Bits 27-20: Pattern Speed (1-255)
Bits 19-12: Brightness (0-255)
Bit 11: Enable (1=on, 0=off)
Bits 10-0: Reserved for future use
```

## 🕐 Clock Divider Integration

BasicBlock integrates with the existing `clk-divider` module:

- **Main Clock**: 125 MHz (Moku-Go platform)
- **Clock Divider**: Configurable division ratio (1-65535)
- **Pattern Timing**: Based on divided clock for visible LED patterns
- **Individual Control**: Each output can have different timing

### Timing Control

- **Global Clock Divider**: Controls overall system speed
- **Pattern Speed**: Individual output timing (1-255)
- **Synchronization**: Optional sync mode for coordinated patterns

## 🚀 Getting Started

### Prerequisites

- **GHDL**: VHDL compiler and simulator
- **Make**: Build automation tool
- **clk-divider module**: Must be available in work library

### Quick Start

1. **Navigate to BasicBlock directory**:
   ```bash
   cd BasicBlock
   ```

2. **Compile the module**:
   ```bash
   make analyze
   ```

3. **Create top-level design**:
   ```bash
   make elaborate
   ```

4. **Check available commands**:
   ```bash
   make help
   ```

### Build Commands

| Command | Purpose |
|---------|---------|
| `make` | Compile all files (default) |
| `make analyze` | Compile VHDL files |
| `make elaborate` | Create top-level design |
| `make clean` | Remove build files |
| `make help` | Show available commands |
| `make syntax` | Check VHDL syntax |
| `make info` | Show module information |
| `make deps` | Generate dependency graph |

## 📚 Learning Objectives

### For Students

1. **VHDL Fundamentals**:
   - Entity and architecture design
   - Package creation and usage
   - Signal and variable management
   - Process and concurrent statements

2. **Modular Design**:
   - Separation of concerns
   - Component instantiation
   - Port mapping and signal routing
   - Interface design

3. **Platform Integration**:
   - Moku-Go platform requirements
   - CustomWrapper interface
   - Control register system
   - MCC compatibility

4. **Build Systems**:
   - Makefile creation and usage
   - Dependency management
   - Build automation
   - Development workflow

### For Developers

1. **Template Usage**:
   - Copy BasicBlock structure for new modules
   - Modify pattern generation for different applications
   - Extend control register system
   - Add new features and capabilities

2. **Best Practices**:
   - Extensive commenting and documentation
   - Consistent naming conventions
   - Error handling and validation
   - Future expansion planning

## 🔮 Future Enhancements

### Pattern System
- **New Patterns**: Morse code, binary counting, music visualization
- **Pattern Sequences**: Complex multi-pattern sequences
- **User Patterns**: Load custom patterns from external sources
- **Pattern Validation**: Automated testing and validation

### Control System
- **Advanced Controls**: Use Control5-15 for additional features
- **Real-time Modification**: Change patterns during operation
- **External Synchronization**: Sync with audio, video, or network
- **Pattern Libraries**: Pre-built pattern collections

### Integration
- **Input Ports**: Use InputA-D for external triggers
- **Audio Reactive**: Respond to audio input signals
- **Network Control**: Remote pattern control via network
- **Advanced Timing**: Complex timing relationships

## 🧪 Testing and Validation

### Current Status
- **Syntax Validation**: All VHDL files compile successfully
- **Architecture Verification**: Modular structure confirmed
- **Integration Testing**: clk-divider integration verified
- **Platform Compatibility**: CustomWrapper interface implemented

### Future Testing
- **Simulation**: Add comprehensive testbench
- **Functional Testing**: Verify all pattern types
- **Timing Analysis**: Validate clock divider integration
- **Platform Testing**: Deploy to actual Moku-Go device

## 📖 Code Examples

### Python API Usage
```python
import moku
m = moku.MokuGo()

# Enable system and set global clock divider
m.set_control_register(0, 0x80000000 | (1000 << 15))  # Enable + divider 1000

# Set Output A to alternating pattern
m.set_control_register(1, 0x20000000 | (64 << 20) | (255 << 12) | (1 << 11))

# Set Output B to chase pattern
m.set_control_register(2, 0x30000000 | (32 << 20) | (200 << 12) | (1 << 11))

# Set Output C to twinkle pattern
m.set_control_register(3, 0x40000000 | (128 << 20) | (180 << 12) | (1 << 11))

# Set Output D to wave pattern
m.set_control_register(4, 0x50000000 | (96 << 20) | (220 << 12) | (1 << 11))
```

### VHDL Pattern Extension
```vhdl
-- Add new pattern to led_pattern_pkg.vhd
constant PATTERN_MORSE : std_logic_vector(3 downto 0) := "1000";

-- Implement pattern function
function generate_morse(counter_val : unsigned(15 downto 0); output_select : unsigned(1 downto 0)) return unsigned is
begin
    -- Morse code implementation
    case counter_val(15 downto 12) is
        when "0000" => return LED_ON;   -- Dot
        when "0001" => return LED_OFF;  -- Space
        when "0010" => return LED_ON;   -- Dash
        -- ... more morse code logic
        when others => return LED_OFF;
    end case;
end function;
```

## 🤝 Contributing

### Development Workflow
1. **Copy BasicBlock structure** for new modules
2. **Modify pattern generation** for specific applications
3. **Extend control system** as needed
4. **Add comprehensive documentation**
5. **Test thoroughly** before deployment

### Code Standards
- **Extensive commenting** for student understanding
- **Consistent naming** conventions
- **Error handling** and validation
- **Future expansion** planning
- **Platform compatibility** maintenance

## 📄 License

This module is part of the Moku VHDL Development Workspace and follows the same licensing terms as the parent project.

## 🙏 Acknowledgments

- **Liquid Instruments**: For the Moku-Go platform and MCC
- **ProbeDriver Module**: For establishing the 3-tier architecture pattern
- **clk-divider Module**: For providing flexible timing control
- **VHDL Community**: For best practices and design patterns

---

**BasicBlock** - Your starting point for modular VHDL development on Moku-Go! 🚀✨
