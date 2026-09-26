* Native K2 supervisor client: status, log, list, program, flash, abort.
* /rp wire records: command,length,payload -> length,payload.
                    ifp1
                    use defsfile
                    endc
                    org 0
Cancelled           rmb 1
FilePath            rmb 1
Target              rmb 1
UploadStarted       rmb 1
NameLength          rmb 1
Progress            rmb 1
FileSize            rmb 4
Count32             rmb 4
CRC                 rmb 4
ExpectedCRC         rmb 4
ChunkSize           rmb 2
LocalName           rmb 128
RemoteName          rmb 128
Path                rmb 1
Action              rmb 1
Context             rmb 1
CurrentCmd          rmb 1
TxLength            rmb 1
RxLength            rmb 1
Nonce               rmb 4
Generation          rmb 4
EntryCount          rmb 2
EntryIndex          rmb 2
LogIndex            rmb 1
LogCount            rmb 1
Clock               rmb 6
DriverInfo          rmb 4
ListSize            rmb 4
DecDigits           rmb 1
Tx                  rmb 242
Rx                  rmb 240
Line                rmb 512
                    rmb 512
MemSize             equ .
                    mod eom,name,Prgrm+Objct,ReEnt+1,Start,MemSize
name                fcs /fpga/
                    fcb 3
Start               lda #$FF
                    sta Path,u
                    sta FilePath,u
                    clr UploadStarted,u
                    clr Cancelled,u
                    clr Action,u
                    clr Context,u
                    lbsr Spaces
                    lda ,x
                    cmpa #C$CR
                    lbeq Parsed
                    leay StatusWord,pcr
                    lbsr Match
                    lbcc Tail
                    leay LogWord,pcr
                    lbsr Match
                    lbcs TryList
                    inc Action,u
                    lbra Tail
TryList             leay ListWord,pcr
                    lbsr Match
                    lbcs TryProgram
                    lda #2
                    sta Action,u
                    lbsr Spaces
                    lda ,x
                    cmpa #'1
                    lblo Tail
                    cmpa #'4
                    lbhi Usage
                    suba #'1
                    sta Context,u
                    leax 1,x
Tail                lbsr Spaces
                    lda ,x
                    cmpa #C$CR
                    lbne Usage
                    lbra Parsed
TryProgram          leay ProgramWord,pcr
                    lbsr Match
                    lbcs TryFlash
                    lda #3
                    lbra ProgramArgs
TryFlash            leay FlashWord,pcr
                    lbsr Match
                    lbcs TryAbort
                    lda #2
                    lbra ProgramArgs
TryAbort            leay AbortWord,pcr
                    lbsr Match
                    lbcs Usage
                    lda #4
                    sta Action,u
                    lbra Tail
ProgramArgs         sta Target,u
                    lda #3
                    sta Action,u
                    lda ,x
                    cmpa #$20
                    lbne Usage
                    lbsr Spaces
                    lda ,x+
                    cmpa #'1
                    lblo Usage
                    cmpa #'4
                    lbhi Usage
                    suba #'1
                    sta Context,u
                    lda ,x
                    cmpa #$20
                    lbne Usage
                    lbsr Spaces
                    leay LocalName,u
                    
                    clr NameLength,u
                    pshs y
PathNext            lda ,x+
                    cmpa #C$CR
                    lbeq PathEnd
                    cmpa #$20
                    lbeq PathTail
                    inc NameLength,u
                    ldb NameLength,u
                    cmpb #127
                    lbhi PathUsage
                    sta ,y+
                    cmpa #'/
                    lbne PathNext
                    sty ,s
                    lbra PathNext
PathTail            lbsr Spaces
                    lda ,x
                    cmpa #C$CR
                    lbne PathUsage
PathEnd             lda #C$CR
                    sta ,y
                    tfr y,d
                    subd ,s
                    cmpd #1
                    lblo PathUsage
                    cmpd #127
                    lbhi PathUsage
                    stb NameLength,u
                    puls x
                    pshs y
                    leay RemoteName,u
                    lbsr CopyBytes
                    clr ,y
                    puls y
* Validate the suffix before opening or changing the selected remote context.
                    lda Target,u
                    cmpa #2
                    lbeq FlashSuffix
                    ldb NameLength,u
                    cmpb #5
                    lblo Usage
                    lda -4,y
                    cmpa #'.
                    lbne Usage
                    lda -3,y
                    ora #$20
                    cmpa #'b
                    lbne Usage
                    lda -2,y
                    ora #$20
                    cmpa #'i
                    lbne Usage
                    lda -1,y
                    ora #$20
                    cmpa #'n
                    lbne Usage
                    lbra Parsed
FlashSuffix         ldb NameLength,u
                    cmpb #4
                    lblo Usage
                    lda -3,y
                    cmpa #'.
                    lbne Usage
                    lda -2,y
                    ora #$20
                    cmpa #'g
                    lbne Usage
                    lda -1,y
                    ora #$20
                    cmpa #'z
                    lbne Usage
                    lbra Parsed
PathUsage           leas 2,s
                    lbra Usage
