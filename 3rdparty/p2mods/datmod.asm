* F$DatMod
*
* Entry:
*     A = Type/Language
*     B = Attr/Rev
*     X = address of name
*     Y = size
*
* Exit:
*     X = address of last byte of name + 1
*     Y = module entry point address
*     U = module header address

Level               equ       1

                    ifp1
                    use       defsfile
                    endc

Type                set       Prgrm+Objct
Revs                set       ReEnt+1
edition             set       $01

                    mod       eom,name,Type,Revs,start,256

name                fcs       "DatMod"
                    fcb       $01

* routine cold
start               clra
                    leax      name,pcr
                    os9       F$Link
                    bcs       error
                    leay      SvcTbl,pcr
                    os9       F$SSvc
                    clrb
error               os9       F$Exit

F$DatMod            equ       $25

SvcTbl              equ       *
                    fcb       F$DatMod
                    fdb       DatMod-*-2
                    fcb       $80

s.namlen            equ       0
s.nextnm            equ       2
s.modptr            equ       6
s.size              equ       8

DatMod
                    leas      -s.size,s

* First, parse the name
                    ldx       R$X,u               get the name of the module
                    os9       F$PrsNam            parse it: TODO /x/x crashes machine!
                    lbcs      DatModEr
                    sty       s.nextnm,s          save updated name pointer
                    tfr       y,d                 get ptr to last char + 1 into D
                    subd      R$X,u               get length of name in D
                    std       s.namlen,s          save name length for later
                    addd      R$Y,u               add name length to caller's specified size
                    addd      #M$IDSize+3         add module header size and CRC
                    pshs      u
                    os9       F$SRqMem            ask system for this memory
                    stu       s.modptr+2,s        else save pointer to module
                    puls      u
                    lbcs      DatModEr            branch if error
                    ldy       s.modptr,s          get module pointer into Y

* We have the memory for the Data Module, now populate it
                    std       M$Size,y            save size in module
                    ldd       #M$ID12             get module ID bytes
                    std       M$ID,y              save in module
                    ldd       R$D,u               get passed type/lang and attr/rev
                    bita      #TypeMask           is type zero?
                    bne       StoreIt             branch if not...
                    anda      #Data               else force type to be data
StoreIt             std       M$Type,y            and save in module
                    ldd       M$Size,y            get module ptr's size
                    subd      s.namlen,s          subtract name's length from size
                    subd      #3                  and CRC
                    std       M$Name,y            and save pointer to it in module header

* Compute header parity
                    pshs      d                   save D (holds offset to name from within module)

                    ldd       #M$IDSize-1
                    pshs      b
                    clrb
EorLoop             eora      b,y
                    incb
                    cmpb      ,s
                    bne       EorLoop
                    puls      b
                    coma
                    sta       M$Parity,y          save parity byte

* Copy name from caller's X to data module
                    ldx       R$X,u               point to caller's passed name
                    puls      d                   get name ptr in module into D
                    addd      s.modptr,s          add absolute address of module
                    tfr       d,y                 and put in Y
                    ldb       s.namlen+1,s        get length of name
CpyLoop             lda       ,x+                 get char
                    sta       ,y+                 put char
                    decb                          decrement counter
                    bne       CpyLoop
                    ora       #$80                set high bit of last character we got
                    sta       -1,y                and put it back in module

* Initialize CRC with constant $FFFFFF
                    ldd       #$FFFF              get CRC initializer
                    std       ,y                  and store
                    sta       2,y

* Compute CRC and validate Module
                    pshs      u
                    tfr       y,u                 U now holds pointer to CRC
                    ldx       s.modptr+2,s        get pointer to module
                    ldy       M$Size,x            get module size
                    leay      -3,y                subtract CRC length
                    os9       F$CRC               update CRC
                    ldd       ,u                  get 1st two bytes of CRC
                    coma                          complement them
                    comb
                    std       ,u                  save them back
                    lda       2,u                 get third byte of CRC
                    coma                          complement them
                    sta       2,u                 save it back
                    os9       F$VModul            and validate module
                    puls      u
                    bcc       DatModOk            branch if all ok
                    pshs      cc,b                preserve error info
                    ldd       M$Size,s            get module size alloced from stack
                    tfr       x,u                 put module ptr from X to U
                    os9       F$SRtMem            return memory
                    puls      b,cc                get error info
                    bra       DatModEr            and exit

* Put return info in caller's regs
DatModOk            ldx       s.nextnm,s          get pointer to char after name
                    stx       R$X,u               save it in caller's X
                    ldx       s.modptr,s          get module pointer
                    stx       R$U,u               save it in caller's U
                    leax      M$IDSize,x          get entry point
                    stx       R$Y,u               save it in caller's Y

DatModEr            leas      s.size,s
                    rts

                    emod
eom                 equ       *
                    end
