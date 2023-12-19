********************************************************************
* Asm - 6809/6309 Assembler
*
* ASM V1.6 - Microware version - 6309 instruction assembly by
*  L. Curtis Boyle
*
* Obtained by Boisy Pitre from L. Curtis Boyle on 10/12/2002
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   6      1999/05/11  Boisy G. Pitre
* Made compliant with 1900-2155.
*
*   7      2003/06/27  Rodney V. Hamilton
* Added 6309 bitfield instructions.
*
*   8      2003/07/28  Rodney V. Hamilton
* Enabled underscore and lowercase in symbols.
*
*   9      2004/03/20  Rodney V. Hamilton
* Added support for LDQ immediate, TFM register modes
* Copied the W indexed addressing code from ASM6309
* 0-register bug fixed, TFR now accepts R16->R8 xfers
* Added new IFDEF/IFNDF conditionals
*
*  10      2004/06/15  Rodney V. Hamilton
* Arbitrary-length labels allowed. (first 8 chars must be unique)
* Listing buffer overruns prevented. Opt W linewidth now 132 max.
* 6309 Reg2Reg ops now allow R16->R8 xfers. (sets warning flag)
* Listing fields spaced correctly, comment field auto-aligned.
*
*  10r1    2004/07/31  Rodney V. Hamilton
* Added "@" as valid symbol char. (but no local label support)
*
*  11      2019/03/25-2019/04/14  L. Curtis Boyle
* Minor optimizations, -O= will overwrite existing output file
* Expanded source line max length to 127 - I think it may work up to 132 fine (not tested)
* 6309 specific optimizations as well
*
*  11r1    2020/08/25-2020/08/30  L. Curtis Boyle
* Fixed bug in generating CRC's in programs that have lead in bytes before the module
*   header (like REL)
* Fixed bug on last line of mult-line listing if G option turned on and size >4 bytes

                    nam       Asm
                    ttl       6809/6309 Assembler

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $02                 Rev 2 to fix CRC when block starts before MOD pseudo op (like REL)
edition             set       11                  11 adds -o doing overwrite (I hope)
DOCASE              equ       1                   enable case-sensitive symbols
NEWDEF              equ       1                   enable IFDEF/IFNDF conditionals
InBufSiz            equ       132                 max size of source line read buffer (originally 120)

                    mod       eom,name,tylg,atrv,asm,size

* u002B Bit flag meanings: (Default=00110101)
LitLine             equ       %10000000           Literal line to print
Comment             equ       %01000000           Comment field present in source line
Operand             equ       %00100000           Operand field present in source line
Command             equ       %00010000           Mnemonic command present in source line
Label               equ       %00001000           Label field present in source line
NoObjct             equ       %00000100           No object code to print
PrintPC             equ       %00000001           Print PC flag
DoNothng            equ       %00000000           Do nothing (no flags set)

                    IFNE      NEWDEF
Numop               equ       162                 # of opcodes in table (including pseudo-ops)
                    ELSE
Numop               equ       160                 # of opcodes in table (including pseudo-ops)
                    ENDC      NEWDEF

* Notes on symbol table entries:
* There are two tables - one is pointed to by <u0010 (which is either 26 or 52 entries), each of which
* points to a linked list of symbol table entries that start with that letter (26 entries if uppercase
* only, 52 entries is upper/lowercase are treated separate). Each entry is 15 bytes:
* $0-$7   : 8 char symbol name
* $8      : Symbol type (0=undefined, 1=label, 2=SET, 3=EQU, 4=Data)
* $9-$A   : value of symbol
* $B-$C   : Linked list ptr to next "lower" (alphabetical) symbol tbl entry (within current start letter)
* $D-$E   : Linked list ptr to next "greater" (alphabetical) symbol tbl entry (within current start letter)
* A value of $0000 in the linked list pointers means no further ones in that direction

u0000               rmb       2                   Ptr to source line input buffer (80 + CR)
u0002               rmb       2                   Ptr to header output buffer    (132 + CR)
u0004               rmb       2                   Ptr to listing output buffer   (132 + CR)
u0006               rmb       2                   Ptr to open file path stack    (13, Ustk)
u0008               rmb       2                   Ptr to Title buffer (TTL, 79 chars + nul)
u000A               rmb       2                   Ptr to Name buffer  (NAM, 39 chars + nul)
u000C               rmb       1                   temp postbyte storage for 6309 bit ops
                    IFNE      DOCASE
u000D               rmb       1                   symbol case mask (was unused)
                    ELSE
u000D               rmb       1                   unused
                    ENDC      DOCASE
u000E               rmb       2                   Ptr to object code buffer (256 bytes)
u0010               rmb       2                   Ptr to symbol first letter index table (26 or 52 entries, depending)
u0012               rmb       2                   Ptr to end of symbol table
u0014               rmb       2                   Ptr to end of listing buffer
u0016               rmb       2                   Ptr to symbol name buffer (8 chars + nul)
u0018               rmb       1                   Path number of current source file
u0019               rmb       1                   Path number of object file, O flag
u001A               rmb       1                   Path number of output listing (stdout)
u001B               rmb       2                   Ptr into object code buffer
u001D               rmb       2                   Ptr to next empty symbol table slot
u001F               rmb       2                   Open file path stack ptr
u0021               rmb       1                   Error count for current line
u0022               rmb       2                   Total warnings
u0024               rmb       2                   Total program bytes generated
u0026               rmb       2                   Total data bytes allocated
u0028               rmb       2                   Total errors
u002A               rmb       1                   For long data lines (fcb,fdb,fcc, etc.), the # of 4 byte blocks generate (for listing)
u002B               rmb       1                   Listing Print Control Bit flags
u002C               rmb       1                   Data space ops in current line
u002D               rmb       2                   Ptr to last symbol found/added (scratch)
u002F               rmb       2                   Ptr to start of current mnemonic
u0031               rmb       2                   Ptr to next field (or operand start)
u0033               rmb       2
u0035               rmb       1                   # lines to end of page
u0036               rmb       1                   Page height (default=66), D flag
u0037               rmb       1                   Page width (default=80), W flag
u0038               rmb       2                   line counter
u003A               rmb       2                   page number
u003C               rmb       1
u003D               rmb       1
u003E               rmb       1                   Pass counter
u003F               rmb       1                   Current SetDP value (defaults to 0)
u0040               rmb       2                   Current code address ('*')
u0042               rmb       2                   Current data address ('.')
u0044               rmb       2
u0046               rmb       1                   # bytes in current instruction
u0047               rmb       1                   Current instructions flags/index handler byte
u0048               rmb       1
u0049               rmb       1
u004A               rmb       1                   MSB of 16 bit # (for addresses & offsets)
u004B               rmb       1                   LSB of 16 bit #
u004C               rmb       1                   Flag for DP (or 8 bit)($01), Extended (or 16 bit)($FF) or other($00) modes
u004D               rmb       1                   Indirect mode flag (0=no, >0=Yes)
u004E               rmb       1                   Indexed mode calc completed flag (0=no)
u004F               rmb       1                   Warning count for current line
u0050               rmb       1                   Header parity byte
u0051               rmb       3                   CRC buffer
u0054               rmb       1                   Inactive (non-coding) nested IF depth
u0055               rmb       1                   Active (code enabled) nested IF depth
u0056               rmb       1                   L opt flag
u0057               rmb       1
u0058               rmb       1                   O opt flag
u0059               rmb       1                   F opt flag
u005A               rmb       1                   M opt flag
u005B               rmb       1                   G opt flag
u005C               rmb       1                   E opt flag
u005D               rmb       1                   I opt flag
u005E               rmb       1                   S opt flag
u005F               rmb       1                   C opt flag
u0060               rmb       1                   N opt flag
* The currently assembled instruction goes here
u0061               rmb       1                   Current instruction's pre-byte (see u0046)
u0062               rmb       1                   Current instruction's opcode
u0063               rmb       1                   More bytes as needed by instruction
u0064               rmb       1
u0065               rmb       2
TmpNum              rmb       2                   1 or 2 byte scratch area to use instead of stack for speed.
OpTable             rmb       2                   Pointer to L03B8 (opcode) table, for slightly faster access
SkipCRC             rmb       1                   Flag:0=calculate CRC, <>0=don't calculate. Will be<>0 if L1323 is called from L159F
StartCRC            rmb       2                   Ptr to 1st byte in output buffer to start calculating CRC (for things like REL)
                    rmb       4096-.              Main buffer area
size                equ       .

name                fcs       /Asm/
                    fcb       edition

asm                 tfr       u,d
                    addd      #$01C0              allocate local stack
                    tfr       d,s
                    std       <u0016
                    addd      #9                  symbol name buffer (8 char+null)
                    std       <u0000              Start of current line in source ($1C9)
