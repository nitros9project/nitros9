                    nam       bootman
                    ttl       Boot Manager

BOOTTRACK           equ       0

                    section   __os9
TYPE                equ       $11                 Prgrm($10)+Objct($01)
ATTR                equ       $80                 REEntrent
REV                 equ       $00                 Revision level
                    endsect

TOP                 equ       $FE00

* The entry point of the boot manager
* Entry: stack is set up, U points to static storage

                    section   bss
sectptr             rmb       2
                    endsect

                    section   code

__start             export
__start
entry               lbsr      mach_init           initialize the machine we're running on
                    leas      entry,pcr           set up stack
                    leau      entry-256,pcr       set up static storage
                    leax      entry-512,pcr       set up sector buffer pointer
                    stx       sectptr,u
                    leax      welcome,pcr
                    bsr       writestr

* start booter calling
bootup
                    leax      cfg_boot,pcr
                    ldy       ,x                  get address of booter
                    beq       bootup              if 0, try again

* call booter's get info entry
                    leax      attempt,pcr
                    bsr       writestr
                    jsr       12,y
                    bsr       writestr
                    leax      crlf,pcr
                    bsr       writestr

loop                bra       loop


attempt             fcc       "Attempting to boot from "
                    fcb       0
welcome             fcc       "NitrOS-9 Boot Manager"
crlf                fcb       13,10
                    fcb       0

* Helpful routines

* writestr - write string to output handler
* Entry:
*   X = address of string (nul terminated)
* Preserves:
*   Y
writestr
                    pshs      y
                    leay      llio,pcr
writeloop
                    lda       ,x+
                    beq       writedone
                    jsr       3,y
                    bra       writeloop
writedone
                    puls      y,pc

                    endsect
