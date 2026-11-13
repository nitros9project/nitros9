* FAT32 file manager. Include os9.d, rbf.d and blkdrv.d first.
FT.Base             equ       BT.Config+BC.Len    32-bit partition base LBA
FT.Length           equ       FT.Base+4           partition blocks (zero=device remainder)
FT.End              equ       FT.Length+4 ; define constant or offset
                    org       0         ; set storage origin
* Keep hot arithmetic and transfer fields in compact indexed-address range.
F.Val               rmb       4                   arithmetic / sector operand
F.Move              rmb       2         ; reserve storage
F.Pos               rmb       4         ; reserve storage
F.Request           rmb       BR.Len    ; reserve storage
F.Info              rmb       BI.Len    ; reserve storage
F.Regs              rmb       2         ; reserve storage
F.Base              rmb       4         ; reserve storage
F.Span              rmb       4         ; reserve storage
F.Total             rmb       4         ; reserve storage
F.FatStart          rmb       4         ; reserve storage
F.DataStart         rmb       4         ; reserve storage
F.FatSize           rmb       4         ; reserve storage
F.MaxCluster        rmb       4                   last valid data cluster
F.Root              rmb       4         ; reserve storage
F.SPC               rmb       1         ; reserve storage
F.Shift             rmb       1         ; reserve storage
F.Fats              rmb       1         ; reserve storage
F.Active            rmb       1         ; reserve storage
* Each cache descriptor is a validity byte followed by its 32-bit LBA.
F.DataValid         rmb       1         ; reserve storage
F.DataLBA           rmb       4         ; reserve storage
F.FatValid          rmb       1         ; reserve storage
F.FatLBA            rmb       4         ; reserve storage
F.Start             rmb       4                   open object's first cluster
F.Size              rmb       4                   visible byte length
F.Entry             rmb       32                  original FAT directory entry
F.Temp              rmb       4         ; reserve storage
F.Cluster           rmb       4                   FAT chain operand
F.Walk              rmb       4                   cached file cluster
F.Hare              rmb       4                   cycle detector; zero after reaching EOC
F.WalkIndex         rmb       4         ; reserve storage
F.WalkValid         rmb       1         ; reserve storage
F.Offset            rmb       4                   logical byte offset for Locate
F.Target            rmb       4         ; reserve storage
F.Scan              rmb       4         ; reserve storage
F.Cursor            rmb       2         ; reserve storage
F.Name              rmb       11        ; reserve storage
F.Dots              rmb       1         ; reserve storage
F.Remain            rmb       2         ; reserve storage
F.Actual            rmb       2         ; reserve storage
F.Dest              rmb       2         ; reserve storage
F.Line              rmb       1         ; reserve storage
F.Stop              rmb       1         ; reserve storage
F.Cookie            rmb       4         ; reserve storage
F.NextPath          rmb       2         ; reserve storage
F.Owner             rmb       2         ; reserve storage
F.Registered        rmb       1         ; reserve storage
F.Creating          rmb       1         ; reserve storage
F.HasLFN            rmb       1         ; reserve storage
F.Mirror            rmb       1         ; reserve storage
F.DirLBA            rmb       4         ; reserve storage
F.DirOff            rmb       2         ; reserve storage
F.FSInfo            rmb       4         ; reserve storage
F.BackInfo          rmb       4         ; reserve storage
F.New               rmb       4         ; reserve storage
F.Link              rmb       4         ; reserve storage
F.Saved             rmb       4         ; reserve storage
F.Value             rmb       4         ; reserve storage
F.FatCopy           rmb       1         ; reserve storage
F.Zero              rmb       1         ; reserve storage
F.GapEnd            rmb       4         ; reserve storage
F.SavedPos          rmb       4         ; reserve storage
F.Wanted            rmb       4         ; reserve storage
F.HintDelta         rmb       1         ; reserve storage
F.Sectors           rmb       1         ; reserve storage
F.Time              rmb       6         ; reserve storage
F.Deleting          rmb       1                   internal open accepts either object type
F.Child             rmb       4                   unpublished directory cluster
F.Parent            rmb       4         ; containing directory cluster for child mutations
                  IFGT    .-256   ; conditional assembly
                    error     PCF field helper offsets exceed one byte
                  ENDC            ; conditional assembly
F.Path              rmb       256       ; reserve storage
F.Record            rmb       256       ; reserve storage
                  IFGT    .-$300  ; conditional assembly
                    error     FAT32 workspace overlaps sector buffers
                  ENDC            ; conditional assembly
                    org       $300      ; set storage origin
F.Data              rmb       512       ; reserve storage
F.Fat               rmb       512       ; reserve storage
F.Len               equ       .         1792 bytes per system path
