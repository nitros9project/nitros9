********************************************************************
* sub1 - Sub1 Sub Battle Simulator subroutine
*
* There is a lot of extraneous and unneccessary instructions throughout
* the code. But since we use the jump table at module enter be careful
* when removing any thing and adjust it accordingly.
* No explicit edition byte in source.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   0      2003/03/29  Paul W. Zibaila
* Disassembly of original distribution.

                    nam       sub1
                    ttl       Sub1 Sub Battle Simulator subroutine

                    ifp1
                    use       defsfile
                    endc

* I/O path definitions
StdIn               equ       0
StdOut              equ       1
StdErr              equ       2



*  defines for 5 bit zero offset instructions
Zldb_u              equ       $E640
Zldb_x              equ       $E600
Zsta_x              equ       $A700
Zclr_u              equ       $6F40
Zclr_x              equ       $6F00

*   misc defines for SUB
SinTblSz            equ       $0169
CntrlSz             equ       $1666

SinDat              equ       $0126
CntrlDat            equ       $1E25

* class D external label equates

D0001               equ       $0001
D0002               equ       $0002
D0003               equ       $0003
D0004               equ       $0004
D0005               equ       $0005
D0006               equ       $0006
D0007               equ       $0007
D0009               equ       $0009
D000D               equ       $000D
D000E               equ       $000E
D0010               equ       $0010
D0012               equ       $0012
D0013               equ       $0013
D0015               equ       $0015
D0030               equ       $0030

* class X external label equates

X0107               equ       $0107               address of subroutine module entry point
X0291               equ       $0291
X0295               equ       $0295
X0296               equ       $0296
X0297               equ       $0297
X0298               equ       $0298
X029A               equ       $029A
X029C               equ       $029C
X02A3               equ       $02A3               side FF = german 23 = American
X0355               equ       $0355
X04F0               equ       $04F0
X04F2               equ       $04F2
X04F4               equ       $04F4
X04F5               equ       $04F5
X04F7               equ       $04F7
X04F8               equ       $04F8
X04F9               equ       $04F9
X04FA               equ       $04FA
X04FB               equ       $04FB
X04FC               equ       $04FC
X04FD               equ       $04FD
X04FE               equ       $04FE
X04FF               equ       $04FF
X0500               equ       $0500
X05CE               equ       $05CE
X1D3F               equ       $1D3F
X1D41               equ       $1D41
X1D44               equ       $1D44
X1D46               equ       $1D46
X1D47               equ       $1D47
X1D49               equ       $1D49               IT.EKO original value (echo)
X1D4A               equ       $1D4A               IT.PAU original value (end of page pause)
X1D6D               equ       $1D6D
X1D76               equ       $1D76
X1D88               equ       $1D88
X1D89               equ       $1D89
X1D8B               equ       $1D8B
X1D8F               equ       $1D8F
X1D91               equ       $1D91
X1D93               equ       $1D93
X1D95               equ       $1D95
X1DA5               equ       $1DA5
X1DA7               equ       $1DA7
X1DAD               equ       $1DAD
X1DAF               equ       $1DAF
X1DB9               equ       $1DB9
X1DD9               equ       $1DD9               temp storage for path num
X1DDA               equ       $1DDA
X1DF6               equ       $1DF6
X1DF9               equ       $1DF9
X1E13               equ       $1E13
X1E16               equ       $1E16               year value
X1E17               equ       $1E17
X1E1D               equ       $1E1D
X1E1E               equ       $1E1E
X1E20               equ       $1E20
X1E22               equ       $1E22
X1E23               equ       $1E23
X1E24               equ       $1E24
X4265               equ       $4265
X4C75               equ       $4C75               side      0=German 1=US
X4C76               equ       $4C76               game type
X4C77               equ       $4C77               game level
X4C78               equ       $4C78
X4C7A               equ       $4C7A
X4C80               equ       $4C80
X4C81               equ       $4C81
X4C82               equ       $4C82
X4C83               equ       $4C83
X4C84               equ       $4C84
X4C85               equ       $4C85
X4C87               equ       $4C87
X4C88               equ       $4C88
X4C90               equ       $4C90
X4CA0               equ       $4CA0
X4CA1               equ       $4CA1
X4CA4               equ       $4CA4
X4CA6               equ       $4CA6
X4CA8               equ       $4CA8
X4CA9               equ       $4CA9
X4CAA               equ       $4CAA
X4CAB               equ       $4CAB
X4CAC               equ       $4CAC
X4CB1               equ       $4CB1
X4CB2               equ       $4CB2
X4CB3               equ       $4CB3
X4CB4               equ       $4CB4
X4CBD               equ       $4CBD
X4CCC               equ       $4CCC
X4CCD               equ       $4CCD
X4CCE               equ       $4CCE
X4CCF               equ       $4CCF
X4CE0               equ       $4CE0
X4CEE               equ       $4CEE
X4CEF               equ       $4CEF
X4CF1               equ       $4CF1
X4CF3               equ       $4CF3
X4CF5               equ       $4CF5
X4CF7               equ       $4CF7
X4CF9               equ       $4CF9
X4CFB               equ       $4CFB
X4CFD               equ       $4CFD
X4CFF               equ       $4CFF
X4D00               equ       $4D00
X4D01               equ       $4D01
X4D02               equ       $4D02
X4D03               equ       $4D03
X4D04               equ       $4D04
X4D11               equ       $4D11
X4D12               equ       $4D12
X4D13               equ       $4D13
X4D1B               equ       $4D1B
X4D1D               equ       $4D1D
X4D1F               equ       $4D1F
X4D21               equ       $4D21
X4D22               equ       $4D22
X4D27               equ       $4D27
X4D28               equ       $4D28
X4D29               equ       $4D29
X4D2B               equ       $4D2B
X4D2E               equ       $4D2E               radio status
X4D3B               equ       $4D3B
X4D3C               equ       $4D3C               new side value
X4D3D               equ       $4D3D
X4D3E               equ       $4D3E
X71B1               equ       $71B1

* subroutines in sub6 that get loaded into the data area
X72C3               equ       $72C3
X72F3               equ       $72F3               seems to proceed character strings
X7304               equ       $7304               calcs an integer based on input in d
X735B               equ       $735B               Change palette routine
X7477               equ       $7477               some sort of copy routine accepts acsii between $20-$5F ???
X74CC               equ       $74CC
X74D9               equ       $74D9
X7691               equ       $7691
X76A4               equ       $76A4
X76B9               equ       $76B9
X7747               equ       $7747
X77E5               equ       $77E5
X782E               equ       $782E               2 place formatted integer output based on input in b
X7843               equ       $7843
X7866               equ       $7866
X7BF4               equ       $7BF4



tylg                set       SbRtn+Objct
atrv                set       ReEnt+rev
rev                 set       $01
*edition set  $01

                    mod       eom,name,tylg,atrv,start,size



* OS9 data area definitions
size                equ       .

name                fcs       "sub1"
*       fcb  edition                           no edition byte included in orig code

* b contains an offset passed by call to smap
start               leax      >JumpTbl,pcr
                    ldd       b,x                 index to subroutine offset
                    ldx       X0107               holds the address of start from smap call
                    jmp       d,x                 nuttin' to it but to jump to it

JumpTbl
L001C               fdb       GoOpts-start        $0023
                    fdb       GameSetup-start     $0FC5
                    fdb       Read_mission-start  $0A05
                    fdb       MakeFile-start      $0880
                    fdb       ReadNewFile-start   $08BC
                    fdb       L0479-start         $0468
                    fdb       Read_mission2-start $0B42
                    fdb       SetParms2-start     $0547
                    fdb       XmtSOS-start        $0DF1
                    fdb       Return2Sea-start    $1243
                    fdb       TransferTorp-start  $145C
                    fdb       XmtPOS-start        $0E3C

GoOpts              lbsr      GetOPts


                    ldd       #$0073
                    std       X1DAF

                    ldd       #$00F4
                    std       X1DAD

* Open Path - Opens a path to the an existing file or device
*             as specified by the path list
* entry:
*       a -> access mode (D S PE PW PR E W R)
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last btye of the path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    lda       #READ.
                    leax      >SinTbl,pcr
                    os9       I$Open
                    pshs      a                   save that path number

* Read  - Reads n bytes from the specified path
* entry:
*       a -> path number
*       x -> address in which to store the data
*       y -> is the number of bytes to read
*
* exit:
*       y -> number of bytes read
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    ldx       #SinDat
                    ldy       #SinTblSz
                    os9       I$Read              load it in data

                    puls      a                   clean up stack

* Close Path - Terminates I/O path
*              (performs an impledd I$Detach call)
* entry:
*       a -> path number
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    os9       I$Close


                    lda       #READ.
                    leax      >Font,pcr
                    os9       I$Open
                    pshs      a                   No need for this here

* Seek  - Repositions a file pointer
* entry:
*       a -> path number
*       x -> MS 16 bits of the desired file position
*       u -> LS 16 bits of the desired file position
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    ldx       #0
                    ldy       #0                  No need for this here
                    ldu       #$0103              file position
                    os9       I$Seek

                    ldx       #$4D3F              save address
                    ldy       #$0308              num of bytes to read
                    lda       ,s                  get the path ?? should still be set
                    os9       I$Read

                    puls      a                   get that same path number no need
                    os9       I$Close             close the file
                    inc       X4C75               increment side ?

                    lbsr      GetMisDat
                    lbsr      GetSubStat
                    lbsr      GetShipmap
                    lbsr      GetMap
                    lbsr      GetConvoy
                    lbsr      SetParams
                    lbsr      SetMorePars

                    lda       #2
                    sta       X05CE

                    ldd       #$0004
                    std       X1D44

                    ldd       #$1234
                    std       X1D3F
                    std       X1D41

                    lbra      GetControl1

                    os9       F$Exit

