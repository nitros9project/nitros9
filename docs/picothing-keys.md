# Pico-Thing keyboard cheat-sheet

What the keys do on a Pico-Thing running NitrOS-9 Level 2. The USB keyboard
drives the video console; the serial console (`/Term`) gets whatever the host
terminal sends. For the bytes each key sends, see the keyboard table in
[copico-video-protocol.md](copico-video-protocol.md#keyboard-input-ff10-viddata-read-side).

## Windows (video console only)

| Key | Action |
|---|---|
| F1 | show the root panel, `/W0`, and give it the keyboard |
| F2–F8 | show `/W1`–`/W7` and give it the keyboard |
| F9–F12 | nothing |

The boot `startup` runs a login on `/W1`, so press **F2** to log in on the
screen. The serial console stays the default login.

## Anywhere

These are SCF's defaults. A program can change or disable them through its
path options.

| Key | Action |
|---|---|
| Ctrl-C | interrupt the program (signal `S$Intrpt`) |
| Ctrl-E | abort the program (signal `S$Abort`) |
| Ctrl-W | pause output at the end of the line; any key continues |

The key is consumed: a Ctrl-C that stops a program does not also turn up at
the start of the next command line.

## Typing a line (SCF line editing)

| Key | Action |
|---|---|
| Backspace, Ctrl-H | delete the last character |
| Ctrl-X | delete the whole line |
| Ctrl-A | repeat the previous line |
| Ctrl-D | reprint the current line |
| Enter | send the line |
| Esc (at the start of a line) | end of file |

## Shell+ command history

At the Shell+ prompt the history keys are the up and down arrows. Shell+
rebinds the interrupt and quit characters to them while it waits for a
command, so Ctrl-C and Ctrl-E are not signals at the prompt.

| Key | Action |
|---|---|
| Up (Ctrl-L) | recall the previous command |
| Down (Ctrl-J) | recall the next command |
| Ctrl-A | accept the recalled command |
| Enter | run it |

On the serial console, use **Ctrl-L** and **Ctrl-J**: a terminal emulator's
arrow keys send ANSI escape sequences, which NitrOS-9 does not understand.

## minted (the full-screen editor)

Ctrl-O shows minted's own help.

**Save and exit:** Ctrl-S, then `y` at "Save file (y/n)?" (a new file asks
for its name), then Ctrl-E. Ctrl-E after a save exits straight away; with
unsaved changes it asks "Exit without saving (y/n)?", where `n` takes you back
to the text. Ctrl-E is also the "break" that minted's error messages ask for.

| Key | Action |
|---|---|
| Arrows | move the cursor |
| Shift+Up / Shift+Down | page up / page down |
| Shift+Left / Shift+Right | delete left / delete right |
| Ctrl+Left / Ctrl+Right | start / end of the line |
| Ctrl-S | save |
| Ctrl-R | rename the file |
| Ctrl-K | delete the line |
| Ctrl-D | duplicate the line |
| Ctrl-G | go to a line number |
| Ctrl-U | undo |
| Ctrl-E | exit |

The Shift and Ctrl arrows need the video console's keyboard. On the serial
console, type their control codes instead: Ctrl-\ and Ctrl-Z to page, Ctrl-X
and Ctrl-Y to delete, Ctrl-P and Ctrl-Q for the start and end of the line.

## Deleting

| Where | Delete left | Delete right | Delete the line |
|---|---|---|---|
| A command line | Backspace, Ctrl-H (and Left on the video keyboard) | none | Ctrl-X |
| minted, video keyboard | Shift+Left | Shift+Right | Ctrl-K |
| minted, serial console | Ctrl-X | Ctrl-Y | Ctrl-K |

In a command line, Backspace erases the character from the screen too. In
minted, Backspace only moves the cursor left, because it sends the same byte as
the Left arrow. The Delete key sends nothing.

Most terminal emulators send DEL (`$7F`) for Backspace, and NitrOS-9 does not
treat that as backspace. On the serial console, set the terminal's Backspace to
send ^H, or press Ctrl-H.

## Keys that share a byte

These follow the CoCo keyboard, so programs cannot tell them apart:

| Keys | Byte | What it means |
|---|---|---|
| Left, Backspace | `$08` | Left deletes in a command line; Backspace moves left in minted |
| Right, Tab | `$09` | |
| Shift+Left, Ctrl-X | `$18` | Shift+Left deletes the whole line at a prompt |
| Ctrl+Up, Ctrl-S | `$13` | Ctrl+Up saves in minted |
| Ctrl+Down, Ctrl-R | `$12` | Ctrl+Down renames in minted |

## Keys that send nothing

Insert, Home, Page Up, Delete, End, Page Down, Print Screen, Scroll Lock,
Pause, and keypad 7/1/9/3/0/. and 5 with Num Lock off. The editing keys are an
open proposal in the protocol document. With Num Lock off, keypad 8/2/4/6 are
the arrows, Shift and Ctrl included.
