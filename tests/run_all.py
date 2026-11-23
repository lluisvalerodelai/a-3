"""Run the Godot checks and every chamber's input-driven solution."""

from pathlib import Path
import os
import subprocess
import sys


def main():
    root = Path(__file__).resolve().parents[1]
    godot = os.environ.get("GODOT_BIN", "godot")
    checks = sorted((root / "tests").glob("*_smoke.gd"))
    checks.append(root / "tests" / "puzzle_solutions.gd")
    failed = []
    for check in checks:
        result = subprocess.run(
            [godot, "--headless", "--fixed-fps", "60", "--path", str(root),
             "--script", str(check)],
            capture_output=True, text=True, timeout=120,
        )
        output = result.stdout + result.stderr
        if result.returncode or "ERROR:" in output or "SCRIPT ERROR:" in output:
            failed.append(check.name)
            print(f"FAIL {check.name}\n{output}", flush=True)
        else:
            print(f"PASS {check.name}", flush=True)
            if check.name == "puzzle_solutions.gd":
                print(output, end="", flush=True)
    print(f"{len(checks) - len(failed)}/{len(checks)} checks passed.")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
