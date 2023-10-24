                    nam       llio_coco3
                    ttl       CoCo 3 low-level I/O handler

                    section   code

llio
                    lbsr      llinit
                    lbsr      llread
                    lbsr      llwrite
                    lbsr      llterm

********** I/O ROUTINES **********

* 6551 Parameters
ADDR                equ       $FF68

A_RXD               equ       ADDR+$00
A_TXD               equ       ADDR+$00
A_STATUS            equ       ADDR+$01
A_RESET             equ       ADDR+$01
A_CMD               equ       ADDR+$02
A_CTRL              equ       ADDR+$03

* Baud rates
_B2400              equ       $1A                 2400 bps, 8-N-1
_B4800              equ       $1C                 4800 bps, 8-N-1
_B9600              equ       $1E                 9600 bps, 8-N-1
_B19200             equ       $1F                 19200 bps, 8-N-1

BAUD                equ       _B9600

* ll_init - Initialize the low-level I/O
* Exit: Carry = 0: Init success; Carry = 1; Init failed
llinit
                    sta       A_RESET             soft reset (value not important)
* Set specific modes and functions:
* - no parity, no echo, no Tx interrupt
* - no Rx interrupt, enable Tx/Rx
                    lda       #$0B
                    sta       A_CMD               save to command register
                    lda       #BAUD
                    sta       A_CTRL              select proper baud rate
* Read any junk rx byte that may be in the register
                    lda       A_RXD
                    rts


* llread - Read one character from 6551
*
* Entry: None
* Exit:  A = character that was read
*
* Note, this routine currently doesn't timeout
llread
r                   lda       A_STATUS            get status byte
                    anda      #$08                mask rx buffer status flag
                    beq       r                   loop if rx buffer empty
                    lda       A_RXD               get byte from ACIA data port
                    rts

* llwrite - Write one character to 6551
*
* Entry: A = character to write
* Exit:  None
llwrite
                    pshs      a                   save byte to write
w                   lda       A_STATUS            get status byte
                    anda      #$10                mask tx buffer status flag
                    beq       w                   loop if tx buffer full
                    puls      a                   get byte
                    sta       A_TXD               save to ACIA data port
                    rts


llterm
                    rts

                    ifne      0
* llwout - Write an entire string
* llwerr - Write an entire string
llwerr
llwout
                    pshs      a
l@                  lda       ,x+
                    cmpa      #C$CR
                    beq       e@
                    leay      -1,y
                    beq       f@
                    bsr       Write
                    bra       l@
e@                  bsr       Write
                    lda       #C$LF
                    bsr       Write
f@                  ldx       <buffptr
                    clrb
                    puls      a,pc

* ReadLine - Read an entire string, up to CR
* Entry: X = address to place string being read (CR terminated)
*        Y = maximum number of bytes to read (including nul byte)
ReadLine
                    ldx       <buffptr
                    pshs      y,x,a
                    ldy       #80
l@                  bsr       Read                read 1 character
                    cmpa      #C$CR               carriage return?
                    beq       e@                  branch if so...
                    cmpa      #$08                backspace?
                    beq       bs@
                    cmpy      #$0000              anymore room?
                    beq       l@
                    leay      -1,y                back up one char
                    sta       ,x+                 and save in input buffer
m@                  bsr       Write               echo back out
                    bra       l@
e@                  sta       ,x
                    bsr       Write
                    lda       #C$LF
                    bsr       Write
                    clrb
                    puls      a,x,y,pc
bs@                 cmpx      1,s                 are we at start
                    beq       l@                  if so, do nothing
                    clr       ,-x                 else erase last byte
                    lbsr      Write               write backspace
                    lda       #C$SPAC             a space...
                    lbsr      Write               write it
                    leay      1,y                 count back up free char
                    lda       #$08                another backspace
                    bra       m@
                    endc

                    endsect
