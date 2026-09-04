#!/usr/bin/env python3
"""
Create a new codebase blob by running `gitingest` and save it to
`github/instructions/blobs/`. Also prune outdated blobs by age or count.

Usage examples:
  python tooling/generate-context-blob.py
  python tooling/generate-context-blob.py --keep-last 5 --max-age-days 30
  python tooling/generate-context-blob.py --cmd "gitingest --profile full"

The script runs an external `gitingest` command (or other command provided
via `--cmd`) and writes its stdout to a timestamped blob file. It then
removes old blob files according to `--max-age-days` and `--keep-last`.
"""

# venv not included. you will have to set that up yourself and install gitingest.
# https://https://pypi.org/project/gitingest/

from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path
import shutil
import tempfile
import uuid


def run_cmd(cmd: str, shell: bool = True) -> str:
	p = subprocess.run(cmd, shell=shell, capture_output=True, text=True)
	if p.returncode != 0:
		raise RuntimeError(f"command failed ({p.returncode}): {cmd}\n{p.stderr}")
	return p.stdout


def make_blob_filename(prefix: str, ext: str) -> str:
	ts = datetime.utcnow().strftime("%Y%m%d-%H%M%S")
	short = uuid.uuid4().hex[:8]
	return f"{prefix}{ts}-{short}.blob{ext}"


def prune_blobs(dirpath: Path, keep_last: int | None, max_age_days: int | None, dry_run: bool, verbose: bool):
	files = sorted([p for p in dirpath.iterdir() if p.is_file()], key=lambda p: p.stat().st_mtime, reverse=True)
	now = datetime.now()

	# Age-based pruning
	if max_age_days is not None:
		cutoff = now - timedelta(days=max_age_days)
		for p in list(files):
			mtime = datetime.fromtimestamp(p.stat().st_mtime)
			if mtime < cutoff:
				if verbose:
					print(f"Pruning by age: {p} (mtime {mtime.isoformat()})")
				if not dry_run:
					p.unlink()
		# refresh list
		files = sorted([p for p in dirpath.iterdir() if p.is_file()], key=lambda p: p.stat().st_mtime, reverse=True)

	# Count-based pruning: keep only the newest `keep_last` files
	if keep_last is not None and keep_last >= 0:
		if len(files) > keep_last:
			to_remove = files[keep_last:]
			for p in to_remove:
				if verbose:
					print(f"Pruning by count: {p}")
				if not dry_run:
					p.unlink()


def main(argv: list[str] | None = None) -> int:
	parser = argparse.ArgumentParser(description="Create a codebase blob using gitingest and prune old blobs")
	parser.add_argument("--cmd", default="gitingest", help="Command to run to generate the blob (default: gitingest)")
	parser.add_argument("--cmd-shell", action="store_true", help="Run the command through the shell (default True when passing a string)")
	parser.add_argument("--output-dir", default="github/instructions/blobs", help="Directory to write blobs into")
	parser.add_argument("--ext", default=".md", help="File extension for blob files (default .md)")
	parser.add_argument("--prefix", default="codebase-", help="Filename prefix for blobs")
	parser.add_argument("--keep-last", type=int, default=10, help="Keep only the N most recent blob files (default 10). Use 0 to delete all.")
	parser.add_argument("--max-age-days", type=int, default=30, help="Remove blobs older than this many days (default 30)")
	parser.add_argument("--dry-run", action="store_true", help="Show actions but don't delete or write files")
	parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")

	args = parser.parse_args(argv)

	repo_root = Path(__file__).resolve().parents[1]
	out_dir = (repo_root / args.output_dir).resolve()
	out_dir.mkdir(parents=True, exist_ok=True)

	if args.verbose:
		print(f"Repo root: {repo_root}")
		print(f"Output dir: {out_dir}")
		print(f"Running command: {args.cmd}")

	try:
		content = run_cmd(args.cmd, shell=args.cmd_shell or True)
	except Exception as e:
		print(f"Error running command: {e}", file=sys.stderr)
		return 2

	filename = make_blob_filename(args.prefix, args.ext)
	target = out_dir / filename

	if args.verbose:
		print(f"Writing blob to: {target}")

	if not args.dry_run:
		# write atomically
		fd, tmp = tempfile.mkstemp(prefix="blob-", suffix=args.ext, dir=str(out_dir))
		try:
			with open(fd, "w", encoding="utf-8") as f:
				f.write(content)
			# rename to final filename
			shutil.move(tmp, str(target))
		finally:
			# ensure tmp removed if something went wrong
			tmp_path = Path(tmp)
			if tmp_path.exists() and tmp_path != target:
				try:
					tmp_path.unlink()
				except Exception:
					pass
	else:
		print("Dry run: would write blob with size", len(content))

	# Prune old blobs
	prune_blobs(out_dir, args.keep_last, args.max_age_days, args.dry_run, args.verbose)

	if args.verbose:
		print("Done.")

	return 0


if __name__ == "__main__":
	raise SystemExit(main())

