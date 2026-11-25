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
| `filesystems` | CPU regressions, all filesystem integrations on both CPUs, and CoCo 1/2 Level One runtime |
| `all` | Quick checks, full builds, OS/game smoke and all filesystem/runtime tests |

The `game` input applies to the MAME suite. The full suite runs nightly on
`main`; heavy suites can also be requested manually. Ordinary pushes run quick checks. Job logs are available from
the workflow run, and MAME diagnostics remain available as artifacts.

Run the same quick checks locally from a checkout with LWTOOLS, ToolShed,
and Python 3 on `PATH`:

```sh
bash scripts/ci-quick.sh
```

For the complete build, also provide the games and languages checkouts and
run `bash .github/workflows/nitros9.sh`. Local quick checks use temporary
module directories so CPU variants do not share compiled outputs.

## Test evidence report

Full/nightly runs and manually selected build, MAME, or filesystem suites
finish with a **Test evidence report** job. Download the **test-evidence-report**
artifact from the run summary, extract the ZIP, and open `index.html`.
For a standalone document, use the **Download the PDF report** link in the
**Test evidence report** job summary. GitHub downloads this as a ZIP containing
`test-report.pdf`; extract it and open the PDF. It includes clickable run/job
links and section bookmarks. It is
readable offline and embeds guest screenshots. Keep the `evidence` directory
beside it to follow links to the bundled result files and logs.

The report shows each job's actual status and elapsed time, descriptions of
its checks, recorded module reference-count/mapping transitions, seeded stress
results, independent filesystem-checker logs, console output, and coverage
limits. Screenshots supplement assertions; they do not establish file-content
or memory-accounting correctness by themselves. Skipped checks remain skipped.
Failed runs still produce a report when checkout and report generation are
available. Missing artifacts and contradictory result JSON are called out,
rather than treated as passing evidence.

The artifact includes machine-readable run/job metadata, a summary, and an
evidence inventory with SHA-256 hashes for bundled files. Full guest disk
images and files larger than 2 MB remain in the original test artifacts on
the run page. Both PDF and HTML reports are retained for 14 days.

To generate a report locally from an existing run:

```sh
gh run download RUN_ID --repo nitros9project/nitros9 --dir artifacts
gh api repos/nitros9project/nitros9/actions/runs/RUN_ID > run.json
gh api --paginate --slurp \
  'repos/nitros9project/nitros9/actions/runs/RUN_ID/jobs?filter=latest&per_page=100' > jobs.json
python3 scripts/ci-test-report.py --artifacts artifacts \
  --run-json run.json --jobs-json jobs.json --output report
```

## Runtime coverage

Filesystem integration has eight independent suites, each built and booted on
both 6809 (`coco3`) and native 6309 (`coco3h`): PCF write, read-only root,
floppy access, FAT boot, RBF commands, RFM, RFM interrupt stress, and module
groups. CPU-qualified job and artifact names keep their evidence separate.

Two additional jobs boot a 64K CoCo 1 (`coco`) and CoCo 2 (`coco2b`) with
Level One. A guest program creates a directory, writes and rereads 513 known
bytes, seeks across a sector boundary, reopens through a relative name, checks
EOF, and creates/deletes a temporary file. The host independently checks the
entire resulting file, the completion file, and disk allocations. This also
regresses the stale Level One RBF open-file list left behind on close, which
could hang a later disk open after a descriptor was reused.

The module-group suite adds synchronized parent/child processes sharing a
multi-block module file. It runs both release orders, executes the survivor,
and tries a stale parent unlink after the child links the parent's former
module. Captured process descriptors establish separate process IDs, mapping
counts and physical blocks at each step; the host verifies final reclamation
and removal of the exited child.

A second guest runs 10 warmup cycles followed by **1,000 measured cycles**.
Each cycle loads and links a group, creates/writes/closes a file, forks a child
which links/executes/reads/unlinks it, waits for the child, executes the parent's
modules again, unlinks them and deletes the file. Alternating groups occupy one
or two physical blocks. The baseline, every 100 cycles and final checkpoint
must have identical free 8K block, process, task and active-path counts, plus
unchanged parent mappings and path slots. Snapshots use temporary F$CpyMem
mappings; task counts include the same temporary observer at each checkpoint.
An independent disk check rejects new orphan, duplicate or missing allocations.
The HTML and PDF reports show the measured checkpoints and two-process cases.

These are finite controlled schedules, not proof against every race or resource
failure. Level One coverage currently uses 6809 and the standard floppy driver;
other devices and physical hardware still need their own runtime coverage.

Local examples (provide the language checkout and verified MAME ROMs):

```sh
CPU=6309 MAME_ROMPATH=/path/to/roms bash scripts/ci-filesystems-mame.sh module-groups
make -C recipes/coco/l1_mame_test MAME_MACHINE=coco MAME_ROMPATH=/path/to/roms check
make -C recipes/coco/l1_mame_test MAME_MACHINE=coco2b MAME_ROMPATH=/path/to/roms check
```

Use separate clean recipe outputs when switching CPU variants locally. Nightly
matrix jobs each start in their own checkout. `LEAK_CYCLES` can shorten a local
debug run; nightly CI keeps the 1,000-cycle default and records the actual count.

## Shared emulator ROMs

The preparation job restores the checksum-pinned ROM cache across runs. On a
cache miss, that job downloads and verifies the archives once, saves the cache,
and publishes a `verified-mame-roms` artifact for the current run. Every emulator
job downloads that small artifact and verifies its checksums; test jobs never
contact the ROM download site. The artifact lasts one day; the reusable cache
is independent of artifact retention. If GitHub evicts the cache, only the
preparation job needs to fetch the ROMs again. Incomplete or incorrect downloads
are never installed as verified archives.
