********************************************************************
* Backup - Make a backup copy of a disk
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   8      ????/??/??
* From Tandy OS-9 Level Two VR 02.00.01.
*
*   9      2005/05/03  Robert Gault
* Folded in a new option F to permit a .dsk image file to be used
* instead of dev1. Full path or local file can be used. There is
* still a comparison of LSN0 to make sure that a disk actually has
* been formatted for the correct number of sides and tracks.
*
*  10      2008/11/12 Robert Gault
* Removed what seemed unnecessary Close and reOpen lines.
* Relocated verification turn off routine.
* Preservation of new disk ID is now possible per Gene's idea.
* SAVEID is a switch to select save/no_save of ID on destination disk.
* Copy and Verification start at LSN1 since LSN0 gets checked several times anyway.
*
*          2026/05/29  Codex
* Annotated source and normalized comments.

;;; backup
;;;
;;; Syntax: backup [opts] <devname1> <devname2>
;;; Function: Copies all data from one disk to another.
;;; Parameters:
;;;     devname1  The drive containing the disk files you want to back up.
;;;     devname2  The drive containing the disk to which you want to transfer the files.
;;;     opts      One or more of the following options.
;;; Options:
;;;      e        Cancels the backup if a read error occurs.
;;;      S        Backup a diskette using only one drive.
;;;      -v       Don't verify the data written to the destination diskette.
;;;      #nK      Increase to n the amount of memory that backup uses.
;;;
;;; Notes
;;;
;;; backup performs a sector by sector copy, ignoring file structures. In all cases, the devices specified must have the same format (size, density, and so forth)
;;; and the destination disk must not have defective sectors.
;;; If you omit both device names, the system assumes you are copying from /DO to /D1. If you omit only the second device
;;; name, OS-9 performs a single-drive backup on the specified drive.
;;; The following demonstrates a complete backup of /DO to /D1. In the example, the diskette in Drive /D1 is a formatted diskette with the name MYDISK. Scratched, which appears in one of the following messages, means erased. You type:
;;;
;;;      backup [ENTER]
;;;
;;; The screen display and your input are:
;;;
;;;      Ready to backup from /dd to /d1 ?: [Y]
;;;      MYDISK
;;;       is being scratched
;;;      OK?: [Y]
;;;      Sectors copied: $0276
;;;      Verify pass
;;;      Sectors verified: $0276
;;;
;;; Following is an example of a single-drive back up. backup reads a portion of the source diskette (the diskette you are copying) into memory. It then prompts you to remove the source diskette and put the destination diskette (the
;;; diskette receiving the copy) into the drive.
;;; After backup writes to the destination diskette, remove the destination diskette and put the source diskette back
;;; into the drive. Continue swapping as prompted until backup copies the entire diskette.
;;; Giving backup as much memory as possible means you have to make fewer diskette exchanges. If enough free memory is available, you can assign up to 56 kilobytes for the backup operation. An Error 207 means that your computer does not have the specified
;;;
;;;      backup /dO #32k [ENTER]
;;;

                    nam       Backup    ; name the OS-9 module
                    ttl       Make a backup copy of a disk ; set the listing title

* Disassembled 02/04/03 23:08:04 by Disasm v1.6 (C) 1988 by RML

                  IFP1
                    use       defsfile  ; pull in OS-9 system definitions
                  ENDC

DOHELP              set       1         ; enable built-in usage text
* Default 0 means do not save destination disk ID. 1 means save it. RG
SAVEID              set       0         ; default to replacing destination disk ID

tylg                set       Prgrm+Objct ; mark module as a program object
atrv                set       ReEnt+rev ; mark module reentrant with revision bits
rev                 set       $00       ; module revision byte
edition             set       10        ; module edition byte

                    mod       eom,name,tylg,atrv,start,size ; define OS-9 module header

