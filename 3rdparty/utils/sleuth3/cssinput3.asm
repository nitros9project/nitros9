
***************************************
**
gtype9              tst       os9flx,u            chk for OS/9 rmb/kill
                    bne       badrg
gtype               ldx       typee,u             get type and range
                    cmpx      alimit,u            chk for overflow
                    bhs       tabovf
                    sta       ,x+
                    bsr       gadrs               get range
                    bhi       badrg
                    lda       comand,u            chk for t
                    cmpa      #$54                check for a T
                    beq       gotyx
gotyp               lbsr      xinee               end of line
gotyx               ldx       eaddr,u             update pointer
                    clr       ,x+                 clear map locns
                    clr       ,x+
                    clr       ,x+
                    stx       typee,u
                    rts
**
tablab              lbsr      ende3               terminate disassembly
tabovf              lbsr      xcrlf               table overflow
                    leax      tabov,pcr
                    lbsr      xpdat
                    lbsr      stopin              reset get flag
                    lbsr      xcrlf
                    lbra      askin
**
badrg               lbsr      xcrlf               bad range
                    leax      invrg,pcr
                    lbsr      xpdat
                    lbsr      stopin              reset get flag
                    lbra      xcrlf
**
gadrs               stx       eaddr,u             get addr range
                    leax      lstar,pcr           print start=
                    lbsr      xpdat
                    lbsr      xbadr               read low limit
                    ldx       eaddr,u
                    ldd       baddr,u
                    std       ,x++
                    stx       eaddr,u
                    pshs      d
                    leax      lendr,pcr           print end=
                    lbsr      xpdat
                    lbsr      xbadr               read high limit
                    ldx       eaddr,u
                    ldd       baddr,u
                    std       ,x++
                    stx       eaddr,u
                    puls      d                   chk negative range
                    cmpd      -$02,x
                    rts
**
rdline              bsr       inbufr              get input line
rdlinx              lda       #$04                put eot after input
                    leax      -$01,y
                    sta       ,x
                    stx       raddr,u
                    rts
**
inbufr              tfr       x,y                 input buffer
                    lbsr      inbtty              set tty parameters
                    tfr       y,x
                    ldb       #fnmlen             was $1e
                    bra       inbuf1
inbufd              tfr       x,y                 input command
                    lbsr      inbtty              set tty parameters
                    tfr       y,x
                    ldb       #$fe
inbuf1              lbsr      xinee               drop leading spaces
                    cmpa      #$20
                    beq       inbuf1
                    bra       inbuf5
inbuf3              lbsr      xinee               scan test to cr
inbuf5              cmpa      #$0d
                    beq       inbufx
                    cmpa      #$03                chk for cntrl-c
                    beq       inbuf7
                    cmpa      #$20
                    blo       inbuf3
                    tstb
                    beq       inbuf3
                    sta       ,y+
                    decb
                    bra       inbuf3
inbuf7              tfr       x,y                 reset buffer
inbufx              clr       ,y+                 ending null
                    pshs      x
                    lbsr      inrtty              reset tty parameters
                    puls      x
                    lda       ,x
                    bne       inbufz
                    lda       #$0d                fake a cr
inbufz              rts
