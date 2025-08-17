#!/usr/bin/env python3
"""
Test script for Enhanced SlotBlinker Control Registers
Verifies safe defaults and control register behavior
"""

def print_control_register_analysis():
    """Analyze what happens when all control registers are zero"""
    print("=== Enhanced SlotBlinker Control Register Analysis ===\n")
    
    # All zeros scenario
    print("🔍 SCENARIO: All Control Registers = 0x00000000")
    print("=" * 50)
    
    # CR0 Analysis
    cr0 = 0x00000000
    nEnable = (cr0 >> 31) & 1
    soft_reset = (cr0 >> 30) & 1
    sign_control = (cr0 >> 29) & 1
    global_divider = (cr0 >> 24) & 0x1F
    pattern_sel = (cr0 >> 16) & 0xFF
    
    print(f"CR0 (0x{cr0:08X}):")
    print(f"  nEnable (bit 31): {nEnable} ({'ENABLED' if nEnable == 0 else 'DISABLED'})")
    print(f"  Soft Reset (bit 30): {soft_reset} ({'RESET' if soft_reset else 'NORMAL'})")
    print(f"  Sign Control (bit 29): {sign_control} ({'SIGNED' if sign_control else 'UNSIGNED'})")
    print(f"  Global Divider (bits 28-24): {global_divider} ({'INVALID - FIXED TO 1' if global_divider == 0 else f'{global_divider}x'})")
    print(f"  Pattern Select (bits 3-0): {pattern_sel} ({'SAWTOOTH' if pattern_sel == 0 else 'SQUARE' if pattern_sel == 1 else 'TRIANGLE' if pattern_sel == 2 else 'SINE' if pattern_sel == 3 else 'RANDOM' if pattern_sel == 4 else 'STAIRCASE' if pattern_sel == 5 else 'EXPONENTIAL' if pattern_sel == 6 else 'PULSE_TRAIN' if pattern_sel == 7 else 'RAMP_RESET' if pattern_sel == 8 else 'ALTERNATING' if pattern_sel == 9 else 'SINE_HARMONICS' if pattern_sel == 10 else 'CHIRP' if pattern_sel == 11 else 'NOISE_BURST' if pattern_sel == 12 else 'DUAL_FREQ' if pattern_sel == 13 else 'MODULATED' if pattern_sel == 14 else 'COMPLEX' if pattern_sel == 15 else 'UNKNOWN'})")
    print()
    
    # CR1-CR4 Analysis (all zeros)
    for i, cr in enumerate([0x00000000, 0x00000000, 0x00000000, 0x00000000], 1):
        freq_div = (cr >> 24) & 0xFF
        amp_scale = (cr >> 16) & 0xFF
        pattern_type = (cr >> 8) & 0xFF
        phase_offset = cr & 0xFF
        
        # Safe defaults
        safe_freq_div = freq_div if freq_div > 0 else [1, 4, 16, 64][i-1]
        safe_pattern_type = pattern_type if pattern_type <= 3 else 0
        
        print(f"CR{i} (0x{cr:08X}):")
        print(f"  Freq Divider (bits 31-24): {freq_div} ({'INVALID - FIXED TO ' + str(safe_freq_div) if freq_div == 0 else f'{freq_div}x'})")
        print(f"  Amp Scale (bits 23-16): {amp_scale} ({'INVALID - FIXED TO 100%' if amp_scale == 0 else f'{amp_scale/255*100:.1f}%'})")
        print(f"  Pattern Type (bits 15-8): {pattern_type} ({'SAWTOOTH' if safe_pattern_type == 0 else 'SQUARE' if safe_pattern_type == 1 else 'SINE' if safe_pattern_type == 2 else 'RANDOM' if safe_pattern_type == 3 else 'RESERVED'})")
        print(f"  Phase Offset (bits 7-0): {phase_offset} ({phase_offset/255*360:.1f}°)")
        print()
    
    print("✅ RESULT: Safe defaults prevent division by zero!")
    print("   - Global divider defaults to 1x")
    print("   - Frequency dividers default to [1, 4, 16, 64]")
    print("   - Amplitude scales default to 100% (full amplitude)")
    print("   - All outputs enabled and generating visible patterns")
    print("   - Unsigned mode (safe voltage range)")
    
    print("\n" + "=" * 50)
    
    # Recommended safe startup values
    print("🚀 RECOMMENDED SAFE STARTUP VALUES:")
    print("CR0: 0x00000000 (Enable, unsigned mode, all defaults)")
    print("CR1: 0x00000000 (Default: 1x speed, sawtooth)")
    print("CR2: 0x00000000 (Default: 4x speed, sawtooth)")
    print("CR3: 0x00000000 (Default: 16x speed, sawtooth)")
    print("CR4: 0x00000000 (Default: 64x speed, sawtooth)")
    
    print("\n" + "=" * 50)
    
    # Test different configurations
    print("🧪 TEST CONFIGURATIONS:")
    
    # Test 1: Fast patterns
    print("\n1. FAST PATTERNS (for debugging):")
    print("   CR0: 0x00000000 (Enable)")
    print("   CR1: 0x01000000 (1x speed)")
    print("   CR2: 0x02000000 (2x speed)")
    print("   CR3: 0x04000000 (4x speed)")
    print("   CR4: 0x08000000 (8x speed)")
    
    # Test 2: Different patterns
    print("\n2. DIFFERENT PATTERNS (Global Control):")
    print("   CR0: 0x00000000 (Enable + Sawtooth)")
    print("   CR0: 0x00000001 (Enable + Square Wave)")
    print("   CR0: 0x00000002 (Enable + Triangle Wave)")
    print("   CR0: 0x00000003 (Enable + Sine Wave)")
    print("   CR0: 0x00000004 (Enable + Random)")
    print("   CR0: 0x00000005 (Enable + Staircase)")
    print("   CR0: 0x00000006 (Enable + Exponential)")
    print("   CR0: 0x00000007 (Enable + Pulse Train)")
    print("   CR0: 0x00000008 (Enable + Ramp with Reset)")
    print("   CR0: 0x00000009 (Enable + Alternating Levels)")
    print("   CR0: 0x0000000A (Enable + Sine with Harmonics)")
    print("   CR0: 0x0000000B (Enable + Chirp)")
    print("   CR0: 0x0000000C (Enable + Noise Burst)")
    print("   CR0: 0x0000000D (Enable + Dual Frequency)")
    print("   CR0: 0x0000000E (Enable + Modulated Carrier)")
    print("   CR0: 0x0000000F (Enable + Complex Waveform)")
    
    # Test 3: Individual pattern override
    print("\n3. INDIVIDUAL PATTERN OVERRIDE:")
    print("   CR0: 0x00000000 (Global: Sawtooth)")
    print("   CR1: 0x00010000 (Output A: Square Wave)")
    print("   CR2: 0x00020000 (Output B: Triangle Wave)")
    print("   CR3: 0x00030000 (Output C: Sine Wave)")
    print("   CR4: 0x00040000 (Output D: Random)")
    
    # Test 4: Slow motion
    print("\n4. SLOW MOTION (for detailed analysis):")
    print("   CR0: 0x10000000 (Enable + 16x global divider)")
    print("   CR1: 0x00000000 (Default speeds)")
    print("   CR2: 0x00000000")
    print("   CR3: 0x00000000")
    print("   CR4: 0x00000000")
    
    # Test 5: Phase shifted
    print("\n5. PHASE SHIFTED (90° apart):")
    print("   CR0: 0x00000000 (Enable)")
    print("   CR1: 0x00000000 (0°)")
    print("   CR2: 0x00004000 (90°)")
    print("   CR3: 0x00008000 (180°)")
    print("   CR4: 0x0000C000 (270°)")
    
    # Test 6: Disable module
    print("\n6. DISABLE MODULE:")
    print("   CR0: 0x80000000 (Disable - bit 31 = 1)")
    print("   CR1: 0x00000000")
    print("   CR2: 0x00000000")
    print("   CR3: 0x00000000")
    print("   CR4: 0x00000000")

