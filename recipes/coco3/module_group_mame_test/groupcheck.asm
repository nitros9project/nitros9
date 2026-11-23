* Exercise two distinct modules sharing a loaded file, using the real kernel.
                    use       defsfile
                    mod       eom,name,Prgrm+Objct,ReEnt+1,start,size
                    org       0
outpath             rmb       1
caseid              rmb       1
reverse             rmb       1
whichgroup          rmb       1
modulea             rmb       2
moduleb             rmb       2
entrya              rmb       2
entryb              rmb       2
physicalmap         rmb       16
record              rmb       8
descriptor          rmb       P$Size
blockflags          rmb       64
                    rmb       256
size                equ       .
name                fcs       /GroupCheck/
                    fcb       1
reportname          fcc       "/dd/group.report"
                    fcb       C$CR
shortfile           fcc       "/dd/short.grp"
                    fcb       C$CR
longfile            fcc       "/dd/long.grp"
                    fcb       C$CR
shortb              fcs       /ShortB/
longb               fcs       /LongB/
residenta           fcs       /ResidentA/
residentb           fcs       /ResidentB/
passed              fcc       /MODULEGROUPPASS/
                    fcb       C$CR
start               leax      reportname,pcr
                    lda       #WRITE.
                    ldb       #READ.+WRITE.
                    os9       I$Create
                    lbcs      fail
                    sta       outpath,u
                    clr       caseid,u
                    clr       whichgroup,u
                    clra
                    leax      physicalmap,u
maploop             clrb
                    exg       a,b
                    std       ,x++
                    exg       a,b
                    inca
                    cmpa      #8
                    blo       maploop
nextgroup           clr       reverse,u
nextcase            inc       caseid,u
                    lda       whichgroup,u
                    beq       loadshort
                    cmpa      #1
                    beq       loadlong
                    leax      residenta,pcr
                    clra
                    pshs      u
                    os9       F$Link
                    bra       saveload
loadshort           leax      shortfile,pcr
                    bra       loadfile
loadlong            leax      longfile,pcr
loadfile            clra
                    pshs      u
                    os9       F$Load
                    bra       saveload
saveload            tfr       u,x
                    puls      u
storea              lbcs      fail
                    stx       modulea,u
                    sty       entrya,u
                    lda       whichgroup,u
                    beq       linkshortb
                    cmpa      #1
                    beq       linklongb
                    leax      residentb,pcr
                    bra       linkb
linkshortb          leax      shortb,pcr
                    bra       linkb
linklongb           leax      longb,pcr
linkb               clra
                    pshs      u
                    os9       F$Link
                    tfr       u,x
                    puls      u
                    lbcs      fail
                    stx       moduleb,u
                    sty       entryb,u
                    jsr       [entrya,u]
                    cmpb      #$A1
                    lbne      bad
                    jsr       [entryb,u]
                    cmpb      #$A2
                    lbne      bad
                    lda       #0
                    lbsr      snapshot
                    tst       reverse,u
                    bne       bfirst
                    ldx       modulea,u
                    lbsr      unlink
                    jsr       [entryb,u]
                    cmpb      #$A2
                    lbne      bad
                    bra       firstdone
bfirst              ldx       moduleb,u
                    lbsr      unlink
                    jsr       [entrya,u]
                    cmpb      #$A1
                    lbne      bad
firstdone           lda       #1
                    lbsr      snapshot
                    tst       reverse,u
                    bne       alast
                    ldx       moduleb,u
                    bra       last
alast               ldx       modulea,u
last                lbsr      unlink
                    lda       #2
                    lbsr      snapshot
                    tst       reverse,u
                    bne       groupdone
                    inc       reverse,u
                    lbra      nextcase
groupdone           inc       whichgroup,u
                    lda       whichgroup,u
                    cmpa      #3
                    lblo      nextgroup
                    lda       outpath,u
                    os9       I$Close
                    lbcs      fail
                    leax      passed,pcr
                    ldy       #16
                    lda       #1
                    os9       I$WritLn
                    lbcs      fail
                    clrb
                    os9       F$Exit
unlink              pshs      u
                    tfr       x,u
                    os9       F$UnLink
                    puls      u
                    lbcs      fail
                    rts
snapshot            sta       record+1,u
                    lda       caseid,u
                    sta       record,u
                    ldd       modulea,u
                    std       record+2,u
                    ldd       moduleb,u
                    std       record+4,u
                    ldd       #$4752
                    std       record+6,u
                    os9       F$ID
                    lbcs      fail
                    leax      descriptor,u
                    os9       F$GPrDsc
                    lbcs      fail
* Copy the system block-map pointer and flags without consuming an MMU slot.
                    leax      physicalmap,u
                    tfr       x,d
                    ldx       #D.BlkMap
                    ldy       #2
                    pshs      u
                    leau      blockflags,u
                    os9       F$CpyMem
                    puls      u
                    lbcs      fail
                    ldx       blockflags,u
                    pshs      x
                    leax      physicalmap,u
                    tfr       x,d
                    puls      x
                    ldy       #64
                    pshs      u
                    leau      blockflags,u
                    os9       F$CpyMem
                    puls      u
                    lbcs      fail
                    lda       outpath,u
                    leax      record,u
                    ldy       #8+P$Size+64
                    os9       I$Write
                    lbcs      fail
                    rts
bad                 ldb       #E$IllArg
fail                os9       F$Exit
                    emod
eom                 equ       *
