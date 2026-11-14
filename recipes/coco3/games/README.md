# CoCo 3 Game Recipes

Build game code, bootable NitrOS-9 images, and MAME startup checks from one
entry point. The games repository owns compilation and game assets; these
recipes own OS configuration, image packaging, and emulator launches.

```sh
make -C recipes/coco3/games list
make -C recipes/coco3/games GAME=rogue
make -C recipes/coco3/games GAME=rogue CPU=6309 run
make -C recipes/coco3/games GAME=sokoban check MAME_ROM_PATH=/path/to/roms
```

`all` (also `disk`) builds the selected game and image. `run` boots it in MAME.
`check` boots a disposable copy and verifies that the selected game's OS-9
process remains present for at least 120 consecutive frames, with at least
60 emulated seconds allowed for startup. It saves screenshots and logs. This
is a startup smoke test, not a game-rules or complete playthrough test.
Rogue checks dismiss the title, enter a name, and take a dungeon turn.
Rogue launches with read/write terminal paths because its original display
routines write through path 0.
For Arcade Pak, the check selects Smash from the shell menu. Reversi retains
its scripted preferences/board input replay and captures additional screens.
Sierra checks select keyboard controls with CTRL-BREAK and allow two emulated
minutes for startup, tracking the engine through its private memory mappings.
They also require Sierra's OS-9 error byte to be clear, so an error dialog
does not count as a successful launch. Koronis checks select RGB and press
the joystick button at the title screen.

Sierra uses application-screen ABI version 2, provided by CoWin/CoVDG and
Co3Hires. The driver reports its capabilities without allocating a screen,
protects allocated screens by process ID, and releases RAM if mapping fails.

## Sources and tools

The defaults use sibling `nitros9-games` and `nitros9-languages` checkouts.
Override `NITROS9_GAMES_DIR` or `LANGUAGES` for another layout. Local builds
use the current game sources, including uncommitted edits, without fetching
or changing branches. GitHub checks out the games repository's `main` branch.
No revision is pinned. Each build records both repository revisions and
tracked game modifications in `revisions.txt`.

All builds need make, LWTOOLS, and ToolShed `os9`; Sierra also needs the host
ToolShed `tocgen`. C ports build the sibling c3 host tools and runtime with
`make -C $(LANGUAGES)/c3 runtime` before compiling the game. MAME is required
only for `run` and `check`. Use `MAME_BINARY` to choose its executable and
`MAME_ROM_PATH` for the ROM directory. ROMs are not included in this repository.

Outputs live under `.build/GAME/CPU/TRANSPORT/`, including OS intermediates,
disk images, revision logs, and `verification/` diagnostics. CPU defaults to
6809; 6309 uses `coco3h` in MAME. Sierra defaults to 2 MiB of emulated RAM
for its private interpreter pool; other games default to 512 KiB. Override
`MAME_RAM` if needed. Game executables remain in their source checkout's normal output locations. The C ports produce 6809 executables,
which also run on 6309 systems.

`clean` removes only the selected recipe build directory. It leaves game
sources and compilation outputs alone. Game compilation is incremental, but
the shared OS recipe rebuilds the disk image on each invocation, replacing saved games on that image. Preserve saves
before rebuilding. Emulator checks use a disposable copy.

## Games and configuration

`configs/*.mak` selects each game's source directory, compiled programs,
data files, display width, startup command, and additional boot modules.
Use `list` for all available game selectors. Supported groups are:

- Arcade Pak, Flight Simulator II, Koronis Rift, Kyum-Gai, Microscopic Mission,
  Pac-OS9, Rescue on Fractalus, Rogue, and Sub Battle Simulator.
- The fourteen Sierra AGI titles, retaining their original volume names,
  geometry, table-of-contents generation, and additional data disks.
- The c3 ports: Adventure, Cocothello, Hordes, Kalah, Reversi, Sokoban,
  Solitaire, and Walk. These require those source directories in your games
  checkout; locally added ports must be published there before CI can use them.

For another game, add a configuration with `GAME_SOURCE`, `GAME_PROGRAMS`,
and either `GAME_COMMAND` or `GAME_STARTUP`. Asset paths are relative to the
game directory. `GAME_ROOTFILES` installs binary data at the disk root (or
`GAME_DATA_DIR`), `GAME_SYSFILES` installs into SYS, and `GAME_SCREENFILES`
installs OS-9 text screens into SCREENS. The shared builder marks commands
executable and preserves binary assets without newline conversion.

## Transports and testing

`TRANSPORT=floppy` is the default. `TRANSPORT=dw` and `TRANSPORT=becker`
retain Flight Simulator II and Koronis Rift's existing DriveWire variants,
using the standard DriveWire and Becker boot modules. Other games currently
support floppy only. Mount those
images using your DriveWire server; `run` and `check` currently support floppy
only. Sierra titles with three disks require manual disk changes after the
first two images mounted by `run`.

