********************************************************************
*
*
*
*
*
* 2026/05/29 fadein clut by Matt Massie
*
*
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

         nam       fadein
         ttl       fade in clut

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
clutptr   rmb      2                 Pointer to CLUT data in buffer
filepath  rmb      1                 File path descriptor
clutoff   rmb      2                 CLUT offset from mapaddr
cmdline   rmb      2                 Saved command line pointer
noopts    rmb      1                 flag: 1 = no options given
filenamebuf rmb    100               buffer for parsed filename
clutbuf   rmb      1312              header(14)+margin(32)+name(10)+CLUT(1024)+pad(232)
          rmb      250               stack buffer
size      equ      .

name      fcs      /fadein/
          fcb      edition

*---------------------------------------------------
* Default CLUT filename if none specified
*---------------------------------------------------
clutfile  fcs      !/dd/cmds/xtclut/!
          fcb      $0D               CR terminator

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
         fcc      /Fadein -h  for help/
         fcb      $0D
msgnoopts_end equ *
msgnoopts_len equ msgnoopts_end-msgnoopts

msghelp1
         fcc      "Fadein -0 /dd/cmds/xtclut       Fades In CLUT 0 /dd/cmds/xtclut with palette."
         fcb      $0D
msghelp1_end equ *
msghelp1_len equ msghelp1_end-msghelp1

msghelp2
         fcc      /                                Valid CLUTS 0-3/
         fcb      $0D
msghelp2_end equ *
msghelp2_len equ msghelp2_end-msghelp2

msghelp3
         fcc      "                                Full device path required /dd/cmds/xtclut"
         fcb      $0D
msghelp3_end equ *
msghelp3_len equ msghelp3_end-msghelp3

*---------------------------------------------------
* Map the CLUT page into process address space
* SAVE X FIRST - X points to command line on entry
*---------------------------------------------------
start
         stx       <cmdline          save command line ptr FIRST
         ldx       #$C1              page to map
         pshs      u                 preserve U
         ldb       #$01              need 1 block
         os9       F$MapBlk          map into process address space
         lbcs      exiterr
         tfr       u,x               mapped address now in X
         puls      u                 restore U
         stx       <mapaddr          save mapped base address
         bra       cont

exiterr
         puls      u                 restore U
         lbra      err

cont
*---------------------------------------------------
* Parse command line options
*
* Format:
*   fadein$0D                    default CLUT 0, default filename
*   fadein -h$0D                 print help and exit
*   fadein -H$0D                 print help and exit
*   fadein -2$0D                 CLUT 2, default filename
*   fadein -2 /dd/sys/myfile$0D  CLUT 2, specified filename
*   fadein /dd/sys/myfile$0D     CLUT 0, specified filename
*
* Scan for:
*   '-' followed by h/H -> help
*   '-' followed by '0'-'3' -> CLUT selection
*   '/' -> start of filename
* If no CLUT option default to CLUT 0 ($1000)
* If no filename default to clutfile label
*---------------------------------------------------
*--- Set defaults ---
         ldd       #$1000            default CLUT 0 offset
         std       <clutoff          store default
*--- Set no-options flag, cleared if any option found ---
         lda       #1
         sta       <noopts           assume no options
*--- Copy default filename into filenamebuf ---
         leax      clutfile,pcr      X -> default filename
         leay      <filenamebuf,u    Y -> filename buffer
cpydefault@
         lda       ,x+               read default filename char
         sta       ,y+               copy to buffer
         cmpa      #$0D              CR terminator?
         bne       cpydefault@       no, keep copying
*--- Restore command line pointer ---
         ldx       <cmdline          X -> command line
*--- Scan command line ---
scanloop@
         lda       ,x+               read char, advance X
         cmpa      #$0D              end of line?
         lbeq      chknoopts@        yes, check if no options given
         cmpa      #$2D              dash '-'? ($2D)
         beq       gotdash@          yes, option follows
         cmpa      #$2F              slash '/'? ($2F) start of filename
         beq       gotfile@          yes, filename follows
         bra       scanloop@         no, keep scanning
