********************************************************************
* co3hires - shared CoCo 3 application screen services
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/07/15  Codex
* Moved SS.AScrn, SS.DScrn, SS.PScrn, SS.FScrn, and the CoVDG form
* of SS.ScInf into a subroutine module shared by CoWin and CoVDG.

                    nam       co3hires
                    ttl       CoCo 3 application screen services

                  IFP1
                    use       defsfile
                    use       cocovtio.d
                  ENDC

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,entry,0

name                fcs       /co3hires/
                    fcb       edition

* Entry table. U is always the VTIO device static-memory pointer.
entry               lbra      Init                            initialize application-screen state
                    lbra      Term                            release all application screens
                    lbra      SetStat                         process an application-screen SetStat
                    lbra      Show                            display the selected application screen

Init                clr       >HRS.DGBuf,u                    select the driver's normal screen
                    leax      >HRS.HiRes,u                    point to the three screen descriptors
                    ldb       #9                              clear all three three-byte descriptors
InitLoop            clr       ,x+
                    decb
                    bne       InitLoop
                    rts

Term                pshs      y,x,d                           preserve the caller's working registers
                    clr       >HRS.DGBuf,u                    no application screen remains selected
                    leay      >HRS.HiRes,u                    point to the first screen descriptor
                    ldb       #3                              visit all three descriptors
                    pshs      b                               keep the descriptor count on the stack
TermLoop            tfr       y,x                             pass the current descriptor to FreeBlks
                    lbsr      FreeBlks                        release its high-RAM allocation, if any
                    leay      3,y                             advance to the next descriptor
                    dec       ,s                              count this descriptor
                    bne       TermLoop
                    leas      1,s                             discard the descriptor count
                    puls      pc,y,x,d                        restore registers and return

* Entry: A=SetStat code, Y=path descriptor, U=device static memory.
SetStat             ldx       PD.RGS,y                        get the caller's register stack
                    cmpa      #SS.ScInf                       CoVDG-compatible application-screen info
                    lbeq      Rt.ScInf
                    cmpa      #SS.DScrn                       display an allocated application screen
                    lbeq      Rt.DScrn
                    cmpa      #SS.PScrn                       change an allocated screen's type
                    lbeq      Rt.PScrn
                    cmpa      #SS.AScrn                       allocate and map an application screen
                    lbeq      Rt.AScrn
                    cmpa      #SS.FScrn                       free an allocated application screen
                    lbeq      Rt.FScrn
                    comb                                      reject unrelated SetStat calls
                    ldb       #E$UnkSvc
                    rts

* Display code and 8K-block count for application screen types 0-4.
DTabl               fcb       $14,$02                         640x192, 2 colors, 16K
                    fcb       $15,$02                         320x192, 4 colors, 16K
                    fcb       $16,$02                         160x192, 16 colors, 16K
                    fcb       $1D,$04                         640x192, 4 colors, 32K
                    fcb       $1E,$04                         320x192, 16 colors, 32K

* Allocate and map a high-resolution application screen.
Rt.AScrn            ldd       R$X,x                           get the requested screen type
                    cmpd      #$0004                          screen types 0-4 are supported
                    bhi       IllArg
                    pshs      y,x,d                           preserve path, register stack, and type
                    ldd       #$0303                          three descriptors, three bytes each
                    leay      >HRS.HiRes,u                    point to the descriptor table
                    lbsr      FindFree                        find an unused descriptor
                    bcs       AllocExit
                    sta       ,s                              save the one-based descriptor number
                    ldb       1,s                             recover the requested screen type
                    stb       HRS.SType,y                     save it in the descriptor
                    leax      >DTabl,pcr                      point to the screen type table
                    lslb                                      convert the type to a two-byte index
                    abx
                    ldb       1,x                             get the required block count
                    stb       HRS.NBlk,y                      save it in the descriptor
                    lda       #$FF                            begin with no rejected allocations
AllocRetry          inca                                      count the next allocation attempt
                    ldb       HRS.NBlk,y                      get the required block count
                    pshs      a                               preserve the rejected-allocation count
                    os9       F$AlHRAM                        allocate contiguous high RAM
                    puls      a
                    bcs       DeAll                           release rejected allocations on failure
                    pshs      b                               save the candidate starting block
                    andb      #$3F                            reduce it to its 512K-bank position
                    pshs      b
                    addb      HRS.NBlk,y                      include the last block in the range
                    decb
                    andb      #$3F                            detect a crossing of a 512K boundary
                    cmpb      ,s+
                    blo       AllocRetry                      reject candidates that cross the boundary
                    puls      b                               recover the accepted starting block
                    stb       ,y                              record it in the descriptor
                    bsr       DeMost                          release all rejected candidates
                    leas      a,s                             discard their saved block numbers
                    ldb       ,y                              recover the accepted starting block
                    lda       1,x                             recover its block count
                    lbsr      MapBlocks                       find or map the screen in the caller's address space
                    bcs       AllocExit
                    ldx       2,s                             recover the caller's register stack
                    std       R$X,x                           return the mapped address
                    ldb       ,s                              get the one-based descriptor number
                    clra
                    std       R$Y,x                           return the screen number