Parsed              leax Clock,u
                    os9 F$Time
                    lbcs Exit
                    os9 F$ID
                    sta Nonce,u
                    lda Clock+3,u
                    sta Nonce+1,u
                    ldd Clock+4,u
                    std Nonce+2,u
                    leax Device,pcr
                    lda #UPDAT.       RPDrv enforces exclusive ownership
                    os9 I$Open
                    lbcs Exit
                    sta Path,u
                    lda Action,u
                    lbeq Status
                    deca
                    lbeq Log
                    deca
                    lbeq List
                    deca
                    lbeq Program
                    lbra AbortUpload
Usage               leay Line,u
                    leax Help,pcr
                    lbsr Text
                    lbsr Print
                    ldb #E$BMode
                    lbra Exit
Done                clrb
Exit                pshs b
* Abort only our upload and only when the transport has become idle.
* Never retransmit an ambiguous append or enqueue an abort while BUSY.
                    tst UploadStarted,u
                    beq CloseFile
                    lda Path,u
                    ldb #$C0
                    os9 I$GetStt
                    bcs CloseFile
                    tfr x,d
                    bita #8
                    bne CloseFile
                    lda #5
                    clrb
                    lbsr ImageExchange
CloseFile           lda FilePath,u
                    cmpa #$FF
                    beq CloseMailbox
                    os9 I$Close
CloseMailbox
                    lda Path,u
                    cmpa #$FF
                    lbeq NoClose
                    os9 I$Close
NoClose             puls b
                    os9 F$Exit
Spaces              lda ,x
                    cmpa #$20
                    lbne SpaceEnd
                    leax 1,x
                    lbra Spaces
SpaceEnd            rts
Match               pshs x
MatchNext           lda ,y+
                    lbeq Matched
                    cmpa ,x+
                    lbeq MatchNext
                    puls x
                    orcc #1
                    rts
Matched             leas 2,s
                    andcc #$FE
                    rts
Status              leay Line,u
                    leax StatusLabel,pcr
                    lbsr Text
                    pshs y
                    lda Path,u
                    ldb #$C0
                    os9 I$GetStt
                    lbcs StatusFail
                    stx DriverInfo,u
                    sty DriverInfo+2,u
                    puls y
* Status byte: bit 0 online, bit 3 busy, bit 6 reply waiting, bit 7 error latched.
                    leax OnlineTxt,pcr
                    lda DriverInfo,u
                    bita #1
                    bne StatOnline
                    leax OfflineTxt,pcr
StatOnline          lbsr Text
                    leax IdleTxt,pcr
                    lda DriverInfo,u
                    bita #8
                    beq StatBusy
                    leax BusyTxt,pcr
StatBusy            lbsr Text
                    lda DriverInfo,u
                    bita #$40
                    beq StatError
                    leax ReplyTxt,pcr
                    lbsr Text
StatError           lda DriverInfo+1,u
                    beq StatNoError
                    leax ErrorTxt,pcr
                    lbsr Text
                    lda DriverInfo+1,u
                    lbsr Hex
                    lbra StatFirmware
StatNoError         leax NoErrorTxt,pcr
                    lbsr Text
StatFirmware        leax FirmwareTxt,pcr
                    lbsr Text
                    lda DriverInfo+2,u
                    lbsr DecByte
* Remote status byte from the supervisor: bit 0 ready, bits 1 and 3 upload in progress.
                    leax SupervisorTxt,pcr
                    lbsr Text
                    leax ReadyTxt,pcr
                    lda DriverInfo+3,u
                    bita #1
                    bne StatReady
                    leax NotReadyTxt,pcr
StatReady           lbsr Text
                    lda DriverInfo+3,u
                    bita #$0A
                    beq StatPrint1
                    leax UploadTxt,pcr
                    lbsr Text
StatPrint1          lbsr Print
                    lda #$0E
                    ldb #4
                    lbsr Request
                    lbcs Exit
                    lda RxLength,u
                    cmpa #8
                    lblo Invalid
                    lda Rx+7,u
                    adda #8
                    cmpa RxLength,u
                    lbne Invalid
                    leay Line,u
                    leax BootLabel,pcr
                    lbsr Text
                    lda Rx+4,u
                    lbeq NoBoot
                    leax ContextTxt,pcr
                    lbsr Text
                    lda Rx+5,u
                    inca
                    adda #'0
                    sta ,y+
                    leax CommaTxt,pcr
                    lbsr Text
                    lda Rx+6,u
                    lbsr SourceName
                    lbsr Text
                    leax CommaTxt,pcr
                    lbsr Text
                    leax Rx+8,u
                    ldb Rx+7,u
                    lbsr Bytes
                    lbra StatusPrint
NoBoot              leax Unknown,pcr
                    lbsr Text
StatusPrint         lbsr Print
                    lbra Done
StatusFail          leas 2,s
                    lbra Exit