srcpath             rmb       1         ; path number for source disk or image
dstpath             rmb       1         ; path number for destination disk
u0002               rmb       2         ; pointer to parsed source path in strbuf
u0004               rmb       5         ; pointer storage for parsed destination path
u0009               rmb       1         ; nonzero after first hex digit has printed
errabrt             rmb       1         ; abort if read error flag (1 = abort, 0 = continue)
pmptsng             rmb       1         ; single-drive prompt flag (1 = prompt, 0 = no prompt)
dontvfy             rmb       1         ; inhibit verify pass flag (1 = skip verify)
fileflg             rmb       1         ; source is image file flag (0 = disk, 1 = file)
noprompt            rmb       1         ; do-not-prompt flag parsed but not otherwise used here
srcerr              rmb       1         ; most recent source read error code
curlsn              rmb       3         ; current 24-bit logical sector number
sctbuf              rmb       2         ; current end pointer in sector buffer
numpages            rmb       1         ; number of 256-byte pages available for transfer buffer
pagcntr             rmb       1         ; remaining page count for current transfer
dstdev              rmb       32        ; destination device name with trailing @
optbuf              rmb       32        ; rbf path option buffer for SS.Opt
bufptr              rmb       2         ; next character position in output/string buffer
strbuf              rmb       424       ; path and output formatting buffer
stack               rmb       80        ; private process stack space
* Important, the next two lines MUST STAY TOGETHER because of assumptions
* about their location in the code.
dstlsn0             rmb       256       ; destination LSN0 sector image
srclsn0             rmb       256       ; source LSN0 sector image
backbuff            rmb       14*256    ; transfer buffer pages after the LSN0 work sectors
size                equ       .         ; end of static data area

name                fcs       /Backup/            ; module name string
                    fcb       edition   ; append edition byte to module name

defparms            fcc       "/d0 /d1"           ; default source and destination device names
                    fcb       C$CR      ; terminate default parameter line
                  IFNE    DOHELP  ; assemble help text when enabled
* Added F option; RG
HelpMsg             fcb       C$LF      ; begin help text on a new line
                    fcc       "Use: Backup [e] [f] [s] [-v]" ; show command syntax
                    fcb       C$LF      ; advance to next help line
                    fcc       "            [/dev1 [/dev2]]" ; show optional device operands
                    fcb       C$LF      ; advance to next help line
                    fcc       "  e - abort if read error" ; describe read-error option
                    fcb       C$LF      ; advance to next help line
                    fcc       "  f - replace dev1 with .dsk image file" ; describe image-file option
                    fcb       C$LF      ; advance to next help line
                    fcc       "  p - do not prompt user" ; describe no-prompt option
                    fcb       C$LF      ; advance to next help line
                    fcc       "  s - single drive prompts" ; describe single-drive option
                    fcb       C$LF      ; advance to next help line
                    fcc       " -v - inhibit verify pass" ; describe verify-inhibit option
                  ENDC    ;       end optional help text
L00A0               fcb       $80+C$CR  ; high-bit-terminated carriage return
L00A1               fcc       "Ready to backup from" ; first ready-prompt fragment
L00B5               fcb       $80+C$SPAC ; high-bit-terminated space
to                  fcs       " to "              ; prompt separator between source and destination
ok                  fcc       "Ok"                ; confirmation prompt prefix
ask                 fcs       " ?: "              ; yes/no prompt suffix
rdysrc              fcs       "Ready Source, hit a key: " ; single-drive source prompt
rdydst              fcs       "Ready Destination, hit a key: " ; single-drive destination prompt
L00F7               fcs       "Sector $"          ; sector-error message prefix
sctscpd             fcs       "Sectors   copied: $" ; copied-sector count prefix
vfypass             fcb       C$LF      ; start verify-pass message on a new line
                    fcc       "Verify pass"       ; verify-pass message text
                    fcb       $80+C$CR  ; terminate message with high-bit CR
sctvfd              fcs       "Sectors verified: $" ; verified-sector count prefix
scratch             fcb       C$LF      ; start scratch warning on a new line
                    fcc       " is being scratched" ; scratch warning text
                    fcb       $80+C$CR  ; terminate warning with high-bit CR
