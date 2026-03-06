#!/usr/bin/env python3
"""Combine many Parquet files into one Parquet file.

This script recursively scans AWSDynamoDB-parquet (or a provided folder), reads
all .parquet files, and writes one combined parquet file under diag-export root
by default.

Default behavior:
- Input root:  ./diag-export/AWSDynamoDB-parquet
- Output file: ./diag-export/AWSDynamoDB-parquet-combined.parquet
"""

from __future__ import annotations

import argparse
from pathlib import Path


def _align_table_to_schema(table, schema, pa):
    """Return a new table with columns ordered and typed to match `schema`.

    - Existing columns are cast to the target type when possible.
    - Missing columns are filled with nulls of the target type.
    """
    cols = []
    names = []
    for field in schema:
        name = field.name
        names.append(name)
        if name in table.column_names:
            col = table.column(name)
            try:
                if col.type != field.type:
                    col = col.cast(field.type)
            except Exception:
                # If cast fails, keep original column and hope Parquet writer accepts it.
                pass
            cols.append(col)
        else:
            # create a null column with the desired type
            null_col = pa.array([None] * table.num_rows, type=field.type)
            cols.append(null_col)

    table_out = pa.Table.from_arrays(cols, names=names)
    try:
        if table_out.schema != schema:
            table_out = table_out.cast(schema)
    except Exception:
        # If cast fails for any reason, return the best-effort table we constructed.
        pass
    return table_out


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Recursively combine Parquet files under AWSDynamoDB-parquet into "
            "one output parquet file."
        )
    )
    parser.add_argument(
        "--input",
        "-i",
        default="./diag-export/AWSDynamoDB-parquet",
        help=(
            "Input parquet folder root "
            "(default: ./diag-export/AWSDynamoDB-parquet)"
        ),
    )
    parser.add_argument(
        "--output",
        "-o",
        default="./diag-export/AWSDynamoDB-parquet-combined.parquet",
        help=(
            "Single output parquet file path "
            "(default: ./diag-export/AWSDynamoDB-parquet-combined.parquet)"
        ),
    )
    parser.add_argument(
        "--compression",
        default="snappy",
        choices=["snappy", "gzip", "brotli", "zstd", "lz4", "none"],
        help="Parquet compression codec for output (default: snappy)",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite output file if it already exists.",
    )
    return parser.parse_args()


def find_parquet_files(root: Path) -> list[Path]:
    files = [p for p in root.rglob("*.parquet") if p.is_file()]
    return sorted(files)


def main() -> int:
    args = parse_args()

    input_root = Path(args.input).resolve()
    output_file = Path(args.output).resolve()

    if not input_root.exists() or not input_root.is_dir():
        print(f"ERROR: input folder does not exist or is not a directory: {input_root}")
        return 2

    if output_file.exists() and not args.overwrite:
        print(f"ERROR: output file already exists: {output_file}")
        print("Use --overwrite to replace it.")
        return 2

    files = find_parquet_files(input_root)
    if not files:
        print(f"No .parquet files found under: {input_root}")
        return 0

    # Import lazily so --help works even when pyarrow is not installed.
    try:
        import pyarrow as pa
        import pyarrow.parquet as pq
    except ImportError as exc:
        raise SystemExit(
            "Missing dependency: pyarrow. Install it with `pip install pyarrow`."
        ) from exc

    schemas = [pq.read_schema(path) for path in files]
    unified_schema = pa.unify_schemas(schemas)

    output_file.parent.mkdir(parents=True, exist_ok=True)

    codec = None if args.compression == "none" else args.compression
    writer = pq.ParquetWriter(output_file, schema=unified_schema, compression=codec)

    try:
        total_rows = 0
        for path in files:
            table = pq.read_table(path)
            # Align each file's table with the unified schema before appending.
            table = _align_table_to_schema(table, unified_schema, pa)
            writer.write_table(table)
            total_rows += table.num_rows
            print(f"added {path} ({table.num_rows} rows)")
    finally:
        writer.close()

    print(
        "\nDone. "
        f"Files={len(files)} "
        f"Rows={total_rows} "
        f"InputRoot={input_root} "
        f"OutputFile={output_file}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
