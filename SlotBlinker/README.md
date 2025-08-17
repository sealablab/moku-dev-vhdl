# SlotBlinker

A minimal, minimalist bitstream that generates distinct wave patterns on all four outputs (OutputA, OutputB, OutputC, OutputD) for easy identification on oscilloscope and logic analyzer instruments.

## Purpose

This project serves as a simple payload for driving the logic analyzer instrument and other instruments during testing and development. It generates easily identifiable patterns that can be clearly distinguished on both oscilloscope and logic analyzer displays.

## Output Patterns

The SlotBlinker generates four distinct counter patterns:

- **OutputA**: Fast counter (increments every clock cycle when enabled)
- **OutputB**: Medium speed counter (increments every 4th clock cycle)
- **OutputC**: Slow counter (increments every 16th clock cycle)  
- **OutputD**: Very slow counter (increments every 64th clock cycle)

## Control

- **Enable**: Control0(31) - Active low enable signal
- **Reset**: Global reset signal
- **Clock**: System clock input

## Files

- `SlotBlinker.vhd` - Main entity that generates the four output patterns
- `top_slot_blinker.vhd` - Top-level file that connects to CustomWrapper interface
- `Makefile` - Build configuration
- `README.md` - This file

## Usage

1. Build the project using the provided Makefile
2. Load the bitstream to your Moku device
3. Connect oscilloscope or logic analyzer to the outputs
4. Use Control0(31) to enable/disable the pattern generation

## Expected Behavior

When enabled, you should see:
- OutputA: Rapidly changing sawtooth pattern
- OutputB: Medium frequency sawtooth pattern (1/4 the speed of OutputA)
- OutputC: Slow sawtooth pattern (1/16 the speed of OutputA)
- OutputD: Very slow sawtooth pattern (1/64 the speed of OutputA)

These distinct frequencies make it easy to identify each output on measurement instruments and verify proper operation.