notsame             fcc       "Disks not formatted identically" ; incompatible-media error text
                    fcb       C$LF      ; terminate incompatible-media line
bkabort             fcc       "Backup Aborted"    ; abort message text
                    fcb       $80+C$CR  ; terminate abort message with high-bit CR

* Here's how registers are set when this process is forked:
*
*   +-----------------+  <--  Y          (highest address)
*   !   Parameter     !
*   !     Area        !
*   +-----------------+  <-- X, SP
*   !   Data Area     !
*   +-----------------+
*   !   Direct Page   !
*   +-----------------+  <-- U, DP       (lowest address)
*
*   D = parameter area size
*  PC = module entry point abs. address
*  CC = F=0, I=0, others undefined

* The start of the program is here.
start               leas      >stack,u  ; move stack pointer to private stack area
                    pshs      b,a       ; save parameter area size
                    pshs      u         ; save direct-page/data-area base
                    tfr       y,d       ; copy top of parameter area to D
                    subd      ,s++      ; compute parameter-top minus data-area base
                    subd      #backbuff-stack ; subtract fixed data before transfer buffer
* A = number of 256 byte pages that are available for backup buffer
                    sta       <numpages ; save available transfer-buffer pages
                    clr       <pmptsng  ; default to no single-drive prompting
                    clr       <fileflg  ; default source operand to disk device
                    clr       <errabrt  ; default to continuing after read errors
                    clr       <dontvfy  ; default to performing verify pass
                    clr       <srcerr   ; clear saved source error code
                    leay      <strbuf,u ; point Y at shared string buffer
                    sty       <bufptr   ; initialize output/string write pointer
                    ldd       ,s++      ; restore command-line parameter length
                    beq       L01E3     ; use default parameters if none were supplied
L0199               ldd       ,x+       ; fetch current option byte and following byte
                    cmpa      #C$SPAC   ; test for leading space
                    beq       L0199     ; skip spaces between options and paths
                    cmpa      #C$COMA   ; test for comma separator
                    beq       L0199     ; skip commas between options and paths
                    eora      #'E       ; compare option character with e/E
                    anda      #$DF      ; ignore case while preserving zero result
                    bne       Chk4P     ; try next option if this is not e/E
                    cmpb      #'0       ; ensure next byte is not alphanumeric option text
                    bcc       Chk4P     ; treat as a path if followed by digit or later
                    inc       <errabrt  ; set abort-on-read-error flag
                    bra       L0199     ; continue parsing options
Chk4P               lda       -$01,x    ; reload current option character
                    eora      #'P       ; compare option character with p/P
                    anda      #$DF      ; ignore case while preserving zero result
                    bne       Chk4S     ; try next option if this is not p/P
                    inc       <noprompt ; record no-prompt option
                    bra       L0199     ; continue parsing options
Chk4S               lda       -$01,x    ; reload current option character
                    eora      #'S       ; compare option character with s/S
                    anda      #$DF      ; ignore case while preserving zero result
                    bne       Chkimg    ; try image option if this is not s/S
                    cmpb      #'0       ; ensure option is not followed by digit or later
                    bcc       L01C1     ; stop option parsing if it looks like a path/token
                    inc       <pmptsng  ; enable single-drive prompting
                    bra       L0199     ; continue parsing options
* New routine to check for new option F; RG
Chkimg              lda       -1,x      ; reload current option character
                    eora      #'F       ; compare option character with f/F
                    anda      #$DF      ; ignore case while preserving zero result
                    bne       L01C1     ; stop option parsing if this is not f/F
                    cmpb      #'0       ; ensure option is not followed by digit or later
                    bcc       L01C1     ; stop option parsing if it looks like a path/token
                    inc       <fileflg  ; mark source as a .dsk image file
                    bra       L0199     ; continue parsing options
