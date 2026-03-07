#!/usr/bin/env python3
"""Global-schema converter for DynamoDB JSON exports -> single Parquet file.

This script scans all input DynamoDB JSON export files, collects the union of
all observed keys, normalizes rows to include every key (missing -> None), and
writes one Parquet file with a stable global schema.
"""

from __future__ import annotations

import argparse
import base64
import gzip
import json
from pathlib import Path
from typing import Any, Iterator

import pyarrow as pa
import pyarrow.parquet as pq


SCRIPT_DIR = Path(__file__).resolve().parent
AWS_BACKEND_DIR = SCRIPT_DIR.parent
LAST_EXPORT_ARN_PATH = AWS_BACKEND_DIR / "last_export_arn"


def read_last_export_arn() -> str | None:
    try:
        return LAST_EXPORT_ARN_PATH.read_text(encoding="utf-8").strip() or None
    except OSError:
        return None


def get_export_id_from_arn(export_arn: str | None) -> str | None:
    if not export_arn:
        return None
    parts = export_arn.strip().split("/")
    return parts[-1] if parts else None


def _contains_json_export_files(path: Path) -> bool:
    if not path.is_dir():
        return False
    for child in path.iterdir():
        if child.is_file() and child.name.lower().endswith((".json", ".json.gz")):
            return True
    return False


def _find_export_folder_in_path(path: Path) -> str | None:
    for part in path.parts:
        if "-" not in part:
            continue
        left, _, right = part.partition("-")
        if left.isdigit() and right:
            return part
    return None


def resolve_export_input_dir(input_path: str | Path, input_label: str = "--input") -> Path:
    candidate = Path(input_path).resolve()
    last_export_arn = read_last_export_arn()
    last_export_id = get_export_id_from_arn(last_export_arn)
    path_export_id = _find_export_folder_in_path(candidate)

    if _contains_json_export_files(candidate):
        if last_export_arn:
            print(f"Bypassing ./last_export_arn ({last_export_arn}) because {input_label} already points to a data directory: {candidate}")
            if path_export_id == last_export_id:
                print(f"{input_label} matches the last export sub_folder: {last_export_id}")
            elif path_export_id and last_export_id:
                print(
                    f"Mismatch: {input_label} points to export sub_folder {path_export_id}, "
                    f"but ./last_export_arn points to {last_export_id}"
                )
        return candidate

    if path_export_id and last_export_id:
        if path_export_id == last_export_id:
            print(f"{input_label} matches the last export sub_folder: {last_export_id}")
        else:
            print(
                f"Mismatch: {input_label} includes export sub_folder {path_export_id}, "
                f"but ./last_export_arn points to {last_export_id}"
            )

    if last_export_id:
        candidate_data_dirs = [
            candidate / "AWSDynamoDB" / last_export_id / "data",
            candidate / last_export_id / "data",
        ]
        for data_dir in candidate_data_dirs:
            if _contains_json_export_files(data_dir):
                print(f"Resolved {input_label} via ./last_export_arn ({last_export_arn}) to {data_dir}")
                return data_dir

        print(
            f"Mismatch: no subtree like AWSDynamoDB/{last_export_id}/data/*.json.gz exists under {candidate}; "
            f"./last_export_arn={last_export_arn}"
        )

    return candidate


def find_default_roundtrip_input_file() -> Path | None:
    last_export_arn = read_last_export_arn()
    last_export_id = get_export_id_from_arn(last_export_arn)
    if not last_export_id:
        return None

    data_dir = AWS_BACKEND_DIR / "diag-export" / "AWSDynamoDB" / last_export_id / "data"
    if not data_dir.is_dir():
        return None

    for path in sorted(data_dir.glob("*.json.gz")):
        return path
    for path in sorted(data_dir.glob("*.json")):
        return path
    return None


def _value_kind(value: Any) -> str:
    if value is None:
        return "none"
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int):
        return "int"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        return "str"
    if isinstance(value, (bytes, bytearray, memoryview)):
        return "bytes"
    if isinstance(value, list):
        return "list"
    if isinstance(value, dict):
        return "dict"
    return type(value).__name__


def _json_safe(value: Any) -> Any:
    if isinstance(value, (bytes, bytearray, memoryview)):
        return base64.b64encode(bytes(value)).decode("ascii")
    if isinstance(value, list):
        return [_json_safe(v) for v in value]
    if isinstance(value, dict):
        return {k: _json_safe(v) for k, v in value.items()}
    return value


def _stringify_dynamic(value: Any) -> str | None:
    if value is None:
        return None
    if isinstance(value, str):
        return value
    safe = _json_safe(value)
    return json.dumps(safe, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def normalize_rows_for_arrow(rows: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], list[str]]:
    """Normalize rows for Arrow by stringifying mixed-type columns.

    Returns:
    - normalized rows
    - sorted list of columns that were stringified due to mixed kinds
    """
    if not rows:
        return [], []

    all_keys: set[str] = set()
    for row in rows:
        all_keys.update(row.keys())

    key_kinds: dict[str, set[str]] = {k: set() for k in all_keys}
    for row in rows:
        for k in all_keys:
            key_kinds[k].add(_value_kind(row.get(k)))

    stringify_keys: set[str] = set()
    for k, kinds in key_kinds.items():
        kinds_no_none = {x for x in kinds if x != "none"}
        if len(kinds_no_none) <= 1:
            continue
        numeric_only = kinds_no_none.issubset({"int", "float"})
        if not numeric_only:
            stringify_keys.add(k)

    ordered_keys = sorted(all_keys)
    normalized: list[dict[str, Any]] = []
    for row in rows:
        out: dict[str, Any] = {}
        for key in ordered_keys:
            val = row.get(key)
            if key in stringify_keys:
                out[key] = _stringify_dynamic(val)
            else:
                out[key] = val
        normalized.append(out)

    return normalized, sorted(stringify_keys)


