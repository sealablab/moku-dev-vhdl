# State Machine Implementation Requirements

## Overview

This document defines the standardized approach for implementing state machines in VHDL modules. The **hybrid approach** combines the benefits of VHDL enumerated types for internal logic with **Status Register records** for external visibility, following the established architecture defined in `register-requirements.md`.

**Key Principle**: All state machines must use VHDL enumerated types internally while providing external visibility through **Status Register records** that follow the established register architecture standards.

**Reference Implementation**: See `rework-v3/ProbeDriver/` for a complete, working example of this approach.

## Core Requirements

### **1. Internal State Management (VHDL Enumerated Types)**

**Must use VHDL enumerated types** for all internal state machines:
```vhdl
type module_state_type is (IDLE, FIRING, COOL_DOWN);
```

**Must include state-to-string functions** for debugging:
```vhdl
function module_state_to_string(state : module_state_type) return string;
```