GetMap
L00B8               pshs      a,b,x,y,u
                    lda       #READ.
                    tst       X4C75               test the side value 0=German 1=US
                    bne       MapUS

                    leax      >Germap,pcr
                    ldy       #$0A9D              number of bytes to read when the file is open
                    bra       LoadMap

MapUS
L00CB               leax      >USAmap,pcr
                    ldy       #$094E              number of bytes to read when the file is open

LoadMap
L00D3               pshs      y                   number of bytes to read when the file is open
                    os9       I$Open              open it
                    ldy       ,s                  once again number of bytes to read when the file is open
                    pshs      a                   save the path
                    ldx       #CntrlDat           Set the addr to store the info
                    lda       ,s                  get the path ???
                    os9       I$Read              do the read
                    puls      a                   pull the path
                    os9       I$Close             close the path

* decode and put it in memory
                    puls      y                   get that number of bytes to read when the file is open
                    leay      -$01,y              drop it by one
                    ldx       #CntrlDat           address where stored (from addr)
                    ldu       #$05CF              destination address
                    lbsr      Decode_copy
                    puls      a,b,x,y,u,pc


GetMisDat
L00F9               pshs      a,b,x,y,u
                    lbsr      Set_75
                    clr       X4D27

                    lda       #READ.
                    leax      >Mis_dat,pcr
                    os9       I$Open
                    sta       X1DD9               stow path number

                    lbsr      L019A

                    ldb       X02A3               load the Side value
                    lda       #$33
                    mul
                    tfr       d,u                 LS 16 bits of file position
                    ldx       #0                  MS 16 bits of file position
                    lda       X1DD9               get our path number
                    os9       I$Seek              reset the file pointer

                    ldx       #$4C8A              address to store the data
                    ldy       #$0033              number of bytes to read
                    lda       X1DD9               get the path number   (not needed)
                    os9       I$Read              read the data from the file

                    lda       X1DD9               get the path number again (not needed)
                    os9       I$Close             close the file

                    ldb       X4CA8
                    decb
                    lslb
                    leax      >ByteTbl4,pcr
                    ldd       b,x
                    addb      X4CA9
                    adca      #0
                    std       X1E17

                    ldb       X4CAA
                    stb       X1E16               year value

                    ldb       X4CAB
                    tst       X4C76               test game type value once
                    bne       L015A               not target practice
                    lbsr      L021B               was target practice

                    ldb       #$10                on return load b
L015A               stb       X4D22               always stow b either from X4CAB or a fixed value of $10

                    tst       X4C76               test that game type value again
                    beq       Ext_MD              if zero we're done

                    ldb       X4CA0
                    lbmi      Ext_MD2             if negative were done
                    lda       #$09                otherwise multiply by 9
                    mul
                    leax      >ByteTbl3,pcr       load pointer to bytetable
                    leax      d,x                 index into it and use that as copy from addr
                    ldy       #$4C63              set destination address to copy to
                    bsr       Copy_9              copy 9 bytes

                    ldb       X4CA1
                    bmi       Ext_MD2             if negative we're done
                    lda       #$09                same as above for 9 more bytes
                    mul
                    leax      >ByteTbl3,pcr
                    leax      d,x
                    ldy       #$4C6C
                    bsr       Copy_9

Ext_MD
L018C               puls      a,b,x,y,u,pc


Copy_9
L018E               lda       #$09                for the use only twice I would have inlined this snippet

Loop_9
L0190               ldb       ,x+
                    stb       ,y+
                    deca
                    bne       Loop_9
                    rts


Ext_MD2
L0198               puls      a,b,x,y,u,pc


L019A               pshs      a,b,x,y,u
                    ldb       X4C76               check that game type value again
                    cmpb      #$02                is it a 2 War Time Command ?
                    lbeq      inc2                if so head for inc & inc

                    tst       X4C76               check that game type value again
                    bne       L01B9               not target practice branch

                    ldb       #$24                set some men loactaions with $
                    stb       X02A3               the side value
                    stb       X4D3B

                    lda       #$01                US
                    sta       X4C75               set side value
                    puls      a,b,x,y,u,pc


L01B9               ldb       X1E16               year value
                    cmpb      X4D3D               new year value
                    bne       L01D7               not equal branch to next sub

                    ldb       X4C75               side value
                    cmpb      X4D3C               new side value
                    bne       L01D7               not equal branch to next sub

                    ldb       X02A3               Side value
                    incb                          bump it
                    cmpb      X4D3B               compare to mate
                    beq       L01D7               if equal branch to next sub
                    stb       X02A3               if not stow b at side value
                    puls      a,b,x,y,u,pc


L01D7               ldb       X4C75               side value
                    stb       X4D3C               new side value

                    ldb       X1E16               year value
                    stb       X4D3D               new year value

                    subb      #39                 start year german b used as index below

                    lda       X4C75               side value
                    cmpa      #0                  German ?
                    bne       Loadtb

                    leax      >ByteTblA,pcr       German
                    bra       Gotta

Loadtb              leax      >ByteTblB,pcr       American
Gotta               lda       b,x
                    sta       X02A3               side value

                    incb                          bump b by one
                    lda       b,x                 index into x again
                    sta       X4D3B               stow that
                    puls      a,b,x,y,u,pc


inc2                inc       X02A3               side value
                    inc       X4D3B
                    puls      a,b,x,y,u,pc


ByteTblA
L020B               fcb       $00,$02,$09,$0F,$15,$1B,$21,$24

ByteTblB
L0213               fcb       $00,$00,$00,$24,$2E,$32,$39,$3C


L021B               pshs      a,b,x,y,u

                    ldb       #$FF                set b to $FF
                    ldx       #$4C8A              start address to set bytes
Loop25              stb       ,x+                 set byte and bump pointer
                    cmpx      #$4CA4              have we moved 25 bytes?
                    blo       Loop25              nope loop again

                    ldd       #0000               I'm sure there is a reason these
                    std       X4CA4               jump all over the place
                    std       X4CA6               but it sure isn't self evident

                    clr       X4C90

                    ldb       #$05
                    stb       X4CB1

                    ldb       #$10
                    stb       X4CAB

                    clr       X4CB3
                    clr       X4CB4

                    ldx       #$0579
                    ldb       #$06
                    stb       $01,x

                    lda       #$60
                    sta       $02,x
                    sta       X1DF6

                    ldd       #$0064
                    std       $03,x

                    lda       #$7F
                    sta       $05,x
                    sta       X1DF9

                    ldd       #$3FFF
                    std       $06,x

                    clr       $12,x               this gets overwritten below
                    clr       $08,x
*                              $09.x is not manipulated

                    leax      $0A,x               so now x is pointed to $0583

                    ldd       #$0108              this is cute a=$01 b=$08
Set8                sta       ,x+                 set 8 bytes to 1
                    decb                          dec the counter
                    bne       Set8

*                              so when we're finished here starting $0580 we have
*                               0580     $06,$60,$00,$64,$7F,$3F,$FF,$00
*                               0588      ??,$01,$01,$01,$01,$01,$01,$01
*                               0590     $01,$01

                    clr       X0296

                    ldd       #$0320
                    std       X1D6D

                    lbsr      L0479               branch down and set some more based at $0579
                    puls      a,b,x,y,u,pc


GetSubStat
L0281               pshs      a,b,x,y,u
                    lda       #$FF
                    sta       X0295

                    lda       #READ.
                    leax      >SubStat,pcr
                    os9       I$Open

                    sta       X1DD9               stow the path num

                    lda       X4CB1               First read of sub stats
                    ldb       #$22
                    mul
                    ldx       #0                  MS 16 bits of file position
                    tfr       d,u                 LS 16 bits of file position
                    lda       X1DD9               get the path num
                    os9       I$Seek              reset file pointer to the head of the file

                    ldx       #$4CCC              destination address
                    ldy       #$0022              number of bytes to read
                    lda       X1DD9               get that pesky path number (not needed)
                    os9       I$Read              read the data

                    lda       X4CB2               second read of sub stats
                    ldb       #$0D
                    mul
                    addd      #$00CC
                    ldx       #0                  MS 16 bits of file position
                    tfr       d,u                 LS 16 bits of file position
                    lda       X1DD9               get path num
                    os9       I$Seek              position the file pointer

                    ldx       #$4CBD              destination address
                    ldy       #$000D              number of bytes to read
                    lda       X1DD9               get the path num (not needed)
                    os9       I$Read              read the data

                    lda       X4C75               test side value
                    cmpa      #0                  is it zero?  German
                    beq       Geroff              if so branch to get next file pos
                    ldu       #$0134              LS 16 bits of file position
                    bra       SetMS1              go get the MS word
Geroff              ldu       #$01AC              LS 16 bits of file position
SetMS1              ldx       #$0000              MS 16 bits of file position
                    lda       X1DD9               get path num
                    os9       I$Seek              position the file pointer

                    ldx       #$0501              destination addr
                    ldy       #$0078              number bytes to read
                    lda       X1DD9               get path num
                    os9       I$Read              read the data

                    lda       X4C75               test side for next read value
                    cmpa      #0                  German ?
                    beq       Geroff2             set up next seek
                    ldu       #$0224              LS word of pos
                    bra       SetMS2              go set MS word
Geroff2             ldu       #$02A2              LS word of pos
SetMS2              ldx       #$0000              MS word of pos
                    lda       X1DD9               get the path num
                    os9       I$Seek              set the file pointer

                    ldx       #$02B7              destination address
                    ldy       #$007E              number of bytes to read
                    lda       X1DD9               get the path num  (not needed)
                    os9       I$Read              fetch the data

                    lda       X1DD9               get the path num (not needed)
                    os9       I$Close             close the file

                    ldx       #$4A80              load base addr for offset index addressing
                    ldu       #$02B7              load base addr for offset index addressing

                    ldb       #$06
                    pshs      b