* End of new routine
L01C1               ldd       -$01,x    ; reload current byte and following byte
                    cmpa      #'-       ; test for dash option prefix
                    bne       L01D7     ; treat current byte as path text if not dashed
                    eorb      #'V       ; compare second option byte with v/V
                    andb      #$DF      ; ignore case while preserving zero result
                    bne       L01D7     ; treat as path if not -v
                    ldd       ,x+       ; consume bytes following -v
                    cmpb      #'0       ; ensure -v is not followed by digit or later
                    bcc       L01D7     ; stop option parsing if it looks like a path/token
                    inc       <dontvfy  ; inhibit verify pass
                    bra       L0199     ; continue parsing options
L01D7               lda       ,-x       ; back up to current non-option byte
                    tst       <fileflg  ; allow image file names without leading slash
                    bne       L01E7     ; accept image-file source name as-is
                    cmpa      #PDELIM   ; test for OS-9 path delimiter
                    beq       L01E7     ; continue if first path begins with slash
                    cmpa      #C$CR     ; test for end of parameter line
                    lbne      ShowHelp  ; show help for unexpected non-path text
L01E3               leax      >defparms,pcr ; use built-in /d0 /d1 default operands
L01E7               leay      >L00A1,pcr ; point to ready prompt text
                    lbsr      L044B     ; append "Ready to backup from"
                    ldy       <bufptr   ; fetch current string-buffer position
                    sty       <u0002    ; remember start of source path text
                    tst       <fileflg  ; test whether source is a .dsk image file
                    bne       L01F7a    ; parse image names without F$PrsNam
                    lbsr      L043A     ; parse and copy OS-9 source path name
                    bra       L01F7     ; continue with destination/path separator scan
L01F7a              lbsr      getnm     ; copy image file name up to space or comma
L01F7               lda       ,x+       ; fetch next command-line separator byte
                    cmpa      #C$SPAC   ; test for space separator
                    beq       L01F7     ; skip spaces before destination path
                    cmpa      #C$COMA   ; test for comma separator
                    beq       L01F7     ; skip commas before destination path
                    cmpa      #C$CR     ; test for missing destination operand
                    bne       L020B     ; validate explicit destination path
                    inc       <pmptsng  ; single operand implies single-drive prompting
                    ldx       <u0002    ; reuse source path as destination path
                    lda       ,x+       ; fetch first byte of copied source path
L020B               cmpa      #PDELIM   ; destination must be an OS-9 device path
                    lbne      ShowHelp  ; show help if destination lacks path delimiter
                    leax      -$01,x    ; back up to start of destination path
                    leay      >to,pcr   ; point to " to " prompt fragment
                    lbsr      L044B     ; append separator to prompt buffer
                    ldy       <bufptr   ; fetch current prompt-buffer position
                    sty       <u0004    ; remember start of destination path text
                    lbsr      L043A     ; parse and copy destination path name
                    leay      >ask,pcr  ; point to yes/no suffix
                    lbsr      getkey    ; display prompt and read confirmation key
                    comb                ; invert carry for following exit logic
                    eora      #'Y       ; compare response with y/Y
                    anda      #$DF      ; ignore case while preserving zero result
                    lbne      exit      ; exit unless user confirmed
                    tst       <fileflg  ; test whether source is an image file
                    bne       L0238b    ; do not append @ to image-file source
                    ldx       <u0002    ; point X at source device path text
                    ldd       #'@*256+C$SPAC ; prepare @ and space terminator pair
L0238               cmpb      ,x+       ; scan for terminating space in source path
                    bne       L0238     ; continue until end of path text
                    std       -$01,x    ; replace terminator with @ and space
L0238b              ldx       <u0002    ; point X at source path text
                    lda       #READ.    ; request read access for source
                    os9       I$Open    ; open source device or image file
                    bcs       L027C     ; handle open error
* Relocated since Close Open is removed. RG
                    sta       <srcpath  ; save source path number
                    leax      >srclsn0,u ; point X at source LSN0 buffer
                    ldy       #256      ; request one sector
                    os9       I$Read    ; read source LSN0
                    bcs       L027C     ; handle source read error
                    ldx       <u0004    ; point X at destination path text
                    leay      <dstdev,u ; point Y at destination device buffer
