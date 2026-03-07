#!/usr/bin/env python3
"""Offline round-trip test for the global-schema single-file converter.

Flow:
1) Read source rows from one input file.
2) Run global-schema converter on that file's parent directory.
3) Read output parquet rows.
4) Compare rows with tolerant equality.
"""

from __future__ import annotations

import argparse
import base64
import json
import sys
import tempfile
from pathlib import Path
from typing import Any

import pyarrow.parquet as pq


def add_scripts_dir_to_path():
    here = Path(__file__).resolve().parent
    if str(here) not in sys.path:
        sys.path.insert(0, str(here))


def is_number(v: Any) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def canonicalize(obj: Any) -> Any:
    if obj is None:
        return None
    if isinstance(obj, (bytes, bytearray, memoryview)):
        return base64.b64encode(bytes(obj)).decode("ascii")
    if isinstance(obj, dict):
        return {k: canonicalize(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [canonicalize(v) for v in obj]
    return obj


def tolerant_equal(a: Any, b: Any, eps: float = 1e-9) -> bool:
    a = canonicalize(a)
    b = canonicalize(b)

    if is_number(a) and is_number(b):
        return abs(float(a) - float(b)) <= eps
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            return False
        return all(tolerant_equal(x, y, eps) for x, y in zip(a, b))
    if isinstance(a, dict) and isinstance(b, dict):
        keys = set(a.keys()) | set(b.keys())
        return all(tolerant_equal(a.get(k), b.get(k), eps) for k in keys)
    return a == b


def run_roundtrip(input_file: Path) -> int:
    add_scripts_dir_to_path()
    import dynamodb_json_to_parquet as converter

    if not input_file.exists():
        print("Input file not found:", input_file)
        return 2

    resolved_input_dir = converter.resolve_export_input_dir(
        input_file.parent,
        input_label="roundtrip input",
    )

    # Source rows are from the same directory the converter scans.
    # This ensures normalization/coercion decisions match conversion behavior.
    src_rows = list(converter.iter_items(resolved_input_dir))

    if not src_rows:
        print("No source rows parsed from input file.")
        return 2

    # Mirror converter-side normalization so comparison matches persisted values.
    normalized_src_rows, _ = converter.normalize_rows_for_arrow(src_rows)

    with tempfile.TemporaryDirectory(prefix="dynamodb-global-rt-") as td:
        out_file = Path(td) / "roundtrip.parquet"
        rc = converter.convert_dynamodb_export(
            str(resolved_input_dir),
            str(out_file),
            compression="snappy",
        )
        if rc != 0:
            print("Converter failed.")
            return rc

        table = pq.read_table(str(out_file))
        pq_rows = table.to_pylist()

        # Map by pk/sk when available.
        def key(row: dict[str, Any]) -> str | None:
            pk = row.get("pk")
            sk = row.get("sk")
            if pk is None or sk is None:
                return None
            return f"{pk}||{sk}"

        src_map = {key(r): r for r in normalized_src_rows if key(r) is not None}
        pq_map = {key(r): r for r in pq_rows if key(r) is not None}

        if not src_map or not pq_map:
            print("Round-trip test requires pk/sk keys in rows.")
            return 2

        missing = [k for k in src_map if k not in pq_map]
        if missing:
            print("Missing rows in parquet map (showing first):", missing[0])
            return 2

        for k, src in src_map.items():
            got = pq_map[k]
            if not tolerant_equal(src, got):
                print("Mismatch at key:", k)
                # Show the first differing field for faster debugging.
                all_fields = sorted(set(src.keys()) | set(got.keys()))
                for field in all_fields:
                    if not tolerant_equal(src.get(field), got.get(field)):
                        print("First differing field:", field)
                        print("SRC_FIELD:", json.dumps(canonicalize(src.get(field)), default=str)[:1200])
                        print("PAR_FIELD:", json.dumps(canonicalize(got.get(field)), default=str)[:1200])
                        break
                print("SRC:", json.dumps(canonicalize(src), default=str)[:3000])
                print("PAR:", json.dumps(canonicalize(got), default=str)[:3000])
                return 2

    print("Round-trip OK for global-schema converter.")
    return 0


def parse_args() -> argparse.Namespace:
    add_scripts_dir_to_path()
    import dynamodb_json_to_parquet as converter

    default_input = converter.find_default_roundtrip_input_file()
    default_input_value = (
        str(default_input)
        if default_input is not None
        else "packages/aws_backend/diag-export/AWSDynamoDB/<export-id>/data/<file>.json.gz"
    )

    p = argparse.ArgumentParser(description="Offline round-trip test for global-schema converter")
    p.add_argument(
        "input",
        nargs="?",
        default=default_input_value,
        help="Input .json/.json.gz sample file (defaults to a file under ./last_export_arn when available)",
    )
    return p.parse_args()


if __name__ == "__main__":
    args = parse_args()
    raise SystemExit(run_roundtrip(Path(args.input).resolve()))