def convert_attr(attr: Any) -> Any:
    """Convert a DynamoDB attribute-value dict to a native Python value."""
    if not isinstance(attr, dict) or len(attr) != 1:
        return attr

    dtype, value = next(iter(attr.items()))

    if dtype == "S":
        return value
    if dtype == "N":
        try:
            return int(value)
        except ValueError:
            try:
                return float(value)
            except ValueError:
                return value
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
        out = []
        for item in value:
            try:
                out.append(int(item))
            except ValueError:
                try:
                    out.append(float(item))
                except ValueError:
                    out.append(item)
        return out
    if dtype == "BS":
        decoded = []
        for item in value:
            try:
                decoded.append(base64.b64decode(item))
            except Exception:
                decoded.append(item)
        return decoded
    if dtype == "L":
        return [convert_attr(item) for item in value]
    if dtype == "M":
        return {k: convert_attr(v) for k, v in value.items()}

    return value


def convert_item(obj: dict[str, Any]) -> dict[str, Any] | None:
    """Convert a DynamoDB export line object into a plain row dict."""
    item = obj.get("Item")
    if not isinstance(item, dict):
        return None
    return {k: convert_attr(v) for k, v in item.items()}


def open_json_lines(path: Path) -> Iterator[dict[str, Any]]:
    """Yield parsed JSON objects from .json or .json.gz files."""
    if path.name.lower().endswith(".gz"):
        handle = gzip.open(path, "rt", encoding="utf-8")
    else:
        handle = path.open("r", encoding="utf-8")

    with handle:
        for line in handle:
            raw = line.strip()
            if not raw:
                continue
            try:
                yield json.loads(raw)
            except json.JSONDecodeError:
                continue


def iter_items(root: Path) -> Iterator[dict[str, Any]]:
    """Iterate converted item rows under a root directory."""
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        lower = path.name.lower()
        if not (lower.endswith(".json") or lower.endswith(".json.gz")):
            continue
        for obj in open_json_lines(path):
            row = convert_item(obj)
            if row is not None:
                yield row


def convert_dynamodb_export(input_dir: str, output_parquet: str, compression: str) -> int:
    input_root = resolve_export_input_dir(input_dir)
    output_file = Path(output_parquet).resolve()

    rows: list[dict[str, Any]] = []

    for row in iter_items(input_root):
        rows.append(row)

    if not rows:
        print(f"No rows found under: {input_root}")
        return 2

    normalized, stringified_keys = normalize_rows_for_arrow(rows)

    output_file.parent.mkdir(parents=True, exist_ok=True)
    table = pa.Table.from_pylist(normalized)
    codec = None if compression == "none" else compression
    pq.write_table(table, output_file, compression=codec)

    print(f"Wrote {len(rows)} rows -> {output_file}")
    print(f"Columns: {len(table.column_names)}")
    if stringified_keys:
        print(f"Stringified mixed-type columns: {len(stringified_keys)}")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="Path to AWSDynamoDB directory containing export subfolders")
    parser.add_argument("--output", required=True, help="Output folder for Parquet file (will be named {exportId}.parquet)")
    parser.add_argument("--exportId", help="Export subfolder to use (default: last_export_arn)")
    parser.add_argument("--overwrite", action="store_true", help="Remove existing output file before writing")
    parser.add_argument(
        "--compression",
        default="zstd",
        choices=["snappy", "gzip", "brotli", "zstd", "lz4", "none"],
        help="Parquet compression codec (default: zstd)",
    )
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    input_root = Path(args.input).resolve()
    if input_root.name != "AWSDynamoDB":
        print(f"ERROR: --input must be the AWSDynamoDB directory, got: {input_root}")
        raise SystemExit(2)

    export_id = args.exportId or get_export_id_from_arn(read_last_export_arn())
    if not export_id:
        print("ERROR: No exportId provided and ./last_export_arn is missing or invalid.")
        raise SystemExit(2)

    export_dir = input_root / export_id / "data"
    if not export_dir.is_dir():
        print(f"ERROR: Export directory not found: {export_dir}")
        raise SystemExit(2)

    output_folder = Path(args.output).resolve()
    output_folder.mkdir(parents=True, exist_ok=True)
    output_file = output_folder / f"{export_id}.parquet"
    if args.overwrite and output_file.exists():
        try:
            output_file.unlink()
        except Exception as exc:
            print(f"Warning: failed to remove existing output file: {output_file}: {exc}")

    rc = convert_dynamodb_export(str(export_dir), str(output_file), args.compression)
    raise SystemExit(rc)