Log                 clr LogIndex,u
LogNext             lda LogIndex,u
                    sta Tx+6,u
                    lda #$10
                    ldb #5
                    lbsr Request
                    lbcs Exit
                    lda RxLength,u
                    cmpa #7
                    lblo Invalid
                    lda Rx+5,u
                    cmpa LogIndex,u
                    lbne Invalid
                    lda Rx+6,u
                    adda #7
                    cmpa RxLength,u
                    lbne Invalid
                    lda Rx+4,u
                    sta LogCount,u
                    lbeq Done
                    cmpa #32
                    lbhi Invalid
                    leay Line,u
                    lda LogIndex,u
                    lbsr Hex
                    lda #' 
                    sta ,y+
                    leax Rx+7,u
                    ldb Rx+6,u
                    lbsr Bytes
                    lbsr Print
                    inc LogIndex,u
                    lda LogIndex,u
                    cmpa LogCount,u
                    lblo LogNext
                    lbra Done
List                lda Context,u
                    sta Tx+6,u
                    lda #8
                    ldb #5
                    lbsr Request
                    lbcs Exit
                    lda RxLength,u
                    cmpa #11
                    lbne Invalid
                    lda Rx+10,u
                    cmpa Context,u
                    lbne Invalid
                    ldd Rx+4,u
                    std Generation,u
                    ldd Rx+6,u
                    std Generation+2,u
                    lda Rx+9,u
                    ldb Rx+8,u
                    std EntryCount,u
                    clra
                    clrb
                    std EntryIndex,u
                    leay Line,u
                    leax ListLabel,pcr
                    lbsr Text
                    lbsr Print
ListNext            ldd EntryIndex,u
                    cmpd EntryCount,u
                    lbhs Done
                    sta Tx+11,u
                    stb Tx+10,u
                    ldd Generation,u
                    std Tx+6,u
                    ldd Generation+2,u
                    std Tx+8,u
                    lda #9
                    ldb #10
                    lbsr Request
                    lbcs Exit
                    lda RxLength,u
                    cmpa #19
                    lblo Invalid
                    lda Rx+18,u
                    adda #19
                    cmpa RxLength,u
                    lbne Invalid
                    ldd Rx+4,u
                    cmpd Generation,u
                    lbne Invalid
                    ldd Rx+6,u
                    cmpd Generation+2,u
                    lbne Invalid
                    lda Rx+9,u
                    ldb Rx+8,u
                    cmpd EntryIndex,u
                    lbne Invalid
                    lda Rx+12,u
                    cmpa Context,u
                    lbne Invalid
                    lbsr CatalogLine
                    ldd EntryIndex,u
                    addd #1
                    std EntryIndex,u
                    lbra ListNext
* Human-readable catalog: source and roles, then path and decimal byte count.
CatalogLine         leay Line,u
                    lda Rx+10,u
                    lbsr SourceName
                    lbsr Text
                    lda Rx+13,u
                    bita #1
                    beq CatBooted
                    leax SavedLabel,pcr
                    lbsr Text
CatBooted           lda Rx+13,u
                    bita #2
                    beq CatHeading
                    leax BootedLabel,pcr
                    lbsr Text
CatHeading          lbsr Print
                    tst Rx+10,u
                    beq CatReturn
                    leay Line,u
                    lda #$20
                    sta ,y+
                    sta ,y+
                    leax Rx+19,u
                    ldb Rx+18,u
                    lbsr Bytes
                    leax SizeOpen,pcr
                    lbsr Text
                    lda Rx+17,u
                    ldb Rx+16,u
                    std ListSize,u
                    lda Rx+15,u
                    ldb Rx+14,u
                    std ListSize+2,u
                    lbsr DecimalSize
                    leax SizeClose,pcr
                    lbsr Text
                    lbsr Print
CatReturn           rts
* Unsigned 32-bit decimal conversion; at most ten stacked digit bytes.
DecimalSize         clr DecDigits,u
DecimalDivide       clra
                    ldb #32
DecimalBit          lsl ListSize+3,u
                    rol ListSize+2,u
                    rol ListSize+1,u
                    rol ListSize,u
                    rola
                    cmpa #10
                    blo DecimalNext
                    suba #10
                    inc ListSize+3,u
DecimalNext         decb
                    bne DecimalBit
                    adda #'0
                    pshs a
                    inc DecDigits,u
                    lda ListSize,u
                    ora ListSize+1,u
                    ora ListSize+2,u
                    ora ListSize+3,u
                    bne DecimalDivide
DecimalEmit         puls a
                    sta ,y+
                    dec DecDigits,u
                    bne DecimalEmit
                    rts
Invalid             ldb #E$Read
                    lbra Exit
* Caller places fields following nonce at Tx+6. A=command, B=payload length.
Request             sta CurrentCmd,u
                    stb TxLength,u
* Drain/flush barrier: complete empty PING before every nonce-bearing request.
                    lda #1
                    sta Tx,u
                    clr Tx+1,u
                    lbsr Exchange
                    lbcs RequestEnd
                    leax Nonce+4,u
                    ldb #4
NonceNext           inc ,-x
                    lbne NonceDone
                    decb
                    lbne NonceNext
NonceDone           ldd Nonce,u
                    std Tx+2,u
                    ldd Nonce+2,u
                    std Tx+4,u
                    lda CurrentCmd,u
                    ldb TxLength,u
                    std Tx,u
                    lbsr Exchange
                    lbcs RequestEnd
                    lda RxLength,u
                    cmpa #4
                    lblo RequestBad
                    ldd Rx,u
                    cmpd Nonce,u
                    lbne RequestBad
                    ldd Rx+2,u
                    cmpd Nonce+2,u
                    lbne RequestBad
                    clrb