Transtat
L032D               fdb       Zclr_x              clr 0,x

                    lda       $01,u
                    sta       $03,x

                    ldd       $02,u
                    std       $04,x

                    lda       $04,u
                    sta       $06,x

                    ldd       $05,u
                    std       $07,x

                    ldd       #0                  set up to clr word
                    std       $01,x
                    std       $09,x

                    leax      $15,x               bump pointer by 21
                    leau      $15,u
                    dec       ,s                  dec the counter
                    bne       Transtat            gone 6 times ? nope loop again

                    puls      b                   clean up stack

                    lda       #$05
                    lbsr      SetByte

                    ldb       X1E16               load year value
                    tst       X4C75               test side value 0=German 1=US
                    lbne      tst2A               test value not zero skip to compare b $2A
                    cmpb      #$27                is it 39 ?
                    bne       tst28               nope goto next test
                    lda       #2
                    lbsr      SetByte
                    lda       #3
                    lbsr      SetByte
                    lda       #4
                    lbsr      SetByte
                    lbra      ExtSubStat

tst28               cmpb      #$28                is it 40 ?
                    bne       tst29               nope go to next test
                    lda       #2
                    lbsr      SetByte

                    ldd       X1E17
                    cmpd      #$005A
                    lbgt      ExtSubStat

                    lda       #3
                    lbsr      SetByte
                    lbra      ExtSubStat

tst29               cmpb      #$29                is it 41 ?
                    bne       tst2a
                    lbra      ExtSubStat

tst2a               cmpb      #$2A                is it 42 ?
                    bne       tst2b
                    lbra      ExtSubStat

tst2b               cmpb      #$2B                is it 43 ?
                    bne       tst2c
                    tst       X4C75               test side value
                    beq       ExtSubStat          german ?

                    lda       #4
                    lbsr      SetByte
                    lbra      ExtSubStat

tst2c               cmpb      #$2C                is it 44 ?
                    bne       tstlst
                    tst       X4C75
                    lbne      ExtSubStat
                    ldd       X1E17
                    cmpd      #$0099
                    lbls      ExtSubStat

L03C8               lda       #2
                    lbsr      SetByte
                    lda       #4
                    lbsr      SetByte
                    lda       #3
                    lbsr      SetByte
                    lbra      ExtSubStat

tstlst              tst       X4C75
                    beq       L03C8
                    lda       #5
                    ldb       #$15
                    mul
                    ldx       #$4A80
                    leax      d,x
                    fdb       Zclr_x              clr 0,x

ExtSubStat
L03EB               puls      a,b,x,y,u,pc


*  a is passed by caller
*  Calcs an offset from base addr and sets it to FF
*
SetByte
L03ED               pshs      a,b,x,y,u
                    ldb       #$15
                    mul
                    ldx       #$4A80
                    leax      d,x
                    lda       #$FF
                    fdb       Zsta_x
                    puls      a,b,x,y,u,pc


GetConvoy
L03FD               pshs      a,b,x,y,u
                    lda       X4C76               check the game type byte
                    bne       ReadConvoy          not target practice
                    puls      a,b,x,y,u,pc


ReadConvoy
L0406               leax      >Convoys,pcr
                    lda       #READ.
                    os9       I$Open
                    sta       X1DD9               save that path num
                    ldx       #$4C90              set up destination addr
                    ldy       #$0579              addr for inner loop RCLop2

                    ldb       #4                  loop counter
                    pshs      b                   push on the stack
RCloop              ldb       ,x+                 get the first byte at 4C90 and bump the pointer
                    lbmi      RCLend              go to loop end
                    lda       #$16                calc the seek position
                    mul
                    tfr       d,u                 LS Word file pos
                    pshs      x,y                 save destination and bytes to read
                    ldx       #0                  MS Word file pos
                    lda       X1DD9               path num
                    os9       I$Seek              reset the file pointer
                    ldx       $02,s               get the val off the stack
                    ldy       #$0016              bytes to read
                    lda       X1DD9               path num
                    os9       I$Read              fetch the data

                    puls      x,y                 grab the old x and y
                    ldb       #3                  set up an inner loop

RCLop2              pshs      b                   push the counter on the stack
                    ldb       $02,y               get the third byte at y
                    addb      #$3B                add to it
                    tst       X4C75               test side value
                    beq       RCx1                if zero (german) stow it and get new thing to work on
                    addb      #$15                otherwise add some more to it then
RCx1                stb       $02,y               stow it back
                    ldb       $05,y               get the next one to work with
                    addb      #$27                add to it
                    tst       X4C75               check that side value
                    beq       RCx2                if zero (german) stow that and cycle the loop
                    addb      #$0B                otherwise add some more then
RCx2                stb       $05,y               stow it back
                    leay      $01,y               bump pointer +1
                    puls      b                   pull the loop counter
                    decb                          decrement it
                    bne       RCLop2              loop if we haven't gone 3 times

                    leay      -$03,y              after 3 loops move y back to start of inner loop value
RCLend              leay      $16,y               set y up for the next $16 byte read
                    dec       ,s                  dec the outer loop counter
                    bne       RCloop              not gone four times ? loop again

                    puls      b                   otherwise clean up stack

                    lda       X1DD9               get that good old path number
                    os9       I$Close             and close the file
                    puls      a,b,x,y,u,pc        return


*  what do I do in the great scheme of things???
L0479               pshs      a,b,x,y,u           our generic save all

                    ldb       X0296
                    lda       #$16
                    mul                           calc an offset
                    ldx       #$0579              get the base address
                    leax      d,x                 set the pointer to base + offset
                    lda       $04,x
                    bpl       PosVal              is it positive ? branch
                    lda       $02,x               otherwise shift a couple bytes
                    sta       $04,x               first then go on
                    lda       $05,x
                    sta       $07,x

PosVal              lda       #$01
                    sta       $08,x

                    ldb       X0296
                    lbsr      L04AF

                    lda       #$07                outer loop counter
                    leau      $0A,x               load u with x+10

Outloop             ldb       a,u                 load b with u+counter (inner counter)
                    beq       Decout              is it zero branch out
In_loop             lbsr      L04DA               not zero
                    decb                          dec inner counter
                    bne       In_loop
Decout              deca
                    bpl       Outloop
                    puls      a,b,x,y,u,pc


*       value passed in b from caller
L04AF               pshs      a,b,x,y,u
                    ldu       #$4A02              set base offset
                    lda       #$15                compute offset
                    mul
                    leau      d,u                 set base + offset
                    fdb       Zclr_u              clear the byte at u
                    clr       $10,u

                    ldd       X1DF6
                    std       $03,u

                    ldd       X1DF9
                    std       $06,u

                    ldd       X1D6D
                    std       $09,u

                    ldb       1,x                 could have pulled x off the stack
                    clra                          instead of mucking around with u
                    std       $01,u

                    stx       $12,u

                    stu       X71B1               stow $4a02 at 71b1
                    puls      a,b,x,y,u,pc


L04DA               pshs      a,b,x,y,u
                    ldb       #$41
                    stb       X1E13

                    ldu       #$42B5              set base address
L04E4               fdb       Zldb_u              ldb ,u
                    bpl       L053D

                    pshs      x                   we've pushed it once
                    leax      >ByteTblF,pcr
                    lda       a,x
                    sta       $12,u
                    puls      x

                    fdb       Zclr_u              clr ,u
                    clr       $10,u

                    ldd       X1DF6
                    std       $03,u

                    ldd       #$1FFF
                    jsr       X76A4
                    addd      $04,u
                    std       $04,u

                    ldd       X1DF9
                    std       $06,u
                    ldd       #$1FFD
                    jsr       X76A4
                    addd      $07,u
                    std       $07,u

                    ldd       X1D6D
                    std       $09,u
                    ldb       $01,x
                    clra
                    std       $01,u

                    ldd       X71B1
                    std       $13,u

                    pshs      u
                    leay      $03,u
                    ldu       #$4C84
                    jsr       X74D9
                    tfr       u,y
                    puls      u

                    sty       $0E,u
                    sta       $0D,u
                    puls      a,b,x,y,u,pc


L053D               leau      $15,u
                    dec       X1E13
                    lbne      L04E4

                    puls      a,b,x,y,u,pc


*     reads a byte from std in not explicitly called
N0549               pshs      a,b,x,y,u
                    clra
                    ldx       #$1DDA
                    ldy       #1
                    os9       I$Read
                    puls      a,b,x,y,u,pc


SetParms2
L0558               pshs      a,b,x,y,u
                    lda       X4C80
                    cmpa      #3
                    beq       ExtSP2              if three were done
                    inca                          bump a
                    sta       X4C80               and save it back
                    ldx       #$4CA4              set up index
                    tst       a,x                 test
                    bne       SetP2

                    lda       #$FF
                    sta       X4C80
                    bra       ExtSP2

SetP2               lda       #4
                    sta       X4C81
ExtSP2
L0578               puls      a,b,x,y,u,pc


* Not labeled by the disassembler
N057A               pshs      y,u
                    ldy       #$1E0D
                    ldu       #$4C84
                    jsr       X74D9
                    lsra
                    lsra
                    puls      y,u,pc


SetParams
L058A               pshs      a,b,x,y,u
                    ldd       #0                  zero (clear) these words
                    std       X4C78
                    std       X4C7A

                    ldb       #$FF                set these bytes
                    stb       X4D2B
                    stb       X4C80

                    lda       #$FF                switching from accb to acca makes no sense
                    sta       X4D28

                    clr       X4D11               clear these bytes
                    clr       X4D29
                    clr       X4C82
                    clr       X0500

                    clrb                          now we clear an acc
                    stb       X4CEE               and store the val at these
                    stb       X0355
                    stb       X0298

                    lbsr      SetParms2           call a sub to set some others

                    lda       #$0A
                    sta       X1D47

                    lda       #1
                    sta       X1D46

                    lda       #$3C
                    sta       X1D76

                    ldb       #$63
                    stb       X4D12
                    stb       X4D13

                    ldd       #$6300
                    std       X4D1F
                    std       X4D1B
                    std       X4D1D

                    lda       X4CE0
                    sta       X4D21

                    ldb       X4CCF
                    stb       X4D00

                    ldb       X4CCE
                    stb       X4CFF

                    addb      X4CCF
                    cmpb      X4CAC

                    bls       Setpar2

                    ldb       X4CCD
                    stb       X4D00

                    lda       X4CAC
                    suba      X4CCD
                    sta       X4CFF

