# Historical distribution tools

These files supported the former monolithic distribution tree:

- `bndi` and `bundi` built release bundles from the old `6809l1`, `6309l1`,
  `6809l2`, `6309l2`, and `dsks` directory layout.
- `bootlistl1`, `bootlistl2`, `tracklistl1`, and `tracklistl2` supplied module
  lists to those bundle builders.
- `mkdskindex` generated a static HTML index for the removed `dsks` tree.

The current recipe system does not use these utilities.
