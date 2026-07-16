# Brainf*ck for NitrOS-9

This directory contains a small Brainf*ck interpreter for NitrOS-9. The
interpreter is an OS-9 program module named `bf` and accepts the path to one
Brainf*ck source file.

## Usage

Place `bf` in an execution directory such as `/DD/CMDS`, then pass it a source
file:

```text
bf helloworld.bf
```

The interpreter reads input for the `,` command from standard input and writes
output from the `.` command to standard output.

## Language commands

| Command | Operation |
| --- | --- |
| `>` | Move the data pointer right |
| `<` | Move the data pointer left |
| `+` | Increment the current byte |
| `-` | Decrement the current byte |
| `.` | Write the current byte |
| `,` | Read one byte into the current cell |
| `[` | Begin a loop while the current byte is nonzero |
| `]` | Return to the matching `[` |

All other characters are ignored. This permits explanatory text in a source
file, although any `[` and `]` characters in that text must remain balanced.

## Included examples

- `helloworld.bf` prints `Hello World!`.
- `inout.bf` reads and echoes one byte.
- `donothing.bf` performs no visible work.
- `99bottles.bf` prints the “99 Bottles of Beer” song.

## Implementation limits

The interpreter provides a 12,000-byte program buffer and a 3,000-byte data
tape. Source beyond the program-buffer capacity is not loaded. The
implementation does not check the data pointer for tape underflow or overflow,
so programs must keep it within the allocated tape.

## Building

The NitrOS-9 source tree and its toolchain must be configured through
`NITROS9DIR`.

```sh
make -C languages/bf
```

This builds the `bf` OS-9 program module. To create the package disk:

```sh
make -C languages/bf dsk
```

The resulting `bf.dsk` contains the interpreter in `CMDS` and this README plus
all included `.bf` examples in the disk's root directory.

Use `make -C languages/bf clean` to remove generated modules and disk images.

For background on the language, see the
[Brainfuck article on Wikipedia](https://en.wikipedia.org/wiki/Brainfuck).
