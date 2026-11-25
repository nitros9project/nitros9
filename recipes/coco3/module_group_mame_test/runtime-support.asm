* Snapshot the real kernel without reserving a persistent mapping slot.
initmap             clra
                    leax      sysmap,u
initloop            clrb
                    exg       a,b
                    std       ,x++
                    exg       a,b
                    inca
                    cmpa      #8
                    blo       initloop
refreshmap          ldx       #D.SysDAT
                    leay      pointer,u
                    tfr       y,d
                    ldy       #2
                    lbsr      copysystem
                    ldx       pointer,u
                    leay      sysmap,u
                    tfr       y,d
                    ldy       #16
                    lbsr      copysystem
                    rts
* X=system address, Y=count, D=destination in this process.
copysystem          pshs      u,x
                    tfr       d,u
                    ldd       2,s
                    addd      #sysmap
                    puls      x
                    os9       F$CpyMem
                    puls      u
                    lbcs      fail
                    rts
* Signal 4/6 from child and 5/7 from parent. One message outstanding at a time.
intercept           stb       event,u
                    rti
waitsignal          sta       expected,u
                    ldd       #6000
                    std       waitleft,u
waitloop            lda       event,u
                    cmpa      expected,u
                    beq       waitdone
                    ldx       #1
                    os9       F$Sleep
                    ldd       waitleft,u
                    subd      #1
                    std       waitleft,u
                    bne       waitloop
                    lbra      bad
waitdone            clr       event,u
                    rts
notify              lda       peer,u
                    os9       F$Send
                    lbcs      fail
                    rts
unlinkheld          ldx       held,u
unlinkx             pshs      u
                    tfr       x,u
                    os9       F$UnLink
                    puls      u
                    lbcs      fail
                    rts
snapshot            sta       phase,u
                    lbsr      refreshmap
                    lda       role,u
                    sta       record,u
                    lda       phase,u
                    sta       record+1,u
                    lda       peer,u
                    sta       record+3,u
                    ldd       held,u
                    std       record+4,u
                    ldd       extra,u
                    std       record+6,u
                    ldd       sequence,u
                    std       record+8,u
                    ldd       #$4752
                    std       record+10,u
                    os9       F$ID
                    lbcs      fail
                    sta       record+2,u
                    leax      descriptor,u
                    os9       F$GPrDsc
                    lbcs      fail
                    ldx       #D.BlkMap
                    ldy       #2
                    leay      pointer,u
                    tfr       y,d
                    ldy       #2
                    lbsr      copysystem
                    ldx       pointer,u
                    leay      blockflags,u
                    tfr       y,d
                    ldy       #64
                    lbsr      copysystem
                    ldx       #D.PrcDBT
                    leay      pointer,u
                    tfr       y,d
                    ldy       #2
                    lbsr      copysystem
                    ldx       pointer,u
                    leay      processes,u
                    tfr       y,d
                    ldy       #256
                    lbsr      copysystem
                    ldx       #D.Tasks
                    leay      pointer,u
                    tfr       y,d
                    ldy       #2
                    lbsr      copysystem
                    ldx       pointer,u
                    leay      tasks,u
                    tfr       y,d
                    ldy       #32
                    lbsr      copysystem
* Count allocated 64-byte path descriptors, not cached path-table pages.
                    ldx       #D.PthDBT
                    leay      pointer,u
                    tfr       y,d
                    ldy       #2
                    lbsr      copysystem
                    ldx       pointer,u
                    leay      pathpages,u
                    tfr       y,d
                    ldy       #64
                    lbsr      copysystem
                    clra
                    clrb
                    std       activepaths,u
                    clr       pathindex,u
pathloop            leax      pathpages,u
                    ldb       pathindex,u
                    lda       b,x
                    beq       pathnext
                    clrb
                    tfr       d,x
                    leay      pathbuffer,u
                    tfr       y,d
                    ldy       #256
                    lbsr      copysystem
                    tst       pathindex,u
                    beq       skipbase
                    lda       pathbuffer,u
                    bsr       countpath
skipbase            equ       *
                    lda       pathbuffer+64,u
                    bsr       countpath
                    lda       pathbuffer+128,u
                    bsr       countpath
                    lda       pathbuffer+192,u
                    bsr       countpath
pathnext            inc       pathindex,u
                    lda       pathindex,u
                    cmpa      #64
                    blo       pathloop
                    lda       outpath,u
                    leax      record,u
                    ldy       #RecordSize
                    os9       I$Write
                    lbcs      fail
                    rts
countpath           tsta
                    beq       countdone
                    ldd       activepaths,u
                    addd      #1
                    std       activepaths,u
countdone           rts
bad                 ldb       #E$IllArg
fail                os9       F$Exit
