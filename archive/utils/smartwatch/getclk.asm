                    nam       getclk
                    ttl       program module

* Disassembled 98/06/01 09:08:21 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

* MPI slot selection code
* $33 = Slot 4
* $22 = Slot 3
* $11 = Slot 2
* $00 = Slot 1
MPISlot             equ       $33

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $02

                    mod       eom,name,tylg,atrv,start,size

SWSubr              rmb       202
ROMAddr             rmb       2
Blk0Addr            rmb       2
u00CE               rmb       1
TmpSecs             rmb       1
NumSecs             rmb       1
TimePckt            rmb       6
                    rmb       200

size                equ       .

name                fcs       /getclk/
                    fcb       $02

start               equ       *
                    clr       <u00CE
                    cmpd      #$0002
                    bcs       L003F
                    com       <u00CE
                    ldd       ,x
                    cmpb      #$0D
                    beq       ProcParm
                    subd      #$2F30
L0027               suba      #$01
                    beq       L0037
                    addb      #$0A
                    bra       L0027

* process parameter
ProcParm            suba      #$30
                    cmpa      #$09
                    bcc       L0093
                    tfr       a,b
L0037               cmpb      #$3C
                    bcc       L0093
                    stb       <TmpSecs
                    stb       <NumSecs

L003F               leax      ,u
                    leay      >L0098,pcr
                    ldb       #$88
L0047               lda       ,y+
                    sta       ,x+
                    decb
                    bne       L0047
L004E               pshs      u
                    ldx       #$003E              X holds ROM block
                    incb                          set B to 1
                    os9       F$MapBlk            map into our addr space
                    leax      ,u                  set X to address of ROM block
                    stx       <ROMAddr            save X
                    ldx       #$0000              get block zero (OS-9 globs, etc)
                    os9       F$MapBlk            map into our address space
                    leax      ,u                  point X to U
                    stx       <Blk0Addr           save X
                    puls      u
                    jsr       <SWSubr
                    pshs      u
                    ldb       #1
                    ldu       <ROMAddr
                    os9       F$ClrBlk            clear this block from our space
                    ldu       <Blk0Addr
                    os9       F$ClrBlk            clear this block from our space
                    puls      u
                    os9       F$STime
                    bcs       L0095
                    clrb
                    tst       <u00CE
                    beq       L0095
L0083               ldx       #$0DD0
                    os9       F$Sleep
                    dec       <TmpSecs
                    bne       L0083
                    lda       <NumSecs
                    sta       <TmpSecs
                    bra       L004E
L0093               ldb       #E$IllArg
L0095               os9       F$Exit

* Exit:
*   X  = address of time packet with time from SW
L0098               pshs      cc
                    orcc      #FIRQMask+IRQMask
                    lda       $FF7F
                    ldb       >D.HINIT,x          get GIME INT0 value in OS-9 globs
                    ldx       <ROMAddr            point X to rom block address
                    pshs      b,a                 save GIME INT0 value/MPI slot
                    lda       #MPISlot            get slot where SW is
                    sta       $FF7F               select it
                    andb      #$FC                16x16 ROM
                    stb       >$FF90              save it in HW
                    leay      >L0117,pcr
                    sta       >$FFDE              put CC3 in ROM mode
                    lda       $04,x               read ROM block (trigger SW?)
L00BA               ldb       #$08
                    lda       ,y+
                    beq       L00CD
L00C0               lsra
                    bcs       L00C6
                    tst       ,x
                    fcb       $8C
L00C6               fdb       $6D01
                    decb
                    beq       L00BA
                    bra       L00C0
L00CD               lda       #$08
L00CF               ldb       #$08
                    pshs      b,a
L00D3               ldb       4,x
                    lsrb
                    rora
                    dec       1,s                 dec count (B) on stack
                    bne       L00D3
                    bsr       L0107
                    stb       1,s
                    puls      a
                    deca
                    bne       L00CF
                    sta       >$FFDF              put in ALL RAM Mode
                    leax      >TimePckt,u
                    ldd       ,s                  get year/Month
                    std       ,x                  save year/month
                    lda       2,s                 get day
                    sta       2,x                 save day
                    ldd       4,s                 get hour/min
                    std       3,x                 save hour/min
                    lda       6,s                 get seconds
                    sta       5,x                 save seconds
                    leas      8,s                 clean stack
                    puls      b,a                 get GIME INT0, org MPI slot
                    sta       >$FF7F              restore org MPI slot
                    stb       >$FF90              restore org GIME INT0
                    puls      pc,cc

L0107               clrb
L0108               cmpa      #$10
                    bcs       L0112
                    suba      #$10
                    addb      #$0A
                    bra       L0108
L0112               pshs      a
                    addb      ,s+
                    rts

L0117               fcb       $C5,$3A,$A3,$5C
                    fcb       $C5,$3A,$A3,$5C
                    fcb       $00

                    emod
eom                 equ       *
                    end
