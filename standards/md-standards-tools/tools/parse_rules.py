
#!/usr/bin/env python3

import sys, re, json
from typing import Any, Dict, List

RULE_RE = re.compile(r"<!--\s*RULE:([^=]+)=(.*?)\s*-->", re.IGNORECASE)

def auto_cast(val: str) -> Any:
    s = val.strip()
    # list (comma-separated) — but ignore commas inside quotes
    if "," in s and not (s.startswith('"') and s.endswith('"')):
        return [auto_cast(part) for part in s.split(",")]
    # booleans
    low = s.lower()
    if low in ("true", "false"):
        return low == "true"
    # ints
    try:
        if s.startswith("0x"):
            return int(s, 16)
        return int(s)
    except ValueError:
        pass
    # floats
    try:
        return float(s)
    except ValueError:
        pass
    # unquote a single pair of quotes
    if (s.startswith('"') and s.endswith('"')) or (s.startswith("'") and s.endswith("'")):
        return s[1:-1]
    return s

def set_nested(d: Dict[str, Any], path: str, value: Any) -> None:
    parts = path.strip().split(".")
    cur = d
    for p in parts[:-1]:
        cur = cur.setdefault(p, {})
    cur[parts[-1]] = value

def parse_file(path: str) -> Dict[str, Any]:
    out: Dict[str, Any] = {}
    with open(path, "r", encoding="utf-8") as f:
        txt = f.read()
    for m in RULE_RE.finditer(txt):
        key, raw = m.group(1).strip(), m.group(2).strip()
        set_nested(out, key, auto_cast(raw))
    return out

def deep_merge(a: Dict[str, Any], b: Dict[str, Any]) -> Dict[str, Any]:
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(a.get(k), dict):
            deep_merge(a[k], v)
        else:
            a[k] = v
    return a

def main():
    if len(sys.argv) < 2:
        print("Usage: parse_rules.py <markdown1> [<markdown2> ...]", file=sys.stderr)
        sys.exit(2)
    merged: Dict[str, Any] = {}
    for p in sys.argv[1:]:
        merged = deep_merge(merged, parse_file(p))
    print(json.dumps(merged, indent=2))
if __name__ == "__main__":
    main()
