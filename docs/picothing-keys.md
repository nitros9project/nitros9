# Pico-Thing keyboard cheat-sheet

What the keys do on a Pico-Thing running NitrOS-9 Level 2. The USB keyboard
drives the video console; the serial console (`/Term`) gets whatever the host
terminal sends. coco-thing sends the same bytes as the video console's keyboard;
other terminal emulators send ANSI escape sequences for the cursor keys, which
only uEmacs understands. For the bytes each key sends, see the keyboard table in
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

The arrow and editing keys mean nothing to SCF. Outside Shell+'s history keys,
pressing one in a command line puts its byte into the line.

## Shell+ command history

At the Shell+ prompt the history keys are the up and down arrows. Shell+
rebinds the interrupt and quit characters to them while it waits for a
command, so Ctrl-C and Ctrl-E are not signals at the prompt.

| Key | Action |
|---|---|
| Up | recall the previous command |
| Down | recall the next command |
| Ctrl-A | accept the recalled command |
| Enter | run it |

On the serial console this needs coco-thing, or a terminal that sends `$8C`
and `$8D` for Up and Down.

## minted (the full-screen editor)

Ctrl-O shows minted's own help.

**Save and exit:** Ctrl-S, then `y` at "Save file (y/n)?" (a new file asks
for its name), then Ctrl-E. Ctrl-E after a save exits straight away; with
unsaved changes it asks "Exit without saving (y/n)?", where `n` takes you back
to the text. Ctrl-E is also the "break" that minted's error messages ask for.

| Key | Action |
|---|---|
| Arrows | move the cursor |
| Page Up / Page Down, Shift+Up / Shift+Down | page up / page down |
| Backspace, Shift+Left | delete left |
| Delete, Shift+Right | delete right |
| Home / End, Ctrl+Left / Ctrl+Right | start / end of the line |
| Ctrl-S | save |
| Ctrl-R | rename the file |
| Ctrl-K | delete the line |
| Ctrl-D | duplicate the line |
| Ctrl-G | go to a line number |
| Ctrl-U | undo |
| Ctrl-E | exit |

The other function and editing keys do nothing; the pound sign is typed as
text. On the serial console the cursor and editing keys need coco-thing.

## ded and uEmacs

In ded, Up and Down show the next and previous sector, and in edit mode the
arrows move the cursor.

In uEmacs (`umacs`), the arrows move by character and line, Ctrl+Left and
Ctrl+Right by word, Ctrl+Up and Ctrl+Down go to the start and end of the
buffer, Home and End to the start and end of the line, Page Up and Page Down
page, and Delete deletes forward. It also understands a terminal's ANSI arrow
keys.

## Deleting

| Where | Delete left | Delete right | Delete the line |
|---|---|---|---|
| A command line | Backspace, Ctrl-H | none | Ctrl-X |
| minted | Backspace, Shift+Left | Delete, Shift+Right | Ctrl-K |

In a command line, Backspace erases the character from the screen too.

Most terminal emulators send DEL (`$7F`) for Backspace, and NitrOS-9 does not
treat that as backspace. On the serial console, set the terminal's Backspace to
send ^H, or press Ctrl-H.

## Key codes

The cursor and editing keys send bytes of their own, so no program mistakes
them for control characters. Backspace (`$08`) and Tab (`$09`) are unchanged.

| Keys | Bytes |
|---|---|
| Up, Down, Left, Right | `$8C` `$8D` `$8E` `$8F` |
| the same with Shift | `$90` `$91` `$92` `$93` |
| the same with Ctrl | `$94` `$95` `$96` `$97` |
| Home, End, Page Up, Page Down | `$98` `$99` `$9A` `$9B` |
| Insert, Delete | `$9D` `$9E` |

With Num Lock off, keypad 8/2/4/6 are the arrows, Shift and Ctrl included, and
keypad 7/1/9/3/0/. are Home, End, Page Up, Page Down, Insert and Delete.
Alt with a printable character sets its top bit, so Alt-A is `$E1`, as on a
CoCo 3.

## Keys that send nothing

Print Screen, Scroll Lock, Pause, and keypad 5 with Num Lock off.
