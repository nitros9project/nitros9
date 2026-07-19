# Contributing to NitrOS-9

Fork the repository, make a focused change, verify the affected recipes or
modules, and submit a pull request.

Assembly formatting is handled by
[`scripts/asmprettyprint.py`](scripts/asmprettyprint.py), which is invoked by
the provided [`scripts/pre-commit`](scripts/pre-commit) hook. Contributors do
not need to maintain a separate set of manual formatting rules.

## Commits

Use a short, descriptive imperative subject. Add a wrapped explanatory body
when the reason for a change is not self-evident.

Keep each commit focused on one logical change. A single logical change may
touch many files—for example, renaming a symbol everywhere it is used—but
unrelated documentation, optimization, and behavior changes should normally
be separate commits.

## Verification

Run the narrowest relevant module build or recipe first. Changes affecting
shared build rules should also run:

```sh
bash .github/workflows/nitros9.sh
```

Generated disk images, objects, maps, listings, and emulator configuration
files should not be committed.