RequestEnd          rts
RequestBad          comb
                    ldb #E$Read
                    rts
Exchange            leax Tx,u
                    clra
                    ldb Tx+1,u
                    addd #2
                    tfr d,y
                    lda Path,u
                    os9 I$Write
                    lbcs RequestEnd
                    leax RxLength,u
                    ldy #1
                    lda Path,u
                    os9 I$Read
                    lbcs RequestEnd
                    clra
                    ldb RxLength,u
                    cmpb #240
                    lbhi RequestBad
                    lbeq ReadPayload
                    tstb
                    lbeq ExchangeEmpty
ReadPayload         tfr d,y
                    leax Rx,u
                    lda Path,u
                    os9 I$Read
                    lbcs RequestEnd
                    tfr y,d
                    cmpb RxLength,u
                    lbne RequestBad
                    clrb
                    rts
ExchangeEmpty       clrb
                    rts
Text                lda ,x+
                    lbeq TextEnd
                    sta ,y+
                    lbra Text
TextEnd             rts
Bytes               tstb
                    lbeq TextEnd
ByteNext            lda ,x+
                    cmpa #$20
                    lblo Dot
                    cmpa #$7F
                    lblo PutByte
Dot                 lda #'.
PutByte             sta ,y+
                    decb
                    lbne ByteNext
                    rts
* SourceName: A = supervisor boot-source code -> X = its label.
SourceName          leax AutoLabel,pcr
                    tsta
                    beq SourceDone
                    leax SDLabel,pcr
                    cmpa #1
                    beq SourceDone
                    leax FlashLabel,pcr
                    cmpa #2
                    beq SourceDone
                    leax GoldenLabel,pcr
                    cmpa #3
                    beq SourceDone
                    leax UnknownSource,pcr
SourceDone          rts
* DecByte: A = 0..255 -> decimal digits at Y, no leading zeros. Uses DecDigits as the emitted-digit flag.
DecByte             clr DecDigits,u
                    ldb #100
                    lbsr DecDigit
                    ldb #10
                    lbsr DecDigit
                    adda #'0
                    sta ,y+
                    rts
DecDigit            pshs b
                    ldb #'0-1
DecLoop             incb
                    suba ,s
                    bcc DecLoop
                    adda ,s
                    cmpb #'0
                    bne DecEmit
                    tst DecDigits,u
                    beq DecSkip
DecEmit             stb ,y+
                    inc DecDigits,u
DecSkip             puls b,pc
Hex                 pshs a
                    lsra
                    lsra
                    lsra
                    lsra
                    lbsr Nibble
                    puls a
                    anda #15
Nibble              adda #'0
                    cmpa #'9
                    lbls Digit
                    adda #7
Digit               sta ,y+
                    rts
Print               lda #C$CR
                    sta ,y+
                    leax Line,u
                    pshs x
                    tfr y,d
                    subd ,s++
                    tfr d,y
                    lda #1
                    os9 I$WritLn
                    lbcs Exit
                    rts
* Shared checked image upload. Target/context/name set by the command parser.
* Size, Count32 and CRC are native big-endian; mailbox fields are little-endian.
Program             leax ProgramSignal,pcr
                    os9 F$Icpt
                    lbcs Exit
                    lda #READ.
                    leax LocalName,u
                    os9 I$Open
                    lbcs Exit
                    sta FilePath,u
                    ldb #SS.Size
                    pshs u
                    os9 I$GetStt
                    tfr u,y
                    puls u
                    lbcs Exit
                    stx FileSize,u
                    sty FileSize+2,u
                    lda Target,u
                    cmpa #2
                    lbeq CheckGzipSize
                    cmpx #$0094
                    lbne BadImage
                    cmpy #$7A5C
                    lbne BadImage
                    lbra SizeOK
CheckGzipSize       cmpx #$0020
                    lbhi BadImage
                    lbne GzipMin
                    cmpy #0
                    lbne BadImage
GzipMin             cmpx #0
                    lbne SizeOK
                    cmpy #18
                    lblo BadImage
SizeOK              leay Line,u
                    leax Checking,pcr
                    lbsr Text
                    lbsr Print
                    lbsr ResetScan
* First pass computes CRC before any remote change. Reject changed/short files.
ScanNext            lbsr ReadChunk
                    lbcs Exit
                    ldy ChunkSize,u
                    lbeq ScanDone
                    lbsr AddCount
                    lbsr CheckWithin
                    lbcs Exit
                    leax Tx+2,u
                    lbsr CRCChunk
                    lbra ScanNext
ScanDone            lbsr ExactSize
                    lbcs Exit
                    com CRC,u
                    com CRC+1,u
                    com CRC+2,u
                    com CRC+3,u
                    ldd CRC,u
                    std ExpectedCRC,u
                    ldd CRC+2,u
                    std ExpectedCRC+2,u
                    lda Target,u
                    cmpa #2
                    lbne RewindImage
