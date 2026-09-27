********************************************************************
* GfxTest - Pico-Thing video console graphics smoke test
*
* Opens /V0 and writes a fixed sequence of graphics draw commands to
* the video pico: a solid yellow bar, a solid grey bar, a white box
* outline, and a white diagonal line on the 1024x480 plane.  It is a
* pure byte-pipe exercise with no graphics library, so it renders the
* same on the real board (type gfxtest at the shell) and headless under
* usim09pt, where scripts/test-vcon.sh screenshots the panel and checks
* the rendered colours.  The two filled bars give the automated check
* solid interiors to sample; the box and line cover the outline and
* line primitives for the eye.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*     1    2026       Created as the committed video console draw test

                    nam       GfxTest
                    ttl       video console graphics smoke test

                  IFP1
                    use       defsfile
                  ENDC

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

                    org       0
path                rmb       1         open path number for the video console
                    rmb       200       working stack
size                equ       .

name                fcs       /GfxTest/
                    fcb       edition

* video console device name; the high bit on the last character marks
* the end of the pathlist for I$Open
V0Name              fcs       "/V0"

* The draw program.  Each graphics command is $1B (escape) then a
* sub-code then a fixed number of operands; coordinates are 16-bit
* big-endian, X before Y, on the 1024x480 panel; colours are GIME
* RGBRGB palette values loaded into palette registers.
Draw                fcb       $0C       clear the screen
* load three palette registers with yellow, grey and white
                    fcb       $1B,$31,$01,$36 palette register 1 is yellow
                    fcb       $1B,$31,$02,$07 palette register 2 is grey
                    fcb       $1B,$31,$03,$3F palette register 3 is white
* a solid yellow bar from the pointer at 100,100 to 300,200
                    fcb       $1B,$32,$01 foreground is register 1
                    fcb       $1B,$40,$00,$64,$00,$64 move the draw pointer to 100,100
                    fcb       $1B,$4A,$01,$2C,$00,$C8 filled bar to 300,200
* a solid grey bar from the pointer at 400,100 to 600,200
                    fcb       $1B,$32,$02 foreground is register 2
                    fcb       $1B,$40,$01,$90,$00,$64 move the draw pointer to 400,100
                    fcb       $1B,$4A,$02,$58,$00,$C8 filled bar to 600,200
* a white box outline and a white diagonal line across the plane
                    fcb       $1B,$32,$03 foreground is register 3
                    fcb       $1B,$40,$00,$32,$00,$32 move the draw pointer to 50,50
                    fcb       $1B,$48,$03,$20,$01,$90 box outline to 800,400
                    fcb       $1B,$40,$00,$64,$01,$2C move the draw pointer to 100,300
                    fcb       $1B,$44,$03,$20,$01,$68 line to 800,360
DrawLen             equ       *-Draw

start               leax      V0Name,pcr ; the video console device
                    lda       #WRITE.   ; open it for output
                    os9       I$Open
                    bcs       Exit      ; give up if it will not open
                    sta       <path     ; remember the path number
                    leax      Draw,pcr  ; the draw program
                    ldy       #DrawLen  ; its length in bytes
                    os9       I$Write   ; pipe every byte to the pico
                    bcs       Close     ; keep the error code on failure
                    clrb                ; success: exit cleanly
* close the path, preserving the exit status in B across the close
Close               pshs      b         ; save the exit status
                    lda       <path     ; the open path
                    os9       I$Close   ; release it
                    puls      b         ; recover the exit status
Exit                os9       F$Exit    ; return the status in B

                    emod
eom                 equ       *
                    end
