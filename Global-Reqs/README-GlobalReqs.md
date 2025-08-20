# README-GlobalReqs

Spent some time trying to 'generalize' and update the previous design patterns into a more coherent set of rules.

**The individual requirements documents in this directory should be applied to all new vhdl modules created in this repository**

## Available Requirements Documents

### **Core Architecture Requirements**
- **`register-requirements.md`** - Three register types (Control, Configuration, Status) with equal treatment
- **`module-naming-scheme-reqs.md`** - Four-layer architecture and naming conventions
- **`state-machine-requirements.md`** - Hybrid approach using VHDL state types internally and status register bits externally

### **Application Order**
1. **Start with** `module-naming-scheme-reqs.md` for directory structure and layer organization
2. **Apply** `state-machine-requirements.md` for all state machine implementations
3. **Follow** `register-requirements.md` for register design and interface standards

### **Compliance Requirements**
- **All new modules** must follow these requirements
- **Existing modules** should be updated to comply during refactoring
- **Testbenches** must validate compliance with all requirements
- **Documentation** must reflect the implemented standards