* Check gzip header and trailer size before erasing a flash slot.
                    lbsr SeekStart
                    lbcs Exit
                    lbsr ReadChunk
                    lbcs Exit
                    ldd Tx+2,u
                    cmpd #$1F8B
                    lbne BadImage
                    lda Tx+4,u
                    cmpa #8
                    lbne BadImage
                    lda Tx+5,u
                    bita #$E0
                    lbne BadImage
                    ldd FileSize+2,u
                    subd #4
                    pshs d
                    ldd FileSize,u
                    sbcb #0
                    sbca #0
                    tfr d,x
                    puls y
* I$Seek consumes X:U; restore the process data base afterwards.
                    lda FilePath,u
                    pshs u
                    tfr y,u
                    os9 I$Seek
                    puls u
                    lbcs Exit
                    leax Tx+2,u
                    ldy #4
                    lda FilePath,u
                    os9 I$Read
                    lbcs Exit
                    cmpy #4
                    lbne BadImage
                    ldd Tx+2,u
                    cmpd #$5C7A
                    lbne BadImage
                    ldd Tx+4,u
                    cmpd #$9400
                    lbne BadImage
RewindImage         lbsr SeekStart
                    lbcs Exit
                    lbsr ResetScan
* Complete a PING barrier before the untagged upload protocol.
                    lda #1
                    clrb
                    lbsr ImageExchange
                    lbcs Exit
                    lbsr CheckCancel
                    lbcs Exit
                    lda Target,u
                    sta Tx+2,u
                    lda Context,u
                    sta Tx+3,u
                    leax FileSize,u
                    leay Tx+4,u
                    lbsr PutLE32
                    leax ExpectedCRC,u
                    leay Tx+8,u
                    lbsr PutLE32
                    ldb NameLength,u
                    stb Tx+12,u
                    leax RemoteName,u
                    leay Tx+13,u
                    lbsr CopyBytes
                    lda #2
                    ldb NameLength,u
                    addb #11
                    lbsr ImageExchange
                    lbcs Exit
                    inc UploadStarted,u
                    tst RxLength,u
                    lbne BadReply
                    leay Line,u
                    leax Sending,pcr
                    lbsr Text
                    lbsr Print
SendNext            lbsr ReadChunk
                    lbcs Exit
                    ldy ChunkSize,u
                    lbeq SendDone
                    lbsr AddCount
                    lbsr CheckWithin
                    lbcs Exit
                    leax Tx+2,u
                    lbsr CRCChunk
                    lda #3
                    ldb ChunkSize+1,u
                    lbsr ImageExchange
                    lbcs Exit
                    lbsr CheckAccepted
                    lbcs Exit
                    inc Progress,u
                    lbne SendNext
* Print progress every 256 chunks (60 KiB), not once per SPI transaction.
                    leay Line,u
                    leax Count32,u
                    ldb #4
ProgressHex         lda ,x+
                    pshs b
                    lbsr Hex
                    puls b
                    decb
                    lbne ProgressHex
                    leax Accepted,pcr
                    lbsr Text
                    lbsr Print
                    lbra SendNext
SendDone            lbsr ExactSize
                    lbcs Exit
                    lbsr CheckCancel
                    lbcs Exit
                    com CRC,u
                    com CRC+1,u
                    com CRC+2,u
                    com CRC+3,u
                    ldd CRC,u
                    cmpd ExpectedCRC,u
                    lbne ChangedImage
                    ldd CRC+2,u
                    cmpd ExpectedCRC+2,u
                    lbne ChangedImage
                    lda #4
                    clrb
                    lbsr ImageExchange
                    lbcs Exit
                    lbsr CheckAccepted
                    lbcs Exit
                    lda Path,u
                    ldb #$C0
                    os9 I$GetStt
                    lbcs Exit
                    tfr x,d
                    bita #$88
                    lbne BadReply
                    tfr y,d
                    bitb #$0A
                    lbne BadReply
                    clr UploadStarted,u
                    leay Line,u
                    leax Programmed,pcr
                    lbsr Text
                    lbsr Print
                    lbra Done
AbortUpload         lda #5
                    clrb
                    lbsr ImageExchange
                    lbcs Exit
                    leay Line,u
                    leax Aborted,pcr
                    lbsr Text
                    lbsr Print
                    lbra Done
BadImage            leay Line,u
                    leax ImageError,pcr
                    lbsr Text
                    lbsr Print
                    ldb #E$BMode
                    lbra Exit
ChangedImage        leay Line,u
                    leax Changed,pcr
                    lbsr Text
                    lbsr Print
BadReply            ldb #E$Read
                    lbra Exit
ImageExchange       std Tx,u
                    lbra Exchange
SeekStart           lda FilePath,u
                    pshs u
                    ldx #0
                    ldu #0
                    os9 I$Seek
                    puls u,pc
ResetScan           clra
                    clrb
                    std Count32,u
                    std Count32+2,u
                    clr Progress,u
                    ldd #$FFFF
                    std CRC,u
                    std CRC+2,u
                    rts
ReadChunk           lbsr CheckCancel
                    bcs ChunkError
                    leax Tx+2,u
                    ldy #240
                    lda FilePath,u
                    os9 I$Read
                    bcc ChunkOK
                    cmpb #E$EOF
                    beq ChunkEOF
                    orcc #1
                    rts
ChunkEOF
                    ldy #0
