# Archive manifest

The archive preserves source and assets that are outside the supported build.
Most of this material was moved from the former `3rdparty` tree during the
repository cleanup. Individual files retain their original copyright and
license notices where available.

| Path | Contents | Status |
| --- | --- | --- |
| `drivers/` | Third-party and obsolete device drivers | Manual historical reference; some have maintained equivalents |
| `fmgrs/` | Third-party file managers | Unsupported |
| `p2mods/` | Experimental and demonstration system modules | Unsupported |
| `packages/` | Historical packages not migrated to apps, games, or languages repositories | Preserved for reference |
| `subrtns/` | Third-party subroutine modules | Unsupported |
| `utils/` | Historical utilities grouped by package or contributor | Manual builds only; compatibility varies |
| `vefs/` | Historical VEF image assets | Data archive |
| `wip/` | Unfinished work | Incomplete and unsupported |
| `project-history/` | Legacy release documentation and migration metadata | Historical record |
| `scripts/` | Obsolete distribution and publishing utilities | Historical reference; not used by supported builds |

Nothing listed here is built by supported recipes or CI. Before reviving an
item, identify its provenance and licensing terms, compare it with maintained
implementations, and move it out of the archive only as part of a reviewed
change.
