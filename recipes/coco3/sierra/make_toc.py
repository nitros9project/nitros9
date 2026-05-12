#!/usr/bin/env python3

import sys
from pathlib import Path


def parse_entry(token: str) -> int:
    token = token.strip().lower()
    if len(token) < 2 or token[0] not in {"d", "s", "v"}:
        raise ValueError(f"unsupported TOC token: {token}")
    return int(token[1:])


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: make_toc.py <toc_txt> <toc_bin>", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])

    rows = []
    for line in src.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("*"):
            continue
        rows.append([parse_entry(token) for token in line.split()])

    if not rows:
        dst.write_bytes(b"")
        return 0

    header_size = len(rows) * 2
    payload = bytearray([len(rows)])

    offset = header_size
    for row in rows:
        payload.extend(offset.to_bytes(2, "big"))
        offset += len(row)

    for row in rows:
        payload.extend(row[:-1])
        payload.append(row[-1] | 0x80)

    dst.write_bytes(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
