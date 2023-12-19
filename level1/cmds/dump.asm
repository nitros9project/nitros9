********************************************************************
* Dump - Show file contents in hex
*
* $Id$
*
* Dump follows the function of the original Microware version but now
* supports large files over 64K, and is free from the problems of garbage
* in wide listings.
*
* In addition it now allows dumping of memory modules and command modules
* in the execution directory.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      ????/??/??
* From Tandy OS-9 Level One VR 02.00.00.
*
*   6      2002/12/23  Boisy G. Pitre
* Incorporated R. Telkman's additions from 1987, added -d option,
* added defs to conditionally assemble without help or screen size check.
*
*          2003/01/17  Boisy G. Pitre
* Removed -d option.
*
*          2003/01/21  Boisy G. Pitre
* Narrow screen now shows properly, only dumps 16 bits worth of address
* data to make room.
*
*          2003/03/03  Boisy G. Pitre
* Fixed bug where header would be shown even if there was no data in a file.
*
*   7      2003/06/06  Rodney V. Hamilton
* Restored Rubout processing for terminals.
*
*   8      2022/11/21-27  L. Curtis Boyle
* Fixed bug where it will not allow filenames with '-' chars in them to open
* Also shrunk option parsing code & more fully commented source

                    nam       Dump
                    ttl       Show file contents in hex

                    ifp1
                    use       defsfile
                    endc

* Tweakable options
DOSCSIZ             set       1                   1 = include SS.ScSiz code, 0 = leave out
DOHELP              set       0                   1 = include help message, 0 = leave out
BUFSZ               set       80                  (max 127)

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       1
edition             set       8

                    org       0
nonopts             rmb       1                   0=No file/module names found, <>0=at least 1 file/module name found
D.Prm               rmb       2                   Ptr to parameters we were passed (filename(s), options)
D.Hdr               rmb       1                   0=print header line, <>0=do NOT print header line
D.Mem               rmb       1                   0=dump from file on disk, <>0=dump from file in Module directory (RAM)
                    IFNE      DOSCSIZ
narrow              rmb       1                   0=80 column, <>0=32 column
                    ENDC
Mode                rmb       1                   I$Open Mode bit flags (READ. or READ.+EXEC.)
D.Opn               rmb       1
D.Beg               rmb       2                   Ptr to start of module in memory (if doing -m)
D.End               rmb       2                   Ptr to end of module in memory (if doing -m)
AddrMSW             rmb       2                   MSW of 32 bit Address in file
AddrLSW             rmb       2                   LSW of 32 bit Address in file
D.Len               rmb       2
HexPtr              rmb       2                   Ptr to current position in TxtBuf for HEX chars
ASCIIPtr            rmb       2                   Ptr to current position in TxtBuf for ASCII chars
Datbuf              rmb       16
Txtbuf              rmb       BUFSZ               text buffer to build output lines in
                    rmb       128
datsz               equ       .

                    mod       length,name,tylg,atrv,start,datsz

name                fcs       /Dump/
                    fcb       edition

* 80 column header
title               fcc       /Address   0 1  2 3  4 5  6 7  8 9  A B  C D  E F  0 2 4 6 8 A C E/
titlelen            equ       *-title

caret               fcb       C$CR
flund               fcc       /-------- ---- ---- ---- ---- ---- ---- ---- ----  ----------------/
                    fcb       C$CR
                    IFNE      DOSCSIZ
* 32 column header
short               fcc       /     0 1 2 3 4 5 6 7  0 2 4 6/
                    fcb       C$LF
                    fcc       /Addr 8 9 A B C D E F  8 A C E/
                    fcb       C$CR
shund               fcc       /==== +-+-+-+-+-+-+-+- +-+-+-+-/
                    fcb       C$CR
                    ENDC

start               stx       <D.Prm              Save ptr to parm area
                    clra
                    sta       <D.Hdr              Default to print header line ON
                    sta       <D.Mem              Default to dump file from DISK
                    sta       <nonopts            Flag that NO file or modules names have been found yet
                    inca
                    sta       <Mode               I$OPEN mode bit flags (set to READ. or READ.+EXEC.)
                    IFNE      DOSCSIZ
                    clr       <narrow             assume wide
