**************************************************
* System Call: F$GCMDir
*
* Notes:
* This system call is only used by OS9p1 to get rid of all
* the empty spaces in the module directory to keep it small
* and compact.
*
* Input:  X = Address of allocation bitmap
*         D = Number of first bit to set
*         Y = Bit count (number of bits to set)
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FGCMDir             ldx       <D.ModDir ; get pointer to module directory start
                    bra       FGcmdirEndModuleDirectory ; skip ahead
FGcmdirDATInitialized ldu       MD$MPDAT,x ; dAT initialized?
                    beq       FGcmdirEmptyEntry ; no it's empty skip ahead
                    leax      MD$ESize,x ; move to next entry
FGcmdirEndModuleDirectory cmpx      <D.ModEnd ; end of module directory?
                    bne       FGcmdirDATInitialized ; no, keep looking
                    bra       FGcmdirModuleDirectoryDATEnd ; branch unconditionally to FGcmdirModuleDirectoryDATEnd
* Move all entrys up 1 slot in directory
FGcmdirEmptyEntry   tfr       x,y       ; move empty entry pointer to Y
                    bra       FGcmdirEsize ; branch unconditionally to FGcmdirEsize
FGcmdirMpdat        ldu       MD$MPDAT,y ; load U from MD$MPDAT,y
                    bne       FGcmdirJoin ; branch if zero is clear to FGcmdirJoin
FGcmdirEsize        leay      MD$ESize,y ; compute MD$ESize,y into Y
                    cmpy      <D.ModEnd ; done complete directory?
                    bne       FGcmdirMpdat ; no, keep going
                    bra       FGcmdirNewModuleDirectoryEnd ; branch unconditionally to FGcmdirNewModuleDirectoryEnd
* Move entry up 1 slot in directory
FGcmdirJoin         equ       *         ; define assembler symbol FGcmdirJoin
                  IFNE    H6309   ; begin conditional assembly for H6309
                    ldw       #MD$ESize ; load W from #MD$ESize
                    tfm       y+,x+     ; transfer memory block using y+,x+
                  ELSE
                    ldu       ,y++      ; load U from ,y++
                    stu       ,x++      ; store U at ,x++
                    ldu       ,y++      ; load U from ,y++
                    stu       ,x++      ; store U at ,x++
                    ldu       ,y++      ; load U from ,y++
                    stu       ,x++      ; store U at ,x++
                    ldu       ,y++      ; load U from ,y++
                    stu       ,x++      ; store U at ,x++
                  ENDC
FGcmdirCompleteDirectory cmpy      <D.ModEnd ; done complete directory?
                    bne       FGcmdirMpdat ; no, keep going

FGcmdirNewModuleDirectoryEnd stx       <D.ModEnd ; save new module directory end pointer
* Shrink DAT table
FGcmdirModuleDirectoryDATEnd ldx       <D.ModDir+2 ; get module directory DAT end pointer
                    bra       FGcmdirBumpModuleDownBy ; branch unconditionally to FGcmdirBumpModuleDownBy

FGcmdirTarget       ldu       ,x        ; load U from ,x
                    beq       FGcmdirTarget2 ; branch if zero is set to FGcmdirTarget2
FGcmdirBumpModuleDownBy leax      -2,x      ; bump module ptr down by 2
                    cmpx      <D.ModDAT ; hit beginning yet?
                    bne       FGcmdirTarget ; no, keep checking
                    clrb                ; yes, return without error
                    rts                 ; return to caller

FGcmdirTarget2      ldu       -2,x      ; load U from -2,x
                    bne       FGcmdirBumpModuleDownBy ; branch if zero is clear to FGcmdirBumpModuleDownBy
                    tfr       x,y       ; transfer register value x,y
                    bra       FGcmdirTarget4 ; branch unconditionally to FGcmdirTarget4

FGcmdirTarget3      ldu       ,y        ; load U from ,y
                    bne       FGcmdirTarget5 ; branch if zero is clear to FGcmdirTarget5
FGcmdirTarget4      leay      -2,y      ; compute -2,y into Y
FGcmdirDmoddat      cmpy      <D.ModDAT ; compare Y with <D.ModDAT
                    bcc       FGcmdirTarget3 ; branch if carry is clear to FGcmdirTarget3
                    bra       FGcmdirDmoddat2 ; branch unconditionally to FGcmdirDmoddat2
FGcmdirTarget5      leay      2,y       ; compute 2,y into Y
                    ldu       ,y        ; load U from ,y
                    stu       ,x        ; store U at ,x
FGcmdirTarget6      ldu       ,--y      ; load U from ,--y
                    stu       ,--x      ; store U at ,--x
                    beq       FGcmdirTarget7 ; branch if zero is set to FGcmdirTarget7
                    cmpy      <D.ModDAT ; compare Y with <D.ModDAT
                    bne       FGcmdirTarget6 ; branch if zero is clear to FGcmdirTarget6

FGcmdirDmoddat2     stx       <D.ModDAT ; store X at <D.ModDAT
                    bsr       FGcmdirTarget8 ; call local routine FGcmdirTarget8
                    clrb                ; yes, return without error
                    rts                 ; return to caller

FGcmdirTarget7      leay      2,y       ; compute 2,y into Y
                    leax      2,x       ; compute 2,x into X
                    bsr       FGcmdirTarget8 ; call local routine FGcmdirTarget8
                    leay      -4,y      ; compute -4,y into Y
                    leax      -2,x      ; compute -2,x into X
                    bra       FGcmdirDmoddat ; branch unconditionally to FGcmdirDmoddat

* Update Module Dir Image Ptrs
FGcmdirTarget8      pshs      u         ; save u on the stack
                    ldu       <D.ModDir ; load U from <D.ModDir
                    bra       FGcmdirLastEntry ; branch unconditionally to FGcmdirLastEntry
FGcmdirSameDATPtrs  cmpy      MD$MPDAT,u ; same DAT ptrs?
                    bne       FGcmdirEntry ; no, skip
                    stx       MD$MPDAT,u ; else update ptrs
FGcmdirEntry        leau      MD$ESize,u ; next entry
FGcmdirLastEntry    cmpu      <D.ModEnd ; last entry?
                    bne       FGcmdirSameDATPtrs ; no
                    puls      u,pc      ; else yes... return
