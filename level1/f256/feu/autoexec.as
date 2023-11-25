********************************************************************
* autoexec - automatic program booter for the Foenix F256
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*
* This booter searches for a program file called 'autoexec' and if found,
* loads and executes it.

               section                       code
**********************************************************
* Entry Point
**********************************************************
autoexecpath   fcc       "/X0/CMDS/autoexec"
               fcb       0

AutoexecGo                
               ldd       #(Prgrm+Objct)*256+$00             get program/language and page count byte
               ldy       #$0000              zero out parameters memory (none used)
               leax      autoexecpath,pcr    point to the absolute path
               os9       F$Fork              attempt to fork
               bcs       ex@                 branch if error
               os9       F$Wait              else wait for it to die
ex@            rts

               endsect
