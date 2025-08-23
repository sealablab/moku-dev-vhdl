
#!/usr/bin/env python3

import sys, json, re
from typing import Any, Dict, List

# Reuse parser by importing or embedding; here we shell out to keep single-file.
# For simplicity, we import the sibling parse_rules.py when both files are present.
import os, subprocess

def to_upper_snake(s: str) -> str:
    return re.sub(r'[^A-Za-z0-9]+', '_', s).strip('_').upper()

def flatten(prefix: str, obj: Any, out: Dict[str, str]):
    if isinstance(obj, dict):
        for k, v in obj.items():
            flatten(f"{prefix}.{k}" if prefix else k, v, out)
    elif isinstance(obj, list):
        out[prefix] = " ".join(str(x) for x in obj)
    elif isinstance(obj, bool):
        out[prefix] = "1" if obj else "0"
    else:
        out[prefix] = str(obj)

def main():
    if len(sys.argv) < 2:
        print("Usage: emit_make_vars.py <markdown1> [<markdown2> ...]", file=sys.stderr)
        sys.exit(2)
    here = os.path.dirname(os.path.abspath(__file__))
    parser = os.path.join(here, "parse_rules.py")
    cmd = ["python3", parser] + sys.argv[1:]
    try:
        parsed = subprocess.check_output(cmd, text=True)
    except subprocess.CalledProcessError as e:
        print(e.output, file=sys.stderr)
        sys.exit(e.returncode)
    data = json.loads(parsed)
    flat: Dict[str, str] = {}
    flatten("", data, flat)

    # Emit as Make variables
    for k, v in sorted(flat.items()):
        mk = to_upper_snake(k)
        # Quote spaces safely
        if " " in v or v == "":
            print(f'{mk} := {v}')
        else:
            print(f'{mk} := {v}')
if __name__ == "__main__":
    main()
