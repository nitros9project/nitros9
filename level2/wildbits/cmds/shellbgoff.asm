********************************************************************
* 
* 
* 
* 
* 
* SHELLBGOFF - by Matt Massie
* 
* Based on work by John Federico
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------


                    nam       shellbgoff
                    ttl       NitrOS-9 Shell BG OFF


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    rmb       200             stack space
size                equ       .


name                fcs       /shellbgoff/
                    fcb       edition

start               ldx       #%00000001       Turn Text on BM_TXT = %00000001
                    ldy       #%11111111       Don't change FFC1  FT_OMIT = %11111111
                    ;lda       ,s               Path # from stack 
                    lda       #1
                    ldb       #SS.DScrn        Display screen with new settings
                    os9       I$SetStt
                    
                    ldy       #2               BM 0-2
par2@               lda       #0
                    ldb       #SS.FScrn        Free Bitmap
                    os9       I$SetStt
                    clrb
                    os9       F$Exit
                    
                    emod
eom                 equ       *
                    end