* Check screen size
                    ldb       #SS.ScSiz           Ask for our screen size
                    os9       I$GetStt
                    bcs       Pass1
                    cmpx      #titlelen+1         Is our current screen width big enough for 80 column?
                    bge       PrePass             Yes, continue
                    sta       <narrow             No, set flag to use narrow 32 column
PrePass             ldx       <D.Prm
                    ENDC

* Pass1 - process any options. This handles multiple option flags following a
*  single '-' or multiple '-' options
* LCB change - wipe them out with spaces as they are flagged.
* Entry: X = ptr to cmd line
* Skip over spaces
Pass1               lda       ,x+                 Get char from parms
                    cmpa      #C$SPAC             Space?
                    beq       Pass1               Yes, skip to next parm char
* Check for EOL
                    cmpa      #C$CR               End of parameters?
                    beq       Pass2               Yes, go do second pass (for filenames)
* Check for option
                    cmpa      #'-                 No, is it a '-' (for an option flag)?
                    bne       Pass1               No, must be part of a filename (which we are skipping for now)
                    pshs      x                   Save current ptr into parms
                    leax      -1,x                Drop back 1
                    cmpx      <D.Prm              Is '-' the very first char in parms?
                    puls      x                   Restore parm ptr w/o changing CMPX flags
                    beq       OptPass0            Very first parm char is '-', skip checking for a leading space
* Make sure we aren't dealing with a filename with a '-' in it
                    lda       -2,x                Get char previous to '-'
                    cmpa      #C$SPAC             Was it a space (indicating option, not filename)?
                    bne       Pass1               No, must be part of a filename, go onto next character in parms
OptPass0            ldb       #C$SPAC             Yes, change '-' to space for 2nd pass
                    stb       -1,x
* Checking option flags
* Here, X points to an option char
OptPass             lda       ,x+                 Get option char from parms
                    cmpa      #C$SPAC             Is it a space? (ie we are done current block of option flags)?
                    beq       Pass1               Yes, go back to check for parm OR filename
                    cmpa      #C$CR               No, is it the end of the parameter chars?
                    beq       Pass2               Yes, done all options, now process filenames
                    anda      #$DF                No, force uppercase for parm character
                    stb       -1,x                Replace option letter in parm buffer with space for pass2
IsItH               cmpa      #'H                 Is it -H for no header?
                    bne       IsItM               No, check next
* Process H here
                    sta       <D.Hdr              Flag that we do NOT want header line
                    bra       OptPass             Check if any more parm characters in current block

IsItM               cmpa      #'M                 Is it -M for dump module in memory?
                    bne       IsItX               No, check next
* Process M here
                    sta       <D.Mem              Flag the we are dumping module from memory (not file)
                    bra       OptPass             Check if any more parm characters in current block

IsItX               cmpa      #'X                 Is it -X for file is in eXecution directory?
                    bne       ShowHelp            No, illegal option so print help (if present)
* Process X here
                    lda       <Mode               Get current MODE bit flags (set to READ. right now)
                    ora       #EXEC.              Add in the EXEC. bit
                    sta       <Mode               Save it back
                    bra       OptPass             Check if any more parm characters in current block

                    IFNE      DOHELP
ShowHelp            leax      HelpMsg,pcr         Point to help message
                    lda       #2                  Std error path
                    ldy       #HelpLen            Length of help message
                    os9       I$Write             Print help out
                    bra       ExitOk              Exit w/o error
                    ENDC

* Pass2 - process any non-options (ie module or filenames)
* At this point, all '-' and actual parameters replaced with spaces
* Entry: X = ptr to cmd line
Pass2               ldx       <D.Prm              Get ptr to parameter buffer again
* Skip over spaces
Pass21              lda       ,x+                 Get char from parms
                    cmpa      #C$SPAC             Space?
                    beq       Pass21              Yes, eat it and get next character
* Check for EOL
Pass22              cmpa      #C$CR               End of parms?
                    beq       EndOfL              Yes, process file/module names & any options that we have
                    leax      -1,x                No, Move ptr back to SPACE
                    sta       <nonopts            Since <>0, flag that we have at least 1 file/module name present
                    bsr       DumpFile            Dump file data to screen
                    bra       Pass21              Find next filename