L0267               ldb       ,x+       ; copy next destination path byte
                    stb       ,y+       ; store destination path byte
                    cmpb      #C$SPAC   ; test for copied path terminator
                    bne       L0267     ; copy until terminating space
                    ldd       #'@*256+C$SPAC ; prepare @ and space terminator pair
                    std       -$01,y    ; force raw device access on destination
                    leax      <dstdev,u ; point X at rewritten destination path
                    lda       #READ.+WRITE. ; request read/write access
                    os9       I$Open    ; open destination device
L027C               lbcs      L03AF     ; report and abort on any pending I/O error
                    sta       <dstpath  ; save destination path number
* Relocated so that Close Open can be removed. RG
                    leax      <optbuf,u ; point X at path option buffer
                    ldb       #SS.OPT   ; select GetStt/SetStt path options
                    os9       I$GetStt  ; read current destination path options
                    ldb       #$01      ; nonzero disables RBF write verify
                    stb       PD.VFY,x  ; turn off driver-level verify during copy
                    ldb       #SS.OPT   ; select path options for update
                    os9       I$SetStt  ; write modified destination path options
                    lbcs      L03AF     ; abort if option update failed
*
                    clr       <curlsn   ; clear high byte of current LSN
                    clr       <curlsn+1 ; clear middle byte of current LSN
                    clr       <curlsn+2 ; clear low byte of current LSN
* This starts copy routine at LSN1 instead of LSN0. RG
                    inc       <curlsn+2 ; start copy phase at LSN1
                    lbsr      L0419     ; optionally prompt for destination disk
                    lda       <dstpath  ; load destination path number
                    leax      >dstlsn0,u ; point X at destination LSN0 buffer
                    ldy       #256      ; request one sector
                    os9       I$Read    ; read destination LSN0
                    pshs      u,x       ; save data base and sector-buffer pointer
                    ldx       #$0000    ; prepare seek MSW as zero
                    leau      ,x        ; prepare seek LSW as zero
                    os9       I$Seek    ; reseek destination to LSN0
                    puls      u,x       ; restore data base and sector-buffer pointer
                    bcs       L027C     ; handle seek/read error
                    ldd       >256,x    ; load source total-sector high/mid bytes from adjacent buffer
                    cmpd      ,x        ; compare against destination total-sector high/mid bytes
                    bne       DsksNOk   ; reject disks with different sector counts
                    ldb       >$0102,x  ; load source total-sector low byte
                    cmpb      $02,x     ; compare destination total-sector low byte
                    beq       DsksOk    ; continue when sector counts match
DsksNOk             leay      >notsame,pcr ; point to format-mismatch message
                    lbra      L03B6     ; print message and exit with carry set
DsksOk              leax      >dstlsn0,u ; point X at destination LSN0 for name display
                    lda       #$BF      ; mark DD.OPT with high-bit terminator for printing
                    sta       <DD.OPT,x ; terminate disk name for prompt output
                    leay      <DD.NAM,x ; point Y at destination disk name
                    lbsr      L044B     ; append disk name to prompt buffer
                    leay      >scratch,pcr ; point to scratch warning text
                    lbsr      L0456     ; display destination scratch warning
                    leay      >ok,pcr   ; point to confirmation prefix
                    lbsr      getkey    ; read confirmation from stdin
                    comb                ; invert carry for following exit logic
                    eora      #'Y       ; compare response with y/Y
                    anda      #$DF      ; ignore case while preserving zero result
                    lbne      exit      ; exit if user declines to scratch destination
                    lda       <dstpath  ; reload destination path number
                    leax      >srclsn0,u ; point X at saved source LSN0
                  IFNE    SAVEID  ; optionally preserve destination disk ID
