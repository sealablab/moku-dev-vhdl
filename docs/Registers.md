# Register Roles & Semantics

This document defines lightweight, human‑oriented conventions for module I/O registers so code and reviews stay consistent without a rigid generator. Following these roles makes it easy to adopt future MCC features.

## TL;DR Table

| Type | Prefix | Owner | Direction | When Sampled / Applied | Validation | Fault on Invalid | Runtime Change | Typical Use |
|---|---|---|---|---|---|---|---|---|
| **Control** | `ctrl_*` | Top | Top→Module | Live, sampled each `clk` | n/a | n/a | Allowed (live) | start/stop, enable, clear, mode pulses |
| **ConfigurationParameter** | `cfg_p_*` | Top | Top→Module | **Latched on reset deassertion** | **Required** | **Yes** (enter FAULT) | Ignored until next reset | limits, IDs, operating envelope |
| **ConfigurationRegister** | `cfg_*` | Top | Top→Module | **Continuous** (or frame‑bounded) | Optional (clamp preferred) | No (unless documented) | Allowed; document timing | UI knobs: intensity, window, averaging |
| **Status** | `stat_*` | Module | Module→Top | Updated synchronously | n/a | n/a | n/a | telemetry, alarms, faults, counters |

> Defaults: Keep reset defaults **safe** and documented. Use read‑as‑zero/write‑ignore for reserved fields.

---

## Fault vs Alarm
- **Fault** (`stat_fault`, optional `stat_fault_code[7:0]`):
  - **Serious** condition; module enters safe/degraded state.
  - **Sticky until reset** (project policy).  

- **Alarm** (`stat_alarm`, optional `stat_alarm_code[7:0]`):
  - **Non‑fatal**, **level** indication of a noteworthy condition (e.g., clipping).
  - **Auto‑clears** when the condition disappears.

Recommended codes (extend per module):
- `0x01` INVALID_CFG_P
- `0x02` OVERFLOW
- `0x03` CLIPPED
- `0x10+` module‑specific

---

## Naming, Direction, prefixes

- **Prefixes:** `ctrl_*`, `cfg_p_*`, `cfg_*`, `stat_*`.
- **Direction (entity ports):**
  - `ctrl_*`, `cfg_p_*`, `cfg_*` are **`in`** (Top→Module).
  - `stat_*` are **`out`** (Module→Top).
- **Assignments (architecture):**
  - **Module must not assign** to `ctrl_*`, `cfg_p_*`, or `cfg_*`.
  - **Top must not drive** `stat_*`.
- **Polarity:** active‑high unless documented; reset is `rst_n` (active‑low) by convention.

---

## Reset, Sampling, and Timing

- On **reset deassertion**, the module **latches and validates** all `cfg_p_*`.
  - Invalid parameters ⇒ set `stat_fault=1`, set `stat_fault_code`, enter safe state.
- `cfg_*` are read continuously (or applied at well‑defined boundaries such as “frame end”). State how changes take effect:
  - **Immediate**: next clock
  - **Frame‑bounded**: on `frame_tick` or equivalent

---

## Minimal VHDL Pattern

```vhdl
-- Module: <Name>
-- Roles:
--   ctrl_*  (Top→Module, live)
--   cfg_p_* (Top→Module, latched @ reset, MUST validate; fault on invalid)
--   cfg_*   (Top→Module, continuous or frame-bounded; clamp preferred)
--   stat_*  (Module→Top)
-- Reset:
--   cfg_p_* latched/validated on reset deassertion; faults sticky until reset
-- Alarm/Fault:
--   Alarm: level, auto-clears
--   Fault: sticky until reset (optional ctrl_fault_clear if implemented)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Example_Core is
  port (
    clk, rst_n        : in  std_logic;

    -- Control
    ctrl_enable       : in  std_logic;
    -- Optional: ctrl_fault_clear : in std_logic;

    -- ConfigurationParameters (latched + MUST validate)
    cfg_p_gain        : in  unsigned(7 downto 0);  -- [1..200], default 0x10
    cfg_p_mode        : in  unsigned(1 downto 0);  -- enum 0..2

    -- ConfigurationRegisters (live)
    cfg_intensity     : in  unsigned(15 downto 0); -- clamp 0..1023
    cfg_window        : in  unsigned(7 downto 0);  -- apply @ frame boundary

    -- Status
    stat_busy         : out std_logic;
    stat_alarm        : out std_logic;
    stat_alarm_code   : out unsigned(7 downto 0);
    stat_fault        : out std_logic;
    stat_fault_code   : out unsigned(7 downto 0)
  );
end entity;
