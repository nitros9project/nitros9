********************************************************************
* pick - Scripting Utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2024/06/28  Boisy Pitre
* Created.

scrdelim        set     '|
maxpromptlen    set     20
maxlinelen		set		80

                    section   bss
keypressed          rmb       1
isflash             rmb       1
prompt              rmb       maxpromptlen+1
scriptpathlist      rmb       maxlinelen+1
linebuff		    rmb		  maxlinelen+1
                    rmb       100
                    endsect

KeySig              equ       $84

                    section   code
                    
IcptRtn
                    lbsr      GETC
                    sta       keypressed,u
                    rti

**********************************************************
* Entry Point
**********************************************************
__start             cmpd      #$0001              any parameters?
                    lbeq      exit                no... exit.
                    ldy       #':*256             get default prompt
                    sty       prompt,u            and set it
                    ldd       ,x                  look for "-p"
                    andb      #$5F                make second character uppercase
                    cmpd      #'-*256+'P          is it a -p?
                    bne       cont@               nope
                    leax      2,x                 else skip over the option
                    lbsr      TO_NON_SP           and skip over any whitespace
* X is at the prompt.
                    leay      prompt,u            point to the buffer
                    ldb       #maxpromptlen       get maximum prompt length in B
l@                  lda       ,x+                 get the prompt character
                    cmpa      #C$CR               carriage return?
                    lbeq      exit                if so, no file was specified -- just exit
                    cmpa      #C$SPAC             space?
                    beq       terminate@          terminate if so
                    sta       ,y+                 else save prompt character in buffer
                    decb                          decrement maximum length
                    bne       l@                  branch if we have more room
terminate@          clr       ,y                  nil terminate the prompt                    
cont@
                    lbsr      TO_NON_SP           and skip over any whitespace to get to the script file
                    ldd       #maxlinelen         else get maximum line length
                    leay      scriptpathlist,u    and script file buffer
                    lbsr      STRNCPY             copy the parameter over
                    leax      IcptRtn,pcr         point to the signal handler routine
                    os9       F$Icpt              install the signal handler
* Entry: X = menu to display
PromptAndRead       lbsr      PUTCR                put a carriage return
                    leax      scriptpathlist,u     point to the file
                    lbsr      SHOWSCRMENU          show the menu
                    bcs       badex@               branch if erro
                    lbsr      PUTCR put carriage return
                    pshs      x
                    leax      prompt,u
                    lbsr      PUTS                 print prompt
                    puls      x
                    lbsr      GETC                get a character
                    lbsr      MATCHASCR attempt to match
                    cmpx      #$0000 did we get a match?
                    bne       process if so, process
                    lbsr      PUTCR else put a carriage return
                    bra       PromptAndRead and go back again
process             lbsr      PUTCR put a carriage return
                    leax      2,x                 skip key and delimiter
                    ldb       #scrdelim get the script delimiter
                    lbsr      TO_CHAR_OR_NIL      find the next instance of the delimiter (before command)
                    leax      1,x                 skip over the delimiter
                    lda       ,x                  get the first character of the command
                    cmpa      #'$                 is it the exit character?
                    beq       exit                branch if so
                    pshs      x,u                 else save the pointer to the command and U
                    lbsr      TO_SP_OR_NIL        find the next space character (before parameter, if any)
                    tst       ,x
                    beq       noparams@
                    clr       ,x+                 nil terminate the command and advance X to parameters
* count parameter length
noparams@           lbsr      STRLEN
                    tfr       d,y                transfer the length to Y    
                    leau      ,x                  point U to parameters for forking (C$CR is at end of parameters)
                    puls      x                   get pointer to command on stack
                    ldd       #(Prgrm+Objct)*256  A = type/language, B = 0 pages of extra stack space
                    os9       F$Fork    fork the program
                    puls      u         recover the static storage pointer
                    os9       F$Wait    wait for the program to complete
                    bra       PromptAndRead                 and go back to process the script again
exit                clrb                clear the carry flag
badex@              os9       F$Exit    exit
                    
* Pick Scripts
*
* Pick scripts are text files that are parsed to perform some command based on a key.
* A script is made up of one or more delimited lines of this form:
*
* K|M|C
*
* Where:
*    K = the key used to invoke the command
*    D = a description string which describes the command
*    C = the command to execute with any parameters
*
* For example:
*
*    * This is a comment (ignored)
*    o|Boot OS-9|bootos9 /x0/OS9Boot
*    # This is another comment (ignored)
*    r|Reset|fnxreset
*
* To use scripts:
*   1. Show the script menu by calling SHOWSCRMENU.
*   2. Match a key to an command by calling MATCHASCR with A holding the key to match.


;;; MATCHASCR
;;;
;;; Match a key to an command in a pick script and return a pointer to the command entry, if found.
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
;;; Show a pick script menu.
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
                ldb     #scrdelim
                pshs    x
                lbsr    TO_CHAR_OR_NIL                                                                                
                clr     ,x
                puls    x
				lbsr	PUTS				print it
				lbsr    PUTCR
				bra		loop@				and continue
ex@             os9     I$Close
                clrb
badex@			puls	x,y,pc
				
                endsection
				
				