* New routine to preserved destination disk ID. Gene's idea. RG
                    pshs      d         ; preserve destination path and scratch D value
                    leay      >dstlsn0,u ; point Y at destination LSN0 image
                    ldd       <DD.DSK,y ; load destination disk ID
                    std       <DD.DSK,x ; copy destination disk ID into source LSN0 image
                    puls      d         ; restore destination path and scratch D value
                    endif     ;         end optional disk-ID preservation
*
                    ldy       #256      ; request one sector
                    os9       I$Write   ; write source LSN0 to destination
                    lbcs      L03AF     ; abort on destination write error
                    pshs      u         ; save data base during seek setup
                    ldx       #$0000    ; prepare seek MSW as zero
                    leau      ,x        ; prepare seek LSW as zero
                    os9       I$Seek    ; seek destination back to LSN0
                    puls      u         ; restore data base
                    lbcs      L03AF     ; abort on destination seek error
                    leax      >srclsn0,u ; point X at source LSN0 buffer
                    os9       I$Read    ; reread destination LSN0 after write
                    lbcs      L03AF     ; abort if reread failed
copyloop            leay      >rdysrc,pcr ; point to source-ready prompt text
                    lbsr      doprompt  ; optionally show single-drive source prompt
                    lda       <numpages ; load maximum transfer page count
                    sta       <pagcntr  ; reset per-pass page counter
                    leax      >dstlsn0,u ; use destination LSN0 area as transfer buffer start
                    lbsr      L0403     ; read a bufferful from current source position
                    lbsr      L0419     ; optionally show destination-ready prompt
                    ldd       <sctbuf   ; load end pointer reached by read loop
                    leax      >dstlsn0,u ; reload transfer buffer start
                    stx       <sctbuf   ; reset sector-buffer pointer to start for next read phase
                    subd      <sctbuf   ; compute number of bytes read this pass
                    beq       L035C     ; skip write if no bytes were read
                    tfr       d,y       ; pass byte count to I$Write
                    lda       <dstpath  ; load destination path number
* DriveWire Note: backup /x1 /d1 returns error 247 at this I$Write!
                    os9       I$Write   ; write buffered sectors to destination
                    bcs       L03AF     ; abort on destination write error
L035C               lda       <srcerr   ; load saved source read status
                    cmpa      #E$EOF    ; test whether source reached EOF
                    bne       copyloop  ; continue copying until source EOF
                    leay      >sctscpd,pcr ; point to copied-sector count prefix
                    lbsr      L0470     ; print current LSN as copied-sector count
                    tst       <dontvfy  ; test verify-inhibit option
                    bne       exit      ; exit now if verify pass was disabled
* Verification code
                    leay      >vfypass,pcr ; point to verify-pass message
                    lbsr      L0456     ; print verify-pass message
                    lda       <dstpath  ; load destination path number
                    sta       <srcpath  ; reuse read routine with destination as source
                    pshs      u         ; save data base during seek setup
                    ldx       #$0000    ; prepare seek MSW as zero
                    leau      1,x       ; seek to LSN1 for verification
                    os9       I$Seek    ; position destination at first copied sector
                    puls      u         ; restore data base
                    clr       <curlsn   ; reset high byte of verified LSN count
                    clr       <curlsn+1 ; reset middle byte of verified LSN count
                    clr       <curlsn+2 ; reset low byte of verified LSN count
                    clr       <srcerr   ; clear saved read status for verify pass
L0396               lda       <numpages ; load maximum verification page count
                    sta       <pagcntr  ; reset per-pass page counter
                    leax      >dstlsn0,u ; point X at transfer buffer
                    lbsr      L0403     ; read and count destination sectors
                    lda       <srcerr   ; load verify-pass read status
                    cmpa      #E$EOF    ; test whether destination read reached EOF
                    bne       L0396     ; continue verify counting until EOF
                    leay      >sctvfd,pcr ; point to verified-sector count prefix
                    lbsr      L0470     ; print current LSN as verified-sector count
                    bra       exit      ; exit successfully
L03AF               os9       F$PErr    ; print current OS-9 error
                    leay      >bkabort,pcr ; point to backup-aborted message
