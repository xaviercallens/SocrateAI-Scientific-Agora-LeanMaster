#!/usr/bin/env python3
"""
test_compile_cards.py
Quickly test compiling every spec and proof individually using lean.
"""
import subprocess
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent.parent
SPECS_DIR = ENGINE_DIR / "specs" / "Specs"
PROOFS_DIR = ENGINE_DIR / "proofs" / "Proofs"

# Get LEAN_PATH from lake env
res = subprocess.run(["lake", "env", "printenv", "LEAN_PATH"], cwd=ENGINE_DIR, capture_output=True, text=True)
lean_path = res.stdout.strip()
print(f"LEAN_PATH: {lean_path}")

env = {"LEAN_PATH": lean_path, "PATH": "/home/xavkal/.elan/bin:/usr/bin:/bin"}

def test_file(filepath: Path):
    cmd = ["lean", str(filepath)]
    out = subprocess.run(cmd, cwd=ENGINE_DIR, capture_output=True, text=True, env=env)
    return out.returncode, out.stdout, out.stderr

print("\n--- Testing Specs ---")
spec_errors = 0
for i in range(1, 37):
    f = SPECS_DIR / f"Card{i:02d}.lean"
    rc, stdout, stderr = test_file(f)
    if rc != 0:
        spec_errors += 1
        print(f"FAIL: {f.name}\n{stderr}")
    else:
        print(f"PASS: {f.name}")

print(f"\nSpec errors: {spec_errors}")
