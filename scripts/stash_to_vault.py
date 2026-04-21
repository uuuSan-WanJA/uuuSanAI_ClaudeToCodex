"""
ClaudeToCodex → Vault 인사이트 stash 래퍼.
MissionDirector의 stash_insight.py를 ai-systems 도메인으로 호출한다.

사용법:
  python scripts/stash_to_vault.py --title "..." --why "..." [--body "..."] [--file path] [--dry-run]

기본값:
  --domain  ai-systems (고정)
  --visibility  portfolio
"""

import sys
import subprocess
from pathlib import Path

def find_stash_script() -> Path:
    here = Path(__file__).resolve()
    # parents: [0]=scripts, [1]=ClaudeToCodex, [2]=Bundle_Harness, [3]=Projects, [4]=ROOT
    root = here.parents[4]
    script = root / "Projects/Bundle_Branding/uuuSanAI_MissionDirector/scripts/stash_insight.py"
    if not script.exists():
        raise FileNotFoundError(f"stash_insight.py not found at: {script}")
    return script


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Vault stash wrapper for ClaudeToCodex (ai-systems)")
    parser.add_argument("--title", required=True)
    parser.add_argument("--why", required=True)
    parser.add_argument("--body", default=None)
    parser.add_argument("--file", default=None)
    parser.add_argument("--visibility", default="portfolio", choices=["private", "portfolio", "mixed"])
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    stash_script = find_stash_script()

    cmd = [
        sys.executable, str(stash_script),
        "--domain", "ai-systems",
        "--title", args.title,
        "--why", args.why,
        "--visibility", args.visibility,
    ]
    if args.body:
        cmd += ["--body", args.body]
    if args.file:
        cmd += ["--file", args.file]
    if args.dry_run:
        cmd += ["--dry-run"]

    result = subprocess.run(cmd, text=True, encoding="utf-8")
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