* LCB NOTE: Since the actual I$ReadLn call is doing 120 bytes (showing that it overlaps the header
* buffer by 40 bytes - could we not increase the size that read to handle? I have tried 132 (which
* appears to work), so that it matches the maximum output line length for a listing, but it conceivably
* could go up to 212 (with full overlap with the header line buffer). But the listing output line buffer
* would need expanded as well.
                    addd      #81                 source buffer (120 char+CR, overlaps hdr buf)
                    std       <u0002
                    addd      #133                header buffer (132 char+CR)
                    std       <u0004              Start of listing buffer
                    addd      #133-1              point to end of listbuf (132 char+CR)
                    std       <u0014              to detect buffer overruns
                    addd      #13+1               allocate open path stack (+CR for listbuf)
                    std       <u0006
                    std       <u001F
                    std       <u0008
                    addd      #80                 TITLE buffer (79 char+null)
                    std       <u000A
                    addd      #40                 NAME buffer (39 char+null)
                    std       <u000E
                    adda      #1                  allocate 256-byte code buffer
                    std       <u0010
                    IFNE      DOCASE
                    addd      #52*2               52 symbol vectors, A-Za-z
                    ELSE
                    addd      #26*2               26 symbol vectors, A-Z
                    ENDC      DOCASE
                    std       <u001D              start of symbol table
                    leau      >L03B8,pc           Point to opcode table
                    stu       <OpTable            Save in DP for slightly faster access later
                    leau      -1,y
                    stu       <u0012              end of symbol table
* Re-grouped to shrink code size a little
                    clra
                    clrb
                    std       <u0057              ??? & O opt=0
                    std       <u0059              F & M opts=0
                    std       <u005D              I & S opts=0
                    std       <u0018              Input path # & Output path # =0
                    sta       <u003E              Pass ctr=0
                    sta       <u0060              N opt =0
                    std       <StartCRC           Init buffer ptr to start CRC calcs on to 0 (no CRC yet)
                    incb                          B=1 now
                    std       <u005B              G opt=0, E opt=1
                    stb       <u005F              C opt=1
                    stb       <u001A              Path # for output listing (stdout=1)
                    coma                          A=$FF
                    sta       <u0056              L opt flag=$FF
                    ldd       #66*256+79          Default page height=66, page width=79
                    std       <u0036
                    IFNE      DOCASE
                    ldb       #$7F                Default symbol case mask
                    stb       <u000D
                    ENDC      DOCASE
                    lbsr      L1696               Parse command line args
                    lda       <u0056
                    bmi       L0081
                    inc       <u0057
L0081               ldx       <u0008              Clear high byte of Title buffer
                    clr       ,x
                    ldx       <u000A              Clear high byte of Name buffer
                    clr       ,x
                    pshs      x,y,u               Save regs
                    ldd       <u0012              Get ptr to end of clear
                    subd      <u0010              Calc size of clear
                    tfr       d,x
                    ldu       <u0010              Point to start of clear
                    clrb                          Clearing to 0's
                    lbsr      StkBlClr            Clear the memory
                    puls      x,y,u               Restore regs
                    ldb       <u005D              Get I option flag
                    beq       L0099
                    dec       <u003E              Interactive option set, Dec pass counter
                    bra       L00A0

L0099               bsr       L00A5               Init vars
* seek to beginning of input file
                    lda       <u0018              source file path number
                    ldu       #$0000
                    leax      ,u
                    os9       I$Seek
                    inc       <u003E              Inc pass # ctr
L00A0               bsr       L00A5               Init vars again
                    lda       #1                  Flag that we are skipping CRC update on this buffer write
                    sta       <SkipCRC
                    lbra      L159F               Flush out final output file buffer (if needed)

L00A5               bsr       L00B1               Init vars for 'L'isting
L00A7               lbsr      L1537               Read in source line, some pre-processing
                    bcs       Rtrn2               Error, return
L00AD               bsr       L00D5               No error, Parse current source code line
                    bra       L00A7               Keep going until source file is done

* initialize CRC to $FFFFFF
L1360               ldd       #$FFFF
                    std       <u0051
                    stb       <u0051+2
Rtrn2               rts

* Init some vars
L00B1               clra
                    clrb
                    std       <u0028              Total errors=0
                    std       <u0022              Total warnings=0
                    std       <u0026              Total data bytes allocated=0
                    std       <u0024              Total program bytes generated=0
                    std       <u0040              Current code address (*)=0
                    std       <u0042              Current data address (.)=0
                    stb       <u003F              Current SETDP value=0
                    std       <u0054              Inactive (non-coding) & Active (Code enabled) nested IF depth=0
                    incb
                    std       <u003A              Page #=0
                    std       <u0038              Line counter=0
                    ldd       <u000E              Get ptr to object code buffer
                    std       <u001B              Save as current ptr in object code buffer
                    bsr       L1360               Initialize CRC
                    lbra      L141A               Page header stuff, I think, and return from there

* Parse current source code line (I think)
L00D5               clra
                    clrb
                    sta       <u0021              Clear error count for current line
                    sta       <u002A              ???
                    sta       <u002C              Clear data space ops in current line
                    sta       <u0046              Clear # bytes for current instruction
                    std       <u004A              Init 16 bit temp for addresses/offsets
                    std       <u004C              Default memory addressing mode to non-DP/Extended, indirect mode flag to NO
                    std       <u004E              Indexed mode calc completed flag=NO, warning count for current line=0
                    std       <u0061              Clear prefix opcode & opcode bytes
                    std       <u0063              Clear 2 more bytes for code (for longer instructions)
                    std       <u0065              And 2 more bytes for code (for longer instructions)
                    lda       #Operand+Command+NoObjct+PrintPC
                    sta       <u002B              Initialize flags
                    ldd       <u0040              Get current code address (*)
                    std       <u0044              Save as a current ptr(?)
* Parse for label field
                    ldx       <u0000              Get ptr to start of current source line
                    lda       ,x                  Get 1st char
                    cmpa      #C$CR               Blank line?
                    beq       L0136               Yes, go ahead
                    cmpa      #'*                 Comment line?
                    beq       L0136               Ditto
                    cmpa      #C$SPAC             Space? (No label field)
                    beq       L0125               Yes, go somewhere else
* Label field found
                    IFNE      H6309
                    oim       #Label,<u002B       Flag Label Present in Listing print control flags
                    ELSE
                    ldb       <u002B              Flag Label Present in Listing print control flags
                    orb       #Label
                    stb       <u002B
                    ENDC
                    lbsr      L0368               copy label to symbol name buffer
                    bcc       L0119
                    ldb       #01                 'bad label' error
                    lbsr      L02FA
                    bra       L0125

L0119               tst       <u0054              Check if we are in Inactive (non-coding) nested IF
                    bne       L0125               Yes, skip ahead
                    lbsr      L0F4A               add label to symbol table
                    bcc       L0125
                    lbsr      L02FA               if add failed, report error
* Check for mnemonic field
L0125               lbsr      L1164               Find start of next field & get first char
                    cmpa      #C$CR               End of line yet?
                    bne       L0141               No, have ptr to mnemonic field
                    lda       <u002B              Get flags (could use TIM on 6309, but, while smaller, it's actually slower)
                    bita      #Label              Was a label present?
                    beq       L0136               No, print whole source line as literal comment
                    lda       #Label+PrintPC      Set Label & Print PC flags (label on line by
                    bra       L0138               itself)

L0136               lda       #LitLine            Whole line is comment flag
L0138               sta       <u002B              Save flags
                    lda       <u0054              Get Inactive (non-coding) nested IF depth
                    bne       L018E               We are in an IF, skip ahead
                    lbra      L01F2               Build output line for listing, return from there

* Process mnemonic field
L0141               stx       <u002F              Save ptr to start of current mnemonic
L0143               lda       ,x+                 Get char
                    cmpa      #C$CR               CR?
                    beq       L0150               Yes, done line
                    cmpa      #C$SPAC             Space?
                    bne       L0143               No, continue getting chars
                    lbsr      L1164               Find start of next field
L0150               stx       <u0031              Save ptr to possible operand field
                    ldx       <u002F              Pointer to start of current op. in source code
                    ldb       #Numop              # of instructions in main table
                    ldy       <OpTable            Get pointer to main opcode/pseudo-op table (saves 1 cycle from original leay)
                    lbsr      L0344               Go point to it's opcode/flag bytes
                    bcc       L0172               Legal opcode, go process
* Unknown mnemonic
L015F               ldb       #02                 'bad instr' error
                    lbsr      L02FA               Print error message
                    ldb       #$03                Set # bytes of current instruction to 3???
                    stb       <u0046
                    IFNE      H6309
                    aim       #^Operand,<u002B    Shut off operand present flag
                    ELSE
                    lda       <u002B
                    anda      #^Operand           Shut off operand present flag
                    sta       <u002B
                    ENDC
                    ldx       <u0031              Get ptr to next field & skip ahead
                    bra       L01C4

* Found mnemonic
* Entry: Y=Ptr to opcode/flag bytes
L0172               lda       <u0054              # of nested IF constructs???
                    beq       L0195               If none, skip ahead???
                    ldb       $01,y               Get flag bytes
                    andb      #%00001111          Only want index handler #
                    cmpb      #$0D                Pseudo op IFxx?
                    bne       L0181               No, check next
                    inca                          Inc nested conditional counter?
                    bra       L018C               Go save it & continue

L0181               cmpb      #$0E                Pseudo Op ELSE/ENDC?
                    bne       L018E               No, check next
                    deca                          Dec nested loop counter?
                    beq       L0195               If down to zero, skip ahead
                    ldb       ,y                  Get opcode byte
                    bne       L018E               If ELSE, skip ahead
L018C               sta       <u0054              Save updated nested loop counter?
L018E               inc       <u0038+1            lsb
                    bne       L0194
                    inc       <u0038              LSB wrapped, bump up msb
L0194               rts

* Calculate pre-bytes if needed (or known yet in 6309's case)
L0195               ldd       ,y                  Get opcode/flag bytes
                    sta       <u0062              Save opcode
                    stb       <u0047              Save flags/index handler nibbles
                    lda       #$10                Preload $10 prefix
                    bitb      #$10                Does this opcode require it?
                    bne       L01A7               Yes, go store before normal opcode byte
                    inca                          Preload $11 prefix
                    bitb      #$20                Does this opcode require it?
                    beq       L01AB               No prefix needed, skip ahead
L01A7               sta       <u0061              Save prebyte
                    inc       <u0046              Increase byte count of current instruction
* Call proper index handler
L01AB               leay      >L0780,pc           Point to 'opcode type' index
                    andb      #%00001111          Mask out non-index information
                    lslb                          adjust for 2 bytes per offset entry
                    ldd       b,y                 Get offset
                    jsr       d,y                 Execute routine
                    lda       <u002B              Operand present flag set?
                    bita      #Operand
                    beq       L01C4               No, skip ahead
                    lda       ,x                  Get next char in source code
                    clr       ,x+                 Clear that char in source line
                    cmpa      #C$CR               Was it a CR?
                    beq       L01D3               Yes, skip ahead
L01C4               lbsr      L1164               Find next field
                    cmpa      #C$CR               End of line?
                    beq       L01D3               Yes, skip ahead
* Bugfix LCB 08/30/2020 - L and G combo on source lines that contain actual code bytes
*  will no longer make a spurious comment on the last line of the block if it isn't an
*  even 4 bytes.
* UNFORTUNATELY IT IS CURRENTLY EATING ANY COMMENT ADDED TO THE FIRST LINE NOW.
                    ldb       <u002A              Is this the first block of a multi-line list (ex. longer FCB,FDB)?
                    bne       L01D3               No, we already printed comment on first block, don't do again
                    ldb       <u002B              Get flags
                    beq       L01D3               If do nothing, skip ahead
                    orb       #Comment            Set Comment field present flag
                    stb       <u002B
L01D3               ldb       <u005D              Interactive command line option set?
                    beq       L01DB               No, skip ahead
                    ldb       <u0021              Get error count for current line
                    bne       L01F2               We have errors, skip straight to building output line for listing
L01DB               ldd       <u0040              Get current code address (* value)
                    addb      <u0046              Add # of bytes in current instruction
                    adca      #$00
                    std       <u0040              Save new current code address
                    bra       L01F2               Build output line for listing

* Pre-fill listing buffer with spaces. Now calls mini stack blast for speed.
* Exit: X=Ptr to start of list buffer
L01E5               pshs      cc,d,y,u            Save Y,U (and reserve 3 bytes for subroutine)
                    ldd       #33                 33 blocks of 4 bytes to clear
                    ldu       <u0004              Get ptr to start of listing buffer
                    leau      >132,u              Point to end of listing buffer+1
                    ldx       #C$SPAC*256+C$SPAC  Clearing with spaces
                    lbsr      FourBClr            Call 4 byte block clear routine
                    leas      3,s                 Eat temp bytes
                    puls      y,u                 Restore regs
L01EF               ldx       <u0004              Get ptr to start of listing buffer again
                    rts

* Take number in D and convert to 5 digit ASCII string (stored at X)
* 6309 - use E and F as 5 digit counter (Y) and current digit (now ,s)
L1084               pshs      u,y,b
                    leau      <L10AA,pc           Point to powers of 10 table
                    ldy       #5                  5 entries (1-10000)
L108E               clr       ,s                  Clear digit
L1090               subd      ,u                  Repeated subtract
                    blo       L1098               Wrapped negative, onto next
                    inc       ,s                  Inc digit
                    bra       L1090

L1098               addd      ,u++                Wrap back to positive, move to next decimal digit
                    stb       <TmpNum             Preserve B
                    ldb       ,s                  Get digit
                    addb      #$30                Make into ASCII #
                    stb       ,x+                 Save ASCII digit into output buffer
                    ldb       <TmpNum             Get B back
                    leay      -1,y                Dec digit counter
                    bne       L108E               More left, keep going
                    puls      pc,u,y,b            Done all 5 digits, return

* Subtraction table for ASCII conversion
L10AA               fdb       10000
                    fdb       1000
                    fdb       100
                    fdb       10
                    fdb       1

* Build output line for Listing
L01F2               ldb       <u003E              Get pass counter
                    beq       L01EF               0, set X to start of listing buffer & return
                    ldb       <u002B              Any flags set?
                    beq       L01EF               No, set X to start of listing buffer & return
                    bsr       L01E5               Prefill list buffer with 132 spaces
                    tst       <u0060              N (Narrow listing) opt flag set?
                    bne       L0205               Yes, skip ahead
                    ldd       <u0038              Get line counter
                    bsr       L1084               Append ASCII version of line # to output buffer
L0205               ldb       <u002B              Literal line flag set?
                    bitb      #LitLine
                    beq       L0213               No, skip ahead
                    ldb       #13                 Yes, set to column 13
                    ldy       <u0000              Point to source buffer
                    lbra      L02AB               copy entire line to list buf

L0213               bitb      #PrintPC
                    beq       L0240
                    lda       #'E
                    ldb       <u0021              Any errors this line?
                    bne       L022F               Yes, add 'E' to list
                    deca                          'D'
                    ldb       <u002C              Any Data space ops this line?
                    bne       L022F               Yes, add 'D' to list
                    lda       #'W
                    ldb       <u004F              Any warnings this line?
                    beq       L0236               No, skip ahead
                    inc       <u0022+1            Yes, bump up total warning count lsb
                    bne       L022F
                    inc       <u0022              msb
L022F               ldb       #$06                Move list buffer position to column 6 (0 based, so 7th position)
                    lbsr      L02E2
                    sta       ,x                  Save line 'type' byte in output listing buffer
L0236               ldb       #$08                Move cursor to position 8 (9th)
                    lbsr      L02E2
                    ldd       <u0044              Get scratch copy of current code address (*)
                    lbsr      L1057               call OUT4HS (print Address)
L0240               ldb       <u002B              Get flags
                    bitb      #NoObjct            Object bytes to print?
                    beq       L0272               No, skip ahead
                    ldb       <u0046              check # bytes in current instruction
                    beq       L0272               None, skip ahead
                    ldb       #u0061              DP addr of instruction buffer
                    tfr       dp,a
                    tfr       d,u                 U=ptr to instruction buffer
                    ldb       ,u+                 Is there a prebyte?
                    bne       L0256               Yes, start there
* Main generating loop - appends up to 4 bytes to output buffer and/or list buffer (in ASCII)
* controlled by <u0046 decing each byte added until done
L0254               ldb       ,u+                 Get next byte of instruction
L0256               pshs      b                   Save copy
                    lbsr      L106B               Append hex version to output buffer (2 digit)
                    puls      a                   Get byte back
                    ldb       <u005D              I(nteractive command line) opt flag set?
                    beq       L0265               No, skip ahead
                    ldb       <u0021              Get error count for current line
                    bne       L026E               There are errors, skip ahead
L0265               lbsr      L130D               add byte to the code buffer
                    inc       <u0024+1            update generated bytecount lsb
                    bne       L026E
                    inc       <u0024              and msb
L026E               dec       <u0046              Dec # of bytes left in current instruction (max 4, not including prebyte)
                    bne       L0254
L0272               ldy       <u0000              Get ptr to source line buffer
                    ldb       <u002B              Get listing control bit flags
                    bitb      #Label              Label field to print?
                    beq       L0281               No, skip ahead
                    ldb       #24                 Yes, set to column 24
                    bsr       L02E2               Update listing ptr
                    bsr       L02C9               Copy buffer from Y to X until space,CR or end of buffer
                    ldb       <u002B              Get flags back
* LCB - moved L0281 label down 1 instruction to skip redundant ldb <u002B (only called from L0272)
L0281               bitb      #Command            Mnemonic field to print?
                    beq       L028F
                    ldb       #33                 Yes, set to column 33
                    bsr       L02E2               Update listing ptr
                    bsr       L02C9               Copy whitespace delimited text from Y buffer to X buffer
                    leay      1,y                 Point to char after CR at end of string we just copied
                    ldb       <u002B              Get listing control bit flags
* LCB - moved L028F label down 1 instruction to skip redundant ldb <u002B (only called from L0281)
L028F               bitb      #Operand            Operand field to print?
                    beq       L02A3
                    ldb       #39                 Yes, set to column 39
                    bsr       L02E2               Update listing ptr
                    ldy       <u0031              Get ptr to next field (or operand start)
                    lbsr      L11BD               Append string @,y to ,x until NUL or CR hit
                    ldb       <u002B              Get listing control bit flags
* LCB - moved L02A3 label down 1 instruction to skip redundant ldb <u002B (only called from L028F)
L02A3               bitb      #Comment            Comment field to print?
                    beq       L02B9
                    ldb       #50                 Yes, set to column 50
* Copy comment field to listing buffer
L02AB               bsr       L02E2               Update listing ptr
                    bsr       L02C9               skip leading spaces, copy first word
                    lbsr      L11BD               copy rest of comment
L02B7               ldb       <u002B              Get flags
L02B9               andb      #^Comment           Clear comment flag
                    cmpb      #NoObjct            Are we generating object code?
                    beq       L02C8               No, return
                    lbsr      L1370               Yes, do it, and updated page counters & page break (if needed)
                    inc       <u0038+1            Bump up line counter lsb
                    bne       L02C8
                    inc       <u0038              If overflowed, inc msb
L02C8               rts

* copy whitespace-delimited text to print buffer
L02C9               lda       ,y+
                    cmpa      #C$SPAC             skip leading spaces
                    beq       L02C9
L02CF               cmpa      #C$CR
                    beq       L02DF
                    cmpx      <u0014              end of buffer?
                    bhs       L02D9               yes, stop copying
                    sta       ,x+                 Append character
L02D9               lda       ,y+                 Get next char, eating spaces until non-space,CR or end of buffer
                    cmpa      #C$SPAC
                    bne       L02CF
L02DF               leay      -1,y                rewind to terminating char
                    rts

* Move listing buffer ptr to column [B], ignore if already past
* Entry: X=current position in list line buffer (0-131 max)
*        B=column requested
* Exit:  X=new position in list line buffer (0-131 max)
L02E2               pshs      u
                    leax      1,x                 Force at least ONE space
                    tst       <u0060              Narrow listing?
                    bne       L02F8               Yes, single space only
L02EC               ldu       <u0004              Point to start of listing buffer
                    leau      b,u                 Offset to column [B] (0-based)
                    stu       <TmpNum             Compare new offset
                    cmpx      <TmpNum             with current offset
                    bhs       L02F8               Already past, ignore
                    leax      ,u                  Update listing ptr
L02F8               puls      pc,u

* Error printing routine
* Entry: B=Internal error # (table entry #)
L02FA               pshs      u,y,x,d             Preserve regs
                    lda       <u005C              Error messages flag on?
                    beq       L0325               No, skip ahead
                    leay      <L061C,pc           Yes, point to '***** Error' string
                    ldx       <u0004              Get ptr to start of write buffer
                    lbsr      L11BD               Append to write buffer (now Y points to error message table @L062A
                    clra                          Table offset is B-1
                    decb
                    lslb                          Adjust for 2 byte entries
* Y is now pointing to L062A already (error routine jump table), so we don't need to leay it here
                    ldd       d,y                 Get 2 bytes @ offset D
                    leay      d,y                 Point to Y to offset
                    lbsr      L11BD               Go print actual error message
                    ldb       1,s
                    cmpb      #$18
                    bne       L0322
                    ldy       2,s
                    lbsr      L11BD
L0322               lbsr      L1368               Something to do with page end
L0325               inc       <u0021              Inc error count for current line
                    inc       <u0028+1            Inc total error count (16 bit number)
                    bne       L032D
                    inc       <u0028              msb
L032D               puls      pc,u,y,x,d          Restore regs & return

L061C               fcc       '***** Error: '
                    fcb       $00

* Pointers to error messages table
L062A               fdb       L065F-L062A         Point to 'bad label2'
                    fdb       L0669-L062A         Point to 'bad instr'
                    fdb       L0673-L062A         Point to 'in number'
                    fdb       L067D-L062A         Point to 'div by 0'
                    fdb       L0686-L062A         Point to ' '
                    fdb       L0688-L062A         Point to 'expr syntax'
                    fdb       L0694-L062A         Point to 'parens'
                    fdb       L069B-L062A         Point to 'redefined name'
                    fdb       L06AA-L062A         Point to 'undefined name'
                    fdb       L06B9-L062A         Point to 'phasing'
                    fdb       L06C1-L062A         Point to 'symbol table full'
                    fdb       L06D3-L062A         Point to 'address mode'
                    fdb       L06E0-L062A         Point to 'out of range'
                    fdb       L06ED-L062A         Point to 'result>255'
                    fdb       L06F8-L062A         Point to 'reg name'
                    fdb       L0701-L062A         Point to 'reg sizes'
                    fdb       L070B-L062A         Point to 'input path'
                    fdb       L0716-L062A         Point to 'object path'
                    fdb       L0722-L062A         Point to 'index reg'
                    fdb       L072C-L062A         Point to '] missing'
                    fdb       L0736-L062A         Point to 'needs label'
                    fdb       L0742-L062A         Point to 'opt list'
                    fdb       L074B-L062A         Point to 'const def'
                    fdb       L0755-L062A         Point to 'can't open'
                    fdb       L0761-L062A         Point to 'label not allowed'
                    fdb       L0773-L062A         Point to 'cond nesting'

* L033D CR copy loop merged into L11BD code -RVH

* Find opcode match
* Entry: Y=Table ptr to look in for match
*        X=Ptr to part of source we are currently checking
*        B=# opcodes in current table
* Exit: Carry set if no matching mnemonic found (and X points to start of bad mnemonic)
*       Carry clear, Y is ptr to opcode & flag bytes, X=ptr to byte after mnemonic if match IS found
* LCB - Optimized to use DP instead of stack for X (since only needed for non-match),
*   and not preserving B at all (always reset by calling routines)
* If this works, may also be able to stx <TmpNum
L0344               stx       <TmpNum             Preserve source code ptr & # opcodes in table
L0346               lda       ,y+                 Get byte from table
                    bmi       L035E               If high bit set, skip ahead
                    eora      ,x+                 Do characters match?
                    anda      #$DF                Ignore case mismatch
                    beq       L0346               If matches, keep doing until last character
L0350               lda       ,y+                 Doesn't match, search for end of current entry
                    bpl       L0350
L0354               leay      2,y                 Skip opcode & flag bytes too
                    ldx       <TmpNum             Reset source code ptr to start of instruction
                    decb                          Dec # opcodes counter
                    bne       L0346               Check until all are done
                    comb                          All done, illegal opcode
                    rts                           Exit with error flag set, and X pointing to start of mnemonic

* Matches so far, on last byte of text mnemonic
L035E               eora      ,x+                 Do last characters match?
                    anda      #$5F                Ignore case and high bit mismatch
                    bne       L0354               Doesn't match, check next
                    clrb                          No error & return
                    rts

* Opcode & Pseudo Opcode Table
* Mnemonic words are high bit terminated
* First numeric byte is the base opcode (before addressing modes considered)
* 2nd is flags:
* Least significiant 4 bits = index into handler table
* 0= LBRA & LBSR (non comparitive long branches/no pre-byte)
* 1= Immediate (no register options) ex. ORCC
* 2= 16 bit register commands
* 3= 8 bit register commands
* 4= CLR, etc. Inherent (A,B,D,E,F,W all supported)
* 5= 'Fixed' (register not negotiable) inherent commands
* 6= LEAx - Indexed only
* 7= Register to register (TFR,EXG) (now patched for dual size 0 register)
* 8= Stack push/pull (except for W - it's done as type 5)
* 9= 16 bit Relative comparative branches setup flag
* A= 8 bit Relative comparative branches
* B= Pseudo op
* C= Pseudo op (label not allowed)
* D= Pseudo op conditionals (IFxx)
* E= Pseudo op (ELSE & ENDC)
* F= 6309 bit ops (OIM,BAND,etc) (was UNUSED)
* Most significiant 4 bits
* %00010000 : $10 prefix byte always needed
* %00100000 : $11 prefix byte always needed
* %01000000 : Immediate mode illegal
* %10000000 : Default to extended mode - not used??? RVH

L03B8               fcs       "ORG"
                    fcb       $00,$0C
                    fcs       "ENDC"
                    fcb       $00,$0E
* Long branches without prebyte
                    fcs       "LBRA"
                    fcb       $16,$00
                    fcs       "LBSR"
                    fcb       $17,$00
* Immediate with no options for register names
                    fcs       "ORCC"
                    fcb       $1A,$01
                    fcs       "ANDCC"
                    fcb       $1C,$01
                    fcs       "CWAI"
                    fcb       $3C,$01
                    fcs       "LDMD"
                    fcb       $3d,$21
                    fcs       "BITMD"
                    fcb       $3c,$21
* Register to register commands (must be here since ADD would match too early)
                    fcs       "ADDR"
                    fcb       $30,$17
                    fcs       "ADCR"
                    fcb       $31,$17
                    fcs       "SUBR"
                    fcb       $32,$17
                    fcs       "SBCR"
                    fcb       $33,$17
                    fcs       "ANDR"
                    fcb       $34,$17
                    fcs       "ORR"
                    fcb       $35,$17
                    fcs       "EORR"
                    fcb       $36,$17
                    fcs       "CMPR"
                    fcb       $37,$17

* 16 bit register commands
                    fcs       "ADDD"
                    fcb       $C3,$02
                    fcs       "SUBD"
                    fcb       $83,$02
                    fcs       "LDD"
                    fcb       $CC,$02
                    fcs       "LDX"
                    fcb       $8E,$02
                    fcs       "LDU"
                    fcb       $CE,$02
                    fcs       "CMPX"
                    fcb       $8C,$02
                    fcs       "JSR"
                    fcb       $8D,$42             Immediate mode not allowed
                    fcs       "STD"
                    fcb       $CD,$42
                    fcs       "STX"
                    fcb       $8F,$42
                    fcs       "STU"
                    fcb       $CF,$42
                    fcs       "CMPU"
                    fcb       $83,$22
                    fcs       "CMPS"
                    fcb       $8C,$22
                    fcs       "CMPD"
                    fcb       $83,$12
                    fcs       "CMPY"
                    fcb       $8C,$12
                    fcs       "LDY"
                    fcb       $8E,$12
                    fcs       "LDS"
                    fcb       $CE,$12
                    fcs       "STY"
                    fcb       $8F,$52
                    fcs       "STS"
                    fcb       $CF,$52
* 6309 additions here
                    fcs       "SUBW"
                    fcb       $80,$12
                    fcs       "CMPW"
                    fcb       $81,$12
                    fcs       "SBCD"
                    fcb       $82,$12
                    fcs       "ANDD"
                    fcb       $84,$12
                    fcs       "BITD"
                    fcb       $85,$12
                    fcs       "LDW"
                    fcb       $86,$12
                    fcs       "STW"
                    fcb       $87,$52             Immediate mode illegal
                    fcs       "EORD"
                    fcb       $88,$12
                    fcs       "ADCD"
                    fcb       $89,$12
                    fcs       "ORD"
                    fcb       $8A,$12
                    fcs       "ADDW"
                    fcb       $8B,$12
                    fcs       "DIVQ"
                    fcb       $8E,$22
                    fcs       "MULD"
                    fcb       $8F,$22
                    fcs       "STQ"
                    fcb       $CD,$52             Immediate mode illegal
                    fcs       "LDQ"
                    fcb       $CC,$12             Immediate has new routine
* 6309 "In Memory" Bit Masking commands - no prebyte
* Immediate mode is illegal for these
                    fcs       "OIM"
                    fcb       $01,$4F
                    fcs       "AIM"
                    fcb       $02,$4F
                    fcs       "EIM"
                    fcb       $05,$4F
                    fcs       "TIM"
                    fcb       $0B,$4F
* 6309 "In Memory" Bit Manipulation commands - prebyte of $11
* address mode is direct page ONLY
                    fcs       "BAND"
                    fcb       $30,$6F
                    fcs       "BIAND"
                    fcb       $31,$6F
                    fcs       "BOR"
                    fcb       $32,$6F
                    fcs       "BIOR"
                    fcb       $33,$6F
                    fcs       "BEOR"
                    fcb       $34,$6F
                    fcs       "BIEOR"
                    fcb       $35,$6F
* these two MUST precede the generic LD and ST
                    fcs       "LDBT"
                    fcb       $36,$6F
                    fcs       "STBT"
                    fcb       $37,$6F
* 8 bit register commands (handles A,B,E,F)
                    fcs       "ADD"
                    fcb       $8B,$03
                    fcs       "CMP"
                    fcb       $81,$03
                    fcs       "SUB"
                    fcb       $80,$03
                    fcs       "SBC"
                    fcb       $82,$03
                    fcs       "AND"
                    fcb       $84,$03
                    fcs       "BIT"
                    fcb       $85,$03
                    fcs       "LD"
                    fcb       $86,$03
                    fcs       "ST"
                    fcb       $87,$43             Immediate mode not allowed
                    fcs       "EOR"
                    fcb       $88,$03
                    fcs       "ADC"
                    fcb       $89,$03
                    fcs       "OR"
                    fcb       $8A,$03
                    fcs       "DIVD"
                    fcb       $8D,$23
* Inherent register commands (now handles A,B,E,F,D & W)
                    fcs       "NEG"
                    fcb       $00,$04
                    fcs       "COM"
                    fcb       $03,$04
                    fcs       "LSR"
                    fcb       $04,$04
                    fcs       "ROR"
                    fcb       $06,$04
                    fcs       "ASR"
                    fcb       $07,$04
                    fcs       "LSL"
                    fcb       $08,$04
                    fcs       "ASL"
                    fcb       $08,$04
                    fcs       "ROL"
                    fcb       $09,$04
                    fcs       "DEC"
                    fcb       $0A,$04
                    fcs       "INC"
                    fcb       $0C,$04
                    fcs       "TST"
                    fcb       $0D,$04
                    fcs       "JMP"
                    fcb       $0E,$44
                    fcs       "CLR"
                    fcb       $0F,$04
* "Fixed" inherent commands (no options for register names)
* Single, unique opcode
                    fcs       "RTS"
                    fcb       $39,$05
                    fcs       "MUL"
                    fcb       $3D,$05
                    fcs       "NOP"
                    fcb       $12,$05
                    fcs       "SYNC"
                    fcb       $13,$05
                    fcs       "DAA"
                    fcb       $19,$05
                    fcs       "SEXW"
                    fcb       $14,$05
                    fcs       "SEX"
                    fcb       $1D,$05
                    fcs       "ABX"
                    fcb       $3A,$05
                    fcs       "RTI"
                    fcb       $3B,$05
                    fcs       "SWI2"
                    fcb       $3F,$15
                    fcs       "SWI3"
                    fcb       $3F,$25
                    fcs       "SWI"
                    fcb       $3F,$05
                    fcs       "PSHSW"
                    fcb       $38,$15
                    fcs       "PULSW"
                    fcb       $39,$15
                    fcs       "PSHUW"
                    fcb       $3A,$15
                    fcs       "PULUW"
                    fcb       $3B,$15
* Load effective address: Indexing mode ONLY
                    fcs       "LEAX"
                    fcb       $30,$06
                    fcs       "LEAY"
                    fcb       $31,$06
                    fcs       "LEAS"
                    fcb       $32,$06
                    fcs       "LEAU"
                    fcb       $33,$06
* Register to register
                    fcs       "TFR"
                    fcb       $1F,$07
                    fcs       "EXG"
                    fcb       $1E,$07
                    fcs       "TFM"
                    fcb       $3B,$27             Prebyte of $11
* Stack push/pull
                    fcs       "PSHS"
                    fcb       $34,$08
                    fcs       "PULS"
                    fcb       $35,$08
                    fcs       "PSHU"
                    fcb       $36,$08
                    fcs       "PULU"
                    fcb       $37,$08
* Normal long branches (except LBRA & LBSR) - probably sets flag & then
* carries on through short branch table below
                    fcs       "LB"            for long branches?
                    fcb       $00,$19

* Short branches
L0530               fcs       "BSR"
                    fcb       $8D,$0A
                    fcs       "BRA"
                    fcb       $20,$0A
                    fcs       "BRN"
                    fcb       $21,$0A
                    fcs       "BHI"
                    fcb       $22,$0A
                    fcs       "BLS"
                    fcb       $23,$0A
                    fcs       "BHS"
                    fcb       $24,$0A
                    fcs       "BCC"
                    fcb       $24,$0A
                    fcs       "BLO"
                    fcb       $25,$0A
                    fcs       "BCS"
                    fcb       $25,$0A
                    fcs       "BNE"
                    fcb       $26,$0A
                    fcs       "BEQ"
                    fcb       $27,$0A
                    fcs       "BVC"
                    fcb       $28,$0A
                    fcs       "BVS"
                    fcb       $29,$0A
                    fcs       "BPL"
                    fcb       $2A,$0A
                    fcs       "BMI"
                    fcb       $2B,$0A
                    fcs       "BGE"
                    fcb       $2C,$0A
                    fcs       "BLT"
                    fcb       $2D,$0A
                    fcs       "BGT"
                    fcb       $2E,$0A
                    fcs       "BLE"
                    fcb       $2F,$0A

* Pseudo ops
                    fcs       "RMB"
                    fcb       $00,$0B
                    fcs       "FCC"
                    fcb       $01,$0B
                    fcs       "FDB"
                    fcb       $02,$0B
                    fcs       "FCS"
                    fcb       $03,$0B
                    fcs       "FCB"
                    fcb       $04,$0B
                    fcs       "EQU"
                    fcb       $05,$0B
                    fcs       "MOD"
                    fcb       $06,$0B
                    fcs       "EMOD"
                    fcb       $07,$0B
                    fcs       "SETDP"
                    fcb       $07,$0C
                    fcs       "SET"
                    fcb       $08,$0B
                    fcs       "OS9"
                    fcb       $09,$0B
                    fcs       "END"
                    fcb       $01,$0C
                    fcs       "NAM"
                    fcb       $02,$0C
                    fcs       "OPT"
                    fcb       $03,$0C
                    fcs       "TTL"
                    fcb       $04,$0C
                    fcs       "PAG"
                    fcb       $05,$0C
                    fcs       "SPC"
                    fcb       $06,$0C
                    fcs       "USE"
                    fcb       $08,$0C
* Conditional assembly switches
                    fcs       "IFEQ"
                    fcb       $00,$0D
                    fcs       "IFNE"
                    fcb       $01,$0D
                    fcs       "IFLT"
                    fcb       $02,$0D
                    fcs       "IFLE"
                    fcb       $03,$0D
                    fcs       "IFGE"
                    fcb       $04,$0D
                    fcs       "IFGT"
                    fcb       $05,$0D
                    fcs       "IFP1"
                    fcb       $06,$0D
                    IFNE      NEWDEF
                    fcs       "IFDEF"  =ifdef
                    fcb       $07,$0D
                    fcs       "IFNDF"  =ifndef
                    fcb       $08,$0D
                    ENDC      NEWDEF
                    fcs       "ELSE"
                    fcb       $01,$0E

L065F               fcc       'bad label'
                    fcb       $00
L0669               fcc       'bad instr'
                    fcb       $00
L0673               fcc       'in number'
                    fcb       $00
L067D               fcc       'div by 0'
                    fcb       $00
L0686               fcc       ' '
                    fcb       $00
L0688               fcc       'expr syntax'
                    fcb       $00
L0694               fcc       'parens'
                    fcb       $00
L069B               fcc       'redefined name'
                    fcb       $00
L06AA               fcc       'undefined name'
                    fcb       $00
L06B9               fcc       'phasing'
                    fcb       $00
L06C1               fcc       'symbol table full'
                    fcb       $00
L06D3               fcc       'address mode'
                    fcb       $00
L06E0               fcc       'out of range'
                    fcb       $00
L06ED               fcc       'result>255'
                    fcb       $00
L06F8               fcc       'reg name'
                    fcb       $00
L0701               fcc       'reg sizes'
                    fcb       $00
L070B               fcc       'input path'
                    fcb       $00
L0716               fcc       'object path'
                    fcb       $00
L0722               fcc       'index reg'
                    fcb       $00
L072C               fcc       '] missing'
                    fcb       $00
L0736               fcc       'needs label'
                    fcb       $00
L0742               fcc       'opt list'
                    fcb       $00
L074B               fcc       'const def'
                    fcb       $00
L0755               fcc       /can't open /
                    fcb       $00
L0761               fcc       'label not allowed'
                    fcb       $00
L0773               fcc       'cond nesting'
                    fcb       $00

* Index by opcode-type jump table
L0780               fdb       L079E-L0780         $001E  type 0 (LBRA/LBSR)
                    fdb       L07A5-L0780         $0025  type 1 (orcc/andcc/cwai)
                    fdb       L07B9-L0780         $0039  type 2 (16 bit reg ADDD,etc.)
                    fdb       L07CE-L0780         $004E  type 3 (8 bit reg ADDA, etc.)
                    fdb       L07F3-L0780         $0073  type 4 (CLR,etc. inherent)
                    fdb       L0826-L0780         $00A6  type 5 (Fixed inherent (RTS,etc)
                    fdb       L082F-L0780         $00AF  type 6 (LEAx)
                    fdb       L0846-L0780         $00C6  type 7 (Register to register)
                    fdb       L0884-L0780         $0104  type 8 (Stack PSH/PUL except W)
                    fdb       L089D-L0780         $011D  type 9 (Long branches)
                    fdb       L08BA-L0780         $013A  type A (Short branches)
                    fdb       L08DC-L0780         $015C  type B (Pseudo op - data and rmb)
                    fdb       L08E1-L0780         $0161  type C (Pseudo op - set values)
                    fdb       L08F9-L0780         $0179  type D (Pseudo op - conditionals)
                    fdb       L0F29-L0780         $07A9  type E (Pseudo op - ELSE/ENDC)
                    fdb       TypeF-L0780         $????  type F (bitfield ops OIM,BAND,etc)

* type 0 - LBRA/LBSR
L079E               lda       #$03                # bytes require for instruction
                    sta       <u0046              Save it
                    lbra      L0951

* type 1 - orcc/andcc/cwai 2 byte immediate mode only, forced register name
L07A5               bsr       L0932               Go find '# for immediate mode
                    bcc       twobyte             Found it, skip ahead
                    ldb       #12                 'address mode' error
                    lbsr      L02FA
* Legal 8 bit immediate mode goes here
twobyte             lda       #$01                Force # bytes of instruction to 1
                    sta       <u0046
                    lda       <u0047              Get flag/index option byte
                    bita      #$20                Pre-byte 11 bit flag on?
                    beq       L07AF               No, 2 byte instruction
                    inc       <u0046              Add 1 to # bytes to compensate for $11
L07AF               bsr       L12F7               Immediate mode parser
                    stb       <u0063              Store immediate value following opcode
                    inc       <u0046              Add 1 to # of bytes for immediate value
Rtrn1               rts


* Called by index mode handler
L12F1               lbsr      L11C2               Call expression evaluator
                    bcs       L1304               If error of some sort, report & return
L12F6               rts

* Immediate mode parser - byte operand
L12F7               lbsr      L11C2               Call expression evaluator
                    bcs       L1304               If error, report it & return
                    tsta
                    beq       Rtrn1
                    inca
                    beq       Rtrn1
                    ldb       #14                 'result>255' error
L1304               lbsr      L02FA               Print error
                    ldd       #$FFFF              Return with dummy value
L093E               orcc      #$01                And flag error
                    rts

L0932               lbsr      L1164               Parse for start of next field
                    cmpa      #'#                 Immediate mode specifier?
                    bne       L093E               No, exit with carry set
                    leax      1,x                 Bump source ptr up by 1, clear carry & return
                    andcc     #$FE                Flag immediate mode=Yes
                    rts

* type 2 - ADDD, LDX, STU etc. (16 bit register commands) (all modes)
L07B9               inc       <u0046              Add 1 to # bytes needed for instruction
                    bsr       L0932               Check if immediate mode requested
                    lbcs      L09C6               No, go check memory-based modes
                    ldd       <u0061              Get prebyte & opcode
                    cmpd      #$10CC              LDQ?
                    beq       ldqimm              Yes, do LDQ immediate
                    bsr       L12F1               Calculate normal immediate mode #'s
                    std       <u0063              Save 16 bit result after opcode
                    inc       <u0046              Add 2 to # bytes needed for instruction
                    inc       <u0046
* Immediate mode check - moved here for fall through
L0941               ldb       <u0047              Get current opcode's flag byte
                    bitb      #%01000000          Immediate mode legal?
                    bne       L0948               No, do something
                    rts                           Yes, return

L0948               ldb       #3                  Set size of illegal instruction to 3 bytes
                    stb       <u0046
                    ldb       #12                 'address mode' error
                    lbra      L02FA               Print error & return from there

* process LDQ immediate - 32 bit data
ldqimm              clra                          LDQ immediate has no prebyte
                    incb                          LDQ immediate opcode is $CD
                    std       <u0061              Save it over old prebyte/opcode
                    lda       #$5                 # of bytes for LDQ immediate
                    sta       <u0046
                    bsr       rut32
                    bcc       finldq
badnum              bne       outrng
                    ldb       #3                  'in number' error
                    fcb       $8C                 CMPX opcode to skip 2 bytes
outrng              ldb       #13                 'out of range' error
                    lbsr      L02FA               Call error printing routine
                    ldd       #$FFFF
                    std       <u004A
finldq              std       <u0065
                    ldd       <u004A
                    std       <u0063
                    rts

* === 32-bit numeric string conversions for LDQ# ===
* === returns MSWord in [u004A], LSWord in D.reg ===
* === (should be merged into L10B4 numeric code) ===
rut32               leas      -8,s                reserve a working area
                    clra                          and clear it to all 00
                    clrb
                    std       ,s
                    std       2,s
                    std       4,s
                    lbsr      L1164               skip spaces; get next char in reg.a
                    leax      1,x
                    cmpa      #'%                 binary?
                    lbeq      dobin32
                    cmpa      #'$                 hexadecimal?
                    beq       dohex32
                    leax      -1,x                assume decimal, point to 1st digit
* 32 bit decimal string conversion
dodec32             lbsr      L113B               convert from ascii
                    bcs       notnum              not 0-9
                    stb       ,s                  save temp
                    bsr       mul2                x2
                    ldd       2,s                 save partial
                    std       6,s
                    ldd       4,s                 in 67dd
                    bsr       mul2                x4
                    bsr       mul2                x8
                    bcs       ovflow
                    addd      4,s                 add #*2 +#*8= #*10
                    std       4,s
                    ldd       2,s
                    IFNE      H6309
                    adcd      #0
                    ELSE
                    adcb      #0
                    adca      #0
                    ENDC
                    bcs       ovflow
                    addd      6,s
                    bcs       ovflow
                    std       2,s
                    ldd       4,s
                    addb      ,s                  add in new digit
                    adca      #0
                    std       4,s
                    ldd       2,s
                    IFNE      H6309
                    adcd      #0
                    ELSE
                    adcb      #0
                    adca      #0
                    ENDC
                    bcs       ovflow
                    std       2,s
                    inc       1,s
                    bra       dodec32

* multiply caller's number by 2 (preserves D)
* stack map:  [0,1]rts [2,3]temps [4,5,6,7]number
mul2                lsl       7,s
mul2b               rol       6,s                 bin32 rol completion
                    rol       5,s
                    rol       4,s
                    rts

* conversion done. return MSW in [004A], LSW in D.reg
notnum              leax      -1,x
                    tst       1,s                 if no digits converted,
                    beq       setc32              not a number, exit with Z & C set
                    ldd       2,s                 return upper 16 bits in [u004A]
                    std       <u004A
                    ldd       4,s                 return lower 16 bits in D reg
                    andcc     #^1
                    bra       gotnum

* 32-bit overflow error, clear Z to flag as out of range
ovflow              andcc     #^4                 clear zero (flag out of range)
setc32              orcc      #1                  set carry (flag error)
gotnum              leas      8,s                 free work area
                    rts                           and return values

* 32 bit hexadecimal string conversion
dohex32             lbsr      L113B
                    bcc       notAF
                    cmpb      #'a
                    blo       nxtlt
                    subb      #'a-'A
nxtlt               cmpb      #'A
                    blo       notnum
                    cmpb      #'F
                    bhi       notnum
                    subb      #'A-10
notAF               stb       ,s
                    lda       2,s
                    bita      #$F0
                    bne       ovflow
                    bsr       mul2
                    bsr       mul2
                    bsr       mul2
                    bsr       mul2
                    ldd       4,s
                    adcb      ,s
                    adca      #0
                    std       4,s
                    ldd       2,s
                    IFNE      H6309
                    adcd      #0
                    ELSE
                    adcb      #0
                    adca      #0
                    ENDC
                    bcs       ovflow
                    std       2,s
                    inc       1,s
                    bra       dohex32

* 32 bit binary string conversion
dobin32             ldb       ,x+
                    subb      #'0
                    bcs       notnum
                    lsrb
                    bne       notnum
                    rol       5,s
                    bsr       mul2b               rotate bytes 4,3,2
                    bcs       ovflow
                    inc       1,s
                    bra       dobin32
* === end of 32-bit numeric conversions for LDQ# ===

* type 3 - 8 bit A & B based instructions (ADD, SUB, CMP, etc.)
L07CE               inc       <u0046              Add 1 to # bytes needed for instruction
                    ldd       <u0061              Get pre-byte & opcode
                    cmpd      #$118d              DIVD instruction?
                    beq       L07E7               Yes, skip register name parser
                    lda       ,x+                 Get next byte from source
                    anda      #$5F                Force to uppercase
                    cmpa      #'A                 Is it an A?
                    beq       L07E7               Yes, go process instruction
                    cmpa      #'E                 Is it an E?
                    beq       newreg              Yes, process
                    cmpa      #'F                 Is it an F?
                    bne       notnew              No, try B
* E or F register
newreg              pshs      a                   Preserve register name a moment
                    lda       <u0062              Get base opcode
                    cmpa      #$82
                    blo       legalcmd            SUB or CMP are ok
                    cmpa      #$86
                    blo       illegal3            SBC,AND & BIT are not ok
                    cmpa      #$88
                    blo       legalcmd            Load & store are ok
                    cmpa      #$8b
                    blo       illegal3            EOR, ADC & OR are not ok (ADD falls through ok)
* Legal E/F command, setup
legalcmd            lda       #$11                Pre-byte for E/F based commands
                    sta       <u0061              Place before opcode
                    inc       <u0046              Add 1 to # bytes needed for instruction
                    puls      a                   Get back register name
                    cmpa      #'F                 Is it F?
                    beq       L07E1               Yes, add mask for F
                    bra       L07E7               Go process various modes

notnew              cmpa      #'B                 Is it a B?
                    beq       L07E1               Yes, add B mask & process instruction
                    bra       illegal2            Illegal register name

* Illegal register (or illegal command for E or F)
illegal3            leas      1,s                 Eat E/F identifier byte
illegal2            leas      2,s                 Eat JSR return address
                    lbra      L015F               Exit with 'bad instr' error

* Mask for B or F commands
L07E1               ldb       #$40                Add offset for B register to base opcode
                    orb       <u0062
                    stb       <u0062
* Process various modes (Extended, DP, Indexed, Immediate)
L07E7               lbsr      L0932               Check for immediate mode
                    lbcs      L09C6               Not immediate, try memory modes
                    lbsr      L0941               Is this command allowed immediate mode?
                    lbra      L07AF               Go do immediate mode (8 bit)

* type 4 - CLR/LSL,etc.
L07F3               inc       <u0046              Inc # bytes in current instruction
                    lda       <u0062              Get base opcode
                    cmpa      #$0E                Is it JMP?
                    beq       L080B               Yes, special case (no inherent)
* Inherent register name commands
                    lda       ,x                  Get next char from source line
                    anda      #$5F                Uppercase only
* $xx40 commands here
                    ldb       #$40                Mask to opcode base for 'xxxA'
                    cmpa      #'A                 Is char an A?
                    beq       L0819               Yes, adjust opcode accordingly
                    cmpa      #'D                 Is char a D?
                    bne       notD                No, check next
Legal10             lda       #$10                Pre-byte for 'D' commands
Legal11             sta       <u0061              Put it before the opcode
                    inc       <u0046              Add 1 to # bytes for this instruction
                    bra       L0819               Go append the main opcode

notD                cmpa      #'E                 Is char an E?
                    bne       notE                No, check next
chkEF               lda       <u0062              Get base opcode
                    beq       illegal             NEGE/NEGF not allowed
                    cmpa      #$03                COMx?
                    beq       goodE               Yes, legal
                    cmpa      #$0A                LSR/ROR/ASR/LSL/ASL/ROL?
                    blo       illegal             Not allowed
goodE               lda       #$11                Rest are allowed, set pre-byte to $11
                    bra       Legal11

* $xx50 commands here
notE                ldb       #$50                Mask to opcode base for 'xxxB'
                    cmpa      #'B                 Is char a B?
                    beq       L0819               Yes, adjust opcode accordingly
                    cmpa      #'W                 Is char a W?
                    bne       notW                No, check next
                    lda       <u0062              Get base opcode
                    beq       illegal             There is no NEGW?
                    cmpa      #$7                 ASRW?
                    beq       illegal             Yes, there isn't one
                    cmpa      #$8                 LSL/ASLW?
                    bne       Legal10             Rest are legal, prefix a $10 & append opcode
* Illegal instructions go here
illegal             leas      2,s                 Eat JSR return address
                    lbra      L015F               Exit with illegal opcode error

notW                cmpa      #'F                 is it an F?
                    bne       L080B               Definately not a register, try memory modes
                    bra       chkEF               Go to generic E/F handler

L080B               lbsr      L09C6               Generic indexed/extended/direct handler???
                    ldb       <u0062              Get base opcode
                    bitb      #%11110000          Any of the 4 bits of high nibble set?
                    beq       L0825               No, return
                    orb       #%01000000          Yes, force bit on & return
                    stb       <u0062
                    rts

* Mask in adjustment for register inherent
L0819               orb       <u0062              Merge Mask for new inherent mode into opcode
                    stb       <u0062              Save new opcode
                    leax      1,x                 Bump source code ptr up to next char
* 6309 - aim #%11011111,<u002B
                    IFNE      H6309
                    aim       #%11011111,<u002B   Shut off 'operand field in src line' flag
                    ELSE
                    ldb       #%11011111          Shut off 'operand field in src line' flag
                    andb      <u002B              And save new flag byte
                    stb       <u002B
                    ENDC
L0825               rts

* RVH - adding 6309 bitfield ops (OIM,etc/BAND,etc) as new type F
* these instructions need special handling for the bitmode postbyte
* use comma delimiters since ASM uses '.' in symbols and as data ptr
TypeF               lda       <u0047              Get flag/index option byte
                    bita      #$20                Pre-byte 11 bit flag on?
                    bne       TypeF2              Yes, must be a bitfield op (BAND,etc)
* OIM/AIM/EIM/TIM - format is op #bitmask,addr(direct,extended,indexed)
* OIM group uses regular type 4 opcode mods for addressing modes
                    lbsr      L07A5               Go process immediate mode (bitmask)
                    stb       <u000C              temp storage - addr handler overwrites postbyte
                    clr       <u0063              which *MUST* be clean for address processing
                    bsr       synchk              check for comma delimiter
                    bsr       L080B               The Type 4 address handler also adjusts the opcode
* move the address bytes up by one to open a hole for the bitmask
fixpost3            ldd       <u0065-1            enter here to move 3 bytes (OIM group)
                    std       <u0065
fixpost1            ldb       <u0063              enter here to move 1 byte (BAND group)
                    lda       <u000C              grab the postbyte
                    std       <u0063              fill the hole
                    rts

* BAND-STBT - format is op rr,sss,ddd,addr (direct only) (prebyte is $11)
* arg fields 1,2,3 form the postbyte (rr ddd sss)
* where rr=CC/A/B/E, sss & ddd are src & dest bit number (0-7)
TypeF2              lbsr      L1164               Find next text field
                    leay      <BTable,pc          Load BAND group register table
                    ldb       #4                  only 4 table entries
                    stb       <u0046              also preset instruction length to 4
                    lbsr      L0971               Use the TRF/EXG scan routine
                    lbcs      L0852               If no match, report "reg name" error
                    sta       <u000C              found register, save bitmask
                    bsr       synchk              check for comma
                    bsr       getbit              get src bit number
                    orb       <u000C              update postbyte cc000xxx
                    stb       <u000C
                    bsr       synchk              check for comma
                    bsr       getbit              get dest bit number
                    lslb                          shift to 00xxx000
                    lslb
                    lslb
                    orb       <u000C              update postbyte ccdddsss
                    stb       <u000C
                    bsr       synchk              check for comma
                    lbsr      L09C6               Go process address
                    lda       #$04                Force # bytes of instruction to 4
                    sta       <u0046              to undo address mode increments
                    lda       <u004C              Get address mode flag
                    ble       L0841               If not direct, "address mode" error
                    bra       fixpost1            move postbyte into position, done!

* get bit number - must be 0-7, else "out of range" error
getbit              lbsr      L12F7               get bit number
                    cmpd      #7
                    bls       TypeF5              bit number valid
                    ldb       #13                 'out of range' error
                    bra       TypeFx              fix stack and exit

* do syntax check for comma, "expr syntax" error if not
synchk              lda       ,x+                 check for delimiter
                    cmpa      #',                 is it a comma?
                    bne       TypeF6              No, syntax error
TypeF5              rts

TypeF6              ldb       #06                 'expr syntax' error
TypeFx              leas      2,s                 eat return addr
                    leax      -1,x                roll ptr back to offending char
                    lbra      L02FA               exit, report error

* BAND register table: 2 bytes for reg name, 1 byte for postbyte bitfield
BTable              fcb       'E,00,$C0
                    fcb       'A,00,$80
                    fcb       'B,00,$40
                    fcb       'C,'C,$00
* Type F end

* type 5 - 'fixed' inherent commands (no options for registers, etc.)
L0826               inc       <u0046              Add 1 to # bytes this instruction
* 6309 - aim #%11011111,<u002B
                    IFNE      H6309
                    aim       #%11011111,<u002B   Shut off 'operand present' flag
                    ELSE
                    ldb       <u002B
                    andb      #%11011111          Shut off 'operand present' flag
                    stb       <u002B
                    ENDC
L082E               rts

* type 6 - LEA* (indexed mode ONLY)
L082F               inc       <u0046              Add 1 to # bytes this instruction
                    lbsr      L09C6               Go set up indexed mode
                    lda       <u004E              Get indexed mode flag
                    bne       L082E               Is indexed mode, everything went fine, exit
                    ldd       #$1212              Otherwise, 2 NOP codes
                    std       <u0062              Save as opcodes
                    ldb       #$02                Force # bytes this instruction to 2
                    stb       <u0046
L0841               ldb       #12                 'address mode' error
                    lbra      L02FA

* type 7 - TFR/EXG & Register to register
L0846               inc       <u0046              at least 2 bytes in this instruction
                    inc       <u0046
                    lbsr      L1164               Find next text field
                    lbsr      L096B               Get 1st register name
                    bcs       L0852               Illegal register name, exit
                    lda       <u0062              check the opcode
                    suba      #$38                Is this a TFM? (38-3B)
                    sta       <u000C              save result for later TST
                    bmi       L0857               No, continue normally
                    cmpb      #4                  Legal TFM register?
                    bls       r0mode              Yes, check for mode flag
L0851               comb                          No, set carry
L0852               ldb       #15                 else 'reg name' error
L0854               lbra      L02FA

* legal TFM reg0: check for R0 auto inc/dec mode
r0mode              lda       ,x+                 Get next char from source
                    cmpa      #'+                 Incrementing source counter?
                    beq       tfmdec1             Yes, assume r+,r (op=$3A)
                    cmpa      #'-                 decrementing source counter?
                    bne       ckcomma             No + or -, assume r,r+ (op=$3B)
* initial tfm opcode from table is 3B
tfmdec2             dec       <u0062              Sets TFM op to $39 for r-,r-
tfmdec1             dec       <u0062              Sets TFM op to $3A for r+,r
* make sure a comma follows
L0857               lda       ,x+                 Get next char
ckcomma             cmpa      #',                 comma?
                    bne       L0851               No, exit with 'reg name' error
                    stb       <u0064              save R0 for later
                    lbsr      L1164               Find next text field
                    lbsr      L096B               Get 2nd register name
                    bcs       L0852               If 2nd name illegal, exit with error
                    tst       <u000C              Is this a TFM? (38-3B)
                    bmi       chkspc              No, continue normally
                    cmpb      #4                  Legal TFM register?
                    bhi       L0851               No, 'reg name' error
* legal TFM reg1: check for R1 auto inc/dec
                    lda       ,x+                 Get next char from source
tfm39               cmpa      #'-                 decrementing source counter?
                    bne       tfm38               No, try R1+
                    lda       #$39                expect op=39 (R-,R-)
                    bra       verify              check if valid R-,R-

tfm38               cmpa      #'+                 incrementing dest counter?
                    bne       tfm3a
                    lda       #$3A
                    cmpa      <u0062              was it R0+,R1+
                    bne       tfm3b
                    lda       #$38                Yes, make op=38 (R+,R+)
                    sta       <u0062
                    bra       chkspc              and verify whitespace follows

tfm3b               inca                          check for op=3b (R,R+)
verify              cmpa      <u0062              is it the expected op?
                    beq       chkspc              Yes, valid TFM, check for EOL/spc
tfmerr              comb                          No, illegal TFM format:
                    ldb       #12                 flag 'reg name' error
                    bra       L0854               and exit

tfm3a               lda       #$3A                expect op=3a (R+,R)
                    cmpa      <u0062              was it R0+,R1
                    bne       tfmerr              illegal R1 form, 'reg name' error
                    leax      -1,x                rewind to current char
chkspc              lbsr      L0B08               look for space or CR, addr mode error
* Normal EXG/TFR/Reg to Reg, just have to check sizes
chksz               lda       <u0064              Get source register back
                    pshs      d                   Preserve both
                    cmpa      #12                 Is source register the 0 register?
                    beq       L0879               Yes, destination size doesn't matter
                    eora      1,s                 Compare register sizes
                    anda      #%00001000          Check if they are same size
                    beq       L0879               Yes, continue
                    anda      ,s                  if not, check if R0=16bit
                    bne       sizerr              No, 8->16 always bad
                    lda       <u0062              but 16->8 is OK
                    cmpa      #$1E                unless op=EXG
                    bne       sizewarn            if not, issue a mismatch warning
sizerr              ldb       #16                 Otherwise, 'reg sizes' error
                    leas      $02,s               Eat copies of regs
                    bra       L0854               and exit

sizewarn            inc       <u004F              warning flag: reg size mismatch
* Create operand byte
* Entry: Stack contains Source & Destination register masks
L0879               puls      a                   Get back source register
                    lsla                          Move into most significiant nibble
                    lsla
                    lsla
                    lsla
                    ora       ,s+                 Merge with destination register
                    sta       <u0063              Save after opcode & return
                    rts

* type 9 (long branches except LBRA/LBSR)
L089D               lda       #$04                Force # of bytes of instruction to 4
                    sta       <u0046
                    leax      -1,x                Bump ptr back to start of mnemonic
                    ldb       #19                 # opcodes to check in table
                    leay      >L0530,pc           Point to branch opcode tables
                    lbsr      L0344               Go find & verify it
                    bcc       L08B3               Found it, continue
                    leas      2,s                 Eat stack
                    lbra      L015F               Exit with error

L08B3               lda       ,y
                    sta       <u0062
                    bra       L0951

* type 10 (short branches)
L08BA               lda       #$02                Force # of bytes of instruction to 2
                    sta       <u0046
                    lbsr      L12F1
                    subd      <u0040              Subtract current code address (*)
                    subd      #$0002              Subtract two for size of BRA itself
                    cmpd      #127                Within range for positive branch?
                    bgt       L08D2               No, out of range error
                    cmpd      #-128               Within range for negative branch?
                    bge       L08D9               Yes, save branch offset
L08D2               ldb       #13                 No, 'out of range' error
                    lbsr      L02FA               Print error out
                    ldb       #-2                 If error, default to branch to itself (infinite loop)
L08D9               stb       <u0063
                    rts

* type $B (Pseudo ops)
L08DC               leau      <L08FE,pc           Point to table
                    bra       L08EF

* Type $C
L08E1               ldb       <u002B
                    bitb      #$08
                    beq       L08EC
                    ldb       #25                 'label not allowed' error
                    lbsr      L02FA               Print error out
L08EC               leau      <L0912,pc           Point to table
L08EF               lbsr      L1164               Hunt down next field in source string
                    ldb       <u0062
                    lslb                          2 byte entries
                    ldd       b,u
                    jmp       d,u

* Type $D
L08F9               leau      <L0924,pc           Point to table
                    bra       L08EF

* 2 byte jump table (type B)
L08FE               fdb       L0BA6-L08FE         RMB
                    fdb       L0C47-L08FE         FCC
                    fdb       L0CBF-L08FE         FDB
                    fdb       L0C6B-L08FE         FCS
                    fdb       L0CAD-L08FE         FCB
                    fdb       L0C27-L08FE         EQU
                    fdb       L0D60-L08FE         MOD
                    fdb       L0D40-L08FE         EMOD
                    fdb       L0C2B-L08FE         SET
                    fdb       L0D51-L08FE         OS9

* Another 2 byte jump table (type C)
L0912               fdb       L0DB9-L0912         ORG
                    fdb       L0DC1-L0912         END
                    fdb       L0DD4-L0912         NAM
                    fdb       L0E2C-L0912         OPT
                    fdb       L0DFD-L0912         TTL
                    fdb       L0E03-L0912         PAG
                    fdb       L0E09-L0912         SPC
                    fdb       L0EB3-L0912         SETDP
                    fdb       L0EC4-L0912         USE

* Another 2 byte jump table (type D)
L0924               fdb       L0EE3-L0924         IFEQ
                    fdb       L0EE8-L0924         IFNE
                    fdb       L0EED-L0924         IFLT
                    fdb       L0EF2-L0924         IFLE
                    fdb       L0EF7-L0924         IFGE
                    fdb       L0EFC-L0924         IFGT
                    fdb       L0F01-L0924         IFP1
                    IFNE      NEWDEF
                    fdb       Lidef-L0924         IFDEF
                    fdb       Lndef-L0924         IFNDF
                    ENDC      NEWDEF

* Long Relative address calculation for LBRA/LBSR, etc
L0951               lbsr      L12F1
                    subd      <u0040              Subtract current code address (*)
                    subb      <u0046              Subtract # bytes in current instruction
                    sbca      #$00                16 bit subtract
                    std       <u0063              Save 16 bit branch offset in assembled instruction buffer
                    cmpd      #127                If positive branch, within 8 bit range?
                    bgt       L096A               No, return
                    cmpd      #-128               If negative branch, within 8 bit range?
                    blt       L096A               No, return
                    inc       <u004F              warning flag: we could use short rel here
L096A               rts

* type 8 (Stack push/pull)
L0884               ldb       #$02                Force # bytes for instruction to 2
                    stb       <u0046
                    lbsr      L1164               Parse to next field
L088B               bsr       L096B               Get register mask
                    lbcs      L0852               Illegal one, exit with 'register name' error
                    ora       <u0063              Mask in bit for new reg into byte after opcode
                    sta       <u0063
                    lda       ,x+                 Get next char from source
                    cmpa      #',                 Comma?
                    beq       L088B               Yes, more register masks to get
                    leax      -1,x                Bump src code ptr back 1 & return
                    rts


* Entry: X=ptr to start of reg name from source
* Exit:  A=Bit mask for PSH/PUL
*        B=Bit mask for EXG/TFR
L096B               leay      <L09A2,pc           Point to register names
                    ldb       #16                 # of register names to check
* Alternate entry for BAND regname search
L0971               pshs      x                   Save start of current register we are checking
L0973               lda       ,y                  Get byte from reg. name
                    beq       L098F               If NUL (empty entry), skip this entry
                    cmpa      ,x+                 Compare with source
                    beq       L0981               Equal, skip ahead
                    eora      #$20                Toggle lowercase (also fixes 0 register bug)
                    cmpa      -1,x                Compare with source
                    bne       L098F               Not equal, skip ahead
* Found reg name we want
L0981               lda       1,y                 Get 2nd char of reg name
                    beq       L099A               NUL, only 1 char, so we match
                    cmpa      ,x+                 2nd char match too?
                    beq       L099A               Yes, found reg
                    adda      #$20                Convert to lowercase
                    cmpa      -1,x                Does that match?
                    beq       L099A               Yes, found it
* Not the register name we want, try next one
L098F               ldx       ,s                  Get ptr to start of current register
                    leay      3,y                 Bump to next one
                    decb                          Dec # registers left to check counter
                    bne       L0973               Keep doing till done
                    orcc      #$01                Set carry flag (illegal register name)
                    puls      pc,x                Restore X & return

* Found register name we wanted
L099A               decb                          Adjust B (EXG/TFR mask)
                    leas      2,s                 Eat X off the stack
                    lda       2,y                 Get PSH/PUL bit mask
                    andcc     #$FE                No error & return
                    rts

* Stack table: 2 bytes for reg. name, 1 byte for bit mask for PSH/PUL
* Positions (done in reverse from highest to lowest) indicates the bit
* mask for register to register operations (ex. TFR)
L09A2               fcb       'F,00,$00           %1111 F
                    fcb       'E,00,$00           %1110 E
                    fcb       00,00,$00           %1101 (2nd zero register won't be used)
                    fcb       '0,00,$00           %1100 Zero register
                    fcb       'D,'P,$08           %1011 DP
                    fcb       'C,'C,$01           %1010 CC
                    fcb       'B,00,$04           %1001 B
                    fcb       'A,00,$02           %1000 A
                    fcb       'V,00,$00           %0111 V
                    fcb       'W,00,$00           %0110 W
                    fcb       'P,'C,$80           %0101 PC
                    fcb       'S,00,$40           %0100 S
                    fcb       'U,00,$40           %0011 U
                    fcb       'Y,00,$20           %0010 Y
                    fcb       'X,00,$10           %0001 X
                    fcb       'D,00,$06           %0000 D (A & B combined)

* Generic memory mode addressing handler: Indexed, Extended, Direct Page
L09C6               lbsr      L1164               Parse for next field in source
                    bsr       L0A14               Check for '<' (DP) & '>' (Extended) modes
                    cmpa      #'[                 Next char indicate indirect mode?
                    bne       L09D7               No, try next
                    inc       <u004D              Set flag for indirect mode
                    leax      1,x                 Bump src code ptr up by 1
                    lda       ,x                  Get next byte
                    bsr       L0A14               Check for '<' or '>' & set flag
L09D7               cmpa      #',                 Comma?
                    lbeq      L0A64               Yes, skip ahead for ,R/,R auto inc/dec
* comma is not first char
                    ldb       1,x                 No, get next char into B
                    cmpb      #',                 Is it a comma? (ie 1st was register name?)
                    bne       L09F1               No, try label/number routine ???
                    anda      #$DF                Force to uppercase
                    cmpa      #'A                 Is it an A?
                    beq       L0A27               Yes, go process
                    cmpa      #'B                 Is it a B?
                    beq       L0A2B               Yes, go process
                    cmpa      #'D                 Is it a D?
                    beq       L0A2F               Yes, go process
                    cmpa      #'E                 Is it an E?
                    beq       MaskE
                    cmpa      #'F                 Is it an F?
                    beq       MaskF
                    cmpa      #'W                 Is it a W?
                    beq       MaskW
* Not a R0,xx... try for numeric or label
L09F1               lbsr      L12F1               Parse for numeric (returns 16 bit # in D)
                    bcc       L09F8               Found one, preserve it
                    clra                          Otherwise, default to 0
                    clrb
L09F8               std       <u004A              Save 16 bit address
                    lda       ,x                  Get char from src code
                    cmpa      #',                 Comma?
                    lbeq      L0B18               Yes, skip way ahead
                    ldb       <u004D              Get indirect mode flag
                    bne       L0A35               If on, skip ahead
                    ldb       <u004C              Get Extended/DP/Indexed mode flag
                    bmi       L0A35               If Extended, go do it
                    bne       L0A53               If Direct Page, go somewhere else
                    lda       <u004A
                    cmpa      <u003F              Same as current SetDP value?
                    beq       L0A53               Yes, go handle as DP addressing
                    bra       L0A35               No, go handle as Extended addressing

* Check for '>' or '<' (Extended or Direct Page addressing)
* Set flag @ <u004C to $FF for >, $01 for <
* Entry: A=char to check from source
L0A14               ldb       #$FF                16 bit addressing flag
                    cmpa      #'>                 16 bit addressing?
                    beq       L0A20               Yes, set flag
                    cmpa      #'<                 8 bit addressing?
                    bne       L0A26               No, return
                    ldb       #$01                8 bit addressing flag
L0A20               stb       <u004C              Save bit size addressing flag
                    leax      1,x                 Bump source ptr
                    lda       ,x                  Get next char & return
L0A26               rts

* A,R comes here
L0A27               ldb       #%10000110
                    bra       L0A31

* B,R comes here
L0A2B               ldb       #%10000101
                    bra       L0A31

* D,R comes here
L0A2F               ldb       #%10001011
                    bra       L0A31

* E,R comes here
MaskE               ldb       #%10000111
                    bra       L0A31

* F,R comes here
MaskF               ldb       #%10001010
                    bra       L0A31

* W,R comes here
MaskW               ldb       #%10001110
L0A31               leax      1,x                 Bump src ptr up by 1
                    bra       L0A97               Skip ahead

* Extended Indirect indexed or Extended modes go here
L0A35               ldd       <u004A              Get 16 bit address
                    inc       <u0046              Add 2 to # bytes for instruction
                    inc       <u0046
                    inc       <u004F              warning flag: extended addressing mode
                    tst       <u004D              Indirect mode on?
                    bne       L0A4A               Yes, Need to add $9F postbyte first
                    std       <u0063              Save extended address
* 6309 - OIM #%00110000,<u0062 (I don't think B needs preserved on exit)
                    IFNE      H6309
                    oim       #%00110000,<u0062   Mask in bit flags for extended mode & return
                    ELSE
                    ldb       #%00110000          Mask in bit flags for extended mode & return
                    orb       <u0062
                    stb       <u0062
                    ENDC
                    rts

* Extended indirect (ex. JMP [<$2000])
L0A4A               std       <u0064              Store 16 bit address after post-byte
                    ldb       #%10011111          Append $9f post-byte for Extended Indirect
                    stb       <u0063
                    lbra      L0AEA

* Direct page mode
L0A53               inc       <u0046              Add 1 to # bytes this instruction
                    ldb       #$01                Set direct mode flag
                    stb       <u004C              (used by Type F BAND ops)
                    ldb       <u004B              Get 8 bit # (LSB of D from L12F1)
                    stb       <u0063              Save it as DP address
                    ldb       <u0062              get opcode
                    bitb      #%11110000          Is it a $0-$F Direct page command?
                    beq       L0A63               Yes, opcode is fine
                    orb       #%00010000          No, force DP mode bit on in opcode
                    stb       <u0062
L0A63               rts

* Comes here if first char is ',' (after parsing '[' if needed)
L0A64               leax      1,x                 Bump source ptr up by 1
                    clra                          Clear 16 bit offset address (3 cyc faster/6809,4 cyc faster/6309)
                    clrb
                    std       <u004A
                    ldd       ,x                  Get 2 chars from source
                    cmpd      #$2D2D              '--' ?
                    beq       L0A8D               Yes, go merge mask for --
                    cmpa      #'-                 '-' ?
                    beq       L0A93               Yes, go merge mask for -
                    bsr       L0AC7               Otherwise, Go find base index register (X,Y,U,S)
                    lbcs      L0B68               Couldn't find one, check for 'PC' offset
* Found base register
                    stb       <u0063              Save base register bit mask in postbyte
                    ldd       ,x                  Get next 2 chars from src (after base reg. name)
                    cmpd      #$2B2B              '++' ?
                    beq       L0AAB               Yes, go process
                    cmpa      #'+                 '+' ?
                    beq       L0AB1               Yes, go process
                    lbra      L0B22

* Mask for double dec. mode
L0A8D               leax      1,x                 Bump src ptr up by 1
                    ldb       #%10000011          Mask for -- mode
                    bra       L0A97               Merge into post byte

* Mask for single dec. mode
L0A93               bsr       L0ABD               Make sure we aren't indirect-it's illegal
                    ldb       #%10000010          Mask for - mode
L0A97               stb       <u0063              Save mask in postbyte
                    leax      1,x                 Bump src ptr up 1 byte
                    bsr       L0AC7               Go get base register (X,Y,U,S)
                    bcc       L0AA5               Found it, merge in base register mask
*
* W CHECK SHOULD GO HERE (but --/-/ or A/B/D/E/F/W,R all come here)
*
                    lda       ,x                  Get base reg name again
                    anda      #$5F                Force to upper case
                    cmpa      #'W                 Is it a W?
                    bne       Noway               No, completely illegal
                    ldb       <u0063              Get current post byte mask
                    cmpb      #%10000011          Is it a '--'?
                    bne       Noway               No, that is the only legal '-' type for W
                    leax      1,x                 Bump ptr past 'W'
                    tst       <u004D              Indirect?
                    beq       NormWMn             No, use normal ,--W mask
                    ldb       #%11100000          Bit mask for [,--W] except for Indirect bit
                    stb       <u0063              Save in post byte
                    bra       L0AEA               Finish processing

NormWMn             ldb       #%11101111          Bit mask for ,--W
                    stb       <u0063              Save in post byte
                    bra       L0AEA               Finish processing

Noway               orcc      #$01                Set error flag
*++ end of W check
L0A9F               ldb       #19                 illegal 'index reg' error
                    lbsr      L02FA
                    clrb                          So clear postbyte to 0
L0AA5               orb       <u0063              Merge in mask into postbyte
                    stb       <u0063
                    bra       L0AEA

* Mask for double inc. mode
L0AAB               ldb       #%10000001          Mask for ++ mode
                    leax      1,x                 Bump up src ptr by 1
                    bra       L0AB5               Merge into postbyte

* Mask for single inc. mode
L0AB1               bsr       L0ABD               Make sure we aren't indirect-it's illegal
                    ldb       #%10000000          Mask for + mode
L0AB5               leax      1,x                 Bump up src ptr by 1
                    orb       <u0063              Merge in auto inc. modes
                    stb       <u0063
                    bra       L0AEA

* Check ,-R or ,R+: illegal if INDIRECT mode
L0ABD               tst       <u004D              Check indirect mode flag
                    beq       L0B17               Normal, exit
                    ldb       #12                 Indirect ,-R is illegal, 'address mode' error
                    lbra      L02FA               Report error & return from there

* Exit: B=bit mask for proper index register (X,Y,U,S)
*       carry set=not legal register
L0AC7               lda       ,x+                 Get next char from source
                    anda      #$5F                Force to uppercase
                    clrb                          X register mask
                    cmpa      #'X                 X register?
                    beq       L0AE2               Yes, acceptable
                    ldb       #%00100000          Y register mask
                    cmpa      #'Y                 Y register
                    beq       L0AE2
                    lslb                          U register mask (%01000000) slightly smaller/faster than ldb #
                    cmpa      #'U                 U register?
                    beq       L0AE2
                    ldb       #%01100000          S register mask
                    cmpa      #'S                 S register?
                    bne       L0AE5               No, not a 'x,R' or 'R+/++' situation
L0AE2               andcc     #$FE                No error & return
                    rts

L0AE5               leax      -1,x                Bump source ptr back
                    orcc      #$01                Set carry (couldn't find index register) & return
L0B17               rts

* Part of indexed mode handler
* This part sets the INDEXED mode bit in the opcode itself, and also sets
* the INDIRECT bit in the postbyte. Both of these are compatible with the new
* W modes (with W being the base register), so this routine does not have to
* be changed.
* NOTE: Can't using oim on 6309; needs to be in B afterwards
L0AEA               ldb       #%00100000          Mask bit for indexed instruction opcodes
                    orb       <u0062              Force instruction to indexed mode
                    stb       <u0062
                    inc       <u0046              Add 1 to size of instruction
                    inc       <u004E              Flag that indexed mode calc is complete
                    tst       <u004D              Indirect mode active?
                    beq       L0B08               No, skip ahead
* NOTE: Can't using oim on 6309; needs to be in B afterwards
                    ldb       #%00010000          Indirect mode bit mask
                    orb       <u0063              Mask into Postbyte
                    stb       <u0063
                    lda       ,x+                 Get next char from source
                    cmpa      #']                 End of indirect mode?
                    beq       L0B08               Yes, go check for end of line
                    ldb       #20                 '] missing' error
                    bra       L0B14

L0B08               lda       ,x                  Get char from source
                    cmpa      #C$SPAC             Space?
                    beq       L0B17               Yes, exit
                    cmpa      #C$CR               CR?
                    beq       L0B17               Yes, exit
L0B12               ldb       #12                 'address mode' error
L0B14               lbra      L02FA               Report error & return

L0B18               leax      1,x                 Bump src ptr up by 1
                    bsr       L0AC7               Get index register mask into B
                    bcs       L0B68               Wasn't X,Y,U,S; skip to checking special ones (PC,etc)
                    orb       <u0063              Merge index register mask into assembled instruction
                    stb       <u0063
L0B22               ldd       <u004A              Get address/offset word
                    tst       <u004C              Check if DP (8 bit), Extended (16 bit) or Other mode
                    bmi       L0B5A               Extended/16 bit, skip ahead
                    bne       L0B52               Direct page/8 bit, skip ahead
* 6309 - TSTD
                    IFNE      H6309
                    tstd                          If offset 0?
                    ELSE
                    ldd       <u004A              Is offset 0?
                    ENDC
                    bne       L0B32               <>0, skip ahead
                    ldb       #$84                Force post byte to no offset (leaving register bits to 0 for now)
                    bra       L0B62

L0B32               tst       <u004D              Indirect mode?
                    bne       L0B46               Yes, skip ahead
                    cmpd      #15                 Within +15 range?
                    bgt       L0B46               No, check next range
                    cmpd      #-16                Within -16 range?
                    blt       L0B46               No, check next range
                    andb      #$1F                Mask for 5 bit signed offset
                    bra       L0B62               Save byte into current assembled instruction

L0B46               cmpd      #127                Within +127 range?
                    bgt       L0B5A               No, used full 16 bit signed value
                    cmpd      #-128               Within -128 range?
                    blt       L0B5A               No, used full 16 bit signed value
L0B52               stb       <u0064              8 bit offset, save offset into current assembled instruction
                    inc       <u0046              Increase size of current instruction
                    ldb       #$88                Bits for 8 bit signed offset for indexed
                    bra       L0B62               Go merge with register bits we already figured out

L0B5A               std       <u0064              Save 16 bit signed offset into current assembled instruction
                    inc       <u0046              Increase size of current instruction by 2
                    inc       <u0046
                    ldb       #$89                Bits for 16 bit signed offset for indexed
L0B62               orb       <u0063              Merge with register bits we already figured out in current assembled instruction
                    stb       <u0063
                    bra       L0AEA               Finish processing indexed instruction (indirect, etc.)

L0B68               ldd       ,x                  Get next 2 chars from source
                    IFNE      H6309
                    andd      #$5F5F              Force case
                    ELSE
                    anda      #$5F                Force case
                    andb      #$5F
                    ENDC
                    cmpd      #$5043              'PC' reg?
                    beq       GotPC               Yes, do PC addressing
                    cmpa      #'W                 Is it 'W'?
                    lbne      L0A9F               No, return with 'illegal reg' error
                    leax      1,x                 Bump ptr past 'W'
                    ldd       <u004A              Get offset calculated (if any)
                    beq       TryWplus            None, try W+
                    std       <u0064              Save offset for mmmm,W
                    inc       <u0046              Add 2 to opcode byte count
                    inc       <u0046
                    tst       <u004D              Indirect mode on?
                    bne       DoInd2              Yes, do that mask
                    ldb       #%10101111          mmmm,W
                    bra       SaveMsk             Finish things up

DoInd2              ldb       #%10110000          [mmmm,W]
                    bra       SaveMsk             Finish things up

TryWplus            ldd       ,x                  Get next 2 bytes
                    cmpd      #$2B2B              Is it '++'?
                    beq       DoWplus             Yes, go do that
                    cmpa      #'+                 Is it '+'?
                    lbeq      L0B12               Yes, 'Address mode' error
                    cmpa      #C$SPAC             Next char a space?
                    beq       JustW               Yes, just ,W
                    cmpa      #C$CR               CR?
                    beq       JustW               Yes, just ,W
                    cmpa      #']                 Close (for indirect)?
                    lbne      L0B12               No, 'Address mode' error
JustW               tst       <u004D              Indirect mode on?
                    bne       DoInd               Yes, make appropriate mask
                    ldb       #%10001111          Normal ,W mask
SaveMsk             stb       <u0063              Save it
                    lbra      L0AEA               Go finish things up

DoInd               ldb       #%10010000          [,W] mask
                    bra       SaveMsk             Finish it up

DoWplus             leax      2,x                 Bump ptr past '++'
                    tst       <u004D              Indirect mode on?
                    bne       Indplus             Yes, go make mask
                    ldb       #%11001111          ,W++
                    bra       SaveMsk

Indplus             ldb       #%11010000          [,W++]
                    bra       SaveMsk

* ,PC or ,PCR comes here
GotPC               leax      2,x                 Bump source ptr past PC
                    lda       ,x
                    anda      #$5F
                    cmpa      #'R                 'pcR'?
                    bne       L0B82               No, skip ahead
                    leax      1,x                 Yes, bump src ptr past PCR
L0B82               inc       <u0046              Bump up # bytes in current instruction
                    ldd       <u004A              Get 16 bit offset value
                    subd      <u0040              Subtract current code address (*)
                    subb      <u0046              Subtract # bytes in current instruction
                    sbca      #$00
                    subd      #$0001              Subtract 1 more (,PC always has extra byte; there is no 5 bit option)
                    tst       <u004C              Check addressing mode flag
                    bmi       L0B9B               Extended (16 bit offset) mode, skip ahead
                    beq       L0B9B               Not DP/8 bit mode; treat as 16 bit anyways
                    stb       <u0064              8 bit mode, save byte into current assembled instruction stream
                    ldb       #$8C                Add these bits to first parm byte for instruction
                    lbra      L0B62

L0B9B               subd      #$0001              Subtract one from offset
                    inc       <u0046              Bump # of bytes in current instruction up by 1
                    std       <u0064              Save 16 bit offset into current assembled instruction
                    ldb       #$8D                Add these bits to first parm byte for instruction
                    lbra      L0B62

* RMB pseudo op
L0BA6               bsr       L0BE4               Calc size of RMB into D
                    pshs      d                   Save it
                    addd      <u0026              Add to total data bytes allocated
                    std       <u0026              Save updated total data bytes allocated
                    bsr       L0BEF               Is label flag set in listing print control flags?
                    beq       L0BB6               No, skip ahead
                    lda       #$04
                    bsr       L0BF7
L0BB6               bsr       L0BD8
                    bsr       L0BEF
                    beq       L0BBE
                    bsr       L0C0A
L0BBE               addd      ,s++
L0BC0               sta       <TmpNum
                    lda       <u002B
                    anda      #Label
                    ora       #Operand+Command+PrintPC
                    sta       <u002B
                    lda       <TmpNum
                    tst       <u005A
                    beq       L0BD3
                    std       <u0040
                    rts

L0BD3               std       <u0042
                    inc       <u002C
                    rts

L0BD8               tst       <u005A
                    beq       L0BDF
                    ldd       <u0040
                    rts

L0BDF               ldd       <u0042
                    std       <u0044
                    rts

* Calc size of RMB, etc.
L0BE4               lbsr      L11C2
                    bcc       L0BEE
                    lbsr      L02FA
                    clra
                    clrb
L0BEE               rts

* Check if Label flag set in listing print control flags
* Exit:
L0BEF               pshs      a
                    lda       <u002B              Get Listing Print Control bit flags
                    bita      #Label              Label flag set?
                    puls      pc,a

L0BF7               ldu       <u002D              Get temp ptr to last symbol found/added
                    ldb       8,u                 Get symbol type
                    bmi       L0C09
                    cmpb      #$02
                    bne       L0C07
                    cmpa      #$02
                    beq       L0C07
                    ora       #$80
L0C07               sta       $08,u
L0C09               rts

L0C0A               tst       <u003E
                    ble       L0C24
                    cmpd      $09,u
                    beq       L0C26
                    pshs      d
                    lda       $08,u
                    bmi       L0C22
                    cmpa      #$02
                    beq       L0C22
                    ldb       #10                 'phasing' error
                    lbsr      L02FA
L0C22               puls      d
L0C24               std       9,u
L0C26               rts

** EQU pseudo op
L0C27               lda       #$03
                    bra       L0C2D

** SET pseudo op
L0C2B               lda       #$02
L0C2D               bsr       L0BEF
                    bne       L0C38
                    ldb       #21                 'needs label' error
                    lbsr      L02FA
                    bra       L0C46

L0C38               bsr       L0BF7
                    bsr       L0BE4
                    ldu       <u002D
                    bsr       L0C0A
                    std       <u0044
                    ldb       #Operand+Command+Label+PrintPC
                    stb       <u002B
L0C46               rts

** FCC pseudo op
L0C47               lda       ,x+
                    pshs      a
                    cmpa      #C$CR
                    beq       L0C64
                    cmpa      #'/
                    bhi       L0C64
                    bsr       L0C8D
L0C55               lda       ,x+
                    cmpa      ,s
                    beq       L0C69
                    cmpa      #C$CR
                    beq       L0C64
                    lbsr      L0CEC
                    bra       L0C55

L0C64               ldb       #23                 'const def' error
                    lbsr      L02FA
L0C69               puls      pc,a

** FCS pseudo op
L0C6B               lda       ,x+
                    pshs      a
                    cmpa      #C$CR
                    beq       L0C64
                    cmpa      #'/
                    bhi       L0C64
                    bsr       L0C8D
L0C79               ldd       ,x+
                    cmpa      #C$CR
                    beq       L0C64
                    cmpa      ,s
                    beq       L0C69
                    cmpb      ,s
                    bne       L0C89
                    ora       #$80
L0C89               bsr       L0CEC
                    bra       L0C79

L0C8D               pshs      x,a
                    leax      -1,x
L0C91               leax      1,x
                    lda       ,x
                    cmpa      #C$CR
                    beq       L0CA1
                    cmpa      ,s
                    bne       L0C91
                    leax      1,x
                    lda       ,x
L0CA1               clr       ,x+
                    stx       <u0033
                    cmpa      #C$CR
                    bne       L0CAB
                    sta       ,x
L0CAB               puls      pc,x,a

** FCB pseudo op
L0CAD               bsr       L0CD5
L0CAF               lbsr      L12F7
                    tfr       b,a
                    bsr       L0CEC
                    lda       ,x+
                    cmpa      #',                 comma?
                    beq       L0CAF
                    leax      -1,x
                    rts

** FDB pseudo op
L0CBF               bsr       L0CD5
L0CC1               lbsr      L12F1
                    pshs      b
                    bsr       L0CEC
                    puls      a
                    bsr       L0CEC
                    lda       ,x+
                    cmpa      #',                 comma?
                    beq       L0CC1
                    leax      -1,x
                    rts

L0CD5               pshs      x
L0CD7               lbsr      L12F1
                    lda       ,x+
                    cmpa      #',                 comma?
                    beq       L0CD7
                    clr       -1,x
                    stx       <u0033
                    cmpa      #C$CR
                    bne       L0CEA
                    sta       ,x
L0CEA               puls      pc,x

* Add byte to output stream
L0CEC               ldb       <u0046              Get # bytes in current instruction
                    cmpb      #4                  0-3?
                    blo       L0CF4               Yes, Add to output stream
                    bsr       L0D03               >=4, call sub first
L0CF4               std       <TmpNum             Save regs
                    tfr       dp,a
                    ldb       #u0062              Point U to Current instruction's opcode
                    tfr       d,u
                    ldd       <TmpNum             Get byte value to add, and offset into output stream back
                    sta       b,u
                    inc       <u0046              Inc # bytes in current instruction
                    rts

* Called if # bytes in current instruction is >=4 and we are adding byte to output stream
* (I am assuming this is used to split FCB's, etc. onto multiple lines especially with G option
L0D03               pshs      x,d                 Save regs
                    ldb       <u002A              Get ??? (may be 4 byte block # we are working on for current source line?)
                    bne       L0D14               If <>0, skip ahead
                    ldx       <u0033              Get ??? ptr (part of source line being processed)
                    lbsr      L01C4               Find next field, etc.
                    tst       <u005B              All constant lines to be generated ('G' option flag)?
                    beq       L0D27               No, just set No object code tor print flag
                    bra       L0D30               Yes, set NoObject & PrintPC flags

L0D14               tst       <u005B              Is G option flag (all constant lines to be generated) set?
                    bne       L0D2D               Yes, skip ahead
                    lda       <u0056              No, get 'L'ist option flag
                    pshs      a                   Save on stack
* 6809/6309 note: B is immediately reloaded in L01D3, so a ldb #$FF / stb <u0056 should work here,and faster
                    clr       <u0056              Temporarily set L flag to -1
                    com       <u0056
                    lbsr      L01D3               check for errors, build output line for listing
                    puls      a                   Get original 'L' option flag
                    sta       <u0056              Save it back
L0D27               ldb       #NoObjct            Flag no object code to print
                    stb       <u002B
                    bra       L0D34

L0D2D               lbsr      L01D3
L0D30               ldb       #NoObjct+PrintPC    Set NoObject Code & Print PC flags in flags byte
                    stb       <u002B
L0D34               ldd       <u0040              Get current code address ('*')
                    std       <u0044              Save copy
                    clr       <u0046              # bytes in current instruction=0
                    inc       <u002A
                    clr       1,s
                    puls      pc,x,d

** EMOD pseudo op
L0D40               lbsr      L1322               First, update CRC (& write out) current output buffer
                    ldd       <u000E              Get ptr to object code buffer
                    std       <u001B              and reset current buffer ptr to start
                    ldd       <u0051              load CRC value
                    coma                          complement it
                    comb
                    std       <u0062              copy to instruction buffer
                    ldb       <u0051+2            third byte too
                    comb
* 6309 - unless A needed later, AIM #^Operand,<u002B replaces 3 lines
                    IFNE      H6309
                    aim       #^Operand,<u002B    clear "Operand field" bit
                    ELSE
                    lda       <u002B              clear "Operand field" bit
                    anda      #^Operand
                    sta       <u002B
                    ENDC
                    bra       L0D59

** OS9 pseudo op
L0D51               ldd       #$103F              opcode for SWI2
                    std       <u0062              Save as current instruction opcode
                    lbsr      L12F7               process byte operand
L0D59               stb       <u0064              Save system call # (or last byte of CRC if from EMOD)
                    ldb       #3                  Size of current instruction=3
                    stb       <u0046
                    rts

** MOD pseudo op - slight mod 08/25/2020 LCB
L0D60               ldd       <u001B              Get current write buffer position
                    cmpd      <u000E              Same as start?
                    beq       NoAdjst             Yes, proceed normally
                    std       <StartCRC           No, save where we actually will start CRC calcs
NoAdjst             clra
                    clrb
                    stb       <u0050              Init header parity byte
                    std       <u0040              Init current code address
                    std       <u0044
                    std       <u0042              Init current data address
                    lbsr      L1360               Init CRC value to $FFFFFF
                    lbsr      L0CD5               Call expression evaluator
                    ldd       #$87CD              Module ID bytes
                    bsr       L0D93               Update with 2 bytes (including header parity)
                    bsr       L0D90               Add other header bytes
                    bsr       L0D8E               This builds the output line list buffer @ u029F (calls L02FA)
                    bsr       L0DA9
                    bsr       L0DA4
                    bsr       L0DA9
                    bsr       L0DA4
                    lda       <u0050              Get header parity byte
                    coma                          Flip the bits (to create final header parity)
                    bsr       L0DA1
                    lda       ,x
                    cmpa      #',                 comma?
                    bne       L0DB8               No, return
                    bsr       L0D8E
L0D8E               bsr       L0DA9
L0D90               lbsr      L12F1
L0D93               pshs      b
                    tfr       a,b
                    bsr       L0D9B
                    puls      b
L0D9B               tfr       b,a                 Copy byte to A
                    eorb      <u0050              Update header parity byte
                    stb       <u0050
L0DA1               lbra      L0CEC

L0DA4               lbsr      L12F7
                    bra       L0D9B

L0DA9               lda       ,x+
                    cmpa      #',                 comma?
                    beq       L0DB8
                    leax      -1,x
                    ldb       #23                 'const def' error
                    lbsr      L02FA
                    leas      2,s
L0DB8               rts

** ORG pseudo op
L0DB9               lbsr      L0BE4
                    std       <u0044
                    lbra      L0BC0

** END pseudo op
L0DC1               ldb       <u002B
                    andb      #Label              $08
                    orb       #Command            $10
                    stb       <u002B
                    lbsr      L01F2               Build output line for listing
                    lbsr      L156C               Close current source file & remove it's path from open file path stack
                    bcc       L0DD3
                    leas      4,s
L0DD3               rts

** NAM pseudo op
L0DD4               ldb       #39                 max name length
                    ldu       <u000A              name buffer
L0DD8               lbsr      L1164
                    lda       <u003E
                    bne       L0DE3
                    lda       ,u
                    bne       L0DFC
L0DE3               lda       ,x+                 copy text to buffer
                    cmpa      #C$CR
                    beq       L0DF4               until end of line
                    sta       ,u+
                    decb
                    bne       L0DE3               or max length
                    lda       #C$CR
L0DF0               cmpa      ,x+                 eat rest of line
                    bne       L0DF0
L0DF4               clr       ,u                  null terminate buffer
                    leax      -1,x
                    ldb       #Operand+Command
                    stb       <u002B
L0DFC               rts

** TTL pseudo op
L0DFD               ldb       #79                 max title length
                    ldu       <u0008              title buffer
                    bra       L0DD8

** PAG pseudo op
L0E03               lbsr      L1408
L0E06               leas      2,s
                    rts

** SPC pseudo op
L0E09               bsr       L0E21
                    bcc       L0E12
                    ldb       #Operand+Command
                    stb       <u002B
                    rts

L0E12               stb       ,-s
                    beq       L0E1D
L0E16               lbsr      L149A
                    dec       ,s
                    bne       L0E16
L0E1D               leas      1,s
                    bra       L0E06

** OPT arg processing (I think also command line options)
L0E2C               ldb       #Operand+Command    Set 2 flags in Listing Print Control flags byte
                    stb       <u002B
                    lbsr      L1164               Find next text field
L0E33               clr       ,-s                 Default Flag to "Set" ($00)
                    lda       ,x+                 Get 1st text field char
                    cmpa      #'-                 Dash?
                    bne       L0E3F               No, leave flag set
                    com       ,s                  Yes, flag "Clear" ($FF)
                    lda       ,x+                 Get next char
L0E3F               leau      <L0EA3,pc           Point to table
                    ldb       #8                  # of entries
                    cmpa      #'a                 Is char lowercase?
                    blo       L0E4A               No, no conversion needed
                    suba      #'a-'A              Bump down to uppercase
L0E4A               cmpa      ,u++                Same as first 1/2 of table entry?
                    beq       L0E68               Yes, skip ahead
                    decb                          No, decrement # entries left
                    bne       L0E4A               Keep checking all 8
                    puls      b
                    cmpa      #'D
                    beq       L0E88
                    cmpa      #'W
                    beq       L0E80
                    cmpa      #'L
                    beq       L0E90
                    cmpa      #'N
                    beq       L0E9B
                    IFNE      DOCASE
* NEW! Symbol case control flag "U"
                    cmpa      #'U
                    bne       L0E63
                    lda       #$5F                uppercase-only mask
                    tstb
                    beq       u.opt               "U" flag, force uppercase
                    lda       #$7F                "-U" flag, upper+lower OK
u.opt               sta       <u000D              store new symbol case mask
                    bra       L0E73
                    ENDC      DOCASE

* unknown command line flag
L0E63               ldb       #22                 'opt list' error
                    lbra      L02FA

L0E21               lbsr      L10B4
                    bcc       L0E2B
                    lbsr      L02FA
                    orcc      #$01
L0E2B               rts

* option flag is one of the 8 in the L0EA3 table comes here
* We need to '-' check for O as a 3rd state (overwrite)
* Entry: ,s=flag setting (0=no dash (regular_, $FF='-' (dash) on option)
*        A=Uppercase char of option found
* New code to set flag different for -O (for overwrite file) LCB 04/08/2019
L0E68               cmpa      #'O                 Object file option?
                    bne       NotO                No, no special processing
                    lda       ,s                  Get current flag for -O ($FF means we had a '-')
                    beq       NotO                No '-', so leave alone
                    dec       ,s                  Change to -1 (so COMA below will change to 1)
NotO                ldb       -1,u                Get DP address this option flag is stored at
                    tfr       dp,a                Move that address to U
                    tfr       d,u
                    puls      a                   Get flag byte (set/not set)
                    coma                          invert it
                    sta       ,u                  Save it to proper mem location
L0E73               lda       ,x+                 Get next char from text field
                    cmpa      #',                 Comma?
                    beq       L0E33               Yes, go process another text field
                    cmpa      #C$SPAC             Space?
                    beq       L0E2C               Yes, go find next text field
                    leax      -1,x                Otherwise, back ptr up and return
                    rts

* Option Flag Table: byte1=flag char, byte2=DP storage loc
L0EA3               fcb       'C,u005F            Conditionals flag
                    fcb       'F,u0059            Form Feed flag
                    fcb       'M,u005A            Motorola format flag
                    fcb       'G,u005B            Generate all constant lines flag
                    fcb       'E,u005C            Error Messages flag
                    fcb       'S,u005E            generate Symbol table flag
                    fcb       'I,u005D            Interactive mode flag
                    fcb       'O,u0058            Object (output) file flag

* 'W' (line width) option
L0E80               bsr       L0E21               process linewidth arg
                    bcs       L0E63               'opt list' error if bad arg
                    cmpb      #132                bugfix: to avoid a
                    bls       L0E84               :printbuf overrun, set
                    ldb       #132                :max line width to 132
L0E84               stb       <u0037              set new line width (chars/line)
                    bra       L0E73

* 'D' (page depth) option
L0E88               bsr       L0E21               process pagedepth arg
                    bcs       L0E63               'opt list' error if bad arg
                    stb       <u0036              set new page depth (lines/page)
                    bra       L0E73

* 'L' (listing) option
L0E90               tstb                          '-L' ?
                    beq       L0E97               no, just 'L'
                    dec       <u0056              yes, unset(?) List flag
                    bra       L0E73

L0E97               inc       <u0056              set List flag
                    bra       L0E73

* 'N' (narrow) option
L0E9B               inc       <u0060              set Narrow flag
                    lda       #31
                    sta       <u0037              set page width to 31
                    bra       L0E97               also set List flag


** SETDP pseudo op
L0EB3               lbsr      L12F7
                    bcs       L0EBA
                    stb       <u003F
L0EBA               clra
                    std       <u0044
                    ldb       #Operand+Command+PrintPC
                    stb       <u002B
                    inc       <u002C
                    rts

** USE pseudo op
L0EC4               lbsr      L1164               Point X to next field (filename)
                    lbsr      L15FB               Open filename pointed to by X
                    fcb       $8c                 CMPX opcode (same speed, 1 byte smaller to skip 2 bytes)
L0ECC               leax      -1,x
L0ECE               ldb       -1,x                Get char
                    cmpb      #C$SPAC             If space, backup up 1 char
                    beq       L0ECC
                    ldu       <u001F              Get ptr to open file path stack
                    ldb       <u0018              Get path # of current source file
                    pshu      b                   Save on open file path stack
                    stu       <u001F              Save updated open file path stack ptr
                    sta       <u0018
                    ldb       #Operand+Command
                    stb       <u002B
                    rts

L0EE3               bsr       L0F0F               IFEQ
                    bne       L0F0C
                    rts

L0EE8               bsr       L0F0F               IFNE
                    beq       L0F0C
                    rts

L0EED               bsr       L0F0F               IFLT
                    bge       L0F0C
                    rts

L0EF2               bsr       L0F0F               IFLE
                    bgt       L0F0C
                    rts

L0EF7               bsr       L0F0F               IFGE
                    blt       L0F0C
                    rts

L0EFC               bsr       L0F0F               IFGT
                    ble       L0F0C
                    rts

L0F01               inc       <u0055              IFP1
                    ldb       #Command
                    bsr       L0F21               update listing flags
                    lda       <u003E
                    bne       L0F0C
                    rts

L0F0C               inc       <u0054
                    rts

L0F0F               inc       <u0055
                    ldb       #Operand+Command
                    bsr       L0F21               update listing flags
                    lbsr      L12F1
                    bcc       L0F1C
                    puls      pc,d

L0F1C               cmpd      #$0000
                    rts

L0F21               tst       <u005F              'C'onditional flag on?
                    bne       L0F26               Yes, update flags
                    clrb                          DoNothng (all flags off)
L0F26               stb       <u002B              Update list control flags
                    rts

                    IFNE      NEWDEF
Lidef               bsr       chkdef              IFDEF (ifdef label)
                    bls       L0F0C               label NOT defined, set FALSE
                    rts

Lndef               bsr       chkdef              IFNDF (ifndef label)
                    bhi       L0F0C               label IS defined, set FALSE
                    rts

chkdef              inc       <u0055              update IF count
                    lbsr      L0368               parse label name
                    bcs       bad.sym             not a valid label
                    ldb       #Operand+Command
                    bsr       L0F21               update listing flags
                    pshs      u,y,x
                    lbsr      L0FC3               search symbol table
* returns carry set if not found, zero set if undefined
                    puls      x,y,u,pc            return (C OR Z) set if not found or undefined

bad.sym             ldb       #01                 'bad label' error
                    lbra      L1304               report error and return carry set
                    ENDC      NEWDEF

** ENDC/ELSE pseudo ops
L0F29               ldb       #Command
                    bsr       L0F21
                    lda       <u0055
                    beq       L0F42
                    lda       <u0062              ELSE op?
                    bne       L0F3B               yes, skip ahead
                    dec       <u0055              ENDC, decrement actuve IF count
                    lda       <u0054              Get inactive nested IF depth
                    beq       L0F41               If 0, return
L0F3B               lda       <u0054              Get inactive nested IF depth
                    beq       L0F0C               If 0, bump up to 1 and return
                    dec       <u0054
L0F41               rts

L0F42               ldb       #26                 'cond nesting' error
                    lbsr      L02FA
                    clr       <u0054
                    rts

* add label to symbol table
L0F4A               pshs      u,y,x
                    bsr       L0FC3
                    stx       <u002D              Save ptr to last symbol found/added
                    ldb       <u003E              Get pass counter
                    bgt       L0F7D
                    bcc       L0F63
                    lda       #$01
                    ldu       <u0040              Get current code address ('*')
                    lbsr      L100B
                    stx       <u002D
                    bcc       L0F9E
                    bra       L0F9A

L0F63               tsta
                    bne       L0F71               If A<>0, check next
                    inca                          Set A=1
                    ldu       <u0040              Get current code address ('*')
                    sta       $08,x               ? Save symbol type?
                    stu       $09,x               ? Save current code address as 16 bit value
                    bra       L0F9E

L0F71               cmpa      #$02                "set" symbol?
                    beq       L0F9E
                    ora       #$80
                    sta       $08,x
L0F79               ldb       #08                 "redefined name" error
                    bra       L0F9A

L0F7D               bcc       L0F83
L0F7F               ldb       #09                 "undefined name" error
                    bra       L0F9A

L0F83               tsta
                    beq       L0F7F
                    bita      #$80
                    bne       L0F79
                    cmpa      #$01
                    bne       L0F9E
                    ldd       <u0040              Get current code address ('*')
                    cmpd      $09,x               Same as 16 bit value in symbol table?
                    beq       L0F9E               Yes, exit with carry clear
                    std       $09,x               Save current code address into symbol table instead
                    ldb       #10                 "phasing" error
L0F9A               orcc      #$01                Set carry & return
                    puls      pc,u,y,x

L0F9E               andcc     #$FE
                    puls      pc,u,y,x

L0FA2               pshs      u,y,x
                    bsr       L0FC3               search symbol table for label
                    ldb       <u003E              pass 1?
                    bne       L0FB7               no, check for undefined symbol
                    bhs       L0FBB               symbol found, return value
                    clra                          not found, set type to "undefined"
                    ldu       #$0000              and default value to 0
                    bsr       L100B               add to symbol table
                    bcs       L0F9A               no room, report symbol table full error
                    bra       L0F9E

L0FB7               lda       8,x                 check symbol type
                    beq       L0F7F               type=0, report undefined sym
L0FBB               ldd       9,x                 get symbol's value
                    bra       L0F9E               and return

* scan symbol table for a match. set carry if no match
L0FC3               bsr       L0FFA               point to 1st letter's list vector
                    ldx       ,x                  do any symbols start with this letter?
                    bne       L0FCD               yes, search the list for a match
                    leay      ,x                  no, clear Y reg (2 bytes, 4 cyc)
                    bra       L0FF7               and report symbol not in list

L0FCD               pshs      x
                    ldy       <u0016              point to "new" symbol name buffer
                    ldb       #8                  max symbol length
L0FD4               lda       ,y+                 fetch char from "new" symbol
                    beq       L0FE5               end found if null
                    cmpa      ,x+                 compare with list symbol char
                    bne       L0FE9               not same, no match
                    decb                          done all 8 yet?
                    bne       L0FD4
L0FDF               puls      x                   yes, found matching symbol name
                    clrb                          clear carry (symbol is in list)
                    lda       $08,x               and return symbol type in A
                    rts

L0FE5               cmpa      ,x+                 is list symbol same length?
                    beq       L0FDF               yes, a match!
L0FE9               puls      y                   symbol names didn't match
                    bhi       L0FF3               "greater" alphabetically?
                    ldx       11,y                no, try "lesser" symbol
                    bne       L0FCD
                    bra       L0FF7               none lesser, not in list

L0FF3               ldx       13,y                yes, try "greater" symbol
                    bne       L0FCD
L0FF7               orcc      #$01                symbol not in list (carry set)
                    rts

* use 1st char of symbol as index into array of linked list vectors
* returns X=address of list vector for this symbol
L0FFA               ldx       <u0016              Get ptr to symbol name that we are adding
                    ldb       ,x                  Get first char
                    ldx       <u0010              address of linked list vector table
                    subb      #'A                 map A-Z to 0-25
* support code for lowercase symbols
                    cmpb      #'a-'A              lowercase symbol?
                    blo       L1008
                    subb      #'a-'Z-1            map a-z to 26-51
L1008               lslb                          2 bytes per entry
                    abx                           point x to list vector for 1st letter of symbol
                    rts

* add new symbol to table if there's room
L100B               ldx       <u001D              get addr of next empty slot
                    pshs      x,a                 Save ptr to next empty slot, and symbol type
                    leax      $0F,x               is there room for one more?
                    cmpx      <u0012
                    blo       L1023               yes!
                    ldb       #11                 "symbol table full" error
L1017               clr       <u0056
                    lda       #$01                Set pass counter to 1
                    sta       <u003E
                    lbsr      L02FA
                    lbra      L15E9               Close I/O paths and exit.

L1023               stx       <u001D              Save ptr to next empty symbol tbl slot
                    sty       ,--s                Save ptr
                    bne       L1032               Not empty, add to existing linked list
* start new linked list, add first symbol
                    leas      2,s                 First symbol in linked list; eat temp stack
                    bsr       L0FFA               Get ptr to 1st entry for start letter linked list into X
                    leay      -$0B,x              Point 11 bytes back (will go into next lower linked list entry)
                    bra       L1040

* append new symbol to existing linked list
L1032               ldx       <u0016              Get ptr to symbol name we are adding
L1034               lda       ,x+                 Get char from symbol name
                    cmpa      ,y+                 check if lower or higher than linked list entry
                    beq       L1034               Same, check next char
                    puls      y                   Get linked list entry ptr back
                    blo       L1040               If new symbol name is lower, save ptr as next lower in linked list
                    leay      2,y                 Higher, offset so ptr saved as next higher in linked list
L1040               ldx       1,s                 Get original ptr to next empty slot
                    stx       $0B,y               Save as linked list ptr to next lower entry
                    ldy       <u0016              Get ptr to symbol name we are adding
                    lda       ,y+                 Get char from symbol name
L1049               sta       ,x+                 Save in name part of linked list entry
                    lda       ,y+                 Get next char from symbol name
                    bne       L1049               Not NUL, keep copying
                    puls      x,a                 Done copying name, get ptr to new entry, and symbol type back
                    sta       8,x                 Save symbol type into linked list entry
                    stu       9,x                 Save value into linked list entry
                    clrb
                    rts

* OUT4HS - Append hex version of D (4 digit) & space to ,x
L1057               bsr       L1065               Append hex version of D to output buffer @ ,X
L105D               sta       <TmpNum             (4)
                    lda       #C$SPAC
                    sta       ,x+
                    lda       <TmpNum             (4)
                    rts                           (5)

* write D reg to X buffer as 4 hex digits
L1065               exg       a,b
                    bsr       L106B               Do high byte first
                    tfr       a,b                 Do low byte, return
* write B reg to X buffer as 2 hex digits
L106B               stb       <TmpNum             Save copy
                    andb      #$F0                Do high nibble char first
                    lsrb
                    lsrb
                    lsrb
                    lsrb
                    bsr       L1079
                    ldb       <TmpNum             Get original copy back
                    andb      #$0F                Low nibble
L1079               cmpb      #$09
                    bls       L107F
                    addb      #$07
L107F               addb      #'0
                    stb       ,x+
                    rts

* numeric string evaluator
L10B4               clra                          Set up and clear 4 byte workspace on stack (2 bytes smaller, 2 cyc faster)
                    clrb                          (2/1)
                    pshs      d                   (7/2)
                    pshs      d                   (7/2)  6 bytes, 18 cycles
                    bsr       L1164               Find start of next text field (A is first char)
                    leax      1,x                 Point to 2nd char
                    cmpa      #'%                 binary?
                    beq       L1121               Yes, do binary conversion
                    cmpa      #'$                 hex?
                    bne       L10F7               no flag, do decimal conversion
* hex string conversion
L10C9               bsr       L113B               Get next digit
                    bcc       L10DD               Was 0 to 9, already converted, so process
                    cmpb      #'a                 lowercase?
                    blo       L10D3               No, presume already uppercase
                    subb      #'a-'A              yes, make uppercase
L10D3               cmpb      #'A                 valid ASCII hex?
                    blo       L114D               No, deal with that
                    cmpb      #'F                 valid ASCII hex?
                    bhi       L114D               No, deal with that
                    subb      #'A-10              yes, de-ASCIIfy A-F
L10DD               stb       ,s                  Save value of digit
                    ldd       2,s                 Get current value of calculated result
                    bita      #$F0                Anything set in the high nibble?
                    bne       L1160               Yes, skip ahead
                    lslb                          No, shift one nibble to left
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    lslb
                    rola
                    addb      ,s                  Add our original binary version of digit to shifted version
                    adca      #$00
                    std       2,s                 Save it back
                    inc       1,s                 Bump up # of digits counter
                    bra       L10C9

* decimal string conversion
L10F7               leax      -1,x                no type flag, point to 1st digit
L10FB               bsr       L113B               Get digit
                    bcs       L114D               If not 0 to 9, skip ahead
                    stb       ,s                  Save converted value
                    ldd       2,s                 Get running final number
                    lslb                          *2
                    rola
                    std       2,s                 Save shifted version
                    lslb                          *4
                    rola
                    lslb
                    rola
                    bcs       L1160               If carry rotated out, then # too big, exit with error
                    addd      2,s                 No carry, add to previous (so now *10)
                    bcs       L1160               If overflowed, # too big, exit with error
                    addb      ,s                  Add converted digit as well
                    adca      #$00
                    bcs       L1160               If overflowed, exit with error
                    std       2,s                 Save result
                    inc       1,s                 Bump up # of digits generated
                    bra       L10FB               Next digit

* binary string conversion
L1121               ldb       ,x+                 Get char
                    subb      #'0                 Convert ASCII 0 or 1 to raw value
                    blo       L114D               If wrapped 0, illegal char
                    lsrb                          Shift out bit
                    bne       L114D               If still more set bits left, illegal char
                    rol       3,s                 Rotate in the bit
                    rol       2,s
                    bcs       L1160               If 16 bits overflows, illegal
                    inc       1,s                 Inc # of digits generated
                    bra       L1121               Do next char

* Get digit from buffer at X.
* Entry: X=Ptr to current ASCII digit
* Exit:  B=0 to 9 if ASCII was '0' to '9', carry clear   OR
*        B=char if NOT '0' to '9', with carry set
L113B               ldb       ,x+                 Get digit
                    cmpb      #'0                 If <'0', exit with carry set
                    blo       L1145
                    cmpb      #'9                 If '0' to '9', convert to value
                    bls       L1148
L1145               orcc      #$01                If anything else, exit with carry set
                    rts

* Find next text field. Eats spaces until next non-space char found
* Entry: X=Ptr to current location in source line
* Exit:  X=Ptr to start of next field in source line
*        A=First char in new field
L1164               lda       ,x+                 Get char.
                    cmpa      #C$SPAC             Space?
                    beq       L1164               Yes, eat it
                    leax      -1,x                Found next field; point to it & return
                    rts

L1148               subb      #'0                 De-ASCIIfy digit
                    andcc     #$FE                No error & return
                    rts

L114D               leax      -1,x                Bump back ptr in source line
                    tst       1,s                 Did we convert any digits?
                    beq       L115B               NO, not a number - exit with Z & C set
                    ldd       2,s                 Get final 16 bit value we made
                    andcc     #^$01               good conversion, clear carry
                    bra       L115D               and exit

L1160               andcc     #^$04               overflow, clear zero flag
L115B               orcc      #$01                conversion error, set carry
L115D               leas      4,s                 release work area and exit
                    rts

* Binary 16-bit multiply:  returns D=D*X, X=0
* Need to figure out if signed or unsigned. If signed, can use MULD on 6309
L116D               pshs      x,d
                    lda       3,s                 Get high byte of original X
                    mul                           Multiply by low byte of D
                    pshs      d                   Save 16 bit result
                    lda       2,s
                    ldb       5,s
                    mul
                    addb      ,s
                    stb       ,s
                    ldd       3,s
                    mul
                    addb      ,s
                    stb       ,s
                    ldd       ,s
                    ldx       #$0000
                    leas      6,s
                    rts

* 16/16 divide - appears to be unsigned only. DIVQ will work only if D on entry
* does not have the hit bit set
* range of dividend first) for 6309
* Binary 16-bit Divide:  returns X/D (D=quotient, X=remainder)
L118E               pshs      y,x,d               Save X/D and reserve 2 extra bytes on stack
* 6309 - tstd
                    IFNE      H6309
                    tstd                          Get dividend
                    ELSE
                    ldd       ,s                  Get dividend
                    ENDC
                    bne       L1198               <>0, do the divide
                    orcc      #$01                /0 error, so exit with carry set
                    bra       L11B8

L1198               ldd       #$0010              Init A to 0, B=counter for # of powers of 2 subtracts
                    stb       4,s                 Save ctr
                    clrb                          Clear carry for shift/rotate
L119E               lsl       3,s                 Shift out hi bit from original X
                    rol       2,s
                    rolb                          Rotate into our new 16 bit word (D)
                    rola
                    subd      ,s                  Subtract dividend from it
                    bmi       L11AC               If wrapped, skip ahead
                    inc       3,s                 Bump up low byte of answer
                    bra       L11AE               Go shift to next power of 2, continue

L11AC               addd      ,s                  We wrapped negative, add current power of 2 back
L11AE               dec       4,s                 Dec number of powers of 2 to go through
                    bne       L119E               Still more, continue
                    tfr       d,x                 X=Remainder
                    ldd       2,s                 D=answer
                    andcc     #$FE                No error
L11B8               leas      6,s                 Eat temp stack & return
                    rts

* expression evaluator
L11C2               pshs      u,y                 Preserve regs
                    leau      ,s                  Point U to copy of Y on stack
                    bsr       L1164               Parse for next field
                    bsr       L11D0               Check for special chars
                    andcc     #$FE                Error flag off
                    puls      pc,u,y              Restore regs & return

L11CE               leax      1,x                 Bump up source ptr
L11D0               bsr       L1211
                    pshs      d
L11D4               lda       ,x                  Get char from source
                    cmpa      #'-                 Minus?
                    bne       L11E2               No, check text
                    bsr       L120F
* 6309 - NEGD replaces next 3 lines
                    IFNE      H6309
                    negd
                    ELSE
                    nega
                    negb
                    sbca      #$00
                    ENDC
                    bra       L11E8

L11E2               cmpa      #'+                 Plus?
                    bne       L11EE               No, check next
                    bsr       L120F
L11E8               addd      ,s
                    std       ,s
                    bra       L11D4

L11EE               tsta                          Null?
                    beq       L120D
                    cmpa      #C$CR               CR?
                    beq       L120D
                    cmpa      #C$SPAC             Space?
                    beq       L120D
                    cmpa      #',                 Comma?
                    beq       L120D
                    cmpa      #')                 Rt paren?
                    beq       L120D
                    cmpa      #']                 Rt bracket?
                    beq       L120D
L1205               ldb       #06                 'expr syntax' error
L1207               leas      ,u
                    orcc      #$01
                    puls      pc,u,y

L120D               puls      pc,d

L120F               leax      1,x
L1211               bsr       L123F
                    pshs      d
L1215               lda       ,x                  Get char from buffer
                    cmpa      #'/                 Divide?
                    bne       L122A               No, check next
                    bsr       L123D
                    pshs      x
                    ldx       2,s
                    lbsr      L118E
                    bcc       L1237
                    ldb       #04                 'div by 0' error
                    bra       L1207

L122A               cmpa      #'*                 Multiply?
                    bne       L120D               No, return
                    bsr       L123D
                    pshs      x
                    ldx       2,s
                    lbsr      L116D
L1237               puls      x
                    std       ,s
                    bra       L1215

L123D               leax      1,x                 Bump up source ptr
L123F               bsr       L126D
                    pshs      d
L1243               lda       ,x
                    cmpa      #'&                 Logical AND?
                    bne       L1251               No, check next
                    bsr       L126B
* 6309 - ANDD
                    IFNE      H6309
                    andd      ,s
                    ELSE
                    andb      $01,s
                    anda      ,s
                    ENDC
                    bra       L1267

L1251               cmpa      #'!                 Logical OR?
                    bne       L125D               No, check next
                    bsr       L126B
* 6309 - ORD
                    IFNE      H6309
                    ord       ,s
                    ELSE
                    orb       $01,s
                    ora       ,s
                    ENDC
                    bra       L1267

L125D               cmpa      #'?                 Logical EOR?
                    bne       L120D               No, return
                    bsr       L126B
* 6309 - EORD
                    IFNE      H6309
                    eord      ,s
                    ELSE
                    eorb      $01,s
                    eora      ,s
                    ENDC
L1267               std       ,s
                    bra       L1243

L126B               leax      1,x                 Bump src code ptr up by 1
L126D               lda       ,x                  Get char from source code
                    cmpa      #'^                 Is it a NOT?
                    bne       L1279               No, check next
                    bsr       L1284               check if next char is some special symbols
* 6309 - COMD
                    IFNE      H6309
                    comd
                    ELSE
                    comb
                    coma
                    ENDC
                    bra       L1283

L1279               cmpa      #'-                 Is it negative?
                    bne       L1288               No, check next
                    bsr       L1284
* 6309 - NEGD
                    IFNE      H6309
                    negd
                    ELSE
                    nega
                    negb
                    sbca      #$00
                    ENDC
L1283               rts

L1284               leax      1,x
L1286               lda       ,x                  Get character from source code
L1288               cmpa      #'(                 Math grouping start symbol?
                    bne       L12A2               No, check next
                    lbsr      L11CE
                    pshs      a                   (Was D, should save two cycles)
                    lda       ,x
                    cmpa      #')                 Math grouping end symbol?
                    puls      a
                    beq       L12B6
                    ldb       #07                 'parens' error
L129D               leas      2,s                 Eat temp stack
L129F               lbra      L1207

L12A2               cmpa      #'*                 Asterisk? (current code address)
                    bne       L12AA               No, check next
                    ldd       <u0040              Get current code address (*)
                    bra       L12B6               Bump up source ptr & return

L12AA               tst       <u005A              If MOTOROLA flag is set, check next
                    bne       L12B9
                    cmpa      #'.                 Period? (current data address)
                    bne       L12B9               No, check next
                    ldd       <u0042              Get current data address (.)
                    inc       <u002C              Inc data space ops in current line
L12B6               leax      1,x                 Bump src code ptr up & return
                    rts

L12B9               cmpa      #''                 Single Quote? (1-character literal)
                    bne       L12C5               No, check next
                    ldd       ,x++                load quote+following char
                    clra                          eat the quote
                    bra       L12D1               test for CR

L12C5               cmpa      #'"                 Double Quote? (2-character literal)
                    bne       L12D9               No, must be number or label
                    leax      1,x                 skip the quote
                    ldd       ,x++                and load the next 2 chars
                    cmpa      #C$CR               first = CR?
                    beq       L12D6
L12D1               cmpb      #C$CR               second = CR?
                    beq       L12D6
                    rts

L12D6               lbra      L1205               'expr syntax'

* labels and numbers come here
L12D9               lbsr      L10B4               process as numeric string
                    bcc       L12F0               It is a legit numeric, return with no error
                    beq       L12E4               not a number, try label
                    ldb       #03                 'in number' error
                    bra       L129F

L12E4               bsr       L0368               process label type operand
                    bcs       L12D6               invalid label, syntax error
                    lbsr      L0FA2               good label, search in symbol table
                    bcs       L129F
L12EE               andcc     #$FE
L12F0               rts

* Copy label field into symbol name buffer
* First 8 characters of label MUST be unique
L0368               lbsr      L1164               Find next text field
                    bsr       L03A0               first char MUST be alphabetic
                    bcs       L03B7               Nope, exit with error flag set
                    pshs      u,y
                    ldu       <u0016              symbol name buffer
                    ldb       #8                  Max # chars in label
                    leax      1,x                 advance to 2nd char
* A=letter, number, period, dollar sign or underscore
L0393               decb                          Copy the first 8 chars
                    bmi       L0379               But check them all
                    sta       ,u+                 Store character in label buffer
* Copy rest of label into buffer
L0379               lda       ,x+                 Get char
                    bsr       L03A0               Check text chars
                    bcc       L0393               Found one, skip special parsing
                    cmpa      #'_                 Is it an underscore?
                    beq       L0393               Yes, go process
                    cmpa      #'@                 Is it an at sign?
                    beq       L0393               Yes, go process
                    cmpa      #'9                 Higher than a 9?
                    bhi       L039A               Yes, skip ahead
                    cmpa      #'0                 Is it a number?
                    bhs       L0393               Yes, go process
                    cmpa      #'.                 Is it a period?
                    beq       L0393               Yes, go process
                    cmpa      #'$                 Is it a dollar sign?
                    beq       L0393               Yes, go process
L039A               leax      -1,x                No, rewind to non-label char
                    clr       ,u+                 Append a NUL to symbol buf
                    puls      pc,u,y              Restore regs & return

* Test for alphabetic [A-Za-z] set carry if not (shorter & faster RVH)
L03A0               cmpa      #'Z                 Uppercase or less?
                    bhi       L03A7               No, check for lowercase
                    cmpa      #'A                 Uppercase letter?
                    rts                           return carry set if not A-Z

L03A7               cmpa      #'z                 Lowercase or less?
                    bhi       L03B5               No, above 'z'
                    cmpa      #'a                 lowercase letter?
                    blo       L03B7               No, between 'Z' & 'a'
                    IFNE      DOCASE
                    anda      <u000D              Apply case mask
                    ELSE
                    anda      #$5F                Force to uppercase
                    ENDC      DOCASE
                    rts

L03B5               orcc      #$01                Non-alphabetic, set carry & return
L03B7               rts

* write a byte to code buffer
* Entry: A=byte to add
* update running CRC value - NOTE ONLY CALLED FROM L130D, SO INLINE
L130D               pshs      x,d                 Update CRC with byte in A:Save regs that we need again below
                    ldx       <u001B              current loc
                    sta       ,x+                 write new byte
                    stx       <u001B              update ptr
                    cmpx      <u0010              buffer full?
                    blo       L1321               no, return
                    bsr       L1322               yes, write it out
                    ldx       <u000E              Get ptr to object code buffer
                    stx       <u001B              and reset current buffer ptr to start
L1321               puls      pc,x,d

* Flush code buffer, update CRC block
L1322               clr       <SkipCRC            Flag that we are updating CRC
* flush code buffer contents, and update CRC as a block if flag clear
L1323               pshs      u,y,x,d             Save regs
* Move F$CRC from above to here (before O flag check, since we need to calc
* it irregardless so it shows up in a listing with no object file), and do
* whole buffer size in one call
* --- start of new code
                    ldd       <u001B              Get current object file buffer position
                    subd      <u000E              still at start of buffer? (ie 0 bytes to write?)
                    beq       L1340               Nothing to write, so no CRC update either
* Edition 11, Rev 2: hopefully fixes bug with code generated BEFORE 'mod' encountered (like REL) LCB 08/25/20
* D is now the size of the buffer to Write, so save it (in case CRC is different size)
                    pshs      d                   Save size to write
                    ldx       <StartCRC           Have something to write, see if we have an alt start position for CRC calc ('mod')
                    beq       NoAltCRC            No alternate, use current settings
                    ldd       <u001B              Get current position in buffer
                    subd      <StartCRC           Subtract position to start CRC calc (size of CRC calc)
                    ldx       <StartCRC           Get ptr to start CRC part of buffer
                    clr       <StartCRC           Zero out Alt start (only 1 MOD statement per file)
                    clr       <StartCRC+1
                    bra       AltCRC              Do CRC skipping bytes before MOD

NoAltCRC            ldx       <u000E              Get ptr to start of buffer for update/write
AltCRC              tfr       d,y                 Save # of bytes to CRC update/write into Y
                    lda       <SkipCRC            Are we updating CRC?
                    bne       WritOnly            No, skip that (we are on final block)
StCRCGd             tfr       dp,a                MSB of CRC buffer ptr
                    ldb       #u0051              LSB of CRC buffer ptr
                    tfr       d,u                 Put in proper register for F$CRC
                    os9       F$CRC               Update CRC for whole object file buffer in 1 shot
* --- end of new code
WritOnly            puls      y                   Get write size back, this time into Y for I$Write call
                    lda       <u0058              O flag?
                    beq       L1340               no, exit (no outfile)
                    lda       <u003E              code generation (second) pass?
                    beq       L1340               no, exit
                    ldx       <u000E              Get start of write buffer
                    lda       <u0019              A=outfile path #
                    beq       L1340               if path=0, no outfile, exit
                    os9       I$Write             write the buffer
                    bcs       L1341               If Write had error, restore U, print summary, exit
L1340               puls      d,x,y,u,pc          Restore regs & return

L1341               ldu       6,s                 Get U back (in case needed for summary stuff)
L1342               os9       F$PErr              yes, print OS9 error message
                    ldb       #18                 'object path' error
                    lbsr      L02FA               then print ASM error message
                    lbra      L15A2               Print summary and exit (since doing F$Exit, don't care about fixing up stack)

*
L1368               lda       <u0057
                    beq       L139A
                    lda       <u0056              Get 'L'ist option flag
                    bmi       L139A               -1 means NO listing, so skip listing line
L1370               lda       <u0035              Get # of lines until end of current page
                    bne       L137B               Still some, skip ahead
                    pshs      x
                    lbsr      L1408               Start next page (form feed or series of CR's)
                    puls      x
L137B               bsr       L138A
                    lda       <u003E              Get pass counter
                    beq       L1387               1st pass, skip ahead
                    lda       <u0056              2nd pass, Get L option flag
                    bmi       L1387               If -1, no listing wanted, reset listing output buffer ptr & return
                    dec       <u0035              Dec # lines left to end of page
L1387               ldx       <u0004              X=ptr to start of listing output buffer & return
                    rts

L138A               lda       <u0057
                    beq       L1392
                    lda       <u0056              Get L opt flag
                    bpl       L139A
L1392               lda       <u005C              Get E opt flag
                    beq       L1387               Reset output line buffer to start & return
                    lda       <u0021              Get error count for current line
                    beq       L1387               No errors, reset listing output buffer ptr & return
L139A               lda       <u003E              Get pass counter
                    beq       L1387               If 0, reset X to start of listing output buffer & return
                    pshs      y,a
                    bsr       L13B8               Append CR to string @ ,X
                    ldb       <u0037              Get page width
                    ldx       <u0004              Get ptr to listing output buffer
                    abx                           Point to end of line in output buffer
                    bsr       L13B8               Add CR to end of line in output buffer
                    ldx       <u0004              Get ptr to start of listing output buffer
                    ldy       #133                listing buffer width=132 chars+CR (max size to write)
                    lda       <u001A              Get path # for listing
                    os9       I$WritLn            Write the line out
                    puls      pc,y,a

* append a CR to end of string
L13B8               lda       #C$CR               CR
                    sta       ,x+                 Append to end of buffer & return
                    rts

* print Date & Time as MM/DD/YYYY hh:mm:ss
L13BD               leas      -$06,s              allocate a date buffer on stack
                    pshs      x
                    leax      $02,s               X=addr of date buffer
                    os9       F$Time              get Date/Time packet
                    puls      x
                    bcs       L13F0               exit on error
                    lda       $01,s               get month byte
                    bsr       L13F7               write 2-digit month
                    ldb       #'/
                    stb       ,x+                 and a slash
                    lda       $02,s               get day byte
                    bsr       L13F7               write 2-digit day
                    stb       ,x+                 and another slash
* shorter 1900-2155 fix
* ++START++
                    ldb       ,s                  system years in B (0-255)
                    lda       #19-1               century in A
c.loop              inca                          add a century
                    subb      #100                subtract 100 yrs
                    bhs       c.loop              until yr<0
                    addb      #100                restore year to 00-99 range
                    bsr       L13F7               write 2-digit century
                    tfr       b,a                 retrieve adjusted year
* ++END++
                    bsr       L13F7               write 2-digit year
                    bsr       L13F2               and a space
                    lda       $03,s               get hours byte
                    bsr       L13F7               write 2-digit hours
                    ldb       #':
                    stb       ,x+                 and a colon
                    lda       $04,s               get minutes byte
                    bsr       L13F7               write 2-digit minutes
                    stb       ,x+                 and another colon
                    lda       $05,s               get seconds byte
                    bsr       L13F7               write 2-digit seconds
L13F0               leas      $06,s               release date buffer
L13F2               lda       #C$SPAC
                    sta       ,x+                 and write another space
                    rts

* write Reg.A to buffer as 2-digit decimal ASCII
L13F7               pshs      b
                    ldb       #'0-1
L13FB               incb
                    suba      #10
                    bhs       L13FB
                    stb       ,x+
                    adda      #'0+10
                    sta       ,x+
                    puls      pc,b

* Copy a string from Y-buf (src) to X-buf (listing buffer)
* until Null or EOL terminator or end of buffer.
L11BB               cmpx      <u0014              reached end of listbuf?
                    bhs       L11BD               yes, stop copying
                    sta       ,x+
L11BD               lda       ,y+                 Enter here:
                    beq       L11C1               exit if Null
                    cmpa      #C$CR               ..or EOL
                    bne       L11BB               else copy
L11C1               rts

* Do page break (either form feed or series of CR's)
L1408               lda       <u0056
                    bmi       L1476
                    lda       <u0059              Get F (form feed) option flag
                    beq       L1414               If 0, print CR's until we have finished page height
                    bsr       L147D               Form feed flag set, print FF instead
                    bra       L141A

L1414               ldb       <u0035              Get # lines until end of page
                    addb      #3                  Add 3 more
                    bsr       L1471               Write out that many CR's to listing output path
L141A               ldx       <u0004              Get ptr to current pos in output string buffer
                    pshs      x                   Save on stack
                    ldx       <u0002              Get ptr to header output buffer
                    stx       <u0004              Save as current output string buffer
                    ldb       <u0036              Get page height
                    subb      #4                  -4 (header, footer, etc. I presume?)
                    stb       <u0035              Save # lines left to print on current page
                    lbsr      L01E5               Prefill list buffer with 132 spaces
                    leay      <L14A5,pc           Point to 'Microware OS-9 Assembler' etc.
                    bsr       L11BD               Append string to output buffer
                    lbsr      L13BD               Append date/time to output buffer
                    ldx       <u0004              Get current output line ptr
                    ldb       <u0037              Get page width
                    subb      #6                  -6
                    abx                           Point there
                    ldd       <u003A              Get page #
                    lbsr      L1084               Convert to ASCII, append to output buffer
                    inc       <u003A+1            Increase page # lsb
                    bne       L1447
                    inc       <u003A              Increase page # msb
L1447               leax      -$08,x              Point back 8 chars in output buffer
                    leay      <L149F,pc           Point to 'Page'
                    bsr       L11BD               Append string to output buffer
                    leax      3,x                 Skip ahead 3 chars in output buffer
                    lbsr      L1370
                    ldy       <u000A              print NAM field
                    bsr       L11BD               Append to output buffer
                    bsr       L13F2               print " - "
                    lda       #'-
                    sta       ,x+
                    bsr       L13F2
                    ldy       <u0008              print TTL field
                    bsr       L11BD               Append to output buffer
                    lbsr      L1370
                    puls      x                   Get back original output buffer ptr
                    stx       <u0004              Save back as current position in output buffer
                    ldb       #$01                1 CR to append
L1471               bsr       L1479               Write it out
                    decb                          Done all chars to append?
                    bne       L1471               No, do until done.
L1476               ldx       <u0004              Get current output listing buffer ptr & return
                    rts

L1479               lda       #C$CR               Writing out CR('s)
                    fcb       $8c                 CMPX opcode to skip two bytes (same speed, saves a byte)
L147D               lda       #C$FORM             Writing out Form Feed
L147F               pshs      y,x,d
                    lda       <u003E              Get pass counter
                    beq       L1498               If pass 0, return
                    lda       <u0057
                    beq       L1498
                    lda       <u0056              Get L (listing) option flag
                    bmi       L1498               Not set, return
                    lda       <u001A              Get path # for listing
                    leax      ,s                  Output line is on stack
                    ldy       #$0001              Single char to write (Form feed or CR)
                    os9       I$WritLn            Write it out
L1498               puls      pc,y,x,d            restore regs & return

L149F               fcc       'Page '
                    fcb       $00
L14A5               fcc       'Microware OS-9 Assembler RS Version 01.00.00    '
                    fcb       $00
L1533               fcc       'ASM:'

L1537               pshs      u,y,x,d
                    lda       <u005D              Interactive mode?
                    beq       L1549               No, skip user prompt
                    leax      <L1533,pc           Point to 'ASM:'
                    ldy       #$0004              Size of text
                    lda       <u001A              Get output path #
                    os9       I$Write             Write it out
L1549               ldx       <u0000              input buffer
                    ldy       #InBufSiz           read 132 max (may be able to do 212 since overlapping buffers, but too wide for output)
                    lda       <u0018              input path number
L1551               os9       I$ReadLn
                    bcc       TabFix              was->L156A
                    cmpb      #E$EOF              EOF?
                    bne       L1560
                    bsr       L156C               Close current source file & remove it's path from open file path stack
                    bcc       L1549
L155E               bra       L156A

L1560               os9       F$PErr
                    ldb       #17                 'input path' error
                    lbsr      L02FA               Error printing routine
                    bsr       L156C               Close current source file & remove it's path from open file path stack
L156A               puls      pc,u,y,x,d

* Close current source path, and remove that path # from open file path stack
L156C               ldu       <u001F              Get ptr to open file path #'s stack
                    cmpu      <u0006              Any paths on stack?
                    bne       L1576               Yes, close path & remove path from path # stack
                    orcc      #$01                No, exit with error
                    rts

* Close current source path, and remove that path # from open file path stack
L1576               lda       <u0018              Get path # for current source file
                    pulu      b                   Get last path # from open file path # stack
                    stu       <u001F              Save updated open file path # stack ptr
                    stb       <u0018              Save last path # as current path #
                    os9       I$Close             Close original current path
                    bcc       L1586               No error, return
                    os9       F$PErr              If error, print it & return
L1586               rts

* RVH add-on: accept tabs in source text by
* converting them to spaces. X=inbuf,Y=count
TabFix              ldd       #C$RARR*256+C$SPAC  ($0920)  A=tab, B=space
t.loop              cmpa      ,x+                 is it a tab?
                    bne       t.next
                    stb       -1,x                yes, change to space
t.next              leay      -1,y
                    bne       t.loop              scan to end of input
                    andcc     #$FE                error flag off
                    bra       L156A               and return

L14D6               fcc       ' error(s)'
                    fcb       $00
L14E0               fcc       ' warning(s)'
                    fcb       $00
L14EC               fcc       ' program bytes generated'
                    fcb       $00
L1505               fcc       ' data bytes allocated'
                    fcb       $00
L151B               fcc       ' bytes used for symbols'
                    fcb       $00

L1587               pshs      d                   Save 16 bit value we want to convert to hex
                    lda       #'$                 Append $ to output buffer
                    sta       ,x+
                    lda       ,s                  Get high byte of 16 bit value back
                    lbsr      L1057               Append value to ,x in 4 hex digit ASCII)
                    puls      d                   Get 16 bit value back
L1594               lbsr      L1084               Append value to ,x in 5 digit decimal ASCII
                    leay      ,u                  Move ptr to Y for subroutine
                    lbsr      L11BD               Copy string from Y to X
                    lbra      L1368               Something to do with page end

L159F               lbsr      L1323               Flush out code buffer (to file if [-]o= is specified)
L15A2               bsr       L149A               Reset some stuff for new line
                    ldd       <u0028              Get total # of errors
                    leau      <L14D6,pc           Point to errors string
                    bsr       L1594               Print summary of errors
                    ldd       <u0022
                    leau      <L14E0,pc           Point to warnings string
                    bsr       L1594               Print summary of warnings
                    ldd       <u0024              Get # bytes generated
                    leau      <L14EC,pc           Point to program bytes generated string
                    bsr       L1587               Print summary of bytes generated (both hex & dec)
                    ldd       <u0026              Get # data bytes allocated
                    leau      <L1505,pc           Point to data bytes allocated string
                    bsr       L1587               Print summary of data bytes generated (both hex & dec)
                    ldd       <u001D              Get ptr to next empty symbol table slot
                    subd      <u0010              Calc # bytes used in symbol table
                    leau      <L151B,pc           Point to bytes used for symbols string
                    bsr       L1587               Print summary of data bytes generated (both hex & dec)
                    lda       <u005E              'S' flag? (list symbol table)
                    beq       L15D5               No, skip ahead
                    bsr       L1612               Yes, print symbol table
L15D5               lda       <u005D              'I' flag?
                    bne       L15E9               Yes, skip ahead
                    lda       <u0059              'F' flag? (use form feeds?)
                    beq       L15E2               No, skip ahead
                    lbsr      L147D               yes, do a formfeed
                    bra       L15E9               Skip past "manual" form feed (multiple CR's)

L15E2               ldb       <u0035              no, get remaining page length
                    addb      #$03                Add 3 to that
                    lbsr      L1471               Write out that many CR's
L15E9               ldu       <u001F              Get ptr to open file path # stack
L15EB               cmpu      <u0006              Nothing on stack?
                    beq       L15F7               Nothing, exit ASM
                    pulu      a                   Close all still open paths on path # stack, then exit ASM
                    os9       I$Close
                    bra       L15EB

L15F7               clrb                          Exit ASM w/o error
                    os9       F$Exit

L149A               ldx       <u0004              Get ptr to output buffer
                    lbra      L1370

* Print symbol table
L1612               ldb       <u0037              Get page width
                    lsrb                          Divide by 16
                    lsrb
                    lsrb
                    lsrb
                    stb       <u003D              We know result is only 8 bits, save two copies
                    stb       <u003C
                    bsr       L149A
                    ldu       <u0010              Get ptr to index of "first letter" table
                    IFNE      DOCASE
                    ldb       #52                 number of vectors in "first letter" table
                    ELSE
                    ldb       #26                 number of vectors in "first letter" table
                    ENDC      DOCASE
                    pshs      b                   Save ctr
L1629               ldy       ,u++                fetch link to chain for next letter
                    beq       L1656               if null, no symbol starts with this letter
L162E               pshs      u,y                 Have link for current letter, save 1st letter tbl and current letter ptrs
                    bra       L1644

L1632               leau      ,y                  Point U to current entry
                    tfr       d,y                 Point Y to next ptr in linked list (current letter)
L1636               ldd       $0B,y               Get link to next "lower" alphabetical linked list entry
                    bne       L1632               There is one, point to it & try again
                    bsr       L165F               Print the entry
                    ldy       $0D,y               Get link to next "greater" alphabetical linked list entry
                    sty       $0B,u               Save as next "lower" alphabetical linked list entry
                    bne       L1636               If it's an active entry, loop back
L1644               ldu       ,s                  Get ptr to symbol table entry in current letter
                    ldy       $0B,u               Get link to next "lower" alphabetical linked list entry
                    bne       L1636               There is an entry, go do something
                    leay      ,u                  None, point to 1st entry for current letter
                    bsr       L165F               Print entry
                    puls      u,y                 Get 1st letter tbl and current letter ptrs
                    ldy       $0D,y               Get next "greater" alphabetical link in current start letter
                    bne       L162E               Have one, go back
L1656               dec       ,s                  if not done, dec ctr of # of table entries
                    bne       L1629               Do until we have gone through all letters
                    leas      1,s                 Eat temp ctr
                    lbra      L1370

* print a symbol table entry
L165F               pshs      u,y
                    ldd       9,y                 get symbol value
                    lbsr      L1057               call OUT4HS
                    lda       8,y                 get symbol type
                    leau      <L1691,pc           Point to table of letters to designate symbol types
                    lda       a,u                 Get letter for our type
                    ldb       #C$SPAC             2nd char is a space
                    std       ,x++                Store both of them in output buffer
                    ldb       #8                  max symbol length
L1673               lda       ,y+                 Copy symbol name until NUL or 8 chars
                    bne       L1679
                    lda       #C$SPAC             space padded
L1679               sta       ,x+
                    decb
                    bne       L1673
                    dec       <u003C
                    beq       L1688
                    lda       #C$SPAC             Add 1 more space
                    sta       ,x+
                    puls      pc,u,y

L1688               lbsr      L1370               ? Something with page breaks
                    ldb       <u003D
                    stb       <u003C
                    puls      pc,u,y

* Symbol types table
L1691               fcb       'U                  0:Undefined
                    fcb       'L                  1:Label
                    fcb       'S                  2:Set
                    fcb       'E                  3:Equ
                    fcb       'D                  4:Data

* Open source file
* Entry: X=Ptr to filename to open
* Exit: A=path # to file (if Carry clear), carry set if error
L15FB               lda       #READ.              open in READ mode
                    os9       I$Open
                    ldb       #24                 'can't open' error
                    lbcs      L1017               if open fails
                    rts

* parse command line args
L1696               pshs      y,x
                    bsr       L15FB               Open source file for read
                    sta       <u0018              store source path number
L169D               lbsr      L1164               find next text field
                    cmpa      #C$CR               EOL?
                    beq       L16CF               we're done
                    lbsr      L0E33               Check for option
                    lda       <u0058              was there an 'O' flag? (object file create)
                    beq       L16CF               No, return
                    lda       -1,x                yes, get char from arg
                    anda      #$5F                Force case
                    cmpa      #C$CR
                    beq       L16C7               no name given, use default (input filename, to default execution directory)
                    ldb       ,x                  D=parameter bytes
                    cmpd      #$4F3D              "O=" object filepath option?
                    bne       L16C7               No, skip ahead to use default settings
                    ldb       #22                 'opt list' error (default)
                    lda       <u0019              if object file is already open (we already did o=), exit with that error
                    bne       L16D1
                    leax      1,x                 else get pathname
                    bsr       L16D4               and open it
                    bra       L169D               resume option processing

L16C7               lda       <u0019              if object file not yet open,
                    bne       L16CF
                    ldx       ,s                  use default name (=source name)
                    bsr       L16D4
L16CF               puls      pc,y,x

L16D1               lbra      L1017

DelFirst            ldx       ,s                  Get filename ptr back
                    lda       #EXEC.              Execution directory default (if not full path in filename)
                    os9       I$DeletX            Delete file
                    bcs       NrmCrErr            If error deleting, exit with internal Can't open error
                    puls      x                   Successful delete, restore filename ptr for create
* open object file
* Entry: X=ptr to filename/path
L16D4               ldd       #$06*256+$2F        mode=write+exec, permissions=pe pr e w r
                    pshs      x                   Save filename ptr (in case we have -o)
                    os9       I$Create
* LCB - New: if error 218 (File exists), then check if <u0058 is >0 (but not negative). If it is,
* do I$DelX first, then back to L16D4
                    bcc       GdCreate            Created fine, save path # & return
                    cmpb      #E$CEF              File already exists?
                    bne       NrmCrErr            No, all other errors will exit with 'can't open' internal error
                    lda       <u0058              Get Object file flag
                    bgt       DelFirst            If <>0 or $FF, then -o is enabled, so delete old one first
NrmCrErr            orcc      #Carry              force carry back on after cmpb above
                    ldb       #24                 'can't open' error
                    leas      2,s                 Eat filename ptr copy
                    bra       L16D1               if create fails AND overwrite (-o) not present

GdCreate            leas      2,s                 Eat copy of X
                    sta       <u0019              store object path number
                    rts

* Stack Blast clear routine for speed (both 6809/6309)
* Entry: B=Value to clear with (single byte). NOTE: If you enter at StkBlCl2, you can
*          have D=double byte value to clear with (useful for hardware text screens, like in
*          Level II grfdrv)
*        X=Size (in bytes) to clear
*        U=Start address to clear from
* NOTE: No incoming regs preserved!
* NOTE: If you have a 2 byte value (hware text), put that in D, and call via StkBlCl2
* NOTE 2: If you know you are doing an even 4 byte sized clear, you can preload X with the value(s)
*    to clear with, A:B as the # of 4 byte chunks, and U as the ptr to then end of the clear,
*    and jump straight to either NormClr. You do have to add 3 bytes to the stack first
StkBlClr            tfr       b,a                 D=double copy of value to clear memory with
StkBlCl2            exg       x,d                 D=Size to clear (in bytes), X=2 byte value to clear with
                    IFNE      H6309
                    addr      d,u                 Point to end of clear area for stack blast
                    ELSE
                    leau      d,u                 Point to end of clear area for stack blast
                    ENDC
                    pshs      b,x                 Save 16 bit value to clear with, & LSB of size (to check for leftover bytes)
                    lsra                          Divide size by 4 (since we are doing 4 bytes at a time)
                    rorb
                    lsra
                    rorb
                    pshs      d                   Save mini-stackblast counters
                    ldd       2,s                 Get A=LSB of # of bytes to clear, B=byte to clear with
                    anda      #%00000011          Non-even multiple of 4?
                    beq       NoOdd               Even, skip single byte cleanup copy
OverLp              lsra                          Odd # of bytes?
                    bcc       Do2                 No, skip to 2 byte copy (can only be 2 at this point)
                    stb       ,-u                 Yes, save 1 byte (could be 1 or 3)
Chk2Byte            lsra                          Double byte as well?
                    bcc       NoOdd               No, do 4 byte chunks if needed
Do2                 stx       ,--u                Save double byte value
NoOdd               ldd       ,s++                Get Mini-stack blast ctrs back
                    beq       ExitClrB            No 4 byte blocks, done
NormClr             leay      ,x                  Dupe 16 bit clear value to Y
ClrLp               pshu      x,y                 Clear 4 bytes
                    decb                          Dec "leftover" (<256) 4 byte block counter
                    bne       ClrLp               Keep doing till that chunk is done
                    deca                          Dec 1Kbyte counter
                    bpl       ClrLp               Still going (B has been set to 0, so inner loop is 256 now)
ExitClrB            puls      b,x,pc              Eat temp regs & return

* Entry if known 4 byte multiple to clear ONLY
* Entry if called here: B,X on stack (or leas -3,s if you don't care)
*   X=16 bit value to clear with
*   U=ptr to end of clear ptr+1
*   A=# of 1k blocks to clear
*   B=# of 4 byte "leftover" blocks to clear
FourBClr            pshs      b,x                 Preserve regs for sub
                    bra       NormClr             Do copy

                    emod
eom                 equ       *
                    end
