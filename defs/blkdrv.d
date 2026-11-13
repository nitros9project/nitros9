* blkdrv ABI 1. All words/longwords are big endian; see docs/blkdrv.md.
BD.Version          equ       1         ; define constant or offset
BD.Magic            equ       $4244     'BD'
BD.Init             equ       0         ; define constant or offset
BD.Read             equ       3         ; define constant or offset
BD.Write            equ       6         ; define constant or offset
BD.Info             equ       9         ; define constant or offset
BD.Flush            equ       12        ; define constant or offset
BD.Term             equ       15        ; define constant or offset
BH.Magic            equ       18        ; define constant or offset
BH.Version          equ       20        ; define constant or offset
BH.Size             equ       21        ; define constant or offset
BH.Memory           equ       22        ; define constant or offset
BH.Len              equ       24        ; define constant or offset

                    org       0         ; set storage origin
BR.Size             rmb       1         ; reserve storage
BR.Version          rmb       1         ; reserve storage
BR.Unit             rmb       1         ; reserve storage
BR.Flags            rmb       1         ; reserve storage
BR.LBA              rmb       4         ; reserve storage
BR.Count            rmb       2         ; reserve storage
BR.Buffer           rmb       2         ; reserve storage
BR.Bytes            rmb       2         ; reserve storage
BR.Done             rmb       2         ; reserve storage
BR.Len              equ       .         ; define constant or offset

                    org       0         ; set storage origin
BI.Size             rmb       1         caller initializes size/version
BI.Version          rmb       1         ; reserve storage
BI.Unit             rmb       1         ; reserve storage
BI.Flags            rmb       1         ; reserve storage
BI.BlockSize        rmb       2         ; reserve storage
BI.Last             rmb       4         inclusive last accessible LBA
BI.MaxCount         rmb       2         ; reserve storage
BI.Len              equ       .         ; define constant or offset
BF.ReadOnly         equ       1         ; define constant or offset
BF.Removable        equ       2         ; define constant or offset
BF.Flush            equ       4         explicit completion supported

* Descriptor extension immediately after M$DTyp (not an RBF option table).
BT.Version          equ       M$DTyp+1  ; define constant or offset
BT.Backend          equ       BT.Version+1 module-relative name offset  ; define constant or offset
BT.Config           equ       BT.Backend+2 ; define constant or offset
* Configuration is immutable for the lifetime of an attachment.
                    org       0         ; set storage origin
BC.Port             rmb       2         ; reserve storage
BC.Unit             rmb       1         ; reserve storage
BC.Flags            rmb       1         memory backend: BF.ReadOnly
BC.Ram              rmb       2         memory backend: system RAM address
BC.Blocks           rmb       2         memory backend: number of 512-byte blocks
BC.Base             rmb       4         memory backend: sparse window start LBA
BC.FailAfter        rmb       2         memory backend: $FFFF disables fault injection
BC.Len              equ       .         ; define constant or offset

                    org       V.USER    ; set storage origin
BV.Module           rmb       2         ; reserve storage
BV.Entry            rmb       2         ; reserve storage
BV.State            rmb       2         ; reserve storage
BV.Alloc            rmb       2         ; reserve storage
BV.Config           rmb       BC.Len    ; reserve storage
BV.Lock             rmb       1         ; reserve storage
BV.Ready            rmb       1         ; reserve storage
BV.Info             rmb       BI.Len    ; reserve storage
BV.FMPaths          rmb       2         file-manager open-path list (opaque to driver)
BV.Len              equ       .         ; define constant or offset
