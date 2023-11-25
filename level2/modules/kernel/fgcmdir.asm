**************************************************
* System Call: F$GCMDir
*
* Notes:
* This system call is only used by OS9p1 to get rid of all
* the empty spaces in the module directory to keep it small
* and compact.
*
* Input:  X = Address of allocation bitmap
*         D = Number of first bit to set
*         Y = Bit count (number of bits to set)
*
* Output: None
*
* Error:  CC = C bit set; B = error code
*
FGCMDir        ldx       <D.ModDir           get pointer to module directory start
               bra       L0C1D               skip ahead
L0C17          ldu       MD$MPDAT,x          DAT initialized?
               beq       L0C23               no it's empty skip ahead
               leax      MD$ESize,x          move to next entry
L0C1D          cmpx      <D.ModEnd           end of module directory?
               bne       L0C17               no, keep looking
               bra       L0C4B
* Move all entrys up 1 slot in directory
L0C23          tfr       x,y                 move empty entry pointer to Y
               bra       L0C2B
L0C27          ldu       MD$MPDAT,y
               bne       L0C34
L0C2B          leay      MD$ESize,y
               cmpy      <D.ModEnd           done complete directory?
               bne       L0C27               no, keep going
               bra       L0C49
* Move entry up 1 slot in directory
L0C34          equ       *
               ifne      H6309
               ldw       #MD$ESize
               tfm       y+,x+
               else      
               ldu       ,y++
               stu       ,x++
               ldu       ,y++
               stu       ,x++
               ldu       ,y++
               stu       ,x++
               ldu       ,y++
               stu       ,x++
               endc      
L0C44          cmpy      <D.ModEnd           done complete directory?
               bne       L0C27               no, keep going

L0C49          stx       <D.ModEnd           save new module directory end pointer
* Shrink DAT table
L0C4B          ldx       <D.ModDir+2         get module directory DAT end pointer
               bra       L0C53

L0C4F          ldu       ,x
               beq       L0C5B
L0C53          leax      -2,x                Bump module ptr down by 2
               cmpx      <D.ModDAT           Hit beginning yet?
               bne       L0C4F               No, keep checking
               clrb                          Yes, return without error
               rts       

L0C5B          ldu       -2,x
               bne       L0C53
               tfr       x,y
               bra       L0C67

L0C63          ldu       ,y
               bne       L0C70
L0C67          leay      -2,y
L0C69          cmpy      <D.ModDAT
               bcc       L0C63
               bra       L0C81
L0C70          leay      2,y
               ldu       ,y
               stu       ,x
L0C76          ldu       ,--y
               stu       ,--x
               beq       L0C87
               cmpy      <D.ModDAT
               bne       L0C76

L0C81          stx       <D.ModDAT
               bsr       L0C95
               clrb                          Yes, return without error
               rts       

L0C87          leay      2,y
               leax      2,x
               bsr       L0C95
               leay      -4,y
               leax      -2,x
               bra       L0C69

* Update Module Dir Image Ptrs
L0C95          pshs      u
               ldu       <D.ModDir
               bra       L0CA4
L0C9B          cmpy      MD$MPDAT,u          same DAT ptrs?
               bne       L0CA2               no, skip
               stx       MD$MPDAT,u          else update ptrs
L0CA2          leau      MD$ESize,u          next entry
L0CA4          cmpu      <D.ModEnd           last entry?
               bne       L0C9B               no
               puls      u,pc                else yes... return
