********************************************************************
* FEU - Foenix Executive Utility
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------

                    nam       FEU
                    ttl       Foenix Executive Utility

VMAJOR              equ       0
VMINOR              equ       4

                    section   bss
abortautoboot       rmb       1
isflash             rmb       1
buffer              rmb       200
                    endsect

                    section   code
DWSet               fcb       $1b,$20,$02,$00,$00,$50,$18,$01,$00,$00
DWSetLen            equ       *-DWSet
Banner              equ       *
                    fcc       /FEU - Foenix Executive Utility/
                    fcb       C$CR
                    fcc       /Version /
                    fcb       VMAJOR+$30
                    fcc       "."
                    fcb       VMINOR+$30
                    fcb       C$CR
                    fcc       /2023 Boisy Gene Pitre/
                    fcb       C$CR
                    fcb       0

FlashMsg            fcc       / - Flash Mode/
                    fcb       C$CR
                    fcb       C$CR
                    fcb       $0

RAMMsg              fcc       / - RAM Mode/
                    fcb       C$CR
                    fcb       C$CR
                    fcb       $0

* Menu configuration table.
* A menu entry consists of the following:
*  Byte 0: the character that activates the option.
*  Byte 1: the options byte ($01 = auto execute this item).
*  Bytes 2-3: the address of the menu string to show.
*  Bytes 4-5: the address of the menu driven action.
*  Bytes 4-5: the address of the auto-executed action.

MENU_ENTRY_LEN      equ       8

Menu

l@                  fcb       'o'
                    fcb       $00
                    fdb       BootOS9Help-l@
                    fdb       BootOS9Go-l@
                    fdb       AutoBootOS9Go-l@

l@                  fcb       'd'
                    fcb       $00
                    fdb       DebugHelp-l@
                    fdb       DebugGo-l@
                    fdb       $0000

l@                  fcb       's'
                    fcb       $00
                    fdb       ShellHelp-l@
                    fdb       ShellGo-l@
                    fdb       $0000

l@                  fcb       'r'
                    fcb       $00
                    fdb       ResetHelp-l@
                    fdb       ResetGo-l@
                    fdb       $0000

                    fcb       0

SecondsToWait       equ       5
PromptForAutoAbort
                    ifgt      SecondsToWait
                    clr       abortautoboot,u
                    lbsr      PRINTS
                    fcc       "Press ESC to abort autoboot in "
                    fcb       $00
                    ldb       #SecondsToWait-1
loop@               pshs      b
                    addb      #$31
                    lbsr      PUTC
                    lbsr      PRINTS
                    fcc       "... "
                    fcb       $00
                    ldx       #60
                    os9       F$Sleep
                    puls      b
                    tst       abortautoboot,u
                    bne       abort@
                    decb
                    bpl       loop@
                    clrb
                    rts
abort@              clr       abortautoboot,u
                    comb
                    endc
                    rts

ShellHelp           fcc       "OS-9 shell"
                    fcb       C$CR
                    fcb       0

Shell               fcs       /shell/
ShellGo             leax      Shell,pcr
                    bra       ForkIt

ResetHelp           fcc       "Reset"
                    fcb       C$CR
                    fcb       0

* This performs a proper reset of the F256.
ResetGo             ldd       #$DEAD              get the sentinel values
                    sta       RST0                store the first value
                    stb       RST1                and the second value
                    lda       #$80                set the high bit
                    sta       SYS0                store the high bit in the register
                    clr       SYS0                then clear the high bit in the register
l@                  bra       l@                  wait for the reset condition

DebugHelp           fcc       "Debugger"
                    fcb       C$CR
                    fcb       0

Debug               fcs       /debug/
DebugGo             leax      Debug,pcr
ForkIt              lda       #Prgrm+Objct
                    clrb
                    ldy       #$0000
                    os9       F$Fork
                    os9       F$Wait
                    rts

BootOS9Help         fcc       "Boot OS-9"
                    fcb       C$CR
                    fcb       0

PrintMBoardInfo     ldx       #SYS0
                    lda       7,x
                    cmpa      #$02
                    bne       isItF256K