AllocExit           leas      2,s                             discard the saved screen type
                    puls      pc,y,x

IllArg              comb                                      report an invalid screen number or type
                    ldb       #E$IllArg
                    rts

DeAll               bsr       DeMost                          release every rejected allocation
                    bra       AllocExit

* Entry: A=count of rejected allocations, Y=accepted screen descriptor.
DeMost              tsta
                    beq       DeMostExit
                    ldb       HRS.NBlk,y                      get blocks per allocation
                    pshs      a                               save the rejected-allocation count
                    pshs      d,y,x                           preserve working registers
                    leay      9,s                             point to saved rejected block numbers
                    clra
DeMostLoop          ldb       ,y+                             get a rejected allocation's first block
                    tfr       d,x
                    ldb       1,s                             get its block count
                    pshs      a                               preserve the loop register
                    os9       F$DelRAM                        release the rejected allocation
                    puls      a
                    dec       ,s                              count it
                    bne       DeMostLoop
                    puls      d,y,x                           restore working registers
                    puls      a                               return the saved-byte count in A
DeMostExit          rts

* Return information about and optionally map an application screen.
Rt.ScInf            pshs      x                               preserve the caller's register stack
                    ldd       R$Y,x                           get unmap/map screen numbers
                    bmi       ScInfMap                        skip unmapping when the high byte is negative
                    bsr       GetInfo
                    bcs       ScInfExit
                    lbsr      UnmapBlocks                     unmap the requested screen
                    bcs       ScInfExit
ScInfMap            ldx       ,s                              recover the caller's register stack
                    ldb       R$Y+1,x                         get the screen number to map
                    bmi       ScInfDone                       negative means no mapping request
                    bsr       GetInfo
                    bcs       ScInfExit
                    lbsr      MapBlocks                       map the requested screen
                    bcs       ScInfExit
                    ldx       ,s
                    std       R$X,x                           return its mapped address
ScInfDone           clrb
ScInfExit           puls      pc,x

* Entry: B=screen number 1-3. Exit: A=block count, B=starting block.
GetInfo             beq       IllArg
                    cmpb      #3
                    bhi       IllArg
                    bsr       GetScrn
                    beq       IllArg
                    ldb       ,x
                    beq       IllArg
                    lda       1,x
                    andcc     #^Carry
                    rts

* Change an allocated application screen to a type requiring no more RAM.
Rt.PScrn            ldd       R$X,x                           get the requested screen type
                    cmpd      #$0004
                    bhi       IllArg
                    pshs      b,a                             save the type and a zero byte
                    leax      >DTabl,pcr
                    lslb
                    incb
                    lda       b,x                             get the new type's block count
                    sta       ,s
                    ldx       PD.RGS,y
                    ldd       R$Y,x                           screen zero has no application-screen type
                    lbeq      PScrnError
                    bsr       ValidateScreen                  find the requested screen descriptor
                    bcs       PScrnError
                    lda       ,s
                    cmpa      1,x                             ensure the allocated screen is large enough
                    bhi       PScrnError
                    lda       1,s
                    sta       2,x                             save the new screen type
                    leas      2,s
                    bra       SelectScreen                    redisplay it with the new type
PScrnError          leas      2,s
                    lbra      IllArg

ValidateScreen      ldd       R$Y,x                           get the requested screen number
                    beq       SelectScreen                    zero selects the driver's normal screen
                    cmpd      #$0003
                    lbgt      IllArg
                    bsr       GetScrn
                    lbeq      IllArg
                    clra
                    rts

Rt.DScrn            bsr       ValidateScreen                  validate the requested screen number
                    bcs       DisplayExit
SelectScreen        stb       >HRS.DGBuf,u                    select normal screen 0 or application screen 1-3
                    inc       <HRS.Chg,u                      ask VTIO to update the display hardware
                    clrb
DisplayExit         rts

* Point X at a one-based screen descriptor and set Z if it is unused.
GetScrn             leax      >HRS.HiRes,u                   point to the first screen descriptor
                    leax      -3,x                            make screen number 1 select the first descriptor
                    abx
                    abx
                    abx
                    tst       ,x
                    rts

Rt.FScrn            ldd       R$Y,x                           get the requested screen number
                    lbeq      IllArg
                    cmpd      #$0003
                    lbhi      IllArg
                    cmpb      >HRS.DGBuf,u                    refuse to free the displayed screen
                    lbeq      IllArg
                    bsr       GetScrn
                    lbeq      IllArg

