********************************************************************
* ascript - Action Script
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

scrdelim        set     C$COMA
maxlinelen		set		80

                    section   bss
keypressed          rmb       1
isflash             rmb       1
scriptpathlist      rmb       maxlinelen
linebuff		    rmb		  maxlinelen
                    rmb       100
                    endsect

KeySig              equ       $84

                    section   code
IcptRtn
                    lbsr      GETC
                    sta       keypressed,u
                    rti                           our interrupt routine does nothing.

**********************************************************
* Entry Point
**********************************************************
__start
                    lda       ,x
                    cmpa      #C$CR
                    beq       exit
                    ldd       #maxlinelen-1
                    leay      scriptpathlist,u
                    lbsr      STRNCPY
                    leax      IcptRtn,pcr
                    os9       F$Icpt
* Entry: X = menu to display
PromptAndRead       lbsr      PUTCR                put a carriage return
                    leax      scriptpathlist,u
                    lbsr      SHOWSCRMENU            show the menu
                    bcs       badex@
                    lbsr      PUTCR
                    lbsr      PRINTS
                    fcc       /? /
                    fcb       0
                    lbsr      GETC                get a character
                    lbsr      MATCHASCR
                    cmpx      #$0000
                    bne       process
                    lbsr      PUTCR
                    bra       PromptAndRead
process             lbsr      PUTCR
                    leax      2,x                 skip key and delimiter
                    ldb       #scrdelim
                    lbsr      TO_CHAR_OR_NIL      find next delimiter (before command)
                    leax      1,x                 skip over the delimiter
                    lda       ,x                  get the first character of the command
                    cmpa      #'$                 is it the exit character?
                    beq       exit                branch if so
                    pshs      x,u                 else save the pointer to the command and U
                    lbsr      TO_CHAR_OR_NIL      find next delimiter (before parameter)
                    clr       ,x+                 nil terminate the command and advance X to parameters
* count parameter length
                    lbsr      STRLEN
                    tfr       d,y                    
                    leau      ,x                  point U to parameters for forking (C$CR is at end of parameters)
                    puls      x                   get pointer to command on stack
                    ldd       #(Prgrm+Objct)*256
                    os9       F$Fork
                    puls      u
                    os9       F$Wait
                    bra       PromptAndRead
exit                clrb
badex@              os9       F$Exit
                    
* Command Scripts
*
* Command scripts are text files that are parsed to perform some command based on a key.
* A command script is made up of one or more comma delimited lines of this form:
*
* K,M,C,P
*
* Where:
*    K = the key used to invoke the command
*    D = a description string which describes the command
*    C = the command to execute
*    P = any parameters for the command
*
* For example:
*
*    * This is a comment (ignored)
*    o,Boot OS-9,bootos9,/x0/OS9Boot
*    # This is another comment (ignored)
*    r,Reset,fnxreset,
*
* To use command scripts:
*   1. Show the script menu by calling SHOWSCRMENU.
*   2. Match a key to an command by calling MATCHASCR with A holding the key to match.


;;; MATCHASCR
;;;
;;; Match a key to an command in an command script and return a pointer to the command entry, if found.
;;;
;;; Entry:  A = The key to match against.
;;;         X = The pathlist to the script file.
;;;
;;; Exit:   X = The pointer to the target script line, or 0 if not found.
;;;
;;; Error:  None.

MATCHASCR:	 	pshs    d,y
				lda		#READ.
                os9     I$Open
				bcs     badex@
loop@           leax    linebuff,u
                ldy     #maxlinelen-1
                lbsr    FGETS
                bcs     notfound@
                ldb     ,x
                cmpb    ,s                  match?
                bne     loop@               no; get next line
ex@             os9     I$Close
                clrb
badex@      	puls	d,y,pc              return
notfound@       ldx     #$0000
                bra     ex@				
                
;;; SHOWSCRMENU
;;;
;;; Show an command script menu.
;;;
;;; Entry:  X = The pathlist to the script file.
;;;
;;; Exit:   None.
;;;
;;; Error:  B = A non-zero error code.
;;;        CC = Carry flag set to indicate error.

SHOWSCRMENU: 	pshs    x,y
				lda		#READ.
                os9     I$Open
				bcs     badex@
loop@           leax    linebuff,u
                ldy     #maxlinelen-1
                lbsr    FGETS
                bcs     ex@
                ldb     ,x++                                                                                            
				lbsr    PUTC
				lbsr    PRINTS
				fcc     " - "
				fcb     0
                ldb                 #scrdelim
                pshs                x
                lbsr                TO_CHAR_OR_NIL                                                                                
                clr     ,x
                puls    x
				lbsr	PUTS				print it
				lbsr    PUTCR
				bra		loop@				and continue
ex@             os9     I$Close
                clrb
badex@			puls	x,y,pc
				
    endsection
				
				