Setpar2             lda       X4CCC
                    sta       X4D01

                    lda       X4CCD
                    sta       X4D02

                    clr       X4D03
                    clr       X4D04

                    ldd       #1
                    std       X1E1E
                    std       X1E20

                    stb       X1E22

                    clr       X1E1D

                    ldy       #0
SPLoop              clr       $4D2D,y
                    leay      1,y
                    cmpy      #$000E
                    bcs       SPLoop

                    clr       X4CEE

                    tst       X4C76               test game type value
                    bne       Setpar3             not target practice

                    clr       X4C81

                    lda       #$5F
                    sta       X4C84

                    lda       #$7F
                    sta       X4C87

                    ldd       #$E678
                    std       X4C85

                    ldd       #$4E20
                    std       X4C88

                    puls      a,b,x,y,u,pc


Setpar3
L065B               ldb       X4CB3
                    lda       #$15
                    mul
                    ldx       #$02B7
                    leax      d,x                 calc an index
                    fdb       Zldb_x              to calc an index
                    lda       #$04
                    mul
                    std       X4CFB               stow that value
                    std       X4CF3
                    std       X4CFD
                    std       X4CF5

                    ldb       $01,x               get bytes at the pointer
                    stb       X4C84               and save them elsewhere

                    ldd       $02,x
                    std       X4C85

                    ldb       $04,x
                    stb       X4C87

                    ldd       $05,x
                    std       X4C88

                    puls      a,b,x,y,u,pc

SetMorePars
L068D               pshs      a,b,x,y,u
                    ldx       #$4A56
                    lda       #$FF
                    fdb       Zsta_x

                    leax      $15,x
                    fdb       Zsta_x

                    lda       X4C77               game level
                    leax      >ByteTblC,pcr
                    ldb       a,x
                    stb       X1E23

                    leax      >Gstring,pcr
                    ldb       a,x
                    stb       X1E24               always a G

                    ldd       X4CBD
                    ldu       #3
                    jsr       X76B9
                    std       X1DDA

                    ldb       X4C77               game level
                    clra                          zero ms byte
                    tfr       d,y                 transfer game level to y
                    ldd       X4CBD
                    cmpy      #$0003              Expert level ?
                    beq       ExtSMP

                    addd      X1DDA
                    cmpy      #$0002              Advanced level ?
                    beq       ExtSMP1

                    addd      X1DDA
                    cmpy      #$0001              Intermediate level ?
                    beq       ExtSMP1

                    addd      X1DDA               must be Novice

ExtSMP1             std       X4CBD

ExtSMP
L06E3               puls      a,b,x,y,u,pc


ByteTblC
L06E5               fcb       $14,$19,$1E,$2D


Gstring
L06E9               fcc       "GGGG"              all bytes $47


GetShipmap
L06ED               pshs      a,b,x,y,u
                    lda       #READ.
                    leax      >Shipmap,pcr
                    os9       I$Open
                    sta       X1DD9               stow the path num

                    ldx       #$5041              destination address
                    ldy       #$0050              number of bytes to read
                    os9       I$Read              fetch the data

                    pshs      a,x,u               why ??
                    ldx       #0                  MS Word of file pos
                    ldu       #$0C9D              LS Word of file pos
                    lda       X1DD9               path num
                    os9       I$Seek              reset file pointer
                    puls      a,x,u               pull what we just saved and then over write it

                    ldx       #$5091              destination address
                    ldy       #$1135              bytes to read
                    lda       X1DD9               get the path num
                    os9       I$Read              fetch the data

                    tst       X4C75               test side value
                    bne       Shpmap2             Not German

                    pshs      a,x,u               duh
                    ldx       #0                  MS Word of file pos
                    ldu       #$0080              LS Word of file pos
                    lda       X1DD9               load the same path num
                    os9       I$Seek              reset the file pointer

                    puls      a,x,u               pull em and overwrite em ??
                    ldx       #$61C6              destination
                    ldy       #$0C1D              number of bytes to read
                    lda       X1DD9               path num
                    os9       I$Read              fetch the data

                    pshs      a,x,u               duh
                    ldx       #0                  MS Word of file pos
                    ldu       #$2A9C              LS Word of file pos
                    lda       X1DD9               get that path num
                    os9       I$Seek              reset the file pointer

                    puls      a,x,u               pull em and over write them duh
                    ldx       #$6DE3              destination addr
                    ldy       #$0230              number of byets to read
                    lda       X1DD9               same path num again
                    os9       I$Read              fetch the data

                    bra       Shpmap3

Shpmap2             pshs      a,x,u
                    ldx       #0                  MW Word of file pos
                    ldu       #$0050              LS Word of file pos
                    lda       X1DD9               path num
                    os9       I$Seek              reset the file pointer

                    puls      a,x,u               waste of time
                    ldx       #$5061              destination addr
                    ldy       #$0030              number of byets to read
                    lda       X1DD9               path num
                    os9       I$Read

                    pshs      a,x,u               waste of time
                    ldx       #0                  MW Word of file pos
                    ldu       #$1DD2              LS Word of file pos
                    lda       X1DD9               path num
                    os9       I$Seek              reset the file pointer

                    puls      a,x,u               waste of time
                    ldx       #$61C6              destination addr
                    ldy       #$0CCA              number of byets to read
                    lda       X1DD9               path num
                    os9       I$Read

                    pshs      a,x,u               waste of time
                    ldx       #0                  MW Word of file pos
                    ldu       #$2CCC              LS Word of file pos
                    lda       X1DD9               path num
                    os9       I$Seek              reset the file pointer

                    puls      a,x,u               waste of time
                    ldx       #$6E90              destination addr
                    ldy       #$02CA              number of byets to read
                    lda       X1DD9               path num
                    os9       I$Read

Shpmap3             lda       X1DD9               its the same stinking path num all along ...
                    os9       I$Close

                    puls      a,b,x,y,u,pc


GetFile             pshs      a
                    ldd       #0000
                    jsr       X77E5

                    jsr       X7747

                    ldd       #$0039
                    std       X1DA7

                    ldd       #$0050
                    std       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "Enter Filename: "
                    fcb       C$NULL
                    fcb       $CC
                    fcb       C$NULL
                    fcb       $45

                    std       X1DA7

                    ldd       #$0056
                    std       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "->"
                    fcb       C$NULL

                    clr       X4265
                    lbsr      GetKBinp
                    puls      a,pc


GetKBinp
L0807               pshs      a,x,y,u
                    ldx       #$4265              base addr to store data
                    jsr       X74CC

                    leax      -$01,x
ReadKey             lbsr      L087F

                    clra                          set path stdin
                    pshs      x                   address to store data ($4264)
                    ldy       #$01                get one byte
                    os9       I$Read              fetch the byte
                    puls      x                   no need for this
                    ldb       ,x                  load b with the keyboard value

                    cmpb      #C$BSP              is it a back space ? (ctrl-h)
                    lbeq      IsBSP

                    cmpb      #C$EOF              is it an ESC (ctrl-break)
                    lbeq      IsEOF

                    cmpb      #C$QUIT             is it ENQ (ctrl-e)
                    lbeq      IsEOF

                    tst       X029C
                    lbne      IsEOF

                    cmpb      #C$CR               carriage return
                    lbeq      EndKey

*                            argument passed in b to this routine
                    jsr       X7477               some sort of copy routine ??
                    cmpx      #$4275              so we read 16 bytes ?
                    blo       NextKey             bump x and read again

                    ldy       X1DA5
                    leay      -$08,y
                    sty       X1DA5
                    lbra      ReadKey

NextKey             leax      $01,x               bump x by one
                    lbra      ReadKey             read the next key press

IsBSP               cmpx      #$4265
                    lbeq      ReadKey
                    leax      -$01,x

                    ldb       #C$SPAC
*                            argument passed in b to this routine
                    jsr       X7477               some sort of copy routine ??
                    ldy       X1DA5
                    leay      -16,y
                    sty       X1DA5
                    lbra      ReadKey

EndKey              clr       X029C
                    puls      a,x,y,u,pc


IsEOF               ldb       #C$EOF
                    bra       EndKey

L087F               pshs      a,b
                    ldb       #'_                 $5F
*                            argument passed in b to this routine
                    jsr       X7477               some sort of copy routine ??

                    ldd       X1DA5
                    subd      #$08
                    std       X1DA5

                    puls      a,b,pc


*   Not explicitly called not labeled by disasm
MakeFile
N0891               pshs      a,b,x,y,u
                    lbsr      GetFile
                    cmpb      #C$EOF
                    lbeq      DontMake

* Delete File - Deletes a specified disk file
*
* entry:
*       x -> address of the path list
*
* exit:
*       x -> address of the last btye of the path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    ldx       #$4265              pointer to file name string
                    os9       I$Delete            delete file if exsits


* Create File - Creates and opens a disk file
*
* entry:
*       a -> access mode (write (2) or update (3))
*       b -> file attributes
*            Bit   Definition
*             0    Read
*             1    Write
*             2    Execute
*             3    Public Read
*             4    Public Write
*             5    Public Execute
*             6    Shareable file
*       x -> address of the path list
*
* exit:
*       a -> path number
*       x -> address of the last btye of the path list + 1
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

                    ldx       #$4265              pointer to file name string
                    ldd       #(WRITE.*$100)+READ.+WRITE.+PREAD.+PWRIT.+SHARE. $025B
                    os9       I$Create            create the file
                    bcs       CallErr             if error occured call error handler
                    sta       X1DD9               store the path number