L03B6               lbsr      L0456     ; display message through output buffer
                    comb                ; return with carry set for nonzero exit status
exit                ldb       #$00      ; use zero status byte unless carry selects error status
                    os9       F$Exit    ; terminate process
L03BF               ldy       #256      ; request one sector
                    lda       <srcpath  ; load active read path number
                    os9       I$Read    ; read next sector into current buffer pointer
                    bcc       L03DC     ; continue when read succeeded
                    stb       <srcerr   ; save read error code
                    cmpb      #E$EOF    ; test for normal end of source/destination
                    beq       L040D     ; stop buffer fill at EOF
                    lbsr      L046C     ; print sector number that failed
                    ldb       <srcerr   ; reload saved read error
                    tst       <errabrt  ; test abort-on-error option
                    bne       L03AF     ; abort immediately if requested
                    os9       F$PErr    ; report nonfatal read error
L03DC               ldd       <curlsn+1 ; load low 16 bits of current LSN
                    addd      #$0001    ; advance sector counter by one
                    std       <curlsn+1 ; save updated low 16 bits
                    bcc       L03E7     ; skip high-byte carry when low word did not wrap
                    inc       <curlsn   ; carry into high byte of 24-bit LSN
L03E7               tst       <srcerr   ; test whether last read had a nonfatal error
                    beq       L03FD     ; skip seek recovery after a good read
                    pshs      u         ; save data base while forming seek offset
                    ldx       <curlsn   ; load high/mid bytes of next LSN into X
                    tfr       b,a       ; move low byte of LSN into seek high byte
                    clrb                ; clear seek low byte
                    tfr       d,u       ; place low word of seek offset in U
                    lda       <srcpath  ; load active read path number
                    os9       I$Seek    ; skip over unreadable sector and continue
                    puls      u         ; restore data base
                    clr       <srcerr   ; clear recovered read-error flag
L03FD               ldx       <sctbuf   ; load current sector buffer pointer
                    leax      >256,x    ; advance pointer by one sector
L0403               stx       <sctbuf   ; save current sector buffer pointer
                    lda       <pagcntr  ; load remaining page count
                    suba      #$01      ; consume one 256-byte page slot
                    sta       <pagcntr  ; save updated remaining page count
                    bcc       L03BF     ; keep reading while page slots remain
L040D               rts                 ; return when buffer is full or EOF was reached

ShowHelp            equ       *         ; help-output entry point
                  IFNE    DOHELP  ; assemble help handler when help text exists
                    leax      <strbuf,u ; point X at output buffer
                    stx       <bufptr   ; reset output buffer pointer
                    leay      >HelpMsg,pcr ; point Y at help message text
                    lbra      L03B6     ; print help and exit with carry set
                  ELSE    ;       assemble tiny handler when help is disabled
                    bra       exit      ; exit without displaying help
                  ENDC    ;       end conditional help handler
L0419               leay      >rdydst,pcr ; point to destination-ready prompt text
doprompt            tst       <pmptsng  ; test whether single-drive prompts are enabled
                    beq       L0439     ; return immediately when prompts are disabled
getkey              bsr       L0456     ; display prompt text currently addressed by Y
                    pshs      y,x,b,a   ; preserve caller registers while reading key
                    leax      ,s        ; use saved A byte on stack as one-byte input buffer
                    ldy       #$0001    ; request one input byte
                    clra                ; read from stdin path 0
                    os9       I$Read    ; read confirmation byte from stdin
                    leay      >L00A0,pcr ; point to CR terminator message
                    bsr       L0456     ; echo newline after key input
                    puls      y,x,b,a   ; restore caller registers with A holding key byte
                    anda      #$7F      ; strip high bit from key byte
L0439               rts                 ; return to caller
* New routine needed as F$PrsNam will stop at the second "/";RG
getnm               pshs      x         ; preserve start of image-file name
                    ldb       #-1       ; initialize byte count before first character
