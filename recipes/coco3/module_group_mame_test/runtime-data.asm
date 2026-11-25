* Shared private data and evidence record layout for runtime probes.
                    org       0
outpath             rmb       1
role                rmb       1
phase               rmb       1
peer                rmb       1
event               rmb       1
expected            rmb       1
reverse             rmb       1
held                rmb       2
extra               rmb       2
entryheld           rmb       2
entryextra          rmb       2
sequence            rmb       2
waitleft            rmb       2
sysmap              rmb       16
pointer             rmb       2
pathindex           rmb       1
pathpages           rmb       64
pathbuffer          rmb       256
record              rmb       12
descriptor          rmb       P$Size
blockflags          rmb       64
processes           rmb       256
tasks               rmb       32
activepaths         rmb       2
RecordSize          equ       .-record
                    rmb       512
size                equ       .
