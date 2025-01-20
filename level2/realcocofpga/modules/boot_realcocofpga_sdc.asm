*********************************************************************
* MATCHBOX COCO SDC BOOT DRIVER FOR OS-9
* Lab-Only version last updated on 1-15-2025
*********************************************************************

	NAM	Boot
	TTL	MatchboxSDC Boot Module

        ifp1
        use       defsfile
        endc

tylg	SET	Systm+Objct
atrv	SET	ReEnt+rev
rev	SET	0
edition	SET	1

	MOD	eom,name,tylg,atrv,start,size

* on-stack buffer to use
	ORG	0
seglist	RMB	2	pointer to segment list
blockloc	RMB	2	pointer to memory requested
blockimg	RMB	2	duplicate of the above
bootloc	RMB	3	sector pointer; not byte pointer
bootsize	RMB	2	size in bytes
LSN	rmb	3
ddtks	rmb	2
savedp	rmb	1
size	EQU	.

name	EQU	*
	FCS	/Boot/
	FCB	edition

* Common booter-required defines

FLOPPY	equ	0

********************************************************************
* Important Notes:
* For certain devices, only the lower 16 bits of DD.BT are used.  This special
* case allows us to save some code by ignoring the loading LSN bits 23-16 in
* DD.BT and FDSL.A.  Booters for such devices (floppy, RAMPak) should have the
* following line in their code to take advantage of this optimization:
*
* LSN24BIT equ 0
*
* Floppy booters require the acquistion of DD.TKS and DD.FMT from LSN0 to make
* certain decisions about the boot process.  In most cases, non-floppy booters
* do not need these values.  Hence, floppy booters should have this line in their
* source code file:
*
* FLOPPY equ 1
*
********************************************************************
                 
start
	orcc	#IntMasks	ensure IRQs are off (necessary?)

* allocate memory on stack for vars and sector buffer
	IFEQ  Level-1
* Level 1: stack is only 256 bytes and its bottom runs against moddir ptrs... so cheat and use free page just above stack
* for 256 byte disk buffer
	leas	-size,s   
	tfr	s,u		get pointer to data area
	ldx	#$500
	ELSE
	leas	-size-256,s
	tfr	s,u		get pointer to data area
	leax	size,u		point U to 256 byte sector buffer
	ENDC
	pshs	u		save pointer to data area
	stx	blockloc,u

* Read LSN0 of OS-9 disk

Boot2	IFGT  Level-1   
	lda   #'0       		 --- loaded in LSN0'
	jsr   <D.BtBug  		 ---
	ENDC            
        
       	clrb             		MSB sector
	ldx	#0         		LSW sector
	bsr	Sectin     		read LSN 0
	bcs	error      		branch if error
                         
* Pull relevant values from LSN0

	IFNE	FLOPPY
	lda	DD.TKS,x		number of tracks on this disk
	ldb	DD.FMT,x		disk format byte
	std	ddtks,u			TAKE NOTE!  ASSUMES ADJACENT VARS!
	ENDC
	ldd	DD.BSZ,x		os9boot size in bytes
	beq	FragBoot		if zero, do frag boot
	std	bootsize,u

* Old style boot -- make a fake FD segment right from LSN0!

	leax	DD.BT,x  
	addd	#$00FF			round up to next page

* Important note: We are making an assumption that the upper 8 bits of the
* FDSL.B field will always be zero.  That is a safe assumption, since an
* FDSL.B value of $00FF would mean the file is 65280 bytes.  A bootfile
* under NitrOS-9 cannot be this large, and therefore this assumption
* is safe.

         sta	FDSL.B+1,x		save file size
         clr	FDSL.S,x		make next segment entry 0
         clr	FDSL.S+1,x
         clr	FDSL.S+2,x
         subd	#$00FF			undo previous add #$00FF
         bra	GrabBootMem
                         
Back2Krn
	lbsr	HWTerm		call HW termination routine
	ldx	blockimg,u		pointer to start of os9boot in memory
	clrb			clear carry
	ldd	bootsize,u
error
	IFEQ	Level-1
	leas	2+size,s		reset the stack    same as PULS U
	ELSE
	leas	2+size+256,s		reset the stack    same as PULS U
	ENDC
	rts			return to kernel
	
* NEW! Fragmented boot support!
*FragBoot ldb   bootloc,u		MSB fd sector location
*         ldx   bootloc+1,u		LSW fd sector location
FragBoot ldb   DD.BT,x			MSB fd sector location
         ldx   DD.BT+1,x		LSW fd sector location
         bsr  Sectin			get fd sector
         ldd   FD.SIZ+2,x		get file size (we skip first two bytes)
         std   bootsize,u
         leax  FD.SEG,x			point to segment table
                         
GrabBootMem                 
         IFGT	Level-1   
         os9	F$BtMem			unknown call by Windows version of OS-9 Assembler?
*	fcb	$10,$3F,$36		manually construct the F$BtMem opcodes
         ELSE            
         os9	F$SRqMem
         ENDC            
         bcs	error

* Save off alloced mem from F$SRqMem into blockloc,u and restore
* the statics pointer in U

         tfr	u,d        		save pointer to requested memory
         ldu	,s         		recover pointer to data stack
         std	blockloc,u
         std	blockimg,u
                         
* Get os9boot into memory
BootLoop stx	seglist,u  		update segment list
         ldb	FDSL.A,x   		MSB sector location
BL2      ldx	FDSL.A+1,x 		LSW sector location
         bne	BL3       
         tstb            
         beq	Back2Krn  
BL3      bsr	Sectin    
         inc	blockloc,u 		point to next input sector in mem

  	IFGT  Level-1   
         lda   #'.
         jsr   <D.BtBug  
         ENDC            
       
         ldx   seglist,u  		get pointer to segment list
         dec   FDSL.B+1,x 		get segment size
         beq   NextSeg    		if <=0, get next segment
                         
         ldd   FDSL.A+1,x 		update sector location by one
         addd  #1        
         std   FDSL.A+1,x
         ldb   FDSL.A,x  
         adcb  #0        
         stb   FDSL.A,x  
         bra   BL2       
                         
NextSeg  leax  FDSL.S,x   		advance to next segment entry
         bra   BootLoop  

************************************************************
* HWRead - Read a 256 byte sector from the Drive Pak
*   Entry:
*          B = bits 23-16 of LSN
*          X = bits 15-0  of LSN
* 	 blockloc,u = ptr to 256 byte sector
*   Exit:  X = ptr to data (i.e. ptr in blockloc,u)
************************************************************

Sectin	pshs	d,y			direct LSN reader (LSN of uDrive card)
	ldy	#-1	timer
br	lda	65393	get SD status
	anda	#64	check busy bits
	beq	nbr	controller is busy
	leay	-1,y	keep checking for a while
	bne	br
	bra	rnr

nbr	ldy	blockloc,u	sector buffer address
	stb	65394
	stx	65395
	clr	65393	start READ process 0000xxDD  where DD is drive 0-3

	clrb
r1	tst	65393
	bpl	r1	wait for block data to be ready to read
	lda	65392
	sta	,y+
	decb
	bne	r1

r9	lda	65393
	anda	#64
	bne	r9	wait forever until controller isn't busy
	
	ldx	blockloc,u
	clrb
	puls	d,y,pc

rnr	ldb	#E$NotRdy
	orcc	#1
	puls	d,y,pc
HWTerm
	clrb      
	rts       

***
* some static strings and data
**

	IFGT	Level-1
Pad	FILL	$39,$1D0-2-1-*
	ENDC      

	EMOD      
eom	EQU       *
	END       
