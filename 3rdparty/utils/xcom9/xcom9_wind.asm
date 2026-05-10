WinOpChr equ   *               Window open characters
         fcb   $1B
         fcb   $22
LWinOp   equ   *-WinOpChr
OpenWin
         leas  -9,s
         stb   2,s             Save switch
         stx   3,s             Start of window
         sty   5,s             Size of window
         cmpa  #1              Inverse?
         bne   NormWin         No
         lda   #2              Foreground color
         sta   7,s
         lda   #5              Background color
         sta   8,s
         bra   WinCopy
NormWin
         lda   #0              Foreground color
         sta   7,s
         lda   #1              Background color
         sta   8,s
WinCopy
         leax  WinOpChr,PCR
         lda   ,x              Copy codes to work area
         sta   ,s
         lda   1,x
         sta   1,s
         lda   #stdout
         ldb   #SS.ScSiz
         OS9   I$GetStt
         cmpx  #80             80 column screen?
         beq   widthok
         clra
         sta   3,s             Set starting x coord=0
         lda   5,s             Get x size
         pshs  x
         cmpa  1,s             <=max?
         puls  x
         bls   widthok
         tfr   x,d
         stb   5,s             Set x size to max
         lda   6,s             Get y size
         cmpa  #2              <=2?
         bhi   widthok
         inca
         sta   6,s
widthok
         lda   4,s
         pshs  y
         cmpa  1,s
         puls  y
         bls   lengok
         tfr   y,d
         stb   4,s
lengok
         leax  ,s              Point x at start of string
         ldy   #9              Load y with length
         lda   #stdout
         OS9   I$Write         Open the window
         leas  9,s             Remove buffer from stack
         rts

WinClChr equ   *               Window close characters
         fcb   $1B
         fcb   $23
LWinCl   equ   *-WinClChr
CloseWin
         pshs  cc
         leax  WinClChr,PCR
         ldy   #LWinCl
         lda   #stdout
         OS9   I$Write
         puls  cc
         rts

