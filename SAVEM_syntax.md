## SAVEM — Save Basic09 Procedure(s) to Raw I-Code Files

### Description

`SAVEM` saves one or more compiled Basic09 procedures from the workspace to disk as raw I-code binary files (`.up` files). It is the counterpart to `LOADM`.

The `.up` extension stands for "unpacked" — the file contains the raw module bytes exactly as they exist in the I-code workspace, without Basic09's packed/compressed encoding. The extension is appended automatically if omitted (case-insensitive check).

---

### Output specifiers: `.` and `>`

Both `.` (dot) and `>` (redirect) are output specifiers — they are interchangeable and control where and under what name the output file is written. Either can appear after an optional proc name or proc list.

An output specifier is followed by a **path argument** that can be:

| Path argument form | Meaning |
|---|---|
| `outname[.up]` | Write to `outname.up` in the current data directory |
| `path/` | Write to the directory `path/`; use the procedure's own name as the filename |
| `/device` | Same as above — bare absolute path with no filename component is treated as a directory |
| `./subdir` | Write to relative subdirectory `subdir`; use the procedure's own name |
| `path/outname[.up]` | Write to `outname.up` inside `path/` |
| `/path/outname[.up]` | Write to `outname.up` at the absolute path |
| `./path/outname[.up]` | Write to `outname.up` at the relative path |

When the path argument refers to a directory (trailing `/`, bare device path, or `./subdir` with no further `/`), the procedure's own name is used as the filename.

---

### Forms

#### 1. No specifier — separate `.up` files, current data directory

```
SAVEM
SAVEM procname
SAVEM procname, procname, ...
SAVEM*
```

| Form | Output |
|---|---|
| `SAVEM` | Current procedure → `procname.up` in CWD |
| `SAVEM procname` | Named procedure → `procname.up` in CWD |
| `SAVEM proc1, proc2, ...` | Each named procedure → its own `procname.up` in CWD |
| `SAVEM*` | Every procedure in workspace → its own `procname.up` in CWD |

#### 2. With output specifier — control path and/or output filename

```
SAVEM [.  | > ] <path-arg>
SAVEM procname [. | >] <path-arg>
SAVEM procname, procname, ... [. | >] <path-arg>
SAVEM* <path-arg>
```

The output specifier (`.` or `>`) applies to:
- **Current procedure** (no proc name given)
- **Single named procedure** (`SAVEM procname . path`)
- **Multiple named procedures** (`SAVEM proc1, proc2, ... > path/`) — if the path arg is a directory, each proc gets its own file; if it names a file, all procs are concatenated into one merged output file
- **All procedures** (`SAVEM* path`) — same rules as multi-proc

Examples across all forms:

| Command | Output |
|---|---|
| `SAVEM . outname` | Current proc → `outname.up` in CWD |
| `SAVEM > outname` | Same |
| `SAVEM . /d1/backup/myprog` | Current proc → `/d1/backup/myprog.up` |
| `SAVEM . /d2/` | Current proc → `/d2/procname.up` (directory target) |
| `SAVEM . /d2` | Same — bare device path treated as directory |
| `SAVEM . ./d2` | Current proc → `d2/procname.up` (relative subdir) |
| `SAVEM myprog . /d1/backup/myprog` | `myprog` → `/d1/backup/myprog.up` |
| `SAVEM myprog > /d2/` | `myprog` → `/d2/myprog.up` |
| `SAVEM prog1, prog2 . /d1/bundle` | Both procs → `/d1/bundle.up` (merged) |
| `SAVEM prog1, prog2 > /d1/` | Each proc → its own `.up` in `/d1/` |
| `SAVEM* /d1/bundle` | All procs → `/d1/bundle.up` (merged) |
| `SAVEM* /d1/` | All procs → their own `.up` files in `/d1/` |
| `SAVEM* /d2` | Same — bare device path treated as directory |

---

### Notes

- `.` and `>` as output specifiers are fully equivalent — use whichever is more natural.
- When saving multiple procedures to a directory target, each procedure is written as a separate file. When saving to a named file, all procedures are concatenated into one merged module file (readable by `LOADM`).
- Files without a path are written to the **current data directory**; use `CHD` to control the destination.
- Output files are created with attributes: owner read+write, public read, no execute.
- If a named procedure is not found in the workspace, Basic09 reports an **Unknown Procedure** error and stops — no file is written.
- Module names are limited to 29 characters. If the procedure name reaches this limit and the output filename is derived from it, the filename is truncated to 26 characters before `.up` is appended.
- The name-list syntax is the same as `SAVE` and `PACK`.

---

## LOADM — Load Raw I-Code File(s) into the Workspace

### Syntax

```
LOADM [/path/]name[.up] [, [/path/]name[.up] ...]
```

### Description

`LOADM` reads one or more `.up` files from disk and loads the raw I-code bytes into Basic09's workspace. It is the counterpart to `SAVEM`.

Each file may contain one or more OS-9 module records (as produced by `SAVEM name > file` or `SAVEM* mergedfile`). All modules found in each file are loaded in order.

If the `.up` extension is omitted from the filename, it is appended automatically (case-insensitive check).

### Forms

| Form | Meaning |
|---|---|
| `LOADM name[.up]` | Load `name.up` from the current data directory |
| `LOADM path/name[.up]` | Load from a relative path |
| `LOADM /path/name[.up]` | Load from an absolute path |
| `LOADM name, name, ...` | Load each named file in sequence from the CWD |
| `LOADM path/name, name, ...` | Load from a path; additional names without a path use the same path |
| `LOADM /path/name, name, ...` | Same, absolute path |

### Examples

```
LOADM myprog
```
Loads `myprog.up` from the current data directory.

```
LOADM /d1/backup/myprog
```
Loads `/d1/backup/myprog.up`.

```
LOADM prog1, prog2, utils
```
Loads `prog1.up`, `prog2.up`, and `utils.up` from the current data directory in sequence.

```
LOADM /d1/bundle
```
Loads `/d1/bundle.up`, which may contain multiple procedures concatenated together (as saved by `SAVEM proc1, proc2 > /d1/bundle` or `SAVEM* /d1/bundle`).

### Notes

- Files without a path are read from the **current data directory**; use `CHD` to control the source.
- If a procedure with the same name already exists in the workspace, `LOADM` reports an **Unknown Procedure** error (duplicate) and stops — the remaining names in the list are not processed.
- A merged file (multiple modules concatenated) has all its modules loaded in order.
- Workspace space is checked before each module is loaded; if insufficient, an **Out of Memory** error is reported.