ChunkOK             sty ChunkSize,u
                    clrb
ChunkError          rts
CheckCancel         ldb Cancelled,u
                    beq CancelOK
                    orcc #1
                    rts
CancelOK            clrb
                    rts
ProgramSignal       cmpb #1
                    bls SignalReturn
                    stb <Cancelled
SignalReturn        rti
AddCount            ldd Count32+2,u
                    addd ChunkSize,u
                    std Count32+2,u
                    ldd Count32,u
                    adcb #0
                    adca #0
                    std Count32,u
                    rts
CheckWithin         ldd Count32,u
                    cmpd FileSize,u
                    bhi CountError
                    blo CountOK
                    ldd Count32+2,u
                    cmpd FileSize+2,u
                    bhi CountError
CountOK             clrb
                    rts
ExactSize           ldd Count32,u
                    cmpd FileSize,u
                    bne CountError
                    ldd Count32+2,u
                    cmpd FileSize+2,u
                    bne CountError
                    clrb
                    rts
CountError          comb
                    ldb #E$Read
                    rts
CheckAccepted       lda RxLength,u
                    cmpa #4
                    bne CountError
                    lda Rx+3,u
                    ldb Rx+2,u
                    cmpd Count32,u
                    bne CountError
                    lda Rx+1,u
                    ldb Rx,u
                    cmpd Count32+2,u
                    bne CountError
                    clrb
                    rts
PutLE32             lda 3,x
                    sta ,y+
                    lda 2,x
                    sta ,y+
                    lda 1,x
                    sta ,y+
                    lda ,x
                    sta ,y+
                    rts
CopyBytes           tstb
                    beq CopyDone
CopyByte            lda ,x+
                    sta ,y+
                    decb
                    bne CopyByte
CopyDone            rts
* Standard reflected CRC32, four byte planes avoid multiplying index by four.
CRCChunk            pshs x,y
CRCNext             lda ,x+
                    eora CRC+3,u
                    pshs x,y
                    leax CRCTable,pcr
                    tfr a,b
                    clra
                    leax d,x
                    lda CRC+2,u
                    eora 768,x
                    sta CRC+3,u
                    lda CRC+1,u
                    eora 512,x
                    sta CRC+2,u
                    lda CRC,u
                    eora 256,x
                    sta CRC+1,u
                    lda ,x
                    sta CRC,u
                    puls x,y
                    leay -1,y
                    bne CRCNext
                    puls x,y,pc
Checking            fcc /Checking image size and CRC32.../
                    fcb 0
Sending             fcc /Programming selected context; bytes accepted shown in hex:/
                    fcb 0
Accepted            fcc / bytes/
                    fcb 0
Programmed          fcc /Image stored; size and CRC verified. Selection and running core unchanged./
                    fcb 0
ImageError          fcc /Invalid image: SD needs a 9730652-byte .bin; flash needs .gz <=2 MiB./
                    fcb 0
Changed             fcc /Image changed or truncated during transfer; not committed./
                    fcb 0
Aborted             fcc /Supervisor upload aborted./
                    fcb 0

Device              fcc "/rp"
                    fcb C$CR
StatusWord          fcc /status/
                    fcb 0
LogWord             fcc /log/
                    fcb 0
ListWord            fcc /list/
                    fcb 0
ProgramWord         fcc /program/
                    fcb 0
FlashWord           fcc /flash/
                    fcb 0
AbortWord           fcc /abort/
                    fcb 0
Help                fcc /Usage: fpga status|log|list [1..4]|program N file.bin|flash N file.gz|abort/
                    fcb 0
StatusLabel         fcc /Mailbox: /
                    fcb 0
OnlineTxt           fcc /online/
                    fcb 0
OfflineTxt          fcc /offline/
                    fcb 0
IdleTxt             fcc /, idle/
                    fcb 0
BusyTxt             fcc /, busy/
                    fcb 0
ReplyTxt            fcc /, reply waiting/
                    fcb 0
NoErrorTxt          fcc /, no error/
                    fcb 0
ErrorTxt            fcc /, error $/
                    fcb 0
FirmwareTxt         fcc /, firmware /
                    fcb 0
SupervisorTxt       fcc /, supervisor /
                    fcb 0
ReadyTxt            fcc /ready/
                    fcb 0
NotReadyTxt         fcc /not ready/
                    fcb 0
UploadTxt           fcc /, upload in progress/
                    fcb 0
BootLabel           fcc /Booted from: /
                    fcb 0
ContextTxt          fcc /context /
                    fcb 0
CommaTxt            fcc /, /
                    fcb 0
Unknown             fcc /not recorded/
                    fcb 0
AutoLabel           fcc /Automatic (SD, then flash)/
                    fcb 0
SDLabel             fcc /SD card/
                    fcb 0
FlashLabel          fcc /Internal flash/
                    fcb 0
GoldenLabel         fcc /GOLDEN recovery/
                    fcb 0
UnknownSource       fcc /Unknown source/
                    fcb 0
SavedLabel          fcc / [saved boot setting]/
                    fcb 0
BootedLabel         fcc / [last booted by RP2040]/
                    fcb 0
