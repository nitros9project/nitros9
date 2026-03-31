********************************************************************
* 
* 
* 
* 
* 
* 2025/12/08 ntptime by Matt Massie
* 
* Set time with WizFi360
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------


                    nam       ntptime
                    ttl       WizFi360 NTP time sync


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

PathNum             rmb       1           Path number storage
BytesCnt            rmb       2           Bytes read count
param               rmb       2
StrColon            rmb       1           Find colon in date string
TZFound             rmb       1
Length              rmb       1
timeout             rmb       1           timeout
silent              rmb       1           silent mode
d.time1             rmb       6
d.time2             rmb       6
TimeBuf             rmb       6           F$STIME buffer
CmdBuf              rmb      52
Buffer              rmb     256           Response buffer
                    rmb     250           stack space
size                equ       .

name                fcs       /ntptime/
                    fcb       edition

Start               clr      <TZFound
                    clr      <Length
                    clr      <silent
                    pshs     x            push options
                    lda      #32          space
                    leax     CmdBuf,u     clear command buffer
                    ldb      #52          52 byte buffer
clrloop             sta      ,x+
                    decb
                    bne      clrloop
                    puls     x            restore options
                    lbsr     parseopts
                    lda      <silent
                    bne      gettzfile
                    lbsr     DoBanner
gettzfile           lbsr     ReadTZFile
                    ldb      #3           3 seconds timeout
                    stb      <timeout
                    leax     DevName,pcr  Point to device name
                    lda      #UPDAT.      Update mode
                    os9      I$Open       Open /wz device
                    lbcs     Error        Branch if error
                    sta      <PathNum     Save path number
 
* Send AT command
                    lda      <TZFound
                    beq      cont@
                    leax     CmdBuf,u
                    ldy      #49
                    ldd      <Length
                    leay     d,y
                    bra      cont2@
cont@               leax     ATCmd,pcr    Point to AT command string
                    ldy      #ATCmdLen    Length of command
cont2@              lda      <PathNum     Get path number
                    os9      I$Write      Write AT command
                    lbcs     CloseErr     Branch if error
                    stx      <param      save new address of parameter area
                    leax     d.time1,u
                    os9      F$Time
l@                  lda      <PathNum    get the current path number
                    ldb      #SS.Ready
                    os9      I$GetStt
                    bcc      readwiz
                    ldb      <timeout
                    beq      l@          no, loop until data is available
                    leax     d.time2,u   use timeout for response
                    os9      F$Time
                    ldb      5,x
                    leax     d.time1,u
                    subb     5,x
                    bpl      a@
                    negb
a@                  cmpb     <timeout
                    lbhs     Error       read.ex
                    bra      l@
* Read response (read up to 256 bytes)
readwiz             lda      <PathNum     Get path number
                    leax     Buffer,u     Point to read buffer
                    ldy      #255         Max bytes to read
                    os9      I$Read       Read response
                    lbcs     CloseErr    Branch if error
                    sty      <BytesCnt    Save actual bytes read

* Display the response
                    lda      <silent      check for silent
                    bne      checkout2
                    lda      #1 STDOUT    path
                    leax     Buffer,u     Point to buffer
                    ldy      <BytesCnt    Bytes to write
                    os9      I$Write      Write to stdout
                    lbcs     CloseErr

* did we receive and OK?
checkout2           leax     Buffer,u
                    ldd      <BytesCnt
                    leax     d,x
                    leax     -4,x          end of buffer -3 look for OK
                    lda      ,x+
                    cmpa     #$0A          check for line feed
                    bne      readwiz
                    lda      ,x+
                    cmpa     #$4F          O?
                    bne      readwiz
                    lda      ,x+
                    cmpa     #$4B          K?
                    bne      readwiz

* Sleep so NTP can get current time
                    ldx      #$100         2 ticks = 2 seconds (assumming 60Hz)
                    os9      F$Sleep
                    lbcs     CloseErr

* try to get the time
                    lda      <PathNum      Get path number
                    leax     ATCmd2,pcr    Point to AT command string
                    ldy      #ATCmd2Len    Length of command
                    os9      I$Write       Write AT command
                    lbcs     CloseErr      Branch if error
                    stx      <param        save new address of parameter area
                    leax     d.time1,u
                    os9      F$Time
l2@                 lda      <PathNum      get the current path number
                    ldb      #SS.Ready
                    os9      I$GetStt
                    bcc      readwiz2
                    ldb      <timeout
                    beq      l2@           no, loop until data is available
                    leax     d.time2,u     use timeout for response
                    os9      F$Time
                    ldb      5,x
                    leax     d.time1,u
                    subb     5,x
                    bpl      a2@
                    negb
a2@                 cmpb     <timeout
                    lbhs     Error         read.ex
                    bra      l2@

* Read response (read up to 256 bytes)
readwiz2            lda      <PathNum      Get path number
                    leax     Buffer,u      Point to read buffer
                    ldy      #255          Max bytes to read
                    os9      I$Read        Read response
                    lbcs     CloseErr      Branch if error
                    sty      <BytesCnt     Save actual bytes read

