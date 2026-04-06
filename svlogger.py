#!/usr/bin/env python3
"""
Script to merge multiple SVLogger log files into a single sorted file by simulation time.

Usage:
    python3 svlogger.py [--output OUTPUT_FILE] [--verbose] [FILE|DIR ...]

Examples:
    python3 svlogger.py *.txt
    python3 svlogger.py logs/
    python3 svlogger.py file1.txt file2.txt --output merged.log
    python3 svlogger.py logs/ output/ --output merged.log
"""

import re
import sys
import os
import argparse
from pathlib import Path

# Default regex pattern to extract simulation time from SVLogger lines
# Matches patterns like: "(@ 406.0ns)" or "(@ 10.0ns)"
DEFAULT_TIME_PATTERN = r"\(@\s*([0-9]+\.?[0-9]*)([a-zA-Z]+)\)"

# Global time pattern variable (will be updated after parsing args)
TIME_PATTERN = re.compile(DEFAULT_TIME_PATTERN)

# Supported time units and their conversion factors to nanoseconds
TIME_UNITS = {
    "ns": 1,
    "us": 1000,
    "ms": 1000000,
    "s": 1000000000,
    "ps": 0.001,
    "fs": 0.000001,
}


def parse_time_to_ns(time_str):
    """Convert time string to nanoseconds for comparison."""
    match = TIME_PATTERN.search(time_str)
    if not match:
        return None

    value = float(match.group(1))
    unit = match.group(2).lower()

    # Default to ns if unit is not recognized
    factor = TIME_UNITS.get(unit, 1)
    return value * factor


def extract_log_entries(file_path):
    """Extract log entries from a file with their original line and time."""
    entries = []

    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            for line_num, line in enumerate(f, 1):
                # Remove ANSI color codes for cleaner processing
                clean_line = re.sub(r"\x1b\[[0-9;]+m", "", line)

                # Check if line contains a time stamp
                time_match = TIME_PATTERN.search(clean_line)
                if time_match:
                    time_ns = parse_time_to_ns(clean_line)
                    if time_ns is not None:
                        entries.append(
                            {
                                "time_ns": time_ns,
                                "original_line": line.rstrip("\n"),
                                "file": os.path.basename(file_path),
                                "line_num": line_num,
                            }
                        )
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}", file=sys.stderr)

    return entries


def merge_and_sort_logs(file_paths, verbose=False):
    """Merge and sort log entries from multiple files."""
    all_entries = []

    for file_path in file_paths:
        if verbose:
            print(f"Processing {file_path}...")

        entries = extract_log_entries(file_path)
        if verbose:
            print(f"  Found {len(entries)} log entries")

        all_entries.extend(entries)

    # Sort by simulation time
    all_entries.sort(key=lambda x: x["time_ns"])

    return all_entries


def write_merged_log(entries, output_path):
    """Write merged log entries to output file."""
    with open(output_path, "w", encoding="utf-8") as f:
        for entry in entries:
            # Write original line (with colors preserved)
            f.write(entry["original_line"] + "\n")

    print(f"Merged {len(entries)} log entries to {output_path}")


def find_log_files(directory):
    """Find all log files in a directory."""
    log_files = []

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".txt") or file.endswith(".log"):
                log_files.append(os.path.join(root, file))

    return log_files


def main():
    parser = argparse.ArgumentParser(
        description="Merge multiple SVLogger log files into a single sorted file by simulation time.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 svlogger.py *.txt
  python3 svlogger.py logs/
  python3 svlogger.py file1.txt file2.txt --output merged.log
  python3 svlogger.py logs/ output/ --output merged.log
        """,
    )

    parser.add_argument("inputs", nargs="+", help="Log files or directories to process")
    parser.add_argument(
        "--output",
        "-o",
        default="svlogger.txt",
        help="Output file name (default: svlogger.txt)",
    )
    parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    parser.add_argument(
        "--time-pattern",
        default=DEFAULT_TIME_PATTERN,
        help=f"Custom regex pattern for time extraction (default: '{DEFAULT_TIME_PATTERN}')",
    )

    args = parser.parse_args()

    # Update the global time pattern if custom pattern was provided
    global TIME_PATTERN
    if args.time_pattern != DEFAULT_TIME_PATTERN:
        TIME_PATTERN = re.compile(args.time_pattern)

    # Collect all file paths from inputs (files and directories)
    file_paths = []

    for input_path in args.inputs:
        if os.path.isdir(input_path):
            if args.verbose:
                print(f"Scanning directory: {input_path}")
            dir_files = find_log_files(input_path)
            if not dir_files:
                print(f"Warning: No log files found in '{input_path}'", file=sys.stderr)
            file_paths.extend(dir_files)
        elif os.path.isfile(input_path):
            file_paths.append(input_path)
        else:
            # Try to expand wildcard pattern
            matched = list(Path(".").glob(input_path))
            if matched:
                file_paths.extend(str(f) for f in matched)
            else:
                print(
                    f"Warning: '{input_path}' not found (not a file or directory)",
                    file=sys.stderr,
                )

    if not file_paths:
        print("Error: No valid input files found", file=sys.stderr)
        parser.print_help()
        sys.exit(1)

    if args.verbose:
        print(f"Found {len(file_paths)} files to process")

    # Process files
    entries = merge_and_sort_logs(file_paths, args.verbose)

    if not entries:
        print("Warning: No log entries found in the input files", file=sys.stderr)
        sys.exit(0)

    # Write output
    write_merged_log(entries, args.output)

    if args.verbose:
        print(
            f"Processing complete. Merged {len(entries)} entries from {len(file_paths)} files."
        )


if __name__ == "__main__":
    main()
