********************************************************************
* drawtest
* test for mouse
*
* by John Federico
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------


                    nam       drawtest
                    ttl       drawtest


                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

pxlblk0		    rmb	      1
pxlblk		    rmb	      1
pxlblkaddr	    rmb	      2
currPath            rmb       1         current path for file read
bmblock0	    rmb	      1
bmblock             rmb       1         bitmap block#
mapaddr             rmb       2         Address for mapped block
currBlk             rmb       2         current mapped in block, (need to read into X)
blkCnt              rmb       1         Counter for block loop
clutheader          rmb       2
clutdata            rmb       2
iter_1              rmb       1
tmpb                rmb       1
tmpg                rmb       1
tmpr                rmb       1
tmpclut             rmb       1024      
                    rmb       250       stack space
size                equ       .

name                fcs       /drawtest/
                    fcb       edition


start
*                   **** Initialize vars
                    ldx       #0
                    stx       <clutheader
                    stx       <clutdata
		    stx	      <pxlblk0
		    stx	      <bmblock0

*                   **** Get a new bitmap 0
                    ldy       #$0                 Bitmap #
                    ldx       #$0                 Screentype = 320x240 (1=320x200)
                    lda       #$0                 Path #
                    ldb       #SS.AScrn           Assign and create bitmap
                    os9       I$SetStt
                    bcc       storeblk            No error, store block#
                    cmpb      #E$WADef            Check if window already defined
                    lbne      error               if other error, then end else continue
storeblk            tfr       x,d
                    stb       <bmblock            Store bitmap block# for later use

setBMClut
*                   **** Assign CLUT0 to BM0
                    ldx       #0                  CLUT #
                    ldy       #0                  Bitmap #
                    lda       #0                  Path #
                    ldb       #SS.Palet           Assign Clut # to Bitmap #
                    os9       I$SetStt
		    leax      clut0,pcr
		    lbsr      clutload
		    lbsr      clutcopy
setlayer
*                   **** Assign BM0 to Layer0               
                    ldx       #0                  Layer #
                    ldy       #0                  Bitmap #
                    lda       #0                  Path # 
                    ldb       #SS.PScrn           Position Bitmap # on Layer #
                    os9       I$SetStt

		    lbsr      clearbitmap

main                
*                    **** Turn on Graphics
                    ldx       #FX_BM+FX_GRF       Turn on Bitmaps and Graphics
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$00                Path #
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt            
                    lbcs      error                 

pollkeyboard        lbsr      INKEY
                    cmpa      #113
                    beq       exit
		    cmpa      #99
		    beq	      clearsub
		    bra	      pollmouse
clearsub	    lbsr      clearbitmap

pollmouse	    ldb	      #SS.Mouse
		    clra
		    os9	      I$GetStt
		    bita      #$01
		    beq	      pollkeyboard
		    lbsr      drawpixel
		    bra	      pollkeyboard


*                   **** Turn off Graphics
exit                ldx       #FX_TXT             Turn on Text, all else off
                    ldy       #FT_OMIT            Don't change $FFC1
                    lda       #$00                Path #
                    ldb       #SS.DScrn           Display Screen with new settings 
                    os9       I$SetStt            
                    lbcs      error

*                   **** Unlink CLUT
                    lbsr      unlinkclut

*                   **** Deallocate Bitmap memory
                    ldy       #$0                 Bitmap 0
                    lda       #$0                 Path #
                    ldb       #SS.FScrn           Free Screen Ram
                    os9       I$SetStt
                    lbcs       error
                    clrb

error               os9       F$Exit

clut0               fcs       /xtclut/


                    fcb       $0D


clearbitmap         lda	      #10	          loop through 10 blocks
                    ldx	      <bmblock0		  block#
		    pshs      u		          preserve u
clrloop@            ldb       #1                  map 1 block
                    os9       F$MapBlk            Map the block
		    pshs      u			  preserve start addr of block
		    ldy	      #$2000		  set up clear loop
loop@		    clr	      ,u+		  clear 8K
		    leay      -1,y		  decrement counter
		    bne	      loop@		  
		    puls      u			  puls start addr to clear block
		    ldb	      #1
		    os9	      F$ClrBlk	          clear block
		    leax      1,x		  incrment block number 
		    deca      			  decrement block counter
		    bne	      clrloop@
		    puls      u
		    rts
		    

INKEY               clra                          std in
                    ldb       #SS.Ready
                    os9       I$GetStt            see if key ready
                    bcc       getit
                    cmpb      #E$NotRdy           no keys ready=no error
                    bne       exit@               other error, report it
                    clra                          no error
                    bra       exit@