gtnm2               lda       ,x+       ; fetch next image-file name byte
                    incb                ; count copied/accepted byte
                    cmpa      #C$SPAC   ; test for space terminator
                    beq       gtnm3     ; stop at space
                    cmpa      #C$COMA   ; test for comma terminator
                    bne       gtnm2     ; continue until space or comma
gtnm3               puls      x         ; restore pointer to image-file name start
                    bra       L0443     ; copy counted name bytes into prompt buffer
* End of new routine;RG
L043A               pshs      x         ; preserve pointer to path name start
                    os9       F$PrsNam  ; parse OS-9 path name and return length in B
                    puls      x         ; restore pointer to path name start
                    bcs       ShowHelp  ; show help if path parsing failed
L0443               lda       ,x+       ; fetch next path/name byte
                    bsr       L04A5     ; append byte to output buffer
                    decb                ; decrement remaining byte count
                    bpl       L0443     ; copy through final counted byte
                    rts                 ; return after name copy

L044B               lda       ,y        ; fetch next high-bit-terminated string byte
                    anda      #$7F      ; strip high-bit terminator for output
                    bsr       L04A5     ; append character to output buffer
                    lda       ,y+       ; refetch original byte and advance source pointer
                    bpl       L044B     ; continue until high bit marks final byte
L0455               rts                 ; return when string copy is complete
L0456               bsr       L044B     ; append selected string to output buffer
                    pshs      y,x,a     ; preserve caller registers during write
                    ldd       <bufptr   ; load end pointer of buffered output
                    leax      <strbuf,u ; point X at start of output buffer
                    stx       <bufptr   ; reset buffer pointer for next message
                    subd      <bufptr   ; compute buffered byte count
                    tfr       d,y       ; pass byte count in Y
                    lda       #$02      ; write to stderr path 2
                    os9       I$WritLn  ; write buffered message line
                    puls      pc,y,x,a  ; restore registers and return
L046C               leay      >L00F7,pcr ; point to sector-error prefix
L0470               bsr       L044B     ; append message prefix to output buffer
                    lda       <curlsn   ; load high byte of current LSN
                    bsr       L0486     ; print high byte without leading zeroes
                    inc       <u0009    ; force remaining bytes to include zero digits
                    lda       <curlsn+1 ; load middle byte of current LSN
                    bsr       L0488     ; print middle byte as hex
                    lda       <curlsn+2 ; load low byte of current LSN
                    bsr       L0488     ; print low byte as hex
                    leay      >L00B5,pcr ; point to high-bit-terminated trailing space
                    bra       L0456     ; write completed sector/count message
L0486               clr       <u0009    ; suppress leading zero nibbles
L0488               pshs      a         ; save byte while printing high nibble
                    lsra                ; shift high nibble toward low nibble
                    lsra                ; continue high-nibble shift
                    lsra                ; continue high-nibble shift
                    lsra                ; finish high-nibble shift
                    bsr       L0494     ; print high nibble if needed
                    puls      a         ; restore original byte
                    anda      #$0F      ; isolate low nibble
L0494               tsta                ; test nibble value
                    beq       L0499     ; preserve leading-zero suppression for zero nibble
                    sta       <u0009    ; mark that a nonzero hex digit has been seen
L0499               tst       <u0009    ; test whether digit output is enabled
                    beq       L0455     ; return without printing leading zero
                    adda      #$30      ; convert 0..9 nibble to ASCII baseline
                    cmpa      #$39      ; test whether converted digit is decimal
                    bls       L04A5     ; append decimal digit
                    adda      #$07      ; adjust A..F digit into uppercase ASCII
L04A5               pshs      x         ; save X around buffer update
                    ldx       <bufptr   ; load next output-buffer pointer
                    sta       ,x+       ; store character and advance pointer
                    stx       <bufptr   ; save updated output-buffer pointer
                    puls      pc,x      ; restore X and return

                    emod      ;         emit module CRC
eom                 equ       *         ; mark end of module image
                    end       ;         end assembly source