* Write - Writes to a file or device
*
* entry:
*       a -> path number
*       x -> starting address of the data to write
*       y -> number of bytes to write
* exit:
*       y -> number of bytes written
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

*                            path still set from create call
                    ldx       #$0109              starting address of data
                    ldy       #$7E04              number of bytes to write
                    os9       I$Write             move the data
                    bcs       CallErr             if error occured call error handler
                    lbra      NoError

CallErr             lbsr      ErrMsg
NoError             lda       X1DD9               load the path number
                    os9       I$Close             close the file

DontMake
L08C8               inc       X0297
                    puls      a,b,x,y,u,pc


ReadNewFile
N08CD               pshs      a,b,x,y,u
                    lbsr      GetFile
                    cmpb      #C$EOF
                    lbeq      NoFile

                    ldu       X1D8B               we overwrite this below
                    pshs      u                   so we save it now

                    ldx       #$4265              address of path list
                    lda       #READ.              access mode
                    os9       I$Open              open the filr
                    bcs       CallEr2             if error occured call error handler
                    sta       X1DD9               stow the path number


* Get status  - Returns the status of a file or device
*               Wildcard call exit status differs based on cal code
* entry:
*       a -> path number
*       b -> function code 2 (SS.Size)
*
* exit:
*       x -> MS 16 bits of the current file size
*       u -> LS 16 bits of the current file size
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)
*

                    ldb       #SS.Size            get the curent file size
                    os9       I$GetStt            make the call
                    tfr       u,x                 move u to x but why ??
                    cmpu      #$7E04              check the file size
                    beq       Readfile            if it's the right size go read it
                    ldb       #E$Btyp             otherwise wrong type error
                    lbra      CallEr2

ReadFile
L08FC               lda       X1DD9               load the path num
                    ldx       #$0109              addr to stow data
                    ldy       #$7E04              bytes to read
                    os9       I$Read              make the call
                    bcs       CallEr2
                    lbra      NoErr
CallEr2             lbsr      ErrMsg

NoErr               puls      u                   get our old value
                    stu       X1D8B               and return it

                    ldx       #$1E25
                    stx       X1D89

                    lda       X1DD9               l   Looks like this gets overwriten too?
*                            $0109 + $7E04 = $7F0D
                    os9       I$Close             close the file
NoFile              inc       X0297
                    puls      a,b,x,y,u,pc

* b contains error code from calling routine
ErrMsg              pshs      a,b,x,y,u
                    ldx       #$0050
                    stx       X1DA5

                    ldx       #$0039
                    leax      16,x
                    stx       X1DA7

                    jsr       X72F3               this writes the strings?
                    fcc       "ERROR #"
                    fcb       C$NULL

                    pshs      b
                    clra
                    jsr       X7304               calcs a integer based on input in d

                    jsr       X72F3               this writes the strings?
                    fcc       " : "
                    fcb       C$NULL

                    puls      b
                    cmpb      #E$Btyp             bad type ??
                    bne       ChkBPth

                    jsr       X72F3               this writes the strings?
                    fcc       "WRONG FILE TYPE"
                    fcb       C$NULL
                    fcb       C$CLSALL            flag to skip # of bytes after next null
                    fcb       C$NULL
                    fcb       $54

ChkBPth             cmpb      #E$BPNam            bad path name
                    bne       ChkPNF
                    jsr       X72F3               this writes the strings?
                    fcc       "BAD PATHNAME"
                    fcb       C$NULL
                    fcb       C$CLSALL            flag to skip # of bytes after next null
                    fcb       C$NULL
                    fcb       $3D

ChkPNF              cmpb      #E$PNNF             path not found
                    bne       ChkDrv
                    jsr       X72F3               this writes the strings?
                    fcc       "FILE NOT FOUND"
                    fcb       C$NULL
                    fcb       C$CLSALL            flag to skip # of bytes after next null
                    fcb       C$NULL
                    fcb       $24

ChkDrv              cmpb      #E$Unit             Illegal drive num
                    blt       SomERR              none of the above and less than E$Unit
*                            E$Unit and greater yields disk error of some kind
                    jsr       X72F3               this writes the strings?
                    fcc       "DISK ERROR"
                    fcb       C$NULL
                    fcb       $20
                    fcb       $10                 this will skip over SomERR msg string

SomERR              jsr       X72F3               this writes the strings?
                    fcc       "SYSTEM ERROR"
                    fcb       C$NULL

                    ldx       X1DA7
                    leax      16,x
                    stx       X1DA7

                    ldx       #$0060
                    stx       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "Press any key to continue"
                    fcb       C$NULL

*       after a string write byte after second null sends to here
                    clra                          set stdin
                    ldx       #$1DDA              addr to save byte
                    ldy       #$01                only need one
                    os9       I$Read              get the input
                    puls      a,b,x,y,u,pc        we're done here return to caller


Zero_txt_area
L09F9               pshs      a,b,x,y,u
                    ldx       #$1E25              clears $2440 bytes
                    ldd       #$0000
ClrLoop             std       ,x++
                    cmpx      #$4265
                    blt       ClrLoop

                    ldd       #$0008
                    std       X1DA5

                    ldd       #$0002
                    std       X1DA7

                    puls      a,b,x,y,u,pc

Read_mission
L0A16               pshs      a,b,x,y,u
                    lbsr      Zero_txt_area       clear mission text area
                    leax      >Mis_txt,pcr        get the name of the file to open
                    lda       #READ.              in read only mode
                    os9       I$Open              open the file
                    sta       X1DD9               path number

                    ldu       #$4CB5              base addr
                    ldb       X0298               get value stored
                    lslb                          multiply by 2
                    tst       X4C76               check that game type byte
                    bne       L0A35               not target practice use this byte as offset
                    ldb       #$06                is target practice use a +6 offset
L0A35               ldu       b,u                 LS Word of file seek
                    ldx       #$0000              MS Word of file seek
                    lda       X1DD9               get the path number which should still be in a
                    os9       I$Seek              repostion file pointer

                    ldx       X1D8B
                    pshs      x
                    ldx       #$1E25
                    stx       X1D8B

L0A4B               ldx       #$4265              addr to stow the data
                    ldy       #$01                number of bytes to read
                    lda       X1DD9               load the path number
                    os9       I$Read              read one byte
                    ldb       X4265               put that byte in b
                    cmpb      #'@                 is it an @  $40
                    lbeq      L0A8D

                    cmpb      #'%                 is it a %   $25
                    lbeq      L0A8D

                    cmpb      #C$CR               is it a carriage return ?
                    beq       L0A74

                    cmpb      #C$LF               is it a line feed
                    beq       L0A7D

*                            argument passed in b to this routine
                    jsr       X7477               nope then some sort of copy routine ??
                    bra       L0A4B               loop again

L0A74               ldd       #$0008
                    std       X1DA5
                    lbra      L0A4B

L0A7D               ldx       X1DA7
                    leax      $08,x
                    cmpx      #$006B
                    bge       L0A74

                    stx       X1DA7
                    lbra      L0A4B

L0A8D               lda       X1DD9               get the path num and
                    os9       I$Close             close the file

                    puls      x
                    stx       X1D8B

                    bsr       SetandSwap

                    lbsr      MVMissn

                    puls      a,b,x,y,u,pc


SetandSwap
L0A9F               pshs      a,b,x,y,u
                    lda       #$FF
                    sta       X0297

                    lda       #$03
                    sta       X1D88

                    ldd       X1D8B
                    pshs      d

                    ldd       #$1E25
                    std       X1D8B

                    ldd       X1DAD
                    pshs      d

                    ldd       #$013F
                    std       X1DAD

                    ldd       #$0000
                    std       X1D8F
                    std       X1D91
                    std       X1D95

                    ldd       #$013F
                    std       X1D93
                    jsr       X7BF4
                    std       X1D93

                    ldd       #$0000
                    std       X1D8F

                    ldd       #$0073
                    std       X1D91
                    std       X1D95
                    jsr       X7BF4

                    ldd       #$0000
                    std       X1D8F
                    std       X1D91
                    std       X1D93

                    ldd       #$0073
                    std       X1D95
                    jsr       X7BF4
                    std       X1D95

                    ldd       #$013F
                    std       X1D8F
                    std       X1D93

                    ldd       #$0000
                    std       X1D91
                    jsr       X7BF4

                    puls      d,x
                    std       X1DAD
                    stx       X1D8B

                    ldx       #$1E25              address 1
                    ldu       X1D8B               address 2
                    ldy       #$2440              number of bytes to swap
L0B27               ldb       ,x                  get a byte from each
                    lda       ,u
                    stb       ,u+                 swap them and bump pointers
                    sta       ,x+
                    leay      -$01,y              decrement the counter
                    bne       L0B27               loop till we are finished

                    puls      a,b,x,y,u,pc


MVMissn             pshs      a,b,x,y,u
                    clra                          stdin path
                    ldx       #$4265              address to save data
                    ldy       #$01                bytes to read
                    os9       I$Read              read byte

                    ldu       X1D8B               get save address
                    ldx       #$1E25              get from address
MVLoop              ldd       ,x++                load a word from x and bump by a word
                    std       ,u++                stow that word at u and bump by a word
                    cmpx      #$4265              have we gotten to the end ??
                    blt       MVLoop              nope loop again

                    puls      a,b,x,y,u,pc


*   Not explicitly called not labeled by disasm
*   similar to Read_mission at L0A16
Read_mission2
N0B53               pshs      a,b,x,y,u
                    lda       #$FF
                    sta       X0297

                    clr       X4D3E

                    ldx       #$1E25              clear the bytes between $1E25 - $4265
                    ldd       #$0000
L0B63               std       ,x++
                    cmpx      #$4265
                    blt       L0B63

                    lbsr      SetandSwap          so now we swap the cleared bytes

                    ldd       #$0008
                    std       X1DA5

                    ldd       #$0002
                    std       X1DA7

                    leax      >Mis_txt,pcr
                    lda       #READ.
                    os9       I$Open
                    sta       X1DD9               save path num

                    ldu       #$4CB5              base address
                    ldb       X0298               get stored value
                    lslb                          multiply by two
                    tst       X4C76               check that game type byte
                    bne       L0B93               not target practice use this value
                    ldb       #$06                otherwise is target practice use a +6 offset