gotdash@
*--- Read char after dash ---
         lda       ,x                read next char (don't advance)
         cmpa      #$0D              end of line?
         lbeq      chknoopts@        malformed, check noopts
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
         leax      1,x               skip digit
         bra       scanloop@         continue scanning for filename
clut1@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1400
         std       <clutoff
         leax      1,x               skip digit
         bra       scanloop@         continue scanning for filename
clut2@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1800
         std       <clutoff
         leax      1,x               skip digit
         bra       scanloop@         continue scanning for filename
clut3@
         lda       #0
         sta       <noopts           clear no-options flag
         ldd       #$1C00
         std       <clutoff
         leax      1,x               skip digit
         bra       scanloop@         continue scanning for filename
gotfile@
*--- Copy filename from command line into filenamebuf ---
*    back up one to include the '/' in the path
         lda       #0
         sta       <noopts           clear no-options flag
         leax      -1,x              back up to include '/'
         leay      <filenamebuf,u    Y -> filename buffer
cpyfile@
         lda       ,x+               read filename char
         sta       ,y+               copy to buffer
         cmpa      #$0D              CR terminator?
         bne       cpyfile@          no, keep copying
         bra       startfade@        done parsing
*---------------------------------------------------
* Help requested - print help lines then exit
*---------------------------------------------------
dohelp@
         leax      msghelp1,pcr      X -> help line 1
         ldy       #msghelp1_len     length of line 1
         lda       #1                stdout path
         os9       I$Writln          print line 1 with newline
         leax      msghelp2,pcr      X -> help line 2
         ldy       #msghelp2_len     length of line 2
         lda       #1                stdout path
         os9       I$Writln          print line 2 with newline
         leax      msghelp3,pcr      X -> help line 3
         ldy       #msghelp3_len     length of line 3
         lda       #1                stdout path
         os9       I$Writln          print line 3 with newline
         lbra      doxit
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
         os9       I$Writln          print hint with newline
         bra       startfade@        proceed with defaults
startfade@
*---------------------------------------------------
* Zero out the CLUT table in hardware
* Write $00 to all 256 entries (B,G,R,A = 0)
* so screen starts black before fade begins
*---------------------------------------------------
         ldx       <mapaddr          base mapped address
         ldd       <clutoff          D = selected CLUT offset
         leax      d,x               point to selected CLUT base
         lda       #$00              zero value
         ldy       #$0400            $400 bytes = 256 entries x 4
zeroclut@
         sta       ,x+               zero byte
         leay      -1,y              decrement count
         bne       zeroclut@         until all zeroed

*---------------------------------------------------
* Open the CLUT file for reading
* filenamebuf holds either parsed or default filename
*---------------------------------------------------
         leax      <filenamebuf,u    point X to filename buffer
         lda       #READ.            read-only access mode
         os9       I$Open            open the file
         lbcs      err               branch if open failed
         sta       <filepath         save path descriptor

*---------------------------------------------------
* Read module into clutbuf
* I$Read: A = path, X -> buffer, Y = byte count
*---------------------------------------------------
         lda       <filepath         path descriptor
         leax      <clutbuf,u        point to our buffer
         ldy       #1312             full buffer size
         os9       I$Read            read module data
         lbcs      closeerr          branch if read failed

*---------------------------------------------------
* Close the file - done reading
*---------------------------------------------------
         lda       <filepath
         os9       I$Close

*---------------------------------------------------
* Parse OS-9 module header to find CLUT data
*
* Module header:
*   $00-$01  Sync bytes  ($87CD)
*   $02-$03  Module size
*   $04-$05  Name offset  <- offset from module start to name
*
* OS-9 name terminates with bit 7 set on last character
* CLUT data starts immediately after that byte
*---------------------------------------------------
         leax      <clutbuf,u        X -> module base in buffer
*--- Read name offset word from header bytes 4-5 ---
         ldd       4,x               D = name offset (big endian word)
*--- Jump to name string using offset ---
         leax      <clutbuf,u        reset X to module base
         leax      d,x               X -> first byte of name string
*--- Scan past OS-9 name string ---
*    OS-9 names terminate with bit 7 set on last character
skipname@
         lda       ,x+               read byte, advance X
         bpl       skipname@         bit 7 clear, not done yet
                                     * bit 7 set, X now -> first CLUT byte
*--- Save pointer to CLUT data ---
         stx       <clutptr          save CLUT data start pointer

*---------------------------------------------------
* CLUT FADE IN
*
* clutptr  = pointer to CLUT data (past module header+name)
* Hardware CLUT is currently all zeros (black)
*
* Outer loop : 32 fade steps
* Inner loop : 256 CLUT entries per step
* Per channel: current += (target >> 5) each step
*              linear ramp from 0 -> target value
* Final step : write target values directly to
*              guarantee exact color match regardless
*              of integer rounding in step calculation
* BGRA format: byte0=Blue byte1=Green byte2=Red byte3=Alpha
*---------------------------------------------------
         lda       #32               32 fade steps
         sta       <fadecount
fadeloop
*--- Point X at hardware CLUT table ---
         ldx       <mapaddr
         ldd       <clutoff          D = selected CLUT offset
         leax      d,x               point to selected CLUT base in hardware
*--- Y points to target CLUT data (past header and name) ---
         ldy       <clutptr          Y -> first target CLUT entry
*--- B = entry counter (256 entries, wraps 255->0) ---
         ldb       #0
*--- Check if this is the final fade step ---
         lda       <fadecount
         cmpa      #1                is this the last step?
         beq       finalstep         yes, write target values directly

*---------------------------------------------------
* Normal fade step - ramp toward target
*---------------------------------------------------
entryloop
         pshs      b                 preserve entry counter
*--- Blue (byte 0) ---
         lda       ,y                read target Blue
         lsra                        divide by 32 (5 right shifts)
         lsra
         lsra
         lsra
         lsra
         pshs      a                 save step value
         lda       ,x                read current hw Blue
         adda      ,s+               add step (and pop)
         cmpa      ,y                clamp: dont exceed target
         bls       blue_ok
         lda       ,y                clamp to target
blue_ok
         sta       ,x+               write Blue, advance hw ptr
*--- Green (byte 1) ---
         lda       1,y               read target Green
         lsra
         lsra
         lsra
         lsra
         lsra
         pshs      a
         lda       ,x
         adda      ,s+
         cmpa      1,y
         bls       green_ok
         lda       1,y
green_ok
         sta       ,x+               write Green, advance hw ptr
*--- Red (byte 2) ---
         lda       2,y               read target Red
         lsra
         lsra
         lsra
         lsra
         lsra
         pshs      a
         lda       ,x
         adda      ,s+
         cmpa      2,y
         bls       red_ok
         lda       2,y
red_ok
         sta       ,x+               write Red, advance hw ptr
*--- Skip Alpha (byte 3, unused) ---
         leax      1,x               skip hw Alpha
         leay      4,y               advance target buffer to next entry
         puls      b                 restore entry counter
         incb                        next entry
         bne       entryloop         loop all 256 entries
         bra       delaystep         do delay then continue

*---------------------------------------------------
* Final step - write target values directly
* guarantees exact color match regardless of
* integer rounding in step calculation
*---------------------------------------------------
finalstep
         pshs      b                 preserve entry counter
*--- Blue ---
         lda       ,y                read target Blue
         sta       ,x+               write directly, advance hw ptr
*--- Green ---
         lda       1,y               read target Green
         sta       ,x+               write directly, advance hw ptr
*--- Red ---
         lda       2,y               read target Red
         sta       ,x+               write directly, advance hw ptr
*--- Skip Alpha ---
         leax      1,x               skip hw Alpha
         leay      4,y               advance target buffer to next entry
         puls      b                 restore entry counter
         incb                        next entry
         bne       finalstep         loop all 256 entries

*---------------------------------------------------
* Inter-step delay
*---------------------------------------------------
delaystep
         pshs      x,y               preserve pointers
         ldx       #$4000            delay count
delayloop@
         leax      -1,x
         bne       delayloop@
         puls      x,y               restore pointers
         dec       <fadecount        one less fade step
         lbne      fadeloop          continue until done

*---------------------------------------------------
* Unmap the CLUT page - Free mapped block
*---------------------------------------------------
         ldu       <mapaddr          get mapped address
         ldx       #$C1              page to unmap
         ldb       #1                1 block
         os9       F$ClrBlk          remove from DAT image
         clrb
err
doxit
         os9       F$Exit            exit program

*---------------------------------------------------
* Close file then exit on read error
*---------------------------------------------------
closeerr
         pshs      b                 preserve error code
         lda       <filepath
         os9       I$Close
         puls      b                 restore error code
         bra       err

         emod
eom      equ       *
         end
