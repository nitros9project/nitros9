********************************************************************
* Setime - Set Date/Time
*
* $Id$
*
* This is a Setime for use when a Y2K compliant system is required.
*
* This is somewhat of a cheat in that any attempts to do a full
* 4 digit conversion on the entered date string would have
* seriously broken the nice, generally compact codeing of the
* original setime module.  I didn't want to do that, so I cheated
* and simply added one more byte to the date packet image it builds
* on the stack.  Its conversion algorithm does 2 digits per pass/byte
* so if you enter 1998 (You MUST now enter the year as a 4 digit
* value!), this image will have a $13 as itas first and unused
* digit, if you enter a 20xx date, it will be a $14.
*
* I check this value after the rest of the conversion is all
* done, and if its $14 (or more), an extra 100 ($64) is added to the
* os9 year byte before the system F$STime call is made, pointing
* the F$STime call at only the normal 6 byte packet of time data.
*
* I've played with this maybe 20 minutes.  Hopefully you can use
* this into the next century without any further concerns about
* the "Y2K" problem.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*  10      ????/??/??  Gene Heskett
* Made Y2K compliant.
*
*  11      1999/05/07  Boisy G. Pitre
* Made totally compliant for 1900-2155.
*
*  12      2002/07/20  Boisy G. Pitre
* Typing a CR at the prompt no longer sets the time to a bogus value.

                    nam       Setime
                    ttl       Set Date/Time

* Disassembled 96/09/26 00:34:54 by Dsm v1.7 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       12

                    mod       eom,name,tylg,atrv,start,size

                    org       0
u0000               rmb       450
size                equ       .

name                fcs       /Setime/
                    fcb       10

L0014               fcb       C$LF
                    fcb       C$LF
                    fcb       C$BELL
                    fcc       "  >> No Clock module found <<"
                    fcb       C$LF
                    fcb       C$LF
L0036               fcb       C$LF
                    fcb       C$LF
                    fcb       C$BELL
                    fcc       "  >> Clock Initialization Errors <<"
                    fcb       C$LF
                    fcb       C$LF
L005E               fcb       C$LF
                    fcc       "       yyyy/mm/dd hh:mm:ss"
                    fcb       C$LF
                    fcc       "Time ? "
L005EL              equ       *-L005E

start               cmpd      #2
                    bcc       L00A3
                    leas      <-20,s
                    leax      >L005E,pcr
                    ldy       #L005EL
                    lda       #1
                    os9       I$WritLn
                    leax      ,s
                    lda       #C$CR
                    sta       ,x
                    ldy       #21
                    clra
                    os9       I$ReadLn

L00A3
* BGP: following lines added in case CR is pressed at prompt.  No need to set time
*      if there is nothing to process
GetNext             lda       ,x+                 +BGP+
                    cmpa      #C$CR               +BGP+
                    beq       L00DF               +BGP+
                    cmpa      #C$SPAC             +BGP+
                    beq       GetNext             +BGP+
                    cmpa      #C$COMA             +BGP+
                    beq       GetNext             +BGP+
                    leax      -1,x                +BGP+

* Make room for time packet on stack
                    leas      -7,s
                    bsr       L00E3
                    stb       ,s
                    bsr       L00E3
                    stb       $01,s
                    bsr       L00E3
                    stb       $02,s
                    bsr       L00E3
                    stb       $03,s
                    bsr       L00E3
                    stb       $04,s
                    bsr       L00E3
                    stb       $05,s
                    bsr       L00E3
                    stb       $06,s               now we have a 7 byte pkt
                    ldb       ,s                  get 1st 2 digits (century)
                    subb      #19                 subtract 19 from century +BGP+
                    lda       #100                now we will +BGP+
                    mul                           multiply difference * 100, now B holds 0, 100 or 200 +BGP+
                    addb      1,s                 add os9's year to century byte +BGP+
                    stb       1,s                 save back in year
                    leax      1,s
                    os9       F$STime
                    bcc       L00DF
                    cmpb      #$EA
                    bne       L00D2
                    leax      >L0014,pcr
                    ldy       #$0022
                    bra       L00DA
L00D2               leax      >L0036,pcr
                    ldy       #40
L00DA               lda       #1
                    os9       I$WritLn
L00DF               clrb
                    os9       F$Exit

L00E3               clrb
                    bsr       L0101
                    bsr       L0101
                    lda       ,x+
                    cmpa      #C$SPAC
                    beq       L0100
                    cmpa      #'/
                    beq       L0100
                    cmpa      #':
                    beq       L0100
                    cmpa      #C$COMA
                    beq       L0100
                    cmpa      #C$PERD
                    beq       L0100
                    leax      -1,x
L0100               rts

L0101               lda       ,x                  get a digit
                    suba      #$30                make it binary
                    bcs       L0114               not a number, go
                    cmpa      #$09
                    bhi       L0114               not a number, go
                    leax      $01,x               inc to next num
                    pshs      a                   save a
                    lda       #$0A                do a 10x
                    mul
                    addb      ,s+                 save result
L0114               rts                           all done

                    emod
eom                 equ       *
                    end
