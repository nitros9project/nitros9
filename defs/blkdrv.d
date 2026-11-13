* blkdrv ABI 1. All words/longwords are big endian; see docs/blkdrv.md.
BD.Version          equ       1
BD.Magic            equ       $4244     'BD'
BD.Init             equ       0
BD.Read             equ       3
BD.Write            equ       6
BD.Info             equ       9
BD.Flush            equ       12
BD.Term             equ       15
BH.Magic            equ       18
BH.Version          equ       20
BH.Size             equ       21
BH.Memory           equ       22
BH.Len              equ       24

                    org       0
BR.Size             rmb       1
BR.Version          rmb       1
BR.Unit             rmb       1
BR.Flags            rmb       1
BR.LBA              rmb       4
BR.Count            rmb       2
BR.Buffer           rmb       2
BR.Bytes            rmb       2
BR.Done             rmb       2
BR.Len              equ       .

                    org       0
BI.Size             rmb       1         caller initializes size/version
BI.Version          rmb       1
BI.Unit             rmb       1
BI.Flags            rmb       1
BI.BlockSize        rmb       2
BI.Last             rmb       4         inclusive last accessible LBA
BI.MaxCount         rmb       2
BI.Len              equ       .
BF.ReadOnly         equ       1
BF.Removable        equ       2
BF.Flush            equ       4         explicit completion supported

* Descriptor extension immediately after M$DTyp (not an RBF option table).
BT.Version          equ       M$DTyp+1
BT.Backend          equ       BT.Version+1 module-relative name offset
BT.Config           equ       BT.Backend+2
* Configuration is immutable for the lifetime of an attachment.
                    org       0
BC.Port             rmb       2
BC.Unit             rmb       1
BC.Flags            rmb       1         memory backend: BF.ReadOnly
BC.Ram              rmb       2         memory backend: system RAM address
BC.Blocks           rmb       2         memory backend: number of 512-byte blocks
BC.Base             rmb       4         memory backend: sparse window start LBA
BC.FailAfter        rmb       2         memory backend: $FFFF disables fault injection
BC.Len              equ       .

                    org       V.USER
BV.Module           rmb       2
BV.Entry            rmb       2
BV.State            rmb       2
BV.Alloc            rmb       2
BV.Config           rmb       BC.Len
BV.Lock             rmb       1
BV.Ready            rmb       1
BV.Info             rmb       BI.Len
BV.FMPaths          rmb       2         file-manager open-path list (opaque to driver)
BV.Len              equ       .