* Display the response
                    lda      <silent
                    bne      CheckStr
                    lda      #1 STDOUT     path
                    leax     Buffer,u      Point to buffer
                    ldy      <BytesCnt     Bytes to write
                    os9      I$Write       Write to stdout
                    lbcs     CloseErr

* check date string
CheckStr            clra
                    sta      <StrColon
                    ldb      #-1
                    leax     Buffer,u
                    ldy      <BytesCnt
strloop             incb
                    lda      ,x+
                    cmpa     #$3A          is it colon?
                    beq      StoreStart
                    leay     -1,y
                    bne      strloop
                    bra      CheckOut

StoreStart          cmpb     #$0D          : should be of location $0D
                    bne      CheckOut      sanity check
                    leax     Buffer,u
                    leay     TimeBuf,u
                    leax     $24,x         get year
                    lbsr     AsciiInt2
                    leax     Buffer,u
                    leax     $12,x         get month
                    lbsr     month
                    leax     Buffer,u
                    leax     $16,x         get day of month
                    lda      ,x
                    bsr      AsciiInt
                    leax     Buffer,u
                    leax     $19,x         get hour
                    bsr      AsciiInt
                    leax     Buffer,u
                    leax     $1C,x         get minutes
                    bsr      AsciiInt
                    leax     Buffer,u
                    leax     $1F,x         get seconds
                    bsr      AsciiInt

* did we receive and OK?
CheckOut            leax     Buffer,u
                    ldd      <BytesCnt
                    leax     d,x
                    leax     -4,x          end of buffer -3 look for OK
                    lda      ,x+
                    cmpa     #$0A          check for line feed
                    lbne     readwiz2
                    lda      ,x+
                    cmpa     #$4F      O?
                    lbne      readwiz2
                    lda      ,x+
                    cmpa     #$4B      K?
                    lbne      readwiz2
                    
* Close the device
CloseDev            lda      <PathNum      Get path number
                    os9      I$Close       Close device
                    bcs      Error         Branch if error
                    leax     TimeBuf,u
                    os9      F$STime       set time
done                clrb     Clear         error code
                    os9      F$Exit        Exit program

* Error handlers
CloseErr            pshs     b             Save error code
                    lda      <PathNum
                    os9      I$Close       Try to close
                    puls     b             Restore error code
 
Error               lda      #1            stdout
                    leax     ErrorMsg,pcr
                    ldy      #ErrorLen
                    os9      I$Write
                    clrb
                    os9      F$Exit        Exit with error

* Concert 2 Byte Ascii to 1 byte Integer - Year, Day, Time Values
* X set to first of 2 Ascii values in buffer desired in Integer
* Y 
AsciiInt            lda       ,x+          get first value
                    suba      #'0'         convert to int
                    ldb       #10
                    mul                    multiply by 10 MSN
                    addb      ,x+
                    subb      #'0'         convert to int
                    tfr       b,a
                    sta       ,y+
                    rts

* Century needs to add 100 to 2 digit year to properly set.
AsciiInt2           lda       ,x+          get first value
                    suba      #'0'         convert to int
                    ldb       #10
                    mul                    multiply by 10 MSN
                    addb      ,x+
                    subb      #'0'         convert to int
                    addb      #100         add 100 so century gets set to 20 instead of 19
                    tfr       b,a
                    sta       ,y+
                    rts

* convert Ascii month to integer  
* Entry: X points to first character of month name in buffer
* Exit: Month value stored at ,Y+
month               pshs      x,y,u        Save registers
                    ldb       #1           Start with month 1
                    leau      MonthTable,pcr
*                    
monthloop           cmpb      #13          Check if we've tried all 12 months
                    beq       nomatch@
*                    
                    lda       ,x           Get 1st char from buffer
                    cmpa      ,u           Compare with table
                    bne       nextmonth@   No match, try next
*                    
                    lda       1,x          Get 2nd char from buffer
                    cmpa      1,u          Compare with table
                    bne       nextmonth@   No match
*                    
                    lda       2,x          Get 3rd char from buffer  
                    cmpa      2,u          Compare with table
                    bne       nextmonth@   No match
* Found match - B contains the month number
                    puls      x,y,u        Restore pointers
                    stb       ,y+          Store month in TimeBuf
                    rts                    
nextmonth@          leau      3,u          Skip 3 chars to next month entry
                    incb                   Increment month counter
                    bra       monthloop                    
* No match found - default to January
nomatch@            puls      x,y,u
                    lda       #1
                    sta       ,y+
                    rts

DoSilent            lda       #1            set silent mode
                    sta       <silent
                    rts

parseopts
* Check if parameters exist
                    lda       ,x
                    cmpa      #$0D
                    beq       NoParams
                    cmpa      #'-'
                    bne       next@
                    ldb       1,x
                    cmpb      #'h'
                    lbeq      DoHelp
                    cmpb      #'H'
                    lbeq      DoHelp
                    cmpb      #'s'
                    lbeq      DoSilent
                    cmpb      #'S'
                    lbeq      DoSilent
