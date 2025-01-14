*************************************************************
* BAWK Edition 3 - (Boisy's Awk) - Line processing utility
*
* (C) 1992 Boisy G. Pitre
*
*        BAWK is a line processing utility "similar", but not exactly
* the same as the UNIX counterpart.  For one, this version of BAWK is
* NOT a processing language.  Its a line processing program.  Don't
* get BAWK confused with AWK.  They are two totally different programs.
*
*        BAWK takes advantages of "fields" in lines of text.  A field
* is a word or symbol, separated by whitespace.  Each field is numbered
* sequentially from left to right.  An example of how BAWK see's fields
* in lines of text:
*
*        1  2    3  4
*        my name is boisy
*
*        The numbers above the words in the line represent the field
* numbers.  BAWK can extract any or all of these fields by their field
* number in any order, for a wide variety of useful formats.  These formats
* can then be piped to another program or to a file for processing.
*
* Usage:  BAWK [-a# -i -d? -l -f -F] "format field" [file] [...]
*
* NOTICE:  Options are CASE SENSITIVE!  Be aware of this when using BAWK.
*
*     Opts:
*        -d? = the optional delimiter you wish to use.
*              Ex. to use a colon as a delimiter in addition to
*                  the already used space, use -d:
*
*        -a# = Anchor start field to #th column.
*
*        -i  = prints lines even if the field doesn't exist.
*              This option tells BAWK to print the format string even
*              if the specified field is not found on the line.
*              Default is OFF.
*
*        -l  = Prints the name of the file currently being scanned.
*
*        -f  = Forks a shell with the expanded line as a parameter.  The
*              expanded line buffer is NOT printed.
*
*        -F  = Forks a shell with the expanded line as a parameter, and
*              prints the expanded line to StdOut.
*
* The format field can contain any characters you wish.  The special
* character '$' is used to denote field positions.  (Fields are from 1 to
* 255).  If you wanted to extract the 5th field in a line, you would include
* $5 in the format string.  BAWK would interpret this to be the fifth
* field, and would then expand it appropriately.  Looking at the previous
* example:
*
*        1  2    3  4
*        my name is boisy
*
*        NOTE: there is a special field, $0, which denotes the ENTIRE
* input line.
*
*        To tell BAWK to print the 3rd field in that line, the following
* command line would work:
*
*        echo my name is boisy | bawk "$3"
*
*        Note that the format string is ALWAYS contained in '"' quotes.
* You may also include non-specific info as part of the field.  I use the
* following line in my /DD/SYS/CRONTAB file to stop my BBS at 7:00 each
* morning:
*
*                 procs | fgrep -i "tsmon" | bawk -f "kill $1"
*
*        This line uses PROCS' output, and pipes it into FGREP.  FGREP then
* throws away any lines that don't contain the word tsmon.  The remaining
* lines that do contain the keyword are then piped to BAWK.  BAWK takes the
* first field of that line (the Process ID number of tsmon), and combines
* it in a format whose output looks like:  kill 3 (assuming 3 is the ID
* of the tsmon process).  Finally, that line is used as a parameter for
* shell execution.
*
*        You may also specify a filename or a list of them AFTER the format
* string.  When using filenames, you can tell BAWK to print the name of the
* file it is currently scanning (to StdOut) using the -f option.
*        To use '$' as a regular character in a format string, use $$.
*  BAWK does not interpret this as the '$' field specifier.
*
*        You can mix and match any number of fields for interesting
* combinations.  If you prefer military time instead of DATE's regular
* output, try this:
*
*              date | bawk -d, "$2 $1 $3"
*
*        This example also introduced the -d option.  This option allows
* you to specify another delimiter in addition to the already used space
* character.  A good example of this would be finding the 5th field in
* the /DD/SYS/PASSWORD file, whose delimiter is a comma, NOT a space.
*
*        Another useful option is -i.  This allows the inclusion of printing
* the format string even though that field is not found on the line.
* Take the previous example again:
*
*        1  2    3  4
*        my name is boisy
*
*        The following command line would print nothing:
*              echo my name is boisy | bawk "Name $5"
*
*        BUT this line will output 'Name ':
*              echo my name is boisy | bawk -i "Name $5"
*
*        Keep in mind that if the -i option is not used, NO lines will
* be printed unless ALL fields are qualified.
*
*
*        One other option worth noting is the -a option.  This option sets
* an "anchor" to the #th column.  Using our infamous example:
*
*        1  2    3  4
*        my name is boisy
*
*        The following command line would print 'name' because the anchor
* is set to the 3rd column (which is a space, ignored by BAWK):
*        echo my name is boisy | bawk -a3 "$1"
*
*        To print the names of all the modules in block $3F using MDIR:
*              mdir e | grep "3F" | bawk "Module: $8"
*
*        BAWK has very useful applications, making it a worthy addition to
* your OS-9 toolbox.  In addition to these features, BAWK works GREAT with
* Shell+'s wildcards!
*
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*
*

                    nam       BAWK
                    ttl       Line processing utility

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Finish

Name                fcs       /bawk/
Ed                  fcb       3                   Edition #3

Anchor              rmb       1
Path                rmb       1
IncFlag             rmb       1                   Inclusion Flag
FileFlag            rmb       1                   Show File Flag
ForkFlag            rmb       1                   Fork Shell Flag
FEFlag              rmb       1                   Fork Shell and Echo Flag
Delim               rmb       1                   Delimiter storage
FileBuff            rmb       60                  Filename buffer
Format              rmb       250                 Format buffer
Line                rmb       250                 Line buffer
ExpLine             rmb       4096                Expanded line buffer
Stack               rmb       200
Params              rmb       200
Finish              equ       .


HelpMess            fcc       /Usage:  BAWK [-d? -i -l -a# -f -F] "format_string" [file] [...]/
                    fcb       C$CR

Shell               fcc       "Shell"
                    fcb       C$CR

FileHead            fdb       C$LF,C$CR
                    fcc       "*** File: "
FileHLen            equ       *-FileHead

****************************************
* Subroutines

****************************************
* Str2Byte - Converts an ASCII string to a single byte
*
* Entry: X - Address of first char in string
*
* Exit:  B - Converted byte
*        X - Last number in string + 1
*

Str2Byte            clrb
cnvloop             lda       ,x+
                    cmpa      #'9
                    bhi       cnvdone
                    suba      #'0
                    blo       cnvdone
                    pshs      a
                    lda       #10
                    mul
                    addb      ,s+
                    bra       cnvloop
cnvdone             leax      -1,x
                    rts

****************************************
* Saves filename in buffer and print it
*
* Entry: X - Address where filename is
*
* Exit:  None.  File is stored in FileBuff
*

SaveFile            pshs      x
                    leay      FileBuff,u
SaveF2              lda       ,x+
                    cmpa      #C$SPAC
                    bne       SaveF3
                    lda       #C$CR
SaveF3              sta       ,y+
                    cmpa      #C$CR
                    bne       SaveF2
                    puls      x
                    rts

****************************************
* Sets the anchor
*
* Entry: X - Address of line
*
* Exit:  X - Points to the EOLN char at the
*            end of the line
*

AncLine             pshs      b                   save counter
                    tst       Anchor              Anchor to a column other than 1 or 0?
                    beq       Return              Nope, process at first column
AncLoop             ldb       Anchor              else move X to anchor point
Anc2                lda       ,x+
                    cmpa      #C$CR
                    beq       BackUp
                    decb
                    bne       Anc2
BackUp              leax      -1,x
Return              puls      b
                    rts

****************************************
* Prints filename to StdOut
*
* Entry:  None
*
* Exit:   None
*
* Prints a file header to StdOut along with
* the filename.
*

PrnFile             pshs      x
                    leax      FileHead,pcr
                    lda       #1
                    ldy       #FileHLen
                    os9       I$Write
                    lbcs      Error
                    leax      FileBuff,u
                    lda       #1
                    ldy       #60
                    os9       I$WritLn
                    lbcs      Error
                    puls      x
                    rts

****************************************
* Strips leading spaces
*
* Entry: X - Address of line
*
* Exit:  X - Points to first non-space character

EatSpace            pshs      a
Eat2                lda       ,x+
                    cmpa      #C$SPAC
                    beq       Eat2
                    leax      -1,x
                    puls      a
                    rts

****************************************
* Entry of program

Start               decb                          any params?
                    lbeq      Help                nope, exit w/ error

                    clr       Path                assume stdin upon entry
                    clr       IncFlag             Clear (OFF) inclusion flag
                    clr       FileFlag            Clear printing of filenames
                    clr       Anchor              Anchor to first column
                    clr       FEFlag              Clear Fork/Echo flag
                    clr       ForkFlag            Clear Fork flag
                    lda       #C$SPAC             put space as extra delimiter
                    sta       Delim

****************************************
* Command line parsing is done here

Parse               bsr       EatSpace
                    lda       ,x+
                    cmpa      #C$CR
                    beq       Help
                    cmpa      #'-
                    bne       IsItQ
* Dash options parsed here
                    lda       ,x+                 load A with char
                    cmpa      #'a                 is it the anchor option?
                    bne       IsItF
                    lbsr      Str2Byte
                    stb       Anchor
                    bra       Parse
IsItF               cmpa      #'f
                    bne       IsItUpF
                    lda       #$ff
                    sta       ForkFlag
                    bra       Parse
IsItUpF             cmpa      #'F
                    bne       IsItL
                    lda       #$ff
                    sta       FEFlag
                    bra       Parse
IsItL               cmpa      #'l
                    bne       IsItI
                    lda       #$FF
                    sta       FileFlag
                    bra       Parse
IsItI               cmpa      #'i                 is it the inclusion option?
                    bne       IsItD
                    lda       #$ff                set Inclusion Flag
                    sta       IncFlag
                    bra       Parse
IsItD               cmpa      #'d                 delimiter?
                    bne       Help                bad option -- error out
                    lda       ,x+                 else load character after the 'D'
                    sta       Delim               save it...
                    bra       Parse               then go back to parsing the line
* Format String detected here
IsItQ               cmpa      #'"                 Is it a '"' format string?
                    bne       Help                nope, must be an error

* Save the format string
SaveFmat            leay      Format,u
SaveFmt2            lda       ,x+                 Point to char after first '"'
                    cmpa      #C$CR
                    beq       Help
                    cmpa      #'"                 is it the second '"'?
                    bne       SaveFmt3            no, save char
                    lda       #C$CR
                    sta       ,y
                    bra       ChkFile
SaveFmt3            sta       ,y+                 else save char
                    bra       SaveFmt2
ChkFile             lbsr      EatSpace            Check after last '"' for a filename
                    lda       ,x
                    cmpa      #C$CR               if no filename, execute from StdIn
                    beq       MainLine
                    bra       OpenFile

****************************************
* Help Routine
*

Help                leax      HelpMess,pcr        Show Help message
                    lda       #2
                    os9       I$WritLn
                    bra       Done

****************************************
* Check for EOF
*

EOF                 cmpb      #E$EOF
                    bne       Error
                    lda       Path
                    os9       I$Close             Close path
                    puls      x                   and restore the cmd line pointer
                    tst       Path
                    beq       Done
                    bra       FilePrs

****************************************
* Exit Here
*

Done                clrb
Error               os9       F$Exit


****************************************
* BAWK goes here if files are on the cmd line
*

FilePrs             lbsr      EatSpace            eat spaces
                    lda       ,x                  check char
                    cmpa      #C$CR               if CR,
                    beq       Done

OpenFile            lbsr      SaveFile
                    lda       #READ.              else assume a file name
                    os9       I$Open              and try to open it
                    bcs       Error
                    sta       Path
                    tst       FileFlag
                    beq       MainLine
                    lbsr      PrnFile

****************************************
* The following lines are the "heart" of BAWK's processing
*

MainLine            pshs      x                   save pointer to cmd line

****************************************
* The line of input is read from here.
*

ReadLine            lda       Path                get path
                    ldy       #250                max chars per line
                    leax      Line,u              point to line buffer
                    os9       I$ReadLn            and read the line
                    bcs       EOF                 check EOF if error

****************************************
* The Process of Expansion starts here.
*

ProcLine            leax      Format,u
                    leay      ExpLine,u           Position Y to expansion line

ParseFmt            lda       ,x+
                    cmpa      #'$                 Is it the '$' field character?
                    beq       FieldPar            Check Field Parameter
PFmt2               sta       ,y+
                    cmpa      #C$CR
                    bne       ParseFmt
                    tst       ForkFlag
                    bne       PFmt3
                    bsr       Print
                    tst       FEFlag              see if the fork/echo flag is set
                    beq       ReadLine
PFmt3               lbsr      Fork
                    bra       ReadLine
FieldPar            lda       ,x+                 get char after '$'
                    cmpa      #'$                 Is it another?
                    beq       PFmt2               yep, store it
                    leax      -1,x
FieldP2             lbsr      Str2Byte            convert the number
                    tstb                          check the number to see if it's 0
                    bne       Field1

****************************************
* The entire line is copied at the direction of $0
*

                    pshs      x
                    leax      Line,u              at this point we copy the entire...
                    lbsr      AncLine             Anchor the line
CopyAll             lda       ,x+                 and transfer the rest of the line
                    cmpa      #C$CR               line since we've encountered a $0
                    beq       Field3              and continue parsing
                    sta       ,y+
                    bra       CopyAll

Field1              pshs      x                   save position in format string
                    bsr       SetField            Position to the proper field
                    tstb                          was there an error?
                    beq       Field2              no, continue with expansion
                    tst       IncFlag             is the inclusion flag set?
                    bne       Field2
                    puls      x
                    bra       ReadLine
Field2              bsr       Expand
Field3              puls      x                   get position in format string
                    bra       ParseFmt            and continue expanding...


****************************************
* SETFIELD - This routine positions the X pointer to the correct field
*
* Entry:  B - Number of the field
*
* Exit:   B - clear if field was found, set if it wasn't found
*         X - Address of Bth field (Points to EOLN if B is set)
*

SetField            leax      Line,u
                    lbsr      AncLine             Anchor the line
Skip                lda       ,x+
                    cmpa      #C$SPAC
                    beq       Skip
                    cmpa      Delim
                    beq       Skip
                    cmpa      #C$CR
                    beq       Leave2
                    decb
                    beq       Leave
EatField            lda       ,x+
                    cmpa      #C$SPAC
                    beq       Skip
                    cmpa      Delim
                    beq       Skip
                    cmpa      #C$CR
                    beq       Leave2
                    bra       EatField
Leave               clrb
Leave2              leax      -1,x
ExExit              rts


****************************************
* EXPAND - This routine "expands" the field into the expansion buffer
*

Expand              lda       ,x+
                    cmpa      #C$SPAC
                    beq       ExExit
                    cmpa      Delim
                    beq       ExExit
                    cmpa      #C$CR
                    beq       ExExit
                    sta       ,y+
                    bra       Expand


****************************************
* The expanded line is printed to StdOut here
*

Print               leax      ExpLine,u           Point X to the expanded line buffer
                    ldy       #500                max chars 500
                    lda       #1
                    os9       I$WritLn            write to stdout
                    lbcs      Error
                    rts

****************************************
* The expanded line is used as a paramter to a shell
*

Fork                pshs      x,u
                    lda       #Prgrm+Objct
                    ldb       #16                 Use 16 pages (4K) of data
                    leax      Shell,pcr           Point to name of Shell
                    ldy       #4096
                    leau      ExpLine,u           Point X to the expanded line buffer
                    os9       F$Fork              Fork it!
                    lbcs      Error
                    os9       F$Wait
                    puls      x,u
                    rts

                    emod
Size                equ       *
                    end

