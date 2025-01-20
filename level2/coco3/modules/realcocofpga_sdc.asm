*********************************************************************
*
* MATCHBOX COCO SDC DRIVER FOR OS-9
* Lab-Only version last updated on 4-11-17
*
*********************************************************************

	nam	MatchboxSDC
	ttl	Matchbox, MiSTer, RealCoCo SDC Disk Driver

        use       os9.d
        use       rbf.d
        use       coco.d


NumDrvs	set	4			RealCoCo and Matchbox limit is 4
LEVEL	set	2

tylg	set	Drivr+Objct   
atrv	set	ReEnt+rev
rev	set	$03
edition	set	1

	mod	eom,name,tylg,atrv,start,size

	org	0
	rmb	DRVBEG+(DRVMEM*NumDrvs)
* Start of driver-specific statics
LSN	rmb	3
retries	rmb	3
	rmb	20
size	equ	.

	fcb	$FF	mode byte
       
name
	fcs	"MatchboxSDC"
	fcb	edition

start
	lbra	Init
	lbra	Read
	lbra	Write
	lbra	GetStat
	lbra	SetStat
	lbra	Term

Term
	clrb
	rts

Init
	ldb	#NumDrvs
	stb	V.NDRV,u
	leax	DRVBEG,u
	lda	#$FF

Init2
	sta	DD.TOT,x		invalidate drive tables
	sta	DD.TOT+1,x
	sta	DD.TOT+2,x
	sta	V.TRAK,x
	leax	DRVMEM,x
	decb
	bne	Init2
	
*	lda	#$00
*	sta	65344	turn of FDC motor
	
* First check to see if controller is ready enough to talk to
	ldx	#-1	timer
int3	lda	65393	get SD status
	anda	#64	check busy bits
	beq	int4
	leax	-1,x	keep checking for a while
	bne	int3
	lbra	NotReady	drive busy

int4	clr	$FF72	MSB
	clr	$FF73	NSB
	clr	$FF74	LSB
	clr	$FF75	xMSB
	
	clrb
	rts

Read

* Set the LSN that we're reading, give controller ample time to calculate if required, most likely not
	stb	LSN,u
	stx	LSN+1,u

	clr	retries,u
	
* wait a while until controller isn't busy
	ldx	#0	time-out
rwait1	lda	65393	get SD status
	anda	#64	check busy bits
	beq	r00	not busy
	leax	-1,x
	bne	rwait1
	dec	retries,u
	bne	rwait1
	lbra	NotReady	timeout

r00	ldb	LSN,u
	stb	65394
	ldx	LSN+1,u
	stx	65395

	ldb	PD.DRV,y	get drive number
	cmpb	#NumDrvs	compare against maximum drives set in 
	lbhs	BadDriveNum
	andb	#$03		controller has limit of 4 drives regardless of OS-9 limit
	orb	PD.DRV,y
	stb	65393		start READ process
	
	ldx	PD.BUF,y
	clrb		256-byte sectors
r1	tst	65393
	bpl	r1	wait for block data to be ready to read
rt1	lda	65392
	sta	,x+
	decb
	bne	r1

	ldd	LSN+1,u	was this local LSN0 ?
	bne	read9	branch if not
	ldb	LSN,u
	bne	read9	branch if not

	ldx	PD.BUF,y	make a copy of local LSN0
	lda	PD.DRV,y
	ldb	#DRVMEM
	mul
	leay	DRVBEG,u
	leay	d,y
	ldb	#DD.SIZ
LSN0cpy	lda	,x+
	sta	,y+
	decb  
	bne	LSN0cpy
read9
	clrb
	rts

Write
	stb	LSN,u
	stx	LSN+1,u
	stb	65394
	stx	65395
	
	clr	retries,u

* wait a while until controller isn't busy
	ldx	#0	timeout
w0	lda	65393	get SD status
	anda	#64	check busy bits
	beq	w1
	leay	-1,y
	bne	w0
	dec	retries,u
	bne	w0
	bra	NotReady

w1
	ldb	PD.DRV,y	get drive number
	cmpb	#NumDrvs
	bhs	BadDriveNum
	andb	#$03		regardless of OS9 drive limit, controller stil has limit of 4 drives
	orb	#$10	command for Write is 000100DD where DD is drive #
	stb	65393	start Write process

w9	clrb
	ldx	PD.BUF,y
w2	lda	65393	wait for controller ack
	lsra	test bit #0 (set means we can write to the data register)
	bcs	w2
	lda	,x+
	sta	65392
	decb
	bne	w2

	clrb
	rts
	
NotReady
	ldb	#E$NotRdy	Device not ready
	bra	error
BadDriveNum	ldb	#E$Unit
error	puls	cc,a,x,y
	orcc	#1
	rts

GetStat
SetStat
	clrb
	rts

	emod
eom	equ	*
	end
	