next@               cmpa      #'+'
                    bne       cont@
                    lda       ,x+             skip the plus
* Create the file
cont@               pshs      x               Save param pointer
                    ;leax      FileName,pcr
                    ;os9       I$Delete
                    lda       #WRITE.+READ.
                    ldb       #READ.+PREAD.+WRITE.
                    leax      FileName,pcr
                    os9       I$Create
                    bcc       GotPath@
                    lda       #WRITE.
                    leax      FileName,pcr
                    os9       I$Open
                    bcs       Error2
GotPath@            sta       <PathNum
                    puls      x               Restore param pointer
* Count parameter length
                    pshs      x
                    ldy       #0
CountLoop@          lda       ,x+
                    cmpa      #$0D
                    beq       FoundEnd@
                    cmpa      #' '
                    beq       FoundEnd@
                    leay      1,y
                    bra       CountLoop@
FoundEnd@           puls      x               Restore start
* Write it
                    lda       <PathNum
                    os9       I$Write
                    bcs       CloseErr2
* Close
                    lda       <PathNum
                    os9       I$Close
                    ;clrb
                    ;os9       F$Exit
                    rts
NoParams            rts
Error2              ;os9       F$Exit
                    rts
CloseErr2           pshs      b
                    lda       <PathNum
                    os9       I$Close
                    puls      b
                    ;os9       F$Exit
                    rts

ReadTZFile          lda       #READ.
                    leax      FileName,pcr
                    os9       I$Open
                    bcs       NoFile@
                    sta       <PathNum
                    lda       <PathNum
                    leax      Buffer,u
                    ldy       #10
                    os9       I$Read          Y returns with bytes read
                    sty       <Length         Save length
                    lda       <PathNum
                    os9       I$Close
                    ldb       #1              TZFound
                    stb       <TZFound
                    leax      ATCmd,pcr
                    leay      CmdBuf,u
                    ldb       #16
loop@               lda       ,x+             put first 16 bytes in buffer
                    sta       ,y+
                    decb
                    bne       loop@
                    leax      Buffer,u        get file timezone buffer
                    ldd       <length
loop2@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       loop2@
                    leax      ATCmd,pcr       advance offset to end of command
                    leax      18,x           
                    ldb       #33             put last 33 bytes in 
loop3@              lda       ,x+
                    sta       ,y+
                    decb
                    bne       loop3@
NoFile@             rts


DoBanner            lda #1
                    leax Banner,pcr
                    ldy #BannerLen
                    os9 I$WritLn
                    rts

DoHelp              lda #1
                    leax Banner,pcr
                    ldy #BannerLen
                    os9 I$WritLn
                    leax Help,pcr
                    ldy #HelpLen
                    os9 I$WritLn
                    leax Help2,pcr
                    ldy #HelpLen2
                    os9 I$WritLn
                    leax Help3,pcr
                    ldy #HelpLen3
                    os9 I$WritLn
                    leax Help4,pcr
                    ldy #HelpLen4
                    os9 I$WritLn
                    leax Help5,pcr
                    ldy #HelpLen5
                    os9 I$WritLn
                    clrb
                    os9      F$Exit        Exit without error

* Data area
DevName             fcc "/wz"
                    fcb $0D Carriage return terminator

ErrorMsg            fcc /WizFi360 Communication Error/
                    fcb $0D
ErrorLen            equ *-ErrorMsg

ATCmd               fcc /AT+CIPSNTPCFG=1,-5,"pool.ntp.org","time.nist.org"/
                    fcb $0D,$0A CR+LF
ATCmdLen            equ *-ATCmd

ATCmd2              fcc "AT+CIPSNTPTIME?"
                    fcb $0D,$0A CR+LF
AtCmd2Len           equ *-ATCmd2

FileName            fcc  "/dd/sys/timezone"
                    fcb  $0D

Banner              fcc  "Ntptime for Wildbits WizFi360. Add -h for help."
                    fcb  $0D
BannerLen           equ *-Banner

Help                fcc  "Usage: Ntptime -6       Sets Timezone to -6"
                    fcb  $0D
HelpLen             equ  *-Help

Help2               fcc  "       Ntptime +6       Sets Timezone to +6"
                    fcb  $0D
HelpLen2            equ  *-Help2

Help3               fcc  "       Ntptime -s       Silent mode"
                    fcb   $0D
HelpLen3            equ  *-Help3
 
Help4               fcc  "       After Timezone set simply use ntptime"
                    fcb   $0D
HelpLen4            equ  *-Help4

Help5               fcc  "       by: Matt Massie"
                    fcb   $0D
HelpLen5            equ  *-Help5

* Month Table - just the 3-letter abbreviations
MonthTable          fcc       "JanFebMarAprMayJunJulAugSepOctNovDec"

                    emod
eom                 equ       *
                    end