L0B93               ldu       b,u                 LS word of file position to seek
                    ldx       #$0000              MS word of file positioin to seek
                    lda       X1DD9               get the path num that is still in a
                    os9       I$Seek              reset the file pointer

L0B9E               ldx       #$4265              addr to stow data
                    ldy       #$01                get one byte
                    lda       X1DD9               get that path numm that's already there
                    os9       I$Read              read a byte

                    ldb       X4265               load it in b
                    cmpb      #'@                 is it an @ $40
                    lbeq      ClsMisTx

                    cmpb      #'%                 is it a %  $25
                    lbeq      ClsMisTx

                    cmpb      #C$CR
                    beq       L0BD5

                    cmpb      #C$LF
                    beq       L0BDE

                    tst       X4D3E
                    bne       L0BD0

                    lbsr      InpReady
                    sta       X4D3E

                    lbsr      MCode

*                            argument passed in b to this routine
L0BD0               jsr       X7477               some sort of copy routine ??
                    bra       L0B9E               loop again

L0BD5               ldd       #$0008
                    std       X1DA5
                    lbra      L0B9E               loop again

L0BDE               ldx       X1DA7
                    leax      $08,x
                    cmpx      #$006B
                    bge       L0BD5
                    stx       X1DA7
                    lbra      L0B9E               loop again

ClsMisTx
L0BEE               lda       X1DD9
                    os9       I$Close
                    lbsr      MVMissn
                    puls      a,b,x,y,u,pc

InpReady
L0BF9               pshs      b,x,y
                    clra                          set path stdin
                    ldb       #SS.Ready           test if data available
                    os9       I$GetStt            make the call
                    bcc       ReadKey2            if ready go read it
                    clra                          not read clear a again
                    puls      b,x,y,pc            pull b back over any error code

ReadKey2
L0C06               clra                          set path stdin
                    ldx       #$1DDA              set address to hold data
                    ldy       #$01                read one byte
                    os9       I$Read              make the call
                    lda       X1DDA               load the data in a
                    cmpa      #C$INTR             is it a key board interrupt (ctrl-C)
                    beq       EndKey2
                    cmpa      #C$QUIT             is it a keyboard abort (ctrl-E)
                    beq       EndKey2
                    tst       X029C
                    bne       EndKey2
                    puls      b,x,y,pc


EndKey2
L0C23               clr       X029C
                    lda       #C$EOF
                    puls      b,x,y,pc


Set_75
L0C2A               pshs      a,b,x,y,u
                    ldy       #$0075              number of bytes to set
                    ldx       #$42B5              base address
                    lda       #$FF                value to set them to
Loop75              fdb       Zsta_x              sta ,x
                    leax      $15,x               bump x by $15
                    leay      -$01,y              decrement the counter
                    lbne      Loop75              are we done ? nope loop again
                    puls      a,b,x,y,u,pc


GetControl1
L0C42               pshs      a,b,x,y,u

                    lda       #READ.
                    leax      >Control1,pcr
                    os9       I$Open

                    ldx       #CntrlDat           address to store
                    ldy       #CntrlSz            bytes to read
                    os9       I$Read

                    os9       I$Close             close the file

                    ldx       #CntrlDat
                    ldy       #CntrlSz
                    ldu       X1D8B
                    lbsr      Decode_copy

                    ldd       #$0109              PRN,CTN
                    jsr       X735B               call Change palette

                    ldd       #$0236              PRN,CTN
                    jsr       X735B               call Change palette

                    lda       #$03
                    sta       X1D88

                    ldx       X1D8B
                    stx       X1D89

                    clra                          make a zero
GCloop              pshs      a                   push it on the stack for a counter
                    ldx       #$0020              huh ?
                    leax      -$0C,x
                    stx       X1DA5               stow that

                    leax      >ByteTbl1,pcr
                    ldb       a,x
                    clra                          make a zero again  (still)
                    addd      #$04                add four to value loaded from ByteTbl1
                    std       X1DA7

                    jsr       X72F3               this writes the strings?
                    fcc       "000"
                    fcb       C$NULL

                    puls      a                   pull our counter
                    inca                          bump it
                    cmpa      #Tbl1sz             made 4 loops ??
                    bne       GCloop              nope go again

                    clra                          clear a
                    leax      >ByteTbl1,pcr
                    ldy       #$02A7

GClop2              pshs      a
                    ldb       #C$SPAC
                    stb       $08,y               save it once
                    stb       ,y+                 save it twice
                    ldb       ,x+                 get the ByteTbl1 byte and bump pointer
                    subb      #$14                subtract $14
                    stb       $08,y
                    stb       ,y+
                    puls      a
                    inca
                    cmpa      #Tbl1sz
                    bne       GClop2

                    ldd       #$0000
                    std       X4CFD
                    std       X4CF9
                    std       X4CFB
                    std       X4CF7
                    std       X4CF5
                    std       X4CF1
                    std       X4CF3
                    std       X4CEF

                    lbsr      SetandJsr1
                    lbsr      SetandJsr2
                    lbsr      SetandJsr3
                    lbsr      SetandJsr4

                    jsr       X7843

                    jsr       X7866

                    lda       #$FF
                    sta       X4D28

                    lda       #READ.
                    leax      >Diesel,pcr
                    os9       I$Open

                    sta       X1DD9               stow the path number
                    ldx       #$0000              MS 16 bits of file pos
                    ldu       #$0072              LS 16 bits of file pos
                    os9       I$Seek              move file pointer

                    ldd       X1D8B               start with some value
                    addd      #$2D63              add a big offset to it
                    tfr       d,x                 move it to x in  prep for the read

                    ldb       #$08                Loop counter
DRloop              pshs      b,x                 push em

                    lda       X1DD9               get the path num
                    ldy       #$000C              read 12 bytes
                    os9       I$Read              copy the bytes

                    puls      b,x                 get the counter and orig destination addr
                    leax      $50,x               bump it by 80
                    decb                          dec the counter
                    bne       DRloop              go again if not zero

                    lda       X1DD9               get the path num
                    os9       I$Close             close the file

                    puls      a,b,x,y,u,pc


Diesel
L0D31               fcc       "sub/diesel.dat"
                    fcb       C$NULL

SetandJsr1
L0D40               pshs      a,b,x,y,u
                    ldd       #$0092
                    std       X1DA7

                    ldd       #$00C8
                    std       X1DA5

                    ldb       X4D11
                    jsr       X782E               2 place formatted output

                    puls      a,b,x,y,u,pc

SetandJsr2
L0D56               pshs      a,b,x,y,u
                    ldd       #$00A2
                    std       X1DA7

                    ldd       #$00C8
                    std       X1DA5

                    ldb       X4D12
                    jsr       X782E               2 place formatted output
                    puls      a,b,x,y,u,pc


* Decodes ??? and copies data
*  x -> from address
*  u -> to address
Decode_copy
L0D6C               pshs      a,b,x,y,u

Decotr              lda       ,x+
                    bpl       Declp2
                    anda      #$7F
                    leay      -1,y
                    ldb       ,x+

Declp1              stb       ,u+
                    deca
                    bne       Declp1

                    bra       Dectr1

Declp2              ldb       ,x+
                    stb       ,u+
                    leay      -1,y
                    deca
                    bne       Declp2
Dectr1              leay      -1,y
                    bne       Decotr

                    puls      a,b,x,y,u,pc

SetandJsr3
L0D8E               pshs      a,b,x,y,u
                    ldd       #$00B2
                    std       X1DA7

                    ldd       #$00C8
                    std       X1DA5

                    ldb       X4D13
                    jsr       X782E               2 place formatted output
                    puls      a,b,x,y,u,pc


SetandJsr4
L0DA4               pshs      a,b,x,y,u
                    ldd       #$0092
                    std       X1DA7

                    ldd       #$0112
                    std       X1DA5

                    clra

                    ldb       X1E1D
                    leax      >ByteTblE,pcr
                    ldb       b,x
                    jsr       X782E               2 place formatted output

                    ldx       #$0128
                    stx       X1DA5

                    leax      >ByteTblD,pcr
                    ldb       X1E1D
                    ldb       b,x
*                            argument passed in b to this routine
                    jsr       X7477               some sort of copy routine ??

                    puls      a,b,x,y,u,pc


ByteTblD
L0DD3               fcb       $53,$53,$53,$4D,$48 SSSMH


ByteTblE
L0DD8               fcb       $01,$05,$1E,$0A,$04



* Get Status - Returns the status of a file or device
* entry:
*       a -> path number
*       b -> SS.Opt (function code 00)
*            Reads the option section of the path descriptor,
*            copies it to the 32 byte area pointed to by x
*       x -> address to receive data packet
*
* error:
*       CC -> Carry set on error
*       b  -> error code (if any)

GetOpts
L0DDD               pshs      a,b,x,y
                    ldd       #(StdOut*$100)+SS.Opt
                    ldx       #$4265
                    pshs      x                   unneeded
                    os9       I$GetStt
                    puls      x                   unneeded
                    lda       $04,x               IT.EKO
                    sta       X1D49               save orig
                    clr       $04,x               set it to NO echo
                    lda       $07,x               IT.PAU
                    sta       X1D4A               save orig value
                    clr       $07,x               set it to NO pause

                    ldd       #(StdOut*$100)+SS.Opt

                    os9       I$SetStt            reset them
                    puls      a,b,x,y,pc


XmtSOS
N0E02               tst       X4D2E
                    beq       SendSOS
                    jsr       X72C3
                    fcc       "The radio is out, Sir"
                    fcb       C$NULL
                    rts