GitHub's normal Build job compiles representative Rogue, Arcade Pak, and
Christmas 1986 images for both CPUs. Emulator tests run only with a manual
workflow dispatch. Select the game in the **Run workflow** form, or:

```sh
gh workflow run build.yml --ref main -f game=rogue
```

The manual job tests the base OS and the selected game for both CPUs. It
keeps game screenshots, MAME logs, and repository revisions for seven days.
Specialized Sierra engine tests and their disposable test fixtures remain
with the engine sources in `nitros9-games`; their production CoCo images
come from this recipe.

## All-games virtual hard drive

```sh
make -C recipes/coco3/games CPU=6309 vhd
make -C recipes/coco3/games CPU=6309 run-vhd MAME_ROM_PATH=/path/to/roms
```

`vhd` compiles every configured game and installs the OS and payloads in one
128 MiB `games.vhd`. The output directory is `.build/collection/CPU/`.
`games-boot.dsk` is a small bootstrap floppy: MAME loads its kernel and
bootfile, then accesses the VHD through EmuDsk as `/dd` and `/h0`. Both files
are required, with no special hard-drive ROM needed. The launch target
attaches them as `-flop1 games-boot.dsk -hard1 games.vhd`.

The numbered `games` menu opens on the 80-column console. Select a number to
launch a game; select 0 to return to the OS shell. The menu returns after the
game exits. 80-column games use the console; games configured for 32 or 40
columns use the dedicated CoWin `/g40` device. The collection bootfile does
not include CoVDG or `/v1`.
Arcade Pak opens a shell where you can run `smash`, `shanghai`, or `thexder`;
exit that shell with EOF to return to the menu. Run `games` again from the
main shell to reopen the menu, or `shell <catalog` to list the installed games.

Each game has its own `/dd/GAMES/name/CMDS` and data directory. Sierra titles
include all resource volumes in that directory. Their table of contents
opens at most two volumes at once, leaving file handles available for the
interpreter. Every entry refers to the VHD, so no data-floppy swapping is needed. Original absolute data paths
used by Adventure, Rogue, Sub Battle Simulator, and Walk are also populated.
Sub Battle Simulator starts directly with all side-two data in `/dd/SUB`.
The collection includes the screen-service support required by Sierra.

Choose a smaller library with `GAMES` (the default includes every game whose
source directory is present in your games checkout):

```sh
make -C recipes/coco3/games GAMES="rogue sokoban reversi" vhd
make -C recipes/coco3/games GAMES="rogue sokoban reversi" check-vhd \
  VHD_TEST_GAME=sokoban MAME_ROM_PATH=/path/to/roms
```

`check-vhd` boots disposable copies of the floppy and VHD, selects the requested
menu entry, and verifies that game's process starts and remains present. It
uses the same startup smoke checks as the individual recipe. Diagnostic files
are saved under `.build/collection/CPU/verification/`.

`run-vhd` uses RGB output, normal emulator speed, and sound by default. Override
`MAME_BINARY`, `MAME_FLAGS`, `MAME_RAM` (default 2 MiB), or `MAME_ROM_PATH` as
needed. `VHD_SECTORS` controls image size in 256-byte sectors (524288 by default).
The default cluster size is four sectors.

These targets are opt-in; they do not add VHD builds to every CI commit.
`run-vhd` reuses an existing collection, preserving saves. It refreshes boot
and launcher configuration when the recipe changes, and repairs a missing
bootstrap floppy without rebuilding the game drive. Use `vhd` explicitly to
refresh game code.
`vhd` and `check-vhd` rebuild the library image, replacing saves on that image;
back up a played VHD before rebuilding. `clean-vhd` removes the selected CPU's
collection directory, including its VHD and saves.

### Update an existing VHD launcher

Close MAME before updating an installed collection:

```sh
make -C recipes/coco3/games CPU=6309 update-vhd-menu
make -C recipes/coco3/games CPU=6309 run-vhd
```

`update-vhd-menu` replaces only the `games` menu module using the collection's
existing catalog. It does not format the drive or replace game data and saves.
This also applies the fix that makes dedicated 40-column game windows visible.

Walk's VHD check verifies both a substantial change from the menu display and
changing animation frames, in addition to checking its running process. This
catches the case where Walk is alive but its window remains hidden.

To force a boot configuration refresh without formatting the VHD, close MAME
and run `make -C recipes/coco3/games CPU=6309 update-vhd-boot`. This updates
both OS9Boot copies, the bootstrap kernel track, the menu, and old launcher
references to `/v1`. Game binaries, assets, and saves are retained. RGB is
selected before each launch while preserving other MAME input settings.

Boot refreshes support fragmented `OS9Boot` files: contiguous files use the
normal data-sector link, while fragmented files use the file-descriptor link
with `DD.BSZ=0`, as supported by the bootloader. Updating the installed VHD
therefore does not require reformatting or a contiguous free allocation.
