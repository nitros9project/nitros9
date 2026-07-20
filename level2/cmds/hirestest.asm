********************************************************************
* HiresTest - Exercise the application screen services
*
* Allocate a 320x192 four-color screen, draw four color bands in its
* mapped memory, display it until a key is read, then restore and free it.
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2026/07/15  Initial version.

                    nam       HiresTest
                    ttl       Test the application screen services

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       1

                    mod       eom,name,tylg,atrv,start,size

ScreenNum           rmb       1                   allocated application screen number
ScreenAddr          rmb       2                   mapped address of screen memory
ErrorCode           rmb       1                   first error encountered during the test
Key                 rmb       1                   byte read while the screen is displayed
                    rmb       128                 local stack
size                equ       .

name                fcs       /HiresTest/
                    fcb       edition

start               clr       <ErrorCode          assume success until an OS-9 call fails
                    lda       #$01                use standard output's VTIO path
                    ldx       #$0001              request type 1: 320x192, four colors
                    ldy       #$0000              SS.AScrn does not use an input Y value
                    ldb       #SS.AScrn           select the allocate-screen service
                    pshs      u                   preserve the program data pointer across F$MapBlk
                    os9       I$SetStt            allocate and map the application screen
                    puls      u                   restore access to the program's data area
                    lbcs      ExitError           missing co3hires or allocation failure
                    stx       <ScreenAddr         remember the mapped screen address
                    tfr       y,d                 move the returned screen number into B
                    stb       <ScreenNum          remember the screen for display and free
                    bsr       DrawBands           paint the bitmap before changing display hardware
                    clra                          form the returned screen number in D/Y
                    ldb       <ScreenNum          get the allocated application screen
                    tfr       d,y                 pass its screen number in Y
                    lda       #$01                issue the service on standard output
                    ldb       #SS.DScrn           select the display-screen service
                    os9       I$SetStt            make the application screen visible
                    bcs       SaveAndCleanup      restore and free if display failed
                    ldx       #$0002              allow VTIO two ticks to switch hardware
                    os9       F$Sleep             wait until the application screen is active
                    bcs       SaveAndCleanup      clean up if the wait was interrupted
                    ldd       #$0009              black and blue for pixel values zero and one
                    std       >$FFB0              program GIME palette registers zero and one
                    ldd       #$243F              red and white for pixel values two and three
                    std       >$FFB2              program GIME palette registers two and three
                    clra                          read from standard input
                    leax      Key,u               point at the one-byte input buffer
                    ldy       #$0001              wait for exactly one input byte
                    os9       I$Read              leave the test image up until a key arrives
                    bcc       Cleanup             a key was read; tear down normally

SaveAndCleanup      stb       <ErrorCode          retain the failure across cleanup calls
Cleanup             ldy       #$0000              screen zero restores VTIO's normal display
                    lda       #$01                issue display service on standard output
                    ldb       #SS.DScrn           select the display-screen service
                    os9       I$SetStt            switch away from application screen memory
                    bcc       ResetPalette        restore colors after switching displays
                    bsr       RecordError         retain this error only if none came first
ResetPalette        lda       #$01                send reset command on standard output
                    leax      DefaultPalette,pcr  point to the default-palette command
                    ldy       #$0002              command contains escape and reset bytes
                    os9       I$Write             restore the terminal's default palette
                    bcc       FreeScreen          continue when palette restoration succeeds
                    bsr       RecordError         retain this error only if none came first
FreeScreen          clra                          form the saved screen number in D/Y
                    ldb       <ScreenNum          get the application screen to release
                    tfr       d,y                 pass its screen number in Y
                    lda       #$01                issue free service on standard output
                    ldb       #SS.FScrn           select the free-screen service
                    os9       I$SetStt            unmap and release application screen memory
                    bcc       Exit                cleanup completed successfully
                    bsr       RecordError         retain this error only if none came first
Exit                ldb       <ErrorCode          return the first error, or zero on success
                    beq       ExitProcess         no error needs to be reported
                    pshs      b                   preserve the error while printing its message
                    os9       F$PErr              identify the failed screen operation for the user
                    puls      b                   return the original error status to the shell
ExitProcess         os9       F$Exit              return control to the shell

ExitError           stb       <ErrorCode          report an allocation or missing-module error
                    bra       Exit                nothing was allocated, so no cleanup is needed

* Record B as the result only when an earlier operation has not already failed.
RecordError         tst       <ErrorCode          has an earlier failure already been saved?
                    bne       RecordDone          yes, preserve the original error code
                    stb       <ErrorCode          no, make this cleanup error the result
RecordDone          rts                           return to cleanup

DefaultPalette      fcb       $1B,$30              restore the driver's default palette

* A type-1 screen has 80 bytes per row and 192 rows. Each byte holds four
* two-bit pixels, so $00, $55, $AA, and $FF produce solid color bands.
DrawBands           ldx       <ScreenAddr         point X at mapped application screen memory
                    clra                          begin with four pixels of color zero
                    ldb       #$04                draw one band in each of the four colors
NextBand            ldy       #3840               48 rows times 80 bytes per row
FillBand            sta       ,x+                 write four same-color pixels and advance
                    leay      -1,y                count down bytes remaining in this band
                    bne       FillBand            fill all 48 rows with the current color
                    adda      #$55                advance to the next repeated two-bit color
                    decb                          count this completed color band
                    bne       NextBand            draw all four bands
                    rts                           return with the visible bitmap complete

                    emod
eom                 equ       *
                    end
