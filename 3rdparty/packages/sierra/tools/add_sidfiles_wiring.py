#!/usr/bin/env python3
"""add_sidfiles_wiring.py - retrofit Phase 2 SID build hooks into per-game makefiles.

For each Sierra AGI game makefile, ensure:
  1. A $(SIDFILES) token is appended to every SUPPORTFILES* variable whose
     value contains both 'logDir' and 'words.tok' (i.e. the data-disk
     manifest that hosts the AGI sound resources).  Other SUPPORTFILES_Dn
     continuation variables (object + extra vol files) are left alone.
  2. A SIDFILES wiring block is inserted before 'ALLOBJS = $(CMDS)':
       <GAME>_PCASSETS ?= $(HOME)/<game>-pcassets
       SIDFILES        := $(if $(wildcard $(<GAME>_PCASSETS)/SNDDIR),sidDir sidSnd,)
       sidDir sidSnd: ... agi_sid_extract.py
           python3 ../tools/agi_sid_extract.py $(<GAME>_PCASSETS) ...

The script is idempotent - re-runs detect already-wired files and skip them.
"""
import re
import sys
from pathlib import Path

GAMES = [
    ("blackcauldron",     "BLACKCAULDRON_PCASSETS"),
    ("christmas86",       "CHRISTMAS86_PCASSETS"),
    ("goldrush",          "GOLDRUSH_PCASSETS"),
    ("kingsquest1",       "KQ1_PCASSETS"),
    ("kingsquest2",       "KQ2_PCASSETS"),
    ("kingsquest3",       "KQ3_PCASSETS"),
    ("kingsquest4",       "KQ4_PCASSETS"),
    ("leisuresuitlarry",  "LSL_PCASSETS"),
    ("manhunter1",        "MH1_PCASSETS"),
    ("manhunter2",        "MH2_PCASSETS"),
    ("policequest1",      "PQ1_PCASSETS"),
    ("spacequest1",       "SQ1_PCASSETS"),
    ("spacequest2",       "SQ2_PCASSETS"),
]

SIDFILES_BLOCK_TEMPLATE = """\
# Phase 2: optional SID polyphonic sound sidecar files.
# Generated from the user's PC AGI {pretty} install by the Python
# extractor in ../tools/.  If $({var}) is unset or its
# SNDDIR is missing, $(SIDFILES) is empty and the build proceeds with
# mono-only sound resources (Phase 1 behaviour, fully backwards
# compatible with the original engine).
{var}\t?= $(HOME)/{dirslug}-pcassets
SIDFILES\t:= $(if $(wildcard $({var})/SNDDIR),sidDir sidSnd,)
dsk: $(SIDFILES)

sidDir sidSnd:\t$({var})/SNDDIR ../tools/agi_sid_extract.py \\
\t\t../tools/agi_snd_parser.py
\tpython3 ../tools/agi_sid_extract.py $({var}) \\
\t\t--sid-dir sidDir --sid-snd sidSnd

"""

def split_logical(lines):
    """Yield (start_idx, end_idx, joined_value) for each backslash-continued
    logical line in the file.  Lines without continuation are yielded as
    single-line records."""
    i = 0
    while i < len(lines):
        start = i
        joined = lines[i].rstrip("\n")
        while joined.endswith("\\") and i + 1 < len(lines):
            i += 1
            joined = joined[:-1] + lines[i].rstrip("\n")
        yield start, i, joined
        i += 1

def append_sidfiles_to_words_tok(content):
    """Append ' $(SIDFILES)' to every line that:
       - is the last physical line of a SUPPORTFILES* variable assignment
         whose joined value contains both 'logDir' and 'words.tok', AND
       - does not already mention SIDFILES.
       Preserves backslash continuations on intermediate lines."""
    lines = content.splitlines(keepends=True)
    changed = False
    for start, end, joined in split_logical(lines):
        m = re.match(r"^SUPPORTFILES\w*\s*[:+]?=", joined)
        if not m:
            continue
        if "logDir" not in joined or "words.tok" not in joined:
            continue
        if "$(SIDFILES)" in joined or "SIDFILES" in joined:
            continue
        # Append to the LAST physical line of the assignment, preserving its
        # trailing newline.  The last physical line is lines[end].
        last = lines[end]
        if last.endswith("\n"):
            lines[end] = last[:-1] + " $(SIDFILES)\n"
        else:
            lines[end] = last + " $(SIDFILES)"
        changed = True
    return "".join(lines), changed

def insert_sidfiles_block(content, game, var):
    """Insert the SIDFILES wiring block before the 'ALLOBJS = $(CMDS)' line.
       Idempotent: skips if the block (detected by SIDFILES marker) already
       present."""
    if re.search(r"^SIDFILES\s*[:+]?=", content, flags=re.MULTILINE):
        return content, False
    block = SIDFILES_BLOCK_TEMPLATE.format(
        pretty=game, var=var, dirslug=game,
    )
    new_content, n = re.subn(
        r"^(ALLOBJS\s*=\s*\$\(CMDS\)\s*)$",
        block + r"\1",
        content,
        count=1,
        flags=re.MULTILINE,
    )
    if n == 0:
        # fallback: append before first 'all:' target if ALLOBJS line missing
        new_content, n = re.subn(
            r"^(all:\s)",
            block + r"\1",
            content,
            count=1,
            flags=re.MULTILINE,
        )
    return new_content, n > 0

def process(makefile_path: Path, game: str, var: str) -> str:
    text = makefile_path.read_text()
    text2, append_changed = append_sidfiles_to_words_tok(text)
    text3, block_changed = insert_sidfiles_block(text2, game, var)
    if text3 != text:
        makefile_path.write_text(text3)
        msgs = []
        if append_changed: msgs.append("appended $(SIDFILES) to SUPPORTFILES")
        if block_changed:  msgs.append("inserted SIDFILES wiring block")
        return "; ".join(msgs)
    return "unchanged (already wired)"

def main():
    base = Path(__file__).resolve().parent.parent
    for game, var in GAMES:
        mk = base / game / "makefile"
        if not mk.exists():
            print(f"{game:20s}  MISSING makefile at {mk}")
            continue
        result = process(mk, game, var)
        print(f"{game:20s}  {result}")

if __name__ == "__main__":
    main()