SendSOS
L0E21               jsr       X72C3
                    fcc       "Sending S.O.S., Sir"
                    fcb       C$NULL

                    ldb       #'S
                    lbsr      MCode

                    ldb       #'O
                    lbsr      MCode

                    ldb       #'S
                    lbsr      MCode

                    ldb       #$FF
                    stb       X4C83
                    rts

XmtPOS
N0E4D               tst       X4D2E
                    beq       SendPOS
                    jsr       X72C3
                    fcc       "The radio is out, Sir"
                    fcb       C$NULL
                    rts

SendPOS
L0E6C               jsr       X72C3
                    fcc       "Radioing position, Sir"
                    fcb       C$NULL

                    ldb       X4C84
                    jsr       X7691
                    lbsr      MCode

                    jsr       X7691
                    lbsr      MCode

                    jsr       X7691
                    lbsr      MCode

                    ldb       X4C87
                    jsr       X7691
                    lbsr      MCode

                    jsr       X7691
                    lbsr      MCode

                    jsr       X7691
                    lbsr      MCode


                    ldb       #'E                 cute litte Easter Egg :-)
                    lbsr      MCode

                    ldb       #'P
                    lbsr      MCode

                    ldb       #'Y
                    lbsr      MCode

                    ldb       #'X
                    lbsr      MCode

                    ldb       #$FF
                    stb       X4C83
                    rts


* Set Status - Sets the status of a file or device
* entry:
*       a -> path number
*       b -> SS.Tone (function code 98) Sound through termional output device
*       x -> duration and amplitude of the tone
*            LSB duration in ticks (60 sec) in the range of 0-255
*            MSB amplitude of the tone in the range of 0-63
*       y -> relative frequency counter (0 = low, 4095 = high)
* exit:
*       Same as entry
* error:
*       There are no error conditions set
*
*  Therefore duration and amplitude passed in accd
*                           freq is passed in y

SoundGen
L0ECA               pshs      a,b,x,y,u
                    tfr       d,x
                    ldd       #(StdOut*$100)+SS.Tone
                    os9       I$SetStt
                    puls      a,b,x,y,u,pc

* Looks like a morse code generator based on character input
MCode
L0ED6               pshs      a,b,x,y,u
                    cmpb      #C$SPAC
                    bne       L0EED               not a space process more
                    lbsr      TimeDly1            otherwise appropriate dead time
                    lbsr      TimeDly1
                    lbsr      TimeDly1
                    lbsr      TimeDly1
                    lbsr      TimeDly1
ExtMCode
                    puls      a,b,x,y,u,pc



L0EED               cmpb      #''                 is it a tick $27
                    blt       ExtMcode
                    cmpb      #'a
                    blt       L0EF7               whats wrong with this logic?
                    subb      #$20                make upper case
L0EF7               cmpb      #'z                 this should have been Uppercase Z
*                            can't be less than a but greater than z
                    bgt       ExtMCode
                    subb      #$27                now we subtract the position of the '
*                            to be zero based in the table
                    leax      >ByteTbl2,pcr
                    ldb       b,x
                    lda       #$08

L0F05               deca
                    lslb
                    bcc       L0F05

Sndloop             lslb
                    bcc       L0F20
                    pshs      a,b
                    ldd       #$3F04              setup sound amplitude/duration
                    tfr       d,x                 move it to x where it should have been
                    ldy       #$0FD7              load the freq value
                    lbsr      SoundGen            make the noise
                    bsr       TimeDly1
                    puls      a,b
                    bra       Sndcntr

L0F20               pshs      a,b
                    ldd       #$3F0C              setup sound amplitude/duration
                    tfr       d,x                 move that to x where it should have been in the first place
                    ldy       #$0FD7              load with freq value
                    lbsr      SoundGen            make the noise
                    bsr       TimeDly1
                    puls      a,b

Sndcntr             deca
                    bne       Sndloop

                    bsr       TimeDly1
                    bsr       TimeDly1
                    bsr       TimeDly1
                    puls      a,b,x,y,u,pc


TimeDly1
L0F3D               pshs      x
                    ldx       #$2710
TD1loop             leax      -1,x
                    bne       TD1Loop
                    puls      x
                    rts

* caller passes a pointer to string data in x
MenuSelect
L0F49               pshs      a,y,u
                    ldd       #$0000
                    std       X1DB9

                    jsr       X77E5

                    ldu       X1D8B
                    pshs      u

                    ldu       #$1E25
                    stu       X1D8B
                    stu       X1D89

                    ldy       #$0006
                    sty       X1DA7

                    ldy       #$0030
                    sty       X1DA5

                    ldb       ,x+
                    pshs      b
                    pshs      b
                    jsr       X74CC

                    lbsr      L0FC3
                    lbsr      L0FC3

L0F81               jsr       X74CC
                    lbsr      L0FC3
                    dec       ,s
                    bne       L0F81

                    puls      a,b,u
                    stu       X1D8B

                    ldu       #$1E25
                    stu       X1D89

                    jsr       X7747

                    addb      #$30
                    pshs      b

ChkInp              lbsr      InpReady
                    tsta                          not ready a = 0
                    beq       ChkInp              loop till we get an input

                    tfr       a,b                 move the returned value to b
                    clra
                    cmpb      #C$CR
                    beq       L0FBA

                    cmpb      #C$EOF
                    beq       L0FBD

                    cmpb      #'1                 Looking for input 1 - 7 max depending on menu
                    blt       ChkInp              less than 1 loop again

                    cmpb      ,s
                    bgt       ChkInp

                    subb      #'1                 subtract "one" ($31) from it so we are now zero based
                    bra       L0FBF

L0FBA               clrb
                    bra       L0FBF

L0FBD               ldb       #$FF
L0FBF               leas      $01,s
                    puls      a,y,u,pc


L0FC3               ldy       #$0030
                    sty       X1DA5

                    ldy       X1DA7
                    leay      $0C,y
                    sty       X1DA7
                    rts


GameSetup
N0FD6               pshs      a,b,x,y,u
                    lda       X4C75               current side
                    sta       X4D3C               new side value

                    lda       X1E16               current year value
                    sta       X4D3D               new year value

                    ldd       #$0000              make room for 4 items
                    pshs      d
                    pshs      d

                    leax      >GameType,pcr
                    lbsr      MenuSelect
                    tstb
                    lbmi      Ex_GS               minus value returned were outa here
                    cmpb      #$00                1 was selected (target practice)
                    lbeq      CaptName            go prompt for capt name
                    stb       ,s                  push value on the stack

                    leax      >GameLev,pcr
                    lbsr      MenuSelect
                    tstb
                    lbmi      Ex_GS               minus value returned were outa here
                    stb       $03,s               push that value on the stack

                    leax      >SideChoose,pcr
                    lbsr      MenuSelect
                    tstb
                    lbmi      Ex_GS               minus value returned were outa here
                    stb       $01,s               push that on the stack

                    lda       ,s                  get the game type from stack
                    cmpa      #$02                3 selected War time command ?
                    beq       WTCmnd

                    cmpb      #$01                check side American ?
                    beq       USAin
                    leax      >YearChoose,pcr
                    bra       YrSel
USAin               leax      >YearChoose2,pcr
YrSel               lbsr      MenuSelect
                    tstb
                    lbmi      Ex_GS               minus value returned were outa here
                    stb       $02,s               push on stack
                    bra       CaptName

WTCmnd
L103B               clr       $02,s               clear the year value
                    pshs      a                   push game type
                    cmpb      #$01                check side American ?
                    beq       Ameri
                    lda       #$FF                German
                    sta       X02A3               side vlaue
                    bra       L104F
Ameri               lda       #$23                American
                    sta       X02A3               side value
L104F               puls      a

CaptName
L1051               ldd       #$0000
                    jsr       X77E5
                    jsr       X7747

                    ldd       #$0039
                    std       X1DA7

                    ldd       #$0050
                    std       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "Enter Captain's Name: "
                    fcb       C$NULL
                    fcb       $CC
                    fcb       C$NULL
                    fcb       $45

                    std       X1DA7

                    ldd       #$0056
                    std       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "->"
                    fcb       C$NULL

*       copies in the current captains name
                    ldx       #$4265              destination address
                    ldy       #$0335              source address
                    lda       #$19                bytes to read
L109B               ldb       ,y+                 get the byte
                    beq       L10A4               if we find a zero exit loop
                    stb       ,x+                 not zero move the data
                    deca                          decrement the loop counter
                    bne       L109B               loop till done

L10A4               clr       ,x                  clear the byte at x
                    lbsr      GetKBinp            get keyboard input
                    cmpb      #C$EOF
                    lbeq      Ex_GS

                    lda       X4265               base address of keyboard input
                    cmpa      #C$CR               a carriage return ?
                    bne       HaveNam             anything else must be a name
                    leax      >Nameless,pcr       was a CR no name chosen
                    bra       CopyNam
HaveNam             ldx       #$4265              set base address for name string
CopyNam             lda       #$19                max bytes to copy
                    ldy       #$0335              captains name storage
Cpy2Nam             ldb       ,x+                 get byte
                    cmpb      #C$CR               is it a carriage return?
                    beq       NMDone              if so were done
                    stb       ,y+                 otherwise move the byte
                    deca                          dec the counter
                    bne       Cpy2Nam


NMDone              clr       ,y

                    puls      a,b
                    sta       X4C76               game type
                    stb       X4C75               side
                    puls      a                   year
                    cmpb      #$00                test side German ?
                    beq       GRyear

USyear              adda      #42                 US first year
                    bra       SavYear

