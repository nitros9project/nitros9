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

## Test evidence report

Full/nightly runs and manually selected build, MAME, or filesystem suites
finish with a **Test evidence report** job. Download the **test-evidence-report**
artifact from the run summary, extract the ZIP, and open `index.html`. It is
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
the run page. Reports are retained for 14 days.

To generate a report locally from an existing run:

```sh
gh run download RUN_ID --repo nitros9project/nitros9 --dir artifacts
gh api repos/nitros9project/nitros9/actions/runs/RUN_ID > run.json
gh api --paginate --slurp \
  'repos/nitros9project/nitros9/actions/runs/RUN_ID/jobs?filter=latest&per_page=100' > jobs.json
python3 scripts/ci-test-report.py --artifacts artifacts \
  --run-json run.json --jobs-json jobs.json --output report
```
