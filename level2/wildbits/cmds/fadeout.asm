********************************************************************
* 
* 
* 
* 
* 
* 2026/05/29 fadeout clut by Matt Massie
* 
* 
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

         nam       fadeout
         ttl       fade out clut

         IFP1
         use       defsfile
         ENDC

tylg     set       Prgrm+Objct
atrv     set       ReEnt+rev
rev      set       $00
edition  set       1

         mod       eom,name,tylg,atrv,start,size

*---------------------------------------------------
* Variable Storage (in data area / direct page)
*---------------------------------------------------
mapaddr   rmb      2                 Mapped Address (2 bytes)
fadecount rmb      1                 Fade Step Counter
clutoff   rmb      2                 CLUT offset from mapaddr
cmdline   rmb      2                 saved command line pointer
noopts    rmb      1                 flag: 1 = no options given
          rmb      250               stack buffer
size      equ      .

name      fcs      /fadeout/
          fcb      edition

*---------------------------------------------------
* CLUT offset table
* Indexed by CLUT number 0-3
* Each entry is a 2 byte offset from mapaddr
*---------------------------------------------------
cluttbl
         fdb      $1000              CLUT 0 offset
         fdb      $1400              CLUT 1 offset
         fdb      $1800              CLUT 2 offset
         fdb      $1C00              CLUT 3 offset

*---------------------------------------------------
* Message strings
*---------------------------------------------------
msgnoopts
         fcc      /Fadeout -h  for help/
         fcb      $0D
msgnoopts_end equ *
msgnoopts_len equ msgnoopts_end-msgnoopts

msghelp1
         fcc      /Fadeout -0          Fades CLUT 0 - Default no options/
         fcb      $0D
msghelp1_end equ *
msghelp1_len equ msghelp1_end-msghelp1

msghelp2
         fcc      /                    Valid CLUTS 0-3/
         fcb      $0D
msghelp2_end equ *
msghelp2_len equ msghelp2_end-msghelp2

*---------------------------------------------------
* Map the CLUT page into process address space
*---------------------------------------------------
start
         stx       <cmdline          save command line ptr FIRST
         ldx       #$C1              page to map
         pshs      u                 preserve U
         ldb       #$01              need 1 block
         os9       F$MapBlk          map into process address space
         lbcs      exiterr@
         tfr       u,x               mapped address now in X
         puls      u                 restore U
         stx       <mapaddr          save mapped base address
         bra       cont@
exiterr@
         puls      u                 restore U
         lbra      err
cont@
*--- restore command line pointer into X for parsing ---
         ldx       <cmdline          X -> command line string
*--- Default to CLUT 0 offset ---
         ldd       #$1000            default CLUT 0 offset
         std       <clutoff          store default
*--- Set no-options flag, cleared if any option found ---
         lda       #1
         sta       <noopts           assume no options
*--- Scan command line for '-' option ---
scanloop@
         lda       ,x+               read char, advance X
         cmpa      #$0D              end of line?
         beq       chknoopts@        yes, check if no options given
         cmpa      #$2D              dash '-'? ($2D)
         beq       gotdash@          yes, read option char
         bra       scanloop@         no, keep scanning
gotdash@
         lda       ,x                read char after dash
         cmpa      #$0D              end of line?
         beq       chknoopts@        malformed, check noopts
*--- check for help option -h or -H ---
         cmpa      #$68              'h' ($68)?
         beq       dohelp@
         cmpa      #$48              'H' ($48)?
         beq       dohelp@
*--- check for CLUT digit ---
         cmpa      #$30              '0'?
         beq       clut0@
         cmpa      #$31              '1'?
         beq       clut1@
         cmpa      #$32              '2'?
         beq       clut2@
         cmpa      #$33              '3'?
         beq       clut3@
         bra       scanloop@         invalid, keep scanning
clut0@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1000
         std       <clutoff
         bra       startfade@
clut1@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1400
         std       <clutoff
         bra       startfade@
clut2@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1800
         std       <clutoff
         bra       startfade@
clut3@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1C00
         std       <clutoff
         bra       startfade@
*---------------------------------------------------
* Help requested - print help lines then exit
*---------------------------------------------------
dohelp@
         leax      msghelp1,pcr      X -> help line 1
         ldy       #msghelp1_len     length of line 1
         lda       #1                stdout path
         os9       I$Writln          print line 1
         leax      msghelp2,pcr      X -> help line 2
         ldy       #msghelp2_len     length of line 2
         lda       #1                stdout path
         os9       I$Write           print line 2
         lbra      doxit@
*---------------------------------------------------
* Check if no options were given, print hint if so
*---------------------------------------------------
chknoopts@
         lda       <noopts           was no-options flag set?
         beq       startfade@        no, options were given, proceed
*--- print hint message ---
         leax      msgnoopts,pcr     X -> no-options hint message
         ldy       #msgnoopts_len    length of message
         lda       #1                stdout path
         os9       I$Write           print hint
         bra       startfade@        proceed with default CLUT 0
startfade@
*---------------------------------------------------
* CLUT FADE OUT
*
* CLUT base  = mapaddr + clutoff
* Entry size = 4 bytes:  [Blue] [Green] [Red] [Alpha]
* 256 entries = $400 bytes total
*
* Outer loop : 32 fade steps
* Inner loop : 256 CLUT entries per step
* Per channel: new = old - 8  (linear), clamped to 0
*              giving 32 x 8 = 256 -> full black
*---------------------------------------------------
         lda       #32               32 fade steps
         sta       <fadecount
fadeloop
*--- Point X at start of selected CLUT table ---
         ldx       <mapaddr          base mapped address
         ldd       <clutoff          D = selected CLUT offset
         leax      d,x               X -> selected CLUT base
*--- B = entry counter (256 entries, wraps 255->0) ---
         ldb       #0
entryloop
         pshs      b                 preserve entry counter
*--- Blue (byte 0) ---
         lda       ,x                read Blue
         suba      #8                linear step down
         bcc       blue_ok@          no borrow = still positive
         clra                        clamp to zero
blue_ok@
         sta       ,x+               write Blue, X -> Green
*--- Green (byte 1) ---
         lda       ,x                read Green
         suba      #8
         bcc       green_ok@
         clra
green_ok@
         sta       ,x+               write Green, X -> Red
*--- Red (byte 2) ---
         lda       ,x                read Red
         suba      #8
         bcc       red_ok@
         clra
red_ok@
         sta       ,x+               write Red, X -> Alpha
*--- Skip Alpha (byte 3, unused) ---
         leax      1,x               step past Alpha
         puls      b                 restore entry counter
         incb                        next entry
         bne       entryloop         loop all 256 entries
*---------------------------------------------------
* Inter-step delay  (adjust $4000 to taste)
*---------------------------------------------------
         pshs      x                 preserve X
         ldx       #$4000            delay count
delayloop@
         leax      -1,x              decrement
         bne       delayloop@        loop until zero
         puls      x                 restore X
         dec       <fadecount        one less fade step
         bne       fadeloop          continue until done
*---------------------------------------------------
* Unmap the CLUT page - Free mapped block
*---------------------------------------------------
         ldu       <mapaddr          get mapped address
         ldx       #$C1              page to unmap
         ldb       #1                1 block
         os9       F$ClrBlk          remove from DAT image
         clrb
err
doxit@
         os9       F$Exit            exit program

         emod
eom      equ       *
         end
