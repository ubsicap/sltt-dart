#!/usr/bin/env python3
"""Convert DynamoDB JSON export files to Parquet.

This script recursively scans an input AWSDynamoDB folder, reads DynamoDB JSON
line files (supports .json and .json.gz), converts each item to plain JSON-like
objects, and writes a mirrored .parquet file tree under an output folder.

Default behavior:
- Input root:  ./diag-export (auto-detects ./diag-export/AWSDynamoDB if present)
- Output root: ./diag-export/AWSDynamoDB-parquet

Example:
    python scripts/dynamodb_json_to_parquet.py \
        --input ./diag-export \
    --output ./diag-export/AWSDynamoDB-parquet
"""

from __future__ import annotations

import argparse
import base64
import gzip
import json
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import Any, Iterable, Iterator

try:
    import pyarrow as pa
    import pyarrow.parquet as pq
except ImportError as exc:
    raise SystemExit(
        "Missing dependency: pyarrow. Install it with `pip install pyarrow`."
    ) from exc


SUPPORTED_SUFFIXES = (".json", ".json.gz")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Recursively convert DynamoDB JSON export files to Parquet and mirror "
            "folder structure under AWSDynamoDB-parquet."
        )
    )
    parser.add_argument(
        "--input",
        "-i",
        default="./diag-export",
        help=(
            "Input folder. Can be either ./diag-export or ./diag-export/AWSDynamoDB "
            "(default: ./diag-export)"
        ),
    )
    parser.add_argument(
        "--output",
        "-o",
        default=None,
        help=(
            "Output root folder for mirrored parquet files "
            "(default: ./diag-export/AWSDynamoDB-parquet)"
        ),
    )
    parser.add_argument(
        "--compression",
        default="snappy",
        choices=["snappy", "gzip", "brotli", "zstd", "lz4", "none"],
        help="Parquet compression codec (default: snappy)",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing parquet files.",
    )
    return parser.parse_args()


def is_supported_input_file(path: Path) -> bool:
    lower = path.name.lower()
    return lower.endswith(SUPPORTED_SUFFIXES)


def open_text_file(path: Path):
    if path.name.lower().endswith(".gz"):
        return gzip.open(path, "rt", encoding="utf-8")
    return path.open("r", encoding="utf-8")


def to_best_number(raw: str) -> Any:
    if any(ch in raw for ch in (".", "e", "E")):
        try:
            return float(raw)
        except ValueError:
            return raw
    try:
        return int(raw)
    except ValueError:
        try:
            dec = Decimal(raw)
            if dec == dec.to_integral_value():
                return int(dec)
            return float(dec)
        except (InvalidOperation, ValueError):
            return raw


def from_dynamodb_attribute(attr: Any) -> Any:
    if not isinstance(attr, dict) or len(attr) != 1:
        return attr

    dtype, value = next(iter(attr.items()))

    if dtype == "S":
        return value
    if dtype == "N":
        return to_best_number(str(value))
    if dtype == "BOOL":
        return bool(value)
    if dtype == "NULL":
        return None
    if dtype == "B":
        try:
            return base64.b64decode(value)
        except Exception:
            return value
    if dtype == "SS":
        return list(value)
    if dtype == "NS":
        return [to_best_number(str(v)) for v in value]
    if dtype == "BS":
        decoded = []
        for entry in value:
            try:
                decoded.append(base64.b64decode(entry))
            except Exception:
                decoded.append(entry)
        return decoded
    if dtype == "L":
        return [from_dynamodb_attribute(v) for v in value]
    if dtype == "M":
        return {k: from_dynamodb_attribute(v) for k, v in value.items()}

    return value


def from_export_line_obj(obj: dict[str, Any]) -> dict[str, Any] | None:
    item = obj.get("Item")
    if not isinstance(item, dict):
        return None
    return {k: from_dynamodb_attribute(v) for k, v in item.items()}


def iter_item_rows(path: Path) -> Iterator[dict[str, Any]]:
    with open_text_file(path) as handle:
        for line_no, line in enumerate(handle, start=1):
            raw = line.strip()
            if not raw:
                continue
            try:
                obj = json.loads(raw)
            except json.JSONDecodeError:
                # This file is likely not line-delimited item data.
                if line_no == 1:
                    return
                continue

            row = from_export_line_obj(obj)
            if row is not None:
                yield row


def output_path_for(input_file: Path, input_root: Path, output_root: Path) -> Path:
    rel = input_file.relative_to(input_root)
    name = rel.name

    if name.lower().endswith(".json.gz"):
        parquet_name = name[: -len(".json.gz")] + ".parquet"
    elif name.lower().endswith(".json"):
        parquet_name = name[: -len(".json")] + ".parquet"
    else:
        parquet_name = name + ".parquet"

    return output_root.joinpath(rel.parent, parquet_name)


def convert_file(
    input_file: Path,
    input_root: Path,
    output_root: Path,
    compression: str,
    overwrite: bool,
) -> tuple[bool, str]:
    output_file = output_path_for(input_file, input_root, output_root)
    if output_file.exists() and not overwrite:
        return False, f"skip exists: {output_file}"

    rows = list(iter_item_rows(input_file))
    if not rows:
        return False, f"skip no item rows: {input_file}"

    output_file.parent.mkdir(parents=True, exist_ok=True)
    table = pa.Table.from_pylist(rows)

    codec = None if compression == "none" else compression
    pq.write_table(table, output_file, compression=codec)

    return True, f"ok {input_file} -> {output_file} ({len(rows)} rows)"


def find_input_files(root: Path) -> Iterable[Path]:
    for path in root.rglob("*"):
        if path.is_file() and is_supported_input_file(path):
            yield path


def resolve_input_root(raw_input: Path) -> Path:
    # Allow passing either ./diag-export or ./diag-export/AWSDynamoDB.
    aws_subdir = raw_input / "AWSDynamoDB"
    if aws_subdir.exists() and aws_subdir.is_dir():
        return aws_subdir
    return raw_input


def resolve_output_root(raw_input: Path, input_root: Path, raw_output: str | None) -> Path:
    if raw_output:
        return Path(raw_output).resolve()

    # If input was ./diag-export/AWSDynamoDB, output should be ./diag-export/AWSDynamoDB-parquet.
    # If input was ./diag-export, and AWSDynamoDB auto-detected, output should still be under ./diag-export.
    if input_root.name == "AWSDynamoDB":
        parent = input_root.parent
    else:
        parent = raw_input
    return (parent / "AWSDynamoDB-parquet").resolve()


def main() -> int:
    args = parse_args()

    raw_input = Path(args.input).resolve()
    input_root = resolve_input_root(raw_input)
    output_root = resolve_output_root(raw_input, input_root, args.output)

    if not input_root.exists() or not input_root.is_dir():
        print(f"ERROR: input folder does not exist or is not a directory: {input_root}")
        return 2

    converted = 0
    skipped = 0

    files = sorted(find_input_files(input_root))
    if not files:
        print(f"No .json/.json.gz files found under: {input_root}")
        return 0

    for file_path in files:
        did_convert, message = convert_file(
            file_path,
            input_root=input_root,
            output_root=output_root,
            compression=args.compression,
            overwrite=args.overwrite,
        )
        print(message)
        if did_convert:
            converted += 1
        else:
            skipped += 1

    print(
        "\nDone. "
        f"Converted={converted} "
        f"Skipped={skipped} "
        f"InputRoot={input_root} "
        f"OutputRoot={output_root}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