f256k@              lbsr      PRINTS
                    fcc       "F256 Jr."
                    fcb       $0
                    bra       cont@
isItF256K           cmpa      #$12
                    bne       cont@
                    lbsr      PRINTS
                    fcc       "F256K"
                    fcb       $0
cont@               rts

**********************************************************
* Entry Point
**********************************************************
__start             leax      >IcptRtn,pcr        point to the intercept routine
                    os9       F$Icpt              install it
                    leax      DWSet,pcr
                    lda       #1
                    ldy       #DWSetLen
                    os9       I$Write
                    leax      >Banner,pcr         point to the banner
                    lbsr      PUTS                print it
                    lbsr      PrintMBoardInfo
                    clr       isflash,u           clear the flash flag (assume we're RAM)
                    lda       $FFAF               get MMU slot 7
                    cmpa      #$07                is it 7? (meaning this is loaded from RAM)
                    beq       ram@                branch if so
                    inc       isflash,u           else increment the flash flag
                    leax      >FlashMsg,pcr       point to the flash message
                    bra       next@               and go print it
ram@                leax      >RAMMsg,pcr         point to the RAM message
next@               lbsr      PUTS                print it
                    lbsr      PromptForAutoAbort  prompt the user to abort autoboot
                    bcs       loop@
                    lbsr      AutoexecGo          attempt to run "autoexec" first
                    leax      Menu,pcr            point to the menu
                    bsr       ExecAutoMenu        perform the automatic execution
loop@               leax      Menu,pcr            point to the menu
                    bsr       PromptAndRead       perform the prompt and read
                    bra       loop@               then continue looping

* Entry: X = menu to display
ExecAutoMenu
next@               tst       ,x                  is the entry's option set character 0?
                    beq       exit@               branch if so, we're done
                    ldd       6,x                 else get address of the auto-exec routine to execute
                    beq       bot@                branch if the address is zero
                    pshs      x                   else save the pointer
                    leax      d,x                 point X to it
                    jsr       ,x                  go do the routine
                    puls      x                   recover the pointer
bot@                leax      MENU_ENTRY_LEN,x    move ahead to the next entry in the menu table
                    bra       next@               and evaluate
exit@               rts                           return

* Entry: X = menu to display
PromptAndRead       pshs      x                   save the menu pointer
                    lbsr      PUTCR               put a carriage return
                    bsr       ShowMenu            show the menu
                    lbsr      PRINTS
                    fcc       /FEU: /
                    fcb       0
                    lbsr      GETC                get a character
                    lbsr      PUTCR
                    puls      x                   restore the menu pointer
next@               tst       ,x                  is the entry's input character 0?
                    beq       exit@               branch if so, we're done
                    cmpa      ,x                  else compare the typed key to the entry's input character
                    beq       exec@               branch if they're equal
                    leax      MENU_ENTRY_LEN,x    else move ahead to the next entry in the menu table
                    bra       next@               and test again
Exec
exec@               ldd       4,x                 get address of routine to execute
                    beq       exit@               address is zero
                    leax      d,x                 point X to it
                    jsr       ,x                  go do the routine
exit@               rts                           return

* Routine to show the menu
* X = menu entry
ShowMenu
show@               ldb       ,x                  get the character at X
                    beq       done@               branch if 0
                    lbsr      PUTC                else print it
                    pshs      x                   save the menu pointer
                    lbsr      PRINTS
                    fcc       " - "
                    fcb       0
                    puls      x                   recover the menu pointer
                    ldd       2,x                 get the menu string address
                    pshs      x                   save the menu entry
                    leax      d,x                 point to it
                    lbsr      PUTS                print it
                    puls      x                   recover
norm@               leax      MENU_ENTRY_LEN,x    advance to the next menu entry
                    bra       show@               show it
done@               lbra      PUTCR               go put a carriage return

IcptRtn             inc       abortautoboot,u     increment the autoboot flag
                    lbsr      PUTCR
                    lbsr      GETC
                    rti                           our interrupt routine does nothing.

                    endsection