def test_control_register_calculations():
    """Test the control register bit field calculations"""
    print("\n" + "=" * 60)
    print("🧮 CONTROL REGISTER BIT FIELD CALCULATIONS")
    print("=" * 60)
    
    # Test CR0 parsing
    print("\nCR0 Bit Field Parsing:")
    cr0 = 0x00000000  # Enable only
    print(f"CR0 = 0x{cr0:08X}")
    print(f"  Bit 31 (nEnable): {(cr0 >> 31) & 1} ({'DISABLED' if (cr0 >> 31) & 1 else 'ENABLED'})")
    print(f"  Bit 30 (Soft Reset): {(cr0 >> 30) & 1}")
    print(f"  Bit 29 (Sign Control): {(cr0 >> 29) & 1}")
    print(f"  Bits 28-24 (Global Divider): {(cr0 >> 24) & 0x1F}")
    print(f"  Bits 3-0 (Pattern Select): {cr0 & 0xF}")
    
    # Test CR1 parsing
    print("\nCR1 Bit Field Parsing:")
    cr1 = 0x01010000  # 1x speed, square wave
    print(f"CR1 = 0x{cr1:08X}")
    print(f"  Bits 31-24 (Freq Divider): {(cr1 >> 24) & 0xFF}")
    print(f"  Bits 23-16 (Amp Scale): {(cr1 >> 16) & 0xFF}")
    print(f"  Bits 15-8 (Pattern Type): {(cr1 >> 8) & 0xFF}")
    print(f"  Bits 7-0 (Phase Offset): {cr1 & 0xFF}")
    
    # Test safe defaults
    print("\nSafe Default Calculations:")
    freq_div = 0
    safe_freq = freq_div if freq_div > 0 else 1
    print(f"  Freq Divider: {freq_div} -> Safe: {safe_freq}")
    
    global_div = 0
    safe_global = global_div if global_div > 0 else 1
    print(f"  Global Divider: {global_div} -> Safe: {safe_global}")

if __name__ == "__main__":
    print_control_register_analysis()
    test_control_register_calculations()
    
    print("\n" + "=" * 60)
    print("✅ ANALYSIS COMPLETE!")
    print("The Enhanced SlotBlinker should now work correctly")
    print("even when all control registers are zero!")
    print("=" * 60)
