********************************************************************
* SysCall - system call subroutine module
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   2      ????/??/??
*          2018/01/19  L. Curtis Boyle
*                      Added more detailed comments to aid programmers
*
* From OS-9 Level Two Vr. 2.00.01 Basic09 disk.

                    nam       SysCall
                    ttl       system call subroutine module

* Disassembled 02/07/06 13:11:18 by Disasm v1.6 (C) 1988 by RML

                    ifp1
                    use       defsfile
                    endc

tylg                set       Sbrtn+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       2

                    mod       eom,name,tylg,atrv,start,size

* Usage: RUN Syscall(call #,ptr to register data block)

* stack params for all RUNB/BASIC09 subroutine calls with RUN. The first 2 params are
*  fixed (return address, and # of params passed). This is followed by pairs of:
* 1) Ptr to the data passed, and 2) the size of the parameter data,
*    for each parameter passed.
* Since, as a subroutine module, we don't get our own data area, we either have to be
*  passed a ptr to a "Safe zone" to manipulate, or use the stack. SYSCALL exclusively
*  uses the stack, since it it doesn't need a lot of data memory.
                    org       0
Return              rmb       2                   0:Return address of caller
PCount              rmb       2                   2:# of params following
PrmPtr1             rmb       2                   4:Ptr to 1st param data
PrmLen1             rmb       2                   6:size of 1st param
PrmPtr2             rmb       2                   8:Ptr to 2nd param data
PrmLen2             rmb       2                   $A:size of 2nd param
PrmSize             equ       *

                    org       0
u0000               rmb       0                   There is no data area for subroutine module
size                equ       .

name                fcs       /SysCall/
                    fcb       edition

start               ldd       PCount,s            get number of parameters
                    cmpd      #$0002              two? (system call #, ptr to register data being passed)
                    bne       L005C               if not, return with error
                    ldd       PrmLen2,s           get size of second parameter
                    cmpd      #$0A                Is the register packet the proper size (6809: CC,A,B,DP,X,Y,U=10 bytes)
                    bne       L005C               No, return with error
                    ldd       [<PrmPtr1,s]        Get System call # into D
                    ldx       PrmLen1,s           get size of first parameter
                    leax      -$01,x              1 byte (BYTE type)?
                    beq       L0034               Yes, continue
                    leax      -$01,x              2 byte (INTEGER type)?
                    bne       L005C               No, and that's the only 2 we can handle for the system call #, so exit with error
                    tfr       b,a                 It was a 2 byte INTEGER, but OS9 system calls only need 1, so move it A
L0034               ldb       #$39                RTS instuction
                    pshs      b,a                 put it and os9 system call # on stack
                    ldd       #$103F              get SWI2 instruction ('os9')
                    pshs      b,a                 put on stack (so stack is now 'os9 x$nam' & 'rts')
                    ldu       PrmPtr2+4,s         get pointer to caller's registers on stack (+4 is because we just put SWI2 and RTS on stack)
* Do not change the values on the following 4 lines LDD LDX LDY LDU because these require 6809 offsets only.  Even on 6309 CPU's
                    ldd       $01,u               R$D Get copies of registers from caller (no system calls have CC as input, or PC as input)
                    ldx       $04,u               R$X
                    ldy       $06,u               R$Y
                    ldu       $08,u               R$U
                    jsr       ,s                  Call our little 4 byte routine on stack (os9 x$nam / rts) with register values passed to us
                    pshs      u,cc                Save U and CC
                    ldu       PrmPtr2+7,s         Get ptr to caller's registers on stack again (+7 now from our 4 byte routine, plus saving U&CC)
* The following line needs to be the $08 rather than R$U because it needs to be forced to 6809 offsets only
                    leau      $08,u               R$U Offset to caller's U register on stack (push works up, so we are leaving U alone at this point)
                    pshu      y,x,dp,b,a          Put 4 of the registers returned from system call into appropriate spots over callers original ones
                    puls      x,a                 Get our saved copies of U and CC we got back from system call
                    sta       ,-u                 Save CC overtop callers original CC (for error flag)
* The following line needs to be the $08 rather than R$U because it needs to be forced to 6809 offsets only
                    stx       $08,u               R$U Save U return back from system call overtop caller's original U
                    leas      $04,s               Eat the 4 byte instruction sequence we made
                    clrb                          Return to caller with no error (it's up to them to read their copies of CC and B to determine if an error happened)
                    rts

L005C               comb                          Return to caller with Parameter error (wrong quantity or wrong type)
                    ldb       #E$ParmEr
                    rts

                    emod
eom                 equ       *
                    end