* Entry: X=three-byte screen descriptor.
FreeBlks            lda       1,x                             get the screen's block count
                    ldb       ,x                              get its starting block
                    beq       FreeExit
                    pshs      a
                    clra
                    sta       ,x                              mark the descriptor unused
                    tfr       d,x
                    puls      b                               pass the block count in B
                    os9       F$DelRAM                        release the high-RAM allocation
FreeExit            rts

* Display the application screen selected in device static memory.
Show                ldb       >HRS.DGBuf,u                    get the selected screen number
                    cmpb      #3
                    bhi       ShowExit
                    bsr       GetScrn
                    beq       ShowExit
                    ldb       2,x                             get its screen type
                    cmpb      #4
                    bhi       ShowExit
                    lslb
                    pshs      x
                    leax      >DTabl,pcr
                    lda       b,x                             get the GIME display code
                    puls      x
                    clrb
                    std       >$FF99                          set resolution and border color
                    std       >D.VIDRS
                    lda       >D.HINIT
                    anda      #$7F                            select native CoCo 3 video mode
                    sta       >D.HINIT
                    sta       >$FF90
                    lda       >D.VIDMD
                    ora       #$80                            select graphics mode
                    anda      #$F8                            select one scanline per character row
                    sta       >D.VIDMD
                    sta       >$FF98
                    ldb       ,x                              get the first physical block
                    clra
                    lslb                                      convert the block to the GIME video offset
                    rola
                    lslb
                    rola
                    sta       >$FF9B
                    tfr       b,a
                    clrb
                    std       <D.VOFF1
                    std       >$FF9D
                    clr       >D.VOFF2
                    clr       >$FF9C
ShowExit            clrb
                    rts

* Find an unused descriptor. Entry: A=count, B=record size, Y=table.
FindFree            clr       ,-s                             initialize one-based descriptor number
                    inc       ,s
FindFreeLoop        tst       ,y
                    beq       FindFreeExit
                    leay      b,y
                    inc       ,s
                    deca
                    bne       FindFreeLoop
                    comb
                    ldb       #E$BMode
FindFreeExit        puls      pc,a

* Map A blocks beginning with physical block B into the current process.
MapBlocks           pshs      u,x,d
                    bsr       ScanBlocks                      are the blocks already mapped contiguously?
                    bcc       MapKnown
                    clra
                    ldb       1,s                             recover the starting physical block
                    tfr       d,x
                    ldb       ,s                              recover the block count
                    os9       F$MapBlk
                    stb       1,s                             preserve an error code
                    tfr       u,d                             return the logical address
                    bcs       MapError
MapKnown            leas      2,s                             discard saved D on success
                    puls      pc,u,x
MapError            puls      pc,u,x,d

* Remove A blocks beginning with physical block B from the process DAT image.
UnmapBlocks         pshs      y,x,a
                    bsr       ScanBlocks
                    bcs       UnmapExit
                    ldd       #DAT.Free
UnmapLoop           std       ,x++
                    dec       ,s
                    bne       UnmapLoop
UnmapExit           puls      pc,y,x,a

* Locate A contiguous physical blocks ending at B in the current DAT image.
ScanBlocks          equ       *
                  IFNE    H6309
                    pshs      a
                    lde       #8
                  ELSE
                    pshs      d
                    lda       #8
                    sta       1,s
                  ENDC
                    ldx       <D.Proc
                    leax      <P$DATImg+$10,x                 start at the end of the DAT image
                    clra
                    addb      ,s                              calculate the last physical block
                    decb
ScanFind            cmpd      ,--x
                    beq       ScanMatch
                  IFNE    H6309
                    dece
                  ELSE
                    dec       1,s
                  ENDC
                    bne       ScanFind
                    bra       ScanBad
ScanMatch           equ       *
                  IFNE    H6309
                    dece
                  ELSE
                    dec       1,s
                  ENDC
                    dec       ,s
                    beq       ScanFound
                    decb
                    cmpd      ,--x
                    beq       ScanMatch
                    bra       ScanBad
ScanFound           equ       *
                  IFNE    H6309
                    tfr       e,a
                  ELSE
                    lda       1,s
                  ENDC
                    lsla
                    lsla
                    lsla
                    lsla
                    lsla                                      convert the DAT slot to a logical address
                    clrb
                  IFNE    H6309
                    puls      b,pc
ScanBad             puls      a
                  ELSE
                    leas      2,s
                    rts
ScanBad             puls      d
                  ENDC
                    comb
                    ldb       #E$BPAddr
                    rts

                    emod
eom                 equ       *
                    end
