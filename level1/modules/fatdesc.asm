* FAT32/blkdrv descriptor template. Explicit partition offset and length.
                    use       defsfile  ; include shared definitions or implementation
                    use       blkdrv.d  ; include shared definitions or implementation
                    use       pcf.d     ; include shared definitions or implementation
                    ifndef    FATBase   ; conditional assembly
FATBase             equ       0         ; define constant or offset
                  ENDC            ; conditional assembly
                    ifndef    FATLength ; conditional assembly
FATLength           equ       0         ; define constant or offset
                  ENDC            ; conditional assembly
                    ifndef    FATPort   ; conditional assembly
FATPort             equ       $FE90     ; define constant or offset
                  ENDC            ; conditional assembly
                    mod       eom,name,Devic+Objct,ReEnt+1,manager,driver ; emit OS-9 module header
                  IFNE    FATWrite ; conditional assembly
                    fcb       $87                 directory/read/write/execute
                  ELSE            ; conditional assembly
                    fcb       $85                 directory/read/execute only
                  ENDC            ; conditional assembly
                    fcb       0                   port extension
                    fdb       FATPort   ; emit word data
                    fcb       1                   only DTP copied to PD.OPT
                    fcb       DT.PCF    ; emit byte data
                    fcb       BD.Version ; emit byte data
                    fdb       backend   ; emit word data
                    fdb       FATPort             BC.Port
                    fcb       0                   unit
                  IFNE    FATWrite ; conditional assembly
                    fcb       0                   writable backend
                  ELSE            ; conditional assembly
                    fcb       BF.ReadOnly ; emit byte data
                  ENDC            ; conditional assembly
                    fdb       0,0                 RAM base, blocks (unused)
                  IFNE    FATVHD  ; conditional assembly
                  IFNE    FATLength explicit partition end
                    fdb       (FATBase+FATLength-1)/65536,(FATBase+FATLength-1)&$FFFF ; emit word data
                  ELSE            ; conditional assembly
                    fdb       $007F,$FFFF VHD hardware remainder (4 GiB ceiling)
                  ENDC            ; conditional assembly
                  ELSE            ; conditional assembly
                    fdb       0,0                 RAM sparse base (unused)
                  ENDC            ; conditional assembly
                    fdb       $FFFF               failure injection disabled
                    fdb       FATBase/65536,FATBase&$FFFF ; emit word data
                    fdb       FATLength/65536,FATLength&$FFFF ; emit word data
name
                  IFNE    DD      ; conditional assembly
                    fcs       /dd/                ; module name or literal text
                  ELSE            ; conditional assembly
                    fcs       /pc0/               ; module name or literal text
                  ENDC            ; conditional assembly
manager             fcs       /pcf/               ; module name or literal text
driver              fcs       /blkdrv/            ; module name or literal text
backend
                  IFNE    FATVHD  ; conditional assembly
                    fcs       /llcocovhd/         ; module name or literal text
                  ELSE            ; conditional assembly
                    fcs       /llwbsdblk/         ; module name or literal text
                  ENDC            ; conditional assembly
                    emod      ;         finish module and CRC
eom                 equ       *         ; define constant or offset
                    end       ;         end assembly source
