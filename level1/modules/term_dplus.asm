********************************************************************
* Term - VTIO VDG Device Descriptor
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

         nam   Term
         ttl   VTIO VDG Device Descriptor

         ifp1  
         use   defsfile
         use   cocovtio.d
         endc  

tylg     set   Devic+Objct
atrv     set   ReEnt+rev
rev      set   $00

* Window descriptor definitions
szx      set   80         number of columns for display
szy      set   24         number for rows for display
         IFGT  Level-1
wnum     set   0          window number
sty      set   1          window type
cpx      set   0          x cursor position
cpy      set   0          y cursor position
         ENDC

         mod   eom,name,tylg,atrv,mgrnam,drvnam

         fcb   UPDAT.     mode byte
         fcb   HW.Page    extended controller address
         fdb   $FFE0      physical controller address
         fcb   initsize-*-1 initilization table size
         fcb   DT.SCF     device type:0=scf,1=rbf,2=pipe,3=scf
         fcb   $00        case:0=up&lower,1=upper only
         fcb   $01        backspace:0=bsp,1=bsp then sp & bsp
         fcb   $00        delete:0=bsp over line,1=return
         fcb   $01        echo:0=no echo
         fcb   $01        auto line feed:0=off
         fcb   $00        end of line null count
         fcb   $01        pause:0=no end of page pause
         fcb   szy        lines per page
         fcb   C$BSP      backspace character
         fcb   C$DEL      delete line character
         fcb   C$CR       end of record character
         fcb   C$EOF      end of file character
         fcb   C$RARR     reprint line character
         fcb   C$SHRARR   duplicate last line character
         fcb   C$PAUS     pause character
         fcb   C$INTR     interrupt character
         fcb   C$QUIT     quit character
         fcb   C$BSP      backspace echo character
         fcb   C$BELL     line overflow character (bell)
         fcb   ModCoDPlus init value for dev ctl reg
         fcb   $00        baud rate
         fdb   name       copy of descriptor name address
         fcb   $00        acia xon char
         fcb   $00        acia xoff char
         fcb   szx        (szx) number of columns for display
         fcb   szy        (szy) number of rows for display
initsize equ   *

name     fcs   /Term/
mgrnam   fcs   /SCF/
drvnam   fcs   /VTIO/

         emod  
eom      equ   *
         end   