SizeOpen            fcc / (/
                    fcb 0
SizeClose           fcc / bytes)/
                    fcb 0
ListLabel           fcc /Images on RP2040 storage:/
                    fcb 0
CRCTable
                    fcb $00,$77,$EE,$99,$07,$70,$E9,$9E,$0E,$79,$E0,$97,$09,$7E,$E7,$90
                    fcb $1D,$6A,$F3,$84,$1A,$6D,$F4,$83,$13,$64,$FD,$8A,$14,$63,$FA,$8D
                    fcb $3B,$4C,$D5,$A2,$3C,$4B,$D2,$A5,$35,$42,$DB,$AC,$32,$45,$DC,$AB
                    fcb $26,$51,$C8,$BF,$21,$56,$CF,$B8,$28,$5F,$C6,$B1,$2F,$58,$C1,$B6
                    fcb $76,$01,$98,$EF,$71,$06,$9F,$E8,$78,$0F,$96,$E1,$7F,$08,$91,$E6
                    fcb $6B,$1C,$85,$F2,$6C,$1B,$82,$F5,$65,$12,$8B,$FC,$62,$15,$8C,$FB
                    fcb $4D,$3A,$A3,$D4,$4A,$3D,$A4,$D3,$43,$34,$AD,$DA,$44,$33,$AA,$DD
                    fcb $50,$27,$BE,$C9,$57,$20,$B9,$CE,$5E,$29,$B0,$C7,$59,$2E,$B7,$C0
                    fcb $ED,$9A,$03,$74,$EA,$9D,$04,$73,$E3,$94,$0D,$7A,$E4,$93,$0A,$7D
                    fcb $F0,$87,$1E,$69,$F7,$80,$19,$6E,$FE,$89,$10,$67,$F9,$8E,$17,$60
                    fcb $D6,$A1,$38,$4F,$D1,$A6,$3F,$48,$D8,$AF,$36,$41,$DF,$A8,$31,$46
                    fcb $CB,$BC,$25,$52,$CC,$BB,$22,$55,$C5,$B2,$2B,$5C,$C2,$B5,$2C,$5B
                    fcb $9B,$EC,$75,$02,$9C,$EB,$72,$05,$95,$E2,$7B,$0C,$92,$E5,$7C,$0B
                    fcb $86,$F1,$68,$1F,$81,$F6,$6F,$18,$88,$FF,$66,$11,$8F,$F8,$61,$16
                    fcb $A0,$D7,$4E,$39,$A7,$D0,$49,$3E,$AE,$D9,$40,$37,$A9,$DE,$47,$30
                    fcb $BD,$CA,$53,$24,$BA,$CD,$54,$23,$B3,$C4,$5D,$2A,$B4,$C3,$5A,$2D
                    fcb $00,$07,$0E,$09,$6D,$6A,$63,$64,$DB,$DC,$D5,$D2,$B6,$B1,$B8,$BF
                    fcb $B7,$B0,$B9,$BE,$DA,$DD,$D4,$D3,$6C,$6B,$62,$65,$01,$06,$0F,$08
                    fcb $6E,$69,$60,$67,$03,$04,$0D,$0A,$B5,$B2,$BB,$BC,$D8,$DF,$D6,$D1
                    fcb $D9,$DE,$D7,$D0,$B4,$B3,$BA,$BD,$02,$05,$0C,$0B,$6F,$68,$61,$66
                    fcb $DC,$DB,$D2,$D5,$B1,$B6,$BF,$B8,$07,$00,$09,$0E,$6A,$6D,$64,$63
                    fcb $6B,$6C,$65,$62,$06,$01,$08,$0F,$B0,$B7,$BE,$B9,$DD,$DA,$D3,$D4
                    fcb $B2,$B5,$BC,$BB,$DF,$D8,$D1,$D6,$69,$6E,$67,$60,$04,$03,$0A,$0D
                    fcb $05,$02,$0B,$0C,$68,$6F,$66,$61,$DE,$D9,$D0,$D7,$B3,$B4,$BD,$BA
                    fcb $B8,$BF,$B6,$B1,$D5,$D2,$DB,$DC,$63,$64,$6D,$6A,$0E,$09,$00,$07
                    fcb $0F,$08,$01,$06,$62,$65,$6C,$6B,$D4,$D3,$DA,$DD,$B9,$BE,$B7,$B0
                    fcb $D6,$D1,$D8,$DF,$BB,$BC,$B5,$B2,$0D,$0A,$03,$04,$60,$67,$6E,$69
                    fcb $61,$66,$6F,$68,$0C,$0B,$02,$05,$BA,$BD,$B4,$B3,$D7,$D0,$D9,$DE
                    fcb $64,$63,$6A,$6D,$09,$0E,$07,$00,$BF,$B8,$B1,$B6,$D2,$D5,$DC,$DB
                    fcb $D3,$D4,$DD,$DA,$BE,$B9,$B0,$B7,$08,$0F,$06,$01,$65,$62,$6B,$6C
                    fcb $0A,$0D,$04,$03,$67,$60,$69,$6E,$D1,$D6,$DF,$D8,$BC,$BB,$B2,$B5
                    fcb $BD,$BA,$B3,$B4,$D0,$D7,$DE,$D9,$66,$61,$68,$6F,$0B,$0C,$05,$02
                    fcb $00,$30,$61,$51,$C4,$F4,$A5,$95,$88,$B8,$E9,$D9,$4C,$7C,$2D,$1D
                    fcb $10,$20,$71,$41,$D4,$E4,$B5,$85,$98,$A8,$F9,$C9,$5C,$6C,$3D,$0D
                    fcb $20,$10,$41,$71,$E4,$D4,$85,$B5,$A8,$98,$C9,$F9,$6C,$5C,$0D,$3D
                    fcb $30,$00,$51,$61,$F4,$C4,$95,$A5,$B8,$88,$D9,$E9,$7C,$4C,$1D,$2D
                    fcb $41,$71,$20,$10,$85,$B5,$E4,$D4,$C9,$F9,$A8,$98,$0D,$3D,$6C,$5C
                    fcb $51,$61,$30,$00,$95,$A5,$F4,$C4,$D9,$E9,$B8,$88,$1D,$2D,$7C,$4C
                    fcb $61,$51,$00,$30,$A5,$95,$C4,$F4,$E9,$D9,$88,$B8,$2D,$1D,$4C,$7C
                    fcb $71,$41,$10,$20,$B5,$85,$D4,$E4,$F9,$C9,$98,$A8,$3D,$0D,$5C,$6C
                    fcb $83,$B3,$E2,$D2,$47,$77,$26,$16,$0B,$3B,$6A,$5A,$CF,$FF,$AE,$9E
                    fcb $93,$A3,$F2,$C2,$57,$67,$36,$06,$1B,$2B,$7A,$4A,$DF,$EF,$BE,$8E
                    fcb $A3,$93,$C2,$F2,$67,$57,$06,$36,$2B,$1B,$4A,$7A,$EF,$DF,$8E,$BE
                    fcb $B3,$83,$D2,$E2,$77,$47,$16,$26,$3B,$0B,$5A,$6A,$FF,$CF,$9E,$AE
                    fcb $C2,$F2,$A3,$93,$06,$36,$67,$57,$4A,$7A,$2B,$1B,$8E,$BE,$EF,$DF
                    fcb $D2,$E2,$B3,$83,$16,$26,$77,$47,$5A,$6A,$3B,$0B,$9E,$AE,$FF,$CF
                    fcb $E2,$D2,$83,$B3,$26,$16,$47,$77,$6A,$5A,$0B,$3B,$AE,$9E,$CF,$FF
                    fcb $F2,$C2,$93,$A3,$36,$06,$57,$67,$7A,$4A,$1B,$2B,$BE,$8E,$DF,$EF
                    fcb $00,$96,$2C,$BA,$19,$8F,$35,$A3,$32,$A4,$1E,$88,$2B,$BD,$07,$91
                    fcb $64,$F2,$48,$DE,$7D,$EB,$51,$C7,$56,$C0,$7A,$EC,$4F,$D9,$63,$F5
                    fcb $C8,$5E,$E4,$72,$D1,$47,$FD,$6B,$FA,$6C,$D6,$40,$E3,$75,$CF,$59
                    fcb $AC,$3A,$80,$16,$B5,$23,$99,$0F,$9E,$08,$B2,$24,$87,$11,$AB,$3D
                    fcb $90,$06,$BC,$2A,$89,$1F,$A5,$33,$A2,$34,$8E,$18,$BB,$2D,$97,$01
                    fcb $F4,$62,$D8,$4E,$ED,$7B,$C1,$57,$C6,$50,$EA,$7C,$DF,$49,$F3,$65
                    fcb $58,$CE,$74,$E2,$41,$D7,$6D,$FB,$6A,$FC,$46,$D0,$73,$E5,$5F,$C9
                    fcb $3C,$AA,$10,$86,$25,$B3,$09,$9F,$0E,$98,$22,$B4,$17,$81,$3B,$AD
                    fcb $20,$B6,$0C,$9A,$39,$AF,$15,$83,$12,$84,$3E,$A8,$0B,$9D,$27,$B1
                    fcb $44,$D2,$68,$FE,$5D,$CB,$71,$E7,$76,$E0,$5A,$CC,$6F,$F9,$43,$D5
                    fcb $E8,$7E,$C4,$52,$F1,$67,$DD,$4B,$DA,$4C,$F6,$60,$C3,$55,$EF,$79
                    fcb $8C,$1A,$A0,$36,$95,$03,$B9,$2F,$BE,$28,$92,$04,$A7,$31,$8B,$1D
                    fcb $B0,$26,$9C,$0A,$A9,$3F,$85,$13,$82,$14,$AE,$38,$9B,$0D,$B7,$21
                    fcb $D4,$42,$F8,$6E,$CD,$5B,$E1,$77,$E6,$70,$CA,$5C,$FF,$69,$D3,$45
                    fcb $78,$EE,$54,$C2,$61,$F7,$4D,$DB,$4A,$DC,$66,$F0,$53,$C5,$7F,$E9
                    fcb $1C,$8A,$30,$A6,$05,$93,$29,$BF,$2E,$B8,$02,$94,$37,$A1,$1B,$8D
                    emod
eom                 equ *
                    end