GRyear              adda      #39                 German first year
SavYear             sta       X1E16               save the year value

                    puls      a
                    sta       X4C77               game level

                    lda       #$03
                    sta       X05CE

                    ldd       #$0000
                    std       X04F0
                    std       X04F2
                    std       X04F4
                    std       X04F5
                    std       X029A

                    clr       X04F7
                    clr       X04F8
                    clr       X04F9
                    clr       X04FA
                    clr       X04FB
                    clr       X04FC
                    clr       X04FD
                    clr       X04FE
                    clr       X04FF

                    lbsr      GetMisDat
                    lbsr      GetSubStat
                    lbsr      GetShipmap
                    lbsr      GetMap
                    lbsr      GetConvoy
                    lbsr      SetParams
                    lbsr      GetControl1
                    lbsr      SetMorePars

                    lda       X4C76               test the game type value
                    cmpa      #$02                is it war time command ?
                    lbne      GetMission          no then get your mission

                    ldd       #$0000
                    jsr       X77E5

                    ldu       X1D8B
                    pshs      u
                    ldu       #$1E25
                    stu       X1D8B

                    ldy       #$0029
                    sty       X1DA7

                    ldy       #$0010
                    sty       X1DA5

                    tst       X4C75               test side value 0 = German 1 = US
                    bne       ImUSA

                    jsr       X72F3               this writes the strings?
                    fcc       "It is the year 1939, and"
                    fcb       C$NULL

                    ldy       #$0032
                    sty       X1DA7

                    ldy       #$0010
                    sty       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "Germany has started"
                    fcb       C$NULL
                    fcb       C$CLSALL            flag to skip # of bytes after next null
                    fcb       C$NULL
                    fcb       $4D                 bytes to skip (US opening message)

ImUSA               jsr       X72F3               this writes the strings?
                    fcc       "It is the year 1942, and the"
                    fcb       C$NULL

                    ldy       #$0032
                    sty       X1DA7

                    ldy       #$0010
                    sty       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "United States has entered"
                    fcb       C$NULL
*                            ends up here at the null after germay started string

                    ldy       #$003A
                    sty       X1DA7

                    ldy       #$0010
                    sty       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "World War II."
                    fcb       C$NULL

                    ldx       #$0063
                    stx       X1DA7

                    ldx       #$0048
                    stx       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "Press any key"
                    fcb       C$NULL

                    puls      u
                    stu       X1D8B
                    jsr       X7747


                    clra                          set path to StdIn
                    ldx       #$1DDA              place to store input
                    ldy       #1                  get one byte
                    os9       I$Read              go fetch it

GetMission
L124B               lbsr      Read_Mission
                    puls      a,b,x,y,u,pc

Ex_GS
L1250               leas      $04,s               clean up the stack
                    puls      a,b,x,y,u,pc



Return2Sea
N1254               pshs      a,b,x,y,u
                    ldd       #$0000
                    std       X029A

                    clr       X04FA
                    clr       X04FB
                    clr       X04FC
                    clr       X04FD
                    clr       X04FE
                    clr       X04FF

                    lda       #$03
                    sta       X05CE

                    ldx       X1E17
                    ldb       X1E16               year value
                    pshs      b,x

                    lbsr      GetMisDat
                    lbsr      GetSubStat
                    lbsr      GetShipmap
                    lbsr      GetMap
                    lbsr      GetConvoy
                    lbsr      SetParams
                    lbsr      GetControl1
                    lbsr      SetMorePars
                    lbsr      Zero_txt_area

                    ldx       #$0029
                    stx       X1DA7

                    ldx       #$0038
                    stx       X1DA5

                    ldy       X1D8B

                    ldu       #$1E25
                    stu       X1D8B

                    ldx       X1E17
                    ldb       X1E16               year value
                    cmpb      ,s+
                    beq       L12BA
                    leax      365,x
L12BA               tfr       x,d
                    subd      ,s++
                    cmpd      #1
                    bge       L12C7
                    ldd       #1

L12C7               jsr       X72F3               this writes the strings?
                    fcc       "After a leave of "
                    fcb       C$NULL

                    jsr       X7304               calcs a integer based on input passed in d

                    jsr       X72F3               this writes the strings?
                    fcc       " days,"
                    fcb       C$NULL

                    ldx       X1DA7
                    leax      9,x
                    stx       X1DA7

                    ldd       #$0038
                    std       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "you get a new mission."
                    fcb       C$NULL

                    ldx       #$0063
                    stx       X1DA7

                    ldx       #$0068
                    stx       X1DA5

                    jsr       X72F3               this writes the strings?
                    fcc       "Press any key"
                    fcb       C$NULL

                    sty       X1D8B

                    lbsr      SetandSwap
                    lbsr      MVMissn
                    lbsr      Read_Mission
                    puls      a,b,x,y,u,pc


GameType
L133D               fcb       $03                 seems to flag number of choices
                    fcc       " SELECT GAME TYPE"
                    fcb       C$NULL
                    fcc       "1. Target practice"
                    fcb       C$NULL
                    fcc       "2. Single mission"
                    fcb       C$NULL
                    fcc       "3. Wartime command"
                    fcb       C$NULL

GameLev
L1388               fcb       $04                 seems to flag number of choices
                    fcc       " SELECT GAME LEVEL"
                    fcb       C$NULL
                    fcc       "1. Novice"
                    fcb       C$NULL
                    fcc       "2. Intermediate"
                    fcb       C$NULL
                    fcc       "3. Advanced"
                    fcb       C$NULL
                    fcc       "4. Expert"
                    fcb       C$NULL


SideChoose
L13CC               fcb       $02                 seems to flag number of choices
                    fcc       "  CHOOSE A SIDE"
                    fcb       C$NULL
                    fcc       "1. German"
                    fcb       C$NULL
                    fcc       "2. American"
                    fcb       C$NULL


YearChoose
L13F3               fcb       $07                 seems to flag number of choices
                    fcc       "  CHOOSE A YEAR"
                    fcb       C$NULL
                    fcc       "1. 1939"
                    fcb       C$NULL
                    fcc       "2. 1940"
                    fcb       C$NULL
                    fcc       "3. 1941"
                    fcb       C$NULL
                    fcc       "4. 1942"
                    fcb       C$NULL
                    fcc       "5. 1943"
                    fcb       C$NULL
                    fcc       "6. 1944"
                    fcb       C$NULL
                    fcc       "7. 1945"
                    fcb       C$NULL


YearChoose2
L143C               fcb       $04                 seems to flag number of choices
                    fcc       "  CHOOSE A YEAR"
                    fcb       C$NULL
                    fcc       "1. 1942"
                    fcb       C$NULL
                    fcc       "2. 1943"
                    fcb       C$NULL
                    fcc       "3. 1944"
                    fcb       C$NULL
                    fcc       "4. 1945"
                    fcb       C$NULL



TransferTorp
N146D               pshs      a,b,x,y,u
                    leax      >TorpTrans,pcr
                    lbsr      MenuSelect
                    stb       X0291
                    inc       X0297
                    puls      a,b,x,y,u,pc


TorpTrans
L147E               fcb       $02                 seems to flag number of choices
                    fcc       "  TRANSFER A TORPEDO"
                    fcb       C$NULL
                    fcc       "1. Forward to Aft"
                    fcb       C$NULL
                    fcc       "2. Aft to Forward"
                    fcb       C$NULL


ByteTblF
L14B8               fcb       $04,$05,$06,$07,$00,$01
                    fcb       $02,$03


Convoys
L14C0               fcc       "sub/convoys.dat"
                    fcb       C$CR


Mis_dat
L14D0               fcc       "sub/missions.dat"
                    fcb       C$CR


Mis_txt
L14E1               fcc       "sub/mission.txt"
                    fcb       C$CR


SubStat
L14F1               fcc       "sub/substats.dat"
                    fcb       C$CR


Font
L1502               fcc       "sub/fonts.dat"
                    fcb       C$CR


Shipmap
L1510               fcc       "sub/shipmap2.dat"
                    fcb       C$CR


Invert
                    fcc       "sub/invert.pic"    had no disasm generated label
                    fcb       C$CR


Control1
L1530               fcc       "sub/control1.cmp"
                    fcb       C$CR


Germap
L1541               fcc       "sub/germap.cmp"
                    fcb       C$CR


USAmap
L1550               fcc       "sub/usamap.cmp"
                    fcb       C$CR


ByteTbl1
L155F               fcb       $18,$49,$78,$A8
Tbl1sz              equ       *-ByteTbl1

ByteTbl2
L1563               fcb       $61,$52,$52,$73,$73,$4C
                    fcb       $5E,$6A,$2D,$20,$30,$38
                    fcb       $3C,$3E,$3F,$2F,$27,$23
                    fcb       $21,$47,$55,$73,$73,$73
                    fcb       $73,$73,$06,$17,$15,$0B
                    fcb       $03,$1D,$09,$1F,$07,$18
                    fcb       $0A,$1B,$04,$05,$08,$19
                    fcb       $12,$0D,$0F,$02,$0E,$1E
                    fcb       $0C,$16,$14,$13


ByteTbl3
L1597               fcb       $01,$72,$40,$00,$45,$FD
                    fcb       $E8,$00,$14,$00,$7E,$00
                    fcb       $00,$37,$40,$00,$FF,$14
                    fcb       $00,$75,$00,$00,$73,$00
                    fcb       $00,$FF,$1E,$00,$75,$00
                    fcb       $00,$73,$00,$00,$FF,$24
                    fcb       $00,$77,$17,$B4,$56,$2F
                    fcb       $68,$FF,$24,$00,$77,$F5
                    fcb       $CB,$56,$18,$92,$FF,$28
                    fcb       $00,$5F,$00,$00,$55,$00
                    fcb       $00,$FF,$18,$00,$60,$00
                    fcb       $00,$55,$00,$00,$FF,$1E


ByteTbl4
L15DF               fcb       $00,$00,$00,$1F,$00,$3B
                    fcb       $00,$5A,$00,$78,$00,$97
                    fcb       $00,$B5,$00,$D4,$00,$F3
                    fcb       $01,$11,$01,$30,$01,$4E
                    fcb       $01,$6D


Nameless
L15F9               fcc       "Nameless"
                    fcb       C$CR

SinTbl
L1602               fcc       "sub/sintbl.dat"
                    fcb       C$CR

                    emod
eom
L1614               equ       *
                    end
