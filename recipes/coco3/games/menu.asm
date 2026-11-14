* Numbered game launcher; each selection runs its private shell script.
        use defsfile
        mod endmod,name,Prgrm+Objct,ReEnt+1,start,mem
buf     rmb 16
choice  rmb 1
scriptfd rmb 1
savedfd rmb 1
termfd  rmb 1
launchptr rmb 2
        rmb 256
mem     equ .
name    fcs /games/
        fcb 1
start   clr termfd,u
again   lda #1
        leax select,pcr
        ldy #2
        os9 I$Write
        lda termfd,u
        beq showmenu
        os9 I$Close
        clr termfd,u
showmenu
        lda #1
        leax menu,pcr
        ldy #menuend-menu
        os9 I$Write
        clra
        leax buf,u
        ldy #16
        os9 I$ReadLn
        lbcs done
        leax buf,u
        clr choice,u
parse   lda ,x+
        cmpa #13
        beq picked
        suba #'0
        lbcs again
        cmpa #9
        lbhi again
        pshs a
        lda choice,u
        cmpa #9
        bhi bad
        ldb #10
        mul
        addb ,s+
        stb choice,u
        bra parse
bad     leas 1,s
        bra again
picked  ldb choice,u
        lbeq done
        cmpb #GameCount
        lbhi again
        decb
        lda #4
        mul
        leax paths,pcr
        leay d,x
        ldd ,y
        leax d,x
        stx launchptr,u
        leax paths,pcr
        ldd 2,y
        leax d,x
* Select the game device while path 1 still refers to the menu's console.
* Rebinding path 1 first loses CoWin's reference to the previously active device.
        lda #UPDAT.
        os9 I$Open
        lbcs forkerror
        sta termfd,u
        leax select,pcr
        ldy #2
        os9 I$Write
        lbcs forkerror
        ldx launchptr,u
* Shell command files are inherited on path 0, not passed as program arguments.
        lda #READ.
        os9 I$Open
        bcs forkerror
        sta scriptfd,u
        clra
        os9 I$Dup
        bcs closeerror
        sta savedfd,u
        clra
        os9 I$Close
        lda scriptfd,u
        os9 I$Dup
        pshs cc,b
        lda scriptfd,u
        os9 I$Close
        puls b,cc
        bcs restoreerror
        pshs u
        leau quiet,pcr
        ldy #3
        leax shell,pcr
        ldd #$1100
        os9 F$Fork
        puls u
        bsr restore
        bcs forkerror
        os9 F$Wait
        tstb
        lbeq again
        pshs b
        leax childmsg,pcr
        bra report
forkerror
        pshs b
        leax forkmsg,pcr
report  lda #1
        ldy #80
        os9 I$WritLn
        puls b
        os9 F$PErr
        clra
        leax buf,u
        ldy #16
        os9 I$ReadLn
        lbra again
closeerror
        pshs b,cc
        lda scriptfd,u
        os9 I$Close
        puls b,cc
        lbra forkerror
restoreerror
        bsr restore
        lbra forkerror
restore pshs d,cc
        clra
        os9 I$Close
        lda savedfd,u
        os9 I$Dup
        lda savedfd,u
        os9 I$Close
        puls d,cc,pc
done    clrb
        os9 F$Exit
select  fcb $1b,$21
shell   fcc /shell/
empty   fcb 13
quiet   fcc /-p/
        fcb 13
forkmsg fcc /Could not start launcher; press Enter./
        fcb 13
childmsg fcc /Launcher exited; press Enter./
        fcb 13
        use menu-data.asm
        emod
endmod  equ *
        end
