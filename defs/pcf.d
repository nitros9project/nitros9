* FAT32 file manager. Include os9.d, rbf.d and blkdrv.d first.
FT.Base             equ       BT.Config+BC.Len    32-bit partition base LBA
FT.Length           equ       FT.Base+4           partition blocks (zero=device remainder)
FT.End              equ       FT.Length+4
                    org       0
* Keep hot arithmetic and transfer fields in compact indexed-address range.
F.Val               rmb       4                   arithmetic / sector operand
F.Move              rmb       2
F.Pos               rmb       4
F.Request           rmb       BR.Len
F.Info              rmb       BI.Len
F.Regs              rmb       2
F.Base              rmb       4
F.Span              rmb       4
F.Total             rmb       4
F.FatStart          rmb       4
F.DataStart         rmb       4
F.FatSize           rmb       4
F.MaxCluster        rmb       4                   last valid data cluster
F.Root              rmb       4
F.SPC               rmb       1
F.Shift             rmb       1
F.Fats              rmb       1
F.Active            rmb       1
* Each cache descriptor is a validity byte followed by its 32-bit LBA.
F.DataValid         rmb       1
F.DataLBA           rmb       4
F.FatValid          rmb       1
F.FatLBA            rmb       4
F.Start             rmb       4                   open object's first cluster
F.Size              rmb       4                   visible byte length
F.Entry             rmb       32                  original FAT directory entry
F.Temp              rmb       4
F.Cluster           rmb       4                   FAT chain operand
F.Walk              rmb       4                   cached file cluster
F.Hare              rmb       4                   cycle detector; zero after reaching EOC
F.WalkIndex         rmb       4
F.WalkValid         rmb       1
F.Offset            rmb       4                   logical byte offset for Locate
F.Target            rmb       4
F.Scan              rmb       4
F.Cursor            rmb       2
F.Name              rmb       11
F.Dots              rmb       1
F.Remain            rmb       2
F.Actual            rmb       2
F.Dest              rmb       2
F.Line              rmb       1
F.Stop              rmb       1
F.Cookie            rmb       4
F.NextPath          rmb       2
F.Owner             rmb       2
F.Registered        rmb       1
F.Creating          rmb       1
F.HasLFN            rmb       1
F.Mirror            rmb       1
F.DirLBA            rmb       4
F.DirOff            rmb       2
F.FSInfo            rmb       4
F.BackInfo          rmb       4
F.New               rmb       4
F.Link              rmb       4
F.Saved             rmb       4
F.Value             rmb       4
F.FatCopy           rmb       1
F.Zero              rmb       1
F.GapEnd            rmb       4
F.SavedPos          rmb       4
F.Wanted            rmb       4
F.HintDelta         rmb       1
F.Sectors           rmb       1
F.Time              rmb       6
F.Deleting          rmb       1                   internal open accepts either object type
F.Child             rmb       4                   unpublished directory cluster
                    ifgt      .-256
                    error     PCF field helper offsets exceed one byte
                    endc
F.Path              rmb       256
F.Record            rmb       256
                    ifgt      .-$400
                    error     FAT32 workspace overlaps sector buffers
                    endc
                    org       $400
F.Data              rmb       512
F.Fat               rmb       512
F.Len               equ       .                   2048 bytes per system path