getit               lbsr      FGETC               go get the key
                    tsta
exit@               rts

FGETC               pshs      a,x,y
                    ldy       #1                  number of char to print
                    tfr       s,x                 point x at 1 char buffer
                    os9       I$Read
                    puls      a,x,y,pc


drawpixel	    tfr	      x,d
		    lsra
		    rorb
		    tfr	      d,x
		    tfr	      y,d
		    lsra
		    rorb
		    tfr	      d,y
		    lda	      #10
		    lbsr      writepixel
		    rts
		    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clut Load
; extry:  x is address of file path/name
; Loads CLUT from file or link
clutload
*                   **** Try to link CLUT data module
*                   **** If Link fails, then Load the module from default chx
                    pshs      a,b,x,y,u
                    lda       #0                  F$Load a=langauge, 0=any
                    os9       F$Link              Try linking module
                    beq       cont@               Link CLUT if no error, if error, try load
                    os9       F$Load              Load and set Y=entry point of module
                    lbcs      err@
cont@               stu       <clutheader
                    sty       <clutdata
err@                puls      u,y,x,b,a


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clut copy
; extry:  none
; copies clut from loaded module to CLUT#0
clutcopy            pshs      a,b,y,u
                    ldx       #0
                    ldy       <clutdata
                    lda       #$0                 Path #
                    ldb       #SS.DfPal           Define Palette CLUT#0 with data Y
                    os9       I$SetStt
err@                puls      u,y,a,b,pc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unlink Clut
; extry:  none
; unlink the current clut module from memory
unlinkclut          pshs      u
                    ldu       <clutheader
                    os9       F$Unlink
                    puls      u,pc


;;; write pixel
;;; takes X,Y and color and puts it in the bitmap bmblock
;;; x=X
;;; b=Y
;;; a=color
;;; use stack for temp vars
writepixel          pshs      a,b,x,y,u
                    leas      -1,s                  add 1 byte to stack for carry
                    clr       ,s                    0=carry,1=color,2=y,3=X
*                   **** D = 320 * gy.
*                   **** 320 = 256 + 64, so use MUL for the lower byte,
*                   **** and then add gy (gy * 256) to the upper byte.
                    lda       2,s                   py     ; 8 bits.
                    ldb       #64
                    mul
                    adda      2,s                   py
                    ror       ,s                    <pcarry  ; Collect the carry bit.
*                   **** D += gx.
                    addd      3,s                   px     ; 16 bits.
                    ror       ,s                    <pcarry  ; Collect the carry bit.
*                   **** Stash the block ID bits.
                    pshs      a

*                   **** Move the lower 13 bits (8191) into a pointer.
                    anda      #31
                    tfr       d,x
*                   **** Restore the carry.
*                   **** This add will set/clear the carry
*                   **** based on the previously collected carry bits.
                    ldb       1,s                   carry bit 
                    addb      #192
*                   **** ror it into the top of the block bits.
                    puls      a
                    rora
*                   **** Shift the block bits to the bottom of A. 
                    lsra
                    lsra
                    lsra
                    lsra
*                   **** A now contains the relative block number,
*                   **** and X contains the block relative offset.xxxxxxxxw
                    pshs      x                   stx pixel offset
                    adda      <bmblock            add start of bitmap to relative to get block#
                    cmpa      <pxlblk              is this the currently mapped block?
                    beq       storepixel@         if current block, then just write the pixel
                    tst       <pxlblk              if not, check if mapped block exists, 0 if none
                    beq       mapit@              no mapped block then branch to map it
                    bsr       fclrblk             have a mapped block, clear it
mapit@              sta       <pxlblk              store the new block we will map
                    ldx       <pxlblk0             load x with mapblock for F$MapBlk
                    ldb       #1                  map 1 block
                    pshs      u                   push u (F$MapBlk returns address in u)
                    os9       F$MapBlk            Map the block
                    lbcc      mapgood@            if successful, finish
                    puls      u,x                 error, clean up and return
                    bra       cleanup@            
mapgood@            stu       <pxlblkaddr         store the logical address
                    puls      u
storepixel@         ldd       <pxlblkaddr
                    puls      x                   pull blk relative offset
                    leax      d,x                 add in logical start of block
                    lda       1,s                 lda with the color
                    sta       ,x                  write the pixel
cleanup@            leas      1,s                 pull carry byte off stack
                    puls      a,b,x,y,u,pc        clean up stack and return

fclrblk             pshs      b,u
                    ldu       <pxlblkaddr
                    ldb       #1
                    os9       F$ClrBlk
                    puls      b,u,pc


                    emod
eom                 equ       *
                    end