EndOfL              tst       <nonopts            any file/module names found?
                    bne       ExitOk              Yes, exit w/o error
                    tst       <D.Mem              No, was memory option specified?
                    bne       ShowHelp            yes but no module name specified, show help
                    clra                          No, assume live typing via stdin path
                    bsr       DumpIn              And go do that
                    IFEQ      DOHELP
ShowHelp
                    ENDC
ExitOk              clrb                          Exit w/o error
DoExit              os9       F$Exit

* Dumping in memory module; link it into our process space
mlink               clra                          Wildcard - any language/type module is allowed
                    pshs      u                   Save data mem ptr
                    os9       F$Link              Link the module into our process
                    stu       <D.Beg              Save ptr to where the module got mapped to
                    puls      u                   Restore data mem ptr
                    bcc       DumpIn              Successful F$Link, go dump module from memory
                    bra       DoExit              Unsuccessful, return with error code from F$Link

DumpFile            tst       <D.Mem              Are we dumping a memory module?
                    bne       mlink               Yes, go map it into our process and dump from there
* Dump file from disk
                    lda       <Mode               No, get mode byte (READ. or READ.+EXEC.)
                    tfr       x,y                 copy ptr to filename in parms to Y (make copy of it?)
                    os9       I$Open              Open the file to be DUMPed
                    bcc       DumpIn              No error, go dump
                    tfr       y,x                 Get ptr to filename from parms back into X
                    ora       #DIR.               Try opening file as a directory
                    os9       I$Open
                    bcs       DoExit              Error, exit with it
