
#!/usr/bin/env python3

import sys, yaml, subprocess, os

def main():
    if len(sys.argv) < 3:
        print("Usage: md_rules_to_yaml.py <out.yaml> <markdown1> [<markdown2> ...]", file=sys.stderr)
        sys.exit(2)
    out = sys.argv[1]
    here = os.path.dirname(os.path.abspath(__file__))
    parser = os.path.join(here, "parse_rules.py")
    data = subprocess.check_output([parser] + sys.argv[2:], text=True)
    obj = yaml.safe_load(data)
    with open(out, "w", encoding="utf-8") as f:
        yaml.safe_dump(obj, f, sort_keys=False)
    print(f"Wrote {out}")
if __name__ == "__main__":
    main()
