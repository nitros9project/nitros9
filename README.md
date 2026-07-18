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
| [Wildbits 6809](https://wildbitscomputing.com/) | NitrOS-9 Level 1 & 2 | 6809 |

# Downloading and Building

To build NitrOS-9, you need the following:

- [lwtools](http://lwtools.projects.l-w.ca). This package contains the required 6809 assembler and linker.
- [ToolShed](https://github.com/n6il/toolshed). ToolShed provides file system tools for creating disk images, copying files to and from those disk images, and more.

Once downloaded and installed, select a build recipe under `recipes`. For
example, to build the CoCo 3 Level 2 floppy image:

```sh
export NITROS9DIR=$HOME/nitros9
make -C recipes/coco3/floppy
```

Each recipe produces its disk image in its own directory. See
[`recipes/README.md`](recipes/README.md) for the available platforms and links
to their build instructions.

# Contributing

If you wish to contribute, please fork the repository and submit pull requests.

Also, assembly source code is formatted to the following specifications:

- Spaces only (no tabs)
- One space between opcode and operand, and operand and comments

This ensures a consistent experience and efficient representation in the repository.

Put [this file](https://github.com/nitros9project/nitros9/blob/main/scripts/pre-commit) in your .git/hooks folder to ensure that any source code you submit is automatically formatted.

## Make commits meaningful

When you commit your changes, please use standard Git message style. The first line of your message should be short but descriptive, telling viewers of the source code what you have changed in 50 characters or less. This is like a "Subject:" line in an email, and `git format-patch` actually uses it as one.

If the change is not 100% self-explanatory, the first line should be followed by a blank line and a message (word wrapped at 72 or fewer characters) telling everyone _why_ you made your changes. Be descriptive, someone (perhaps even you) will someday need to understand what you had in mind when you wrote something, and the easier that is for them the better.

Everything in each commit should be related to a single change, described in the message. For example, if you are documenting a source file and also optimizing it, those actions are separate even if they touch the same file. Document it first, then optimize; so that if you accidentally make a mistake in one change, we can use Git tools to revert just that change without having to detangle two of them.

That doesn't mean you need to do _everything_ separately, though. It's possible for one change to touch many files and still be a single change. One example would be renaming an assembly language symbol-- something like that should definitely be done in every file that uses it, so that there's no window during which the build process is broken.
