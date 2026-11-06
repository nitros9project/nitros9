CoCo 3 RFM integration tests in MAME
==================================

Run from this directory:

    make check

For just the directory/execution checks (about a minute):

    make check TEST_SUITE=directories

For the visible CoCo 3 window:

    make run

Requirements: Python 3, MAME with CoCo 3/Becker support, the normal NitrOS-9
cross-build tools and sibling nitros9-languages sources. ROMs default to
~/.local/share/mame/roms (the setting in Boisy's .zshrc). Override explicitly:

    make check MAME_ROMPATH="/path/to/roms" MAME_BINARY=/path/to/mame

Only the normal CoCo 3 and Disk BASIC v1.1 ROMs are needed. No HDB-DOS ROM or
remote boot image is required. The machine boots the local generated floppy.
RFM, rfmdrv, Y0 and Becker DWIO are resident in OS9Boot. There is no
startup file. The visible run boots directly to the shell without running tests.
For manual RFM use, enter:

    load utilpak1

The RFM driver links and initializes DWIO on its first Attach; no /X0 device
or initialization command is required. To explicitly run the scripted checks,
enter "shell </dd/rfmauto". The headless check posts
that command after boot; it does not install or depend on a startup file.

The runner starts a deliberately small loopback DriveWire/RFM protocol fixture
on TCP 65504, then starts MAME. It uses an isolated config to enable Becker and
select the port; personal MAME settings are not changed. No third-party server
is needed for these tests. An occupied port fails rather than stopping another
server. DW_PORT can select one of MAME's supported ports, 65500 through 65509.

The guest copies files of 0, 1, 255, 256, 257, 1024 and 65537 bytes from /Y0 to
/DD and back, running binary comparisons along the way. The host verifies every
roundtrip with SHA-256 after Close. Reaching the shell's final echo is not proof
of success: look for the host's PASS message. The headless check returns nonzero
if MAME exits or the timeout expires without all expected outputs.

The directory checks cover absolute and relative chd/chx, child and parent
traversal (36 relative changes through child/deep/leaf and sibling directories,
with a unique marker read after every change), inherited directories in forked
utilities and rfmfork (parent changes both directories before child first I/O,
then child changes both and parent verifies its own state), independent data and
execution directories, dir/dir -e/dir -x/dir -e -x, MakDir, relative creation,
Delete, and failed directory changes preserving the previous location. The
original test executables exist only on the host share, so successful execution
proves loading through the remote execution directory. Captured listings and
program output are checked by the host, along with actual protocol requests.
The two deliberate missing-directory changes should report error 216.
Directory records put .. before .; dot-only paths follow OS-9 semantics
(... ascends two levels), as required by the Shell+ current-directory prompt.
The standard-library checks are: python3 scripts/test-rfm-fixture.py (from the
repository root).

Artifacts live under .rfm-test:
  mame.log        emulator diagnostics
  protocol.jsonl  actual guest protocol requests/errors
  screen.png      periodic CoCo 3 screenshot
  share/rfmtest   deterministic input files and returned outputs
  manifest.json  expected SHA-256 hashes

TEST_SECONDS defaults to 600 (wall time); MAME also has an emulated-time limit.
The full sequence can take several minutes at normal floppy speed.
The visible run closes when the timeout expires or you exit MAME. Use a larger
TEST_SECONDS for extended interactive inspection. Each run recreates only the
fixture's output files, completion marker and owned scratch directory; the floppy image is rebuilt.

This fixture is not a production DriveWire server. It exercises file transport
and directory/metadata exchange, but not complete status handling, production
permissions, locking, reconnect or directory ownership after parent exit/PID reuse. Test those against
the actual server separately. ReadLn, WritLn, failure injection, Seek-related
boot transfers and direct hardware timeout checks also have deterministic CPU
regressions in scripts/test-rfm.py; see scripts/test-rfm.txt.
