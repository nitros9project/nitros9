# Continuous integration

The **Build** workflow runs **Quick checks** on the latest commit of every
branch push, including branch names containing `/`. Fork pull requests run
these checks too. Internal pull requests use their branch's push check, so
opening a PR does not repeat the work. A newer push cancels an older run on
the same branch.

Automatic checks use one Ubuntu runner, with a ten-minute timeout:

- Reject unresolved merge markers and parse every tracked recipe makefile.
- Run the small Python regression tests.
- Assemble the actual recipe system modules for CoCo Level 1/6809 and
  CoCo 3 Level 2/6809 and 6309; verify their OS-9 CRCs.
- Build and validate the Corsham ROM when that recipe is present, including
  its fixed size and hardware-vector placement.

LWTOOLS 4.25 and ToolShed 2.6.1 are cached together. A cold cache downloads
checksum-verified archives and builds LWTOOLS. Source modules are rebuilt on
every run. The automatic job does not check out games or languages, build
filesystem images, or install an emulator. It checks assembly and covered
regressions; successful booting and gameplay require the MAME suite.

## Run heavier tests

In GitHub, open **Actions → Build → Run workflow**, select the branch, and
choose a `suite`:

| Suite | Work |
| --- | --- |
| `quick` | Automatic checks only |
| `full` (default) | Quick checks, then all product builds and representative games |
| `mame` | Quick checks, then boot both CPUs and the selected game in MAME |
| `all` | Quick checks, then both full builds and MAME |

The `game` input applies to the MAME suite. Heavy suites run only when
requested; ordinary pushes do not start them. Job logs are available from
the workflow run, and MAME diagnostics remain available as artifacts.

Run the same quick checks locally from a checkout with LWTOOLS, ToolShed,
and Python 3 on `PATH`:

```sh
bash scripts/ci-quick.sh
```

For the complete build, also provide the games and languages checkouts and
run `bash .github/workflows/nitros9.sh`. Local quick checks use temporary
module directories so CPU variants do not share compiled outputs.