* Memory or stdin reads come here
DumpIn              stx       <D.Prm              Save ptr to next parm block (after current file/module name)
                    sta       <D.Opn              Save path to file ($00 if F$Link'd)
* NOTE: If we opened a file from disk, we haven't read anything in yet?!? Or set <D.Beg?
                    ldx       <D.Beg              Get ptr to start of module in memory
                    ldd       M$Size,x            Get module size
                    leax      d,x                 Point to end of the module
                    stx       <D.End              Save it
                    clra                          Init Address offset to 0 (X:D)
                    clrb
                    tfr       d,x                 X=0
* Entry here: X:D is 32 bit Address value (first column). Only LSW used on 32 column DUMP
onpas               std       <AddrLSW            Save least sig 16 bits for new value for "Address" column
                    bhs       notbg               If updated address did not wrap $FFFF, we are done
                    leax      1,x                 >$FFFF, so inc MSW of address as well
notbg               stx       <AddrMSW            Save updated MSW
                    tst       <D.Hdr              Are we printing header lines?
                    bne       nohed               No, skip ahead
                    IFNE      DOSCSIZ
                    tst       <narrow             Yes, are we only doing 32 columns?
                    beq       flpag               No, 80 column so skip ahead
                    aslb                          B=B*2
                    ENDC
flpag               tstb                          Check B (Y line #)
                    bne       nohed               If not on line 0, skip printing header line
                    lbsr      iseof               Are we at the end of the file (or in memory module)?
                    bcc       flpag2              No, go print header line
                    ldx       <D.Prm              Get ptr to file/module name in parameters & return
                    rts

flpag2              leax      caret,pcr           Print first header line
                    lbsr      print
                    ldb       #16                 default to 16 source bytes per output line to dump
                    leax      title,pcr           Point to header text
                    leay      flund,pcr           Point to full 80 column line underlines for header text
                    IFNE      DOSCSIZ
                    tst       <narrow             Are we only printing 32 columns?
                    beq       doprt               No, full 80, so go print both lines
* 6809/6309 - could be lsrb instead. LCB
                    ldb       #8                  Yes, only dump 8 source bytes per output line
                    leax      short,pcr           Point to short header text
                    leay      shund,pcr           & short 32 column underlines for header text
                    ENDC
doprt               pshs      y                   Save underline text ptr
                    clra                          D=B
                    std       <D.Len              Save # of source bytes to dump out per line
                    bsr       print               Print header text line
                    puls      x                   Get ptr to underline text
                    bsr       print               Print that too
nohed               leax      Txtbuf,u            Point to our output text buffer
                    stx       <HexPtr             Save as current output buffer ptr
                    ldb       <D.Len+1            Get # of source bytes/line (to calc size of output buffer we use)
                    lda       #3                  *3 (2 bytes for hex value, 1 for ascii)
                    mul
                    addd      #2                  And add 2 more (for space between hex and ASCII)
                    IFNE      DOSCSIZ
                    tst       <narrow             only doing 32 column?
                    beq       leayit              No, full 80 so skip ahead
                    subd      #4                  32 column, subtract 4 from offset
                    ENDC
leayit              leay      d,x                 Point Y (as offset) to where ASCII part of dump will be
                    sty       <ASCIIPtr           Save it
                    lda       #C$SPAC             Prefill output text buffer with spaces
                    ldb       #BUFSZ-1
clbuf               sta       b,x
                    decb
                    bpl       clbuf
                    ldb       #AddrMSW            Offset to start of 32 bit Address in DP
                    IFNE      DOSCSIZ
                    tst       <narrow             Are we formatting for 32 column?
                    beq       adlop               No, continue
                    incb                          Yes, bump to LSW of Address in DP (we only print LSW of Address)
                    incb
                    ENDC
* Append address to output buffer. 32 bit/8 chars for 80 columns, least sig 16 bits/4 chars <80 columns
adlop               lda       b,u                 Get byte from 32 bit address value
                    lbsr      onbyt               Output 2 digit hex part of address to output buffer
                    incb                          Point to next byte of 32 byte address value
                    cmpb      #AddrMSW+4          Are we done the entire 32 bit address?
                    bne       adlop               No, keep doing until all done.
                    ldx       <HexPtr             Bump hex output ptr up 1 (add space before hex dump on output line)
                    leax      1,x
                    stx       <HexPtr
                    bsr       readi               Get next block of data from file (returns B=# of bytes read)
                    bcs       eofck               If error reading next block, go handle (return from there)
* Do 2 source bytes at a time so we can add spacing between (if 80 column)
onlin               lbsr      onchr               Output Hex & ASCII chars to output buffer
                    decb                          Dec # of bytes left to process in current source block
                    ble       enlin               Done all of them, do end of line & print to screen
                    lbsr      onchr               Output next source byte as Hex & ASCII chars to output buffer
                    decb                          Dec # of bytes left to process in current source block
                    ble       enlin               Done all of them, do end of line & print to screen
                    IFNE      DOSCSIZ
                    tst       <narrow             If <80 columns, go straight to next source bytes
                    bne       onlin
                    ENDC
                    lda       #C$SPAC             If 80 columns, add a space between every 4 hex chars
                    lbsr      savec
                    bra       onlin               On to next source buffer byte

enlin               lda       #C$CR
                    ldx       <ASCIIPtr           Put a CR into current position in output buffer
                    sta       ,x
                    leax      Txtbuf,u            Point to start of text buffer
                    bsr       print               Flush output line to screen
                    ldd       <AddrLSW            Get LSW of current address
                    ldx       <AddrMSW            Get MSW of current address
                    addd      <D.Len              Add # of source bytes/per line to address to LSW
                    lbra      onpas               Start on next line on screen

* Write buffer to screen
* Entry: X=ptr to text to print
* pointed to by X, up to maximum of 80 chars (or CR)
print               ldy       #BUFSZ              Max 80 chars
                    lda       #1                  Std out
                    os9       I$WritLn            Write to screen
                    lbcs      DoExit              Error, exit with it
                    rts

* Read next block of source bytes (enough for next output line)
* Exit: Y & B=8,16 (if full block) or 1-16 if EOF
readi               ldy       <D.Len              Get # of source bytes that we are printing per line
                    clrb
                    tst       <D.Mem              Are we dumping from memory instead of file?
                    bne       redad               Yes, set up for next block in memory module
                    leax      Datbuf,u            Reading from file; point to file buffer
                    lda       <D.Opn              Get path to file (or stdin)
                    os9       I$Read              Read in enough bytes to do output next line
                    bcs       reded               If error, exit with it
                    tfr       y,d                 D=# of bytes actually read (may be smaller if end of file)
reded               rts

* Read next block from mapped in memory module
* Entry: D=size of next source block to read
*        X=ptr to current position in source buffer
redad               bsr       iseofm              Check if we are done the memory module
                    bcc       setct               No, set up for next read block from memory module
                    rts                           Yes, return with EOF error

setct               subd      <D.Len              Are we at end of module?
                    bcs       redof               Yes, size of read = # of bytes left
                    clra                          No, init size to read to 0 (so it ends up being read buffer size)
                    clrb
redof               addd      <D.Len              D=size to read
                    clr       -1,s                Force carry to be clear
                    leay      d,x                 Point Y to next source chunk in module
                    sty       <D.Beg              Save that as source position to start reading from
                    rts

eofck               cmpb      #E$EOF              Was the error and EOF error?
                    orcc      #Carry              Force carry flag (but leave BEQ flag)
                    lbne      DoExit              No, just abort
                    clrb                          Yes, clear error
                    ldx       <D.Prm              And point X to where we left off in parmeters
                    rts

* Check for end of file/module
iseof               tst       <D.Mem              Dumping module in memory?
                    bne       iseofm              Yes, handle in memory module
                    lda       <D.Opn              Disk file, get file path
                    ldb       #SS.EOF             Check if we are at end of file
                    os9       I$GetStt
                    cmpb      #E$EOF
                    beq       iseofex
                    clrb                          Not at end of file, return with no error
iseofok             rts

iseofex             orcc      #Carry              Exit with end of File error
                    ldb       #E$EOF
                    rts

* Check for end of DUMP for module in memory
* Exit: D=# bytes left or EOF error
iseofm              ldd       <D.End              Get ptr to end of module in memory
                    ldx       <D.Beg              Get ptr to start of module in memory
                    subd      <D.Beg              D=end-start (Size) of module
                    beq       iseofex             End of memory module, return with EOF error
                    andcc     #^Carry             More to go, exit w/o error
                    rts

* convert low nibble in A to hex digit & append that to output text buffer
onibl               anda      #$0F                Only keep lower nibble
                    cmpa      #9                  ASCII numeric digit?
                    bls       nocom               Yes, skip ahead
                    adda      #7                  No, offset value to do A-F
nocom               adda      #'0                 ASCII-fy digit
* If called here, append char in A to hex part of output buffer
savec               pshs      x                   Save X
                    ldx       <HexPtr             Get current output buffer ptr
                    sta       ,x+                 Save ASCII hex digit to buffer
                    stx       <HexPtr             Save updated output buffer ptr
                    puls      x,pc                Restore X & return

* Append char at current input buffer position to both Hex & ASCII parts of output buffer
* Exit: B is preserved
*       X updated to point to next byte in source buffer
onchr               lda       ,x+                 Get char from input buffer
                    bsr       onbyt               Append hex value for byte to output buffer
                    pshs      x,a                 Save output buffer ptr & char
                    anda      #$7F                Mask off high bit
                    cmpa      #C$SPAC             control char?
                    blo       cntrl               Yes, change to a '.' for ASCII output
                    cmpa      #$7F                rubout?
                    blo       savet               No, output ASCII as is
cntrl               lda       #'.                 change non-printable char to '.'
savet               ldx       <ASCIIPtr           Get current ptr in txtbuf
                    sta       ,x+                 Save ASCII char
                    stx       <ASCIIPtr           Save updated ptr
                    puls      a,x,pc              Restore source ptr, current byte & return

* Add byte in A to output stream as 2 hex digits
onbyt               pshs      a                   Save original value
                    lsra                          Shift high nibble to low
                    lsra
                    lsra
                    lsra
                    bsr       onibl               Append hex char for high nibble to output buffer
* 6809/6309 - could do puls a here, then rts instead of puls. Or save A in DP (faster)
                    lda       ,s                  Get original value back
                    bsr       onibl               Append hex char for low nibble to output buffer
                    puls      a,pc

                    IFNE      DOHELP
HelpMsg             fcc       "Use: Dump [opts] [<path>] [opts]"
                    fcb       C$CR,C$LF
                    fcc       "  -h = no header"
                    fcb       C$CR,C$LF
                    fcc       "  -m = module in memory"
                    fcb       C$CR,C$LF
                    fcc       "  -x = file in exec dir"
                    fcb       C$CR,C$LF
HelpLen             equ       *-HelpMsg
                    ENDC

                    emod
length              equ       *
                    end
