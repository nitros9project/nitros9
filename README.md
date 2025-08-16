# The NitrOS-9 Repository (on GitHub)

NitrOS-9 is a community-based distribution of the [Microware OS-9 operating system](https://en.wikipedia.org/wiki/OS-9) for the [Motorola 6809](https://en.wikipedia.org/wiki/Motorola_6809) that was introduced in the late 1970s and sold into the 1980s.

The [Hitachi 6309](https://en.wikipedia.org/wiki/Hitachi_6309), which contains additional registers and enhanced instructions, is also supported.

Here are the current ports of NitrOS-9:

| Computer  | Port | Processor |
| ------------- | ------------- |  ------------- |
| TRS-80 Color Computer  | NitrOS-9 Level 1 | 6809 & 6309 |
| Radio Shack Color Computer 2 | NitrOS-9 Level 1 | 6809 & 6309 |
| Tandy Color Computer 3 | NitrOS-9 Level 2 | 6809 & 6309 |
| [CoCo3FPGA](https://groups.io/g/CoCo3FPGA) | NitrOS-9 Level 2 | 6809 |
| Dragon 64 & Tano Dragon | NitrOS-9 Level 1 | 6809 |
| Dragon Alpha | NitrOS-9 Level 1 | 6809 |
| [Atari w/ Liber809](http://www.github.com/boisy/liber809) | NitrOS-9 Level 1 | 6809 |
| [Corsham 6809 SS-50](https://www.corshamtech.com/product/ss-50-6809-cpu-board/) | NitrOS-9 Level 1 | 6809 |
| [Foenix F256 with FNX6809](https://www.c256foenix.com/) | NitrOS-9 Level 1 & 2 | 6809 |

# Downloading and Building

To build NitrOS-9, you need the following:

- [lwtools](http://lwtools.projects.l-w.ca). This package contains the required 6809 assembler and linker.
- [ToolShed](https://github.com/n6il/toolshed). ToolShed provides file system tools for creating disk images, copying files to and from those disk images, and more.

Once downloaded and installed, you can build the entire project:

```
export NITROS9DIR=$HOME/nitros9
make
```

Then to build all of the disk images:

```
make dsk
```

The result is a number of disk images (ending in .dsk) that can be used on real floppy drives, emulators, and DriveWire.

# Contributing

If you wish to contribute, please fork the repository and submit pull requests.

Also, assembly source code is formatted to the following specifications:

- Spaces only (no tabs)
- Labels start at column 1
- Opcodes start at column 21
- Operands start at column 31
- Comments start at column 51

Put [this file](https://github.com/nitros9project/nitros9/blob/main/scripts/pre-commit) in your .git/hooks folder to ensure that any source code you submit is automatically formatted.

# Coding Style Guidelines

Here are some general coding guidelines for the project.

## Add a comment to every line of assembly

Having a comment on each line of assembly may seem excessive, but doing so keeps the meaning behind flow of the code intact and gives the reader a clear understanding of what is happening.

## Make comments meaningful

Take time to write clearly about what a line of code is doing. Avoid repeating the obvious, if possible.

Instead of this:

```
     clra        clear A
```

do this:

```
     clra        set the path to standard input
```      

## Write comments in lowercase and don't use punctuation

Comments may or may not be complete sentences; as such, dispense with the formalism of capitalization and punctuation.

Instead of this:

```
     ldb   #E$PNNF      Prepare the "pathname not found" error.
```

do this:

```
     ldb   #E$PNNF      prepare the "pathname not found" error
```      
## Use full words

Avoid abbreviations. Spelling out words increases the readability of the comments.

Instead of this:

```
     pshs  d,x,y,u      push regs
     leax  ,u           load path desc ptr in X
```

do this:

```
     pshs  d,x,y,u      save the registers on the stack
     leax  ,u           load the path descriptor pointer in X
```

## Ensure an empty line is at the end of a source file

Adding an empty line to the end of a source file ensures that some programs that parse
the input do not abandon any important information on the last line.

Instead of this:

```
     rts
```

do this:

```
     rts

```
