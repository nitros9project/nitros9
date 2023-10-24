********************************
* Gsort - with mods for big dirs
* copyright (c) 1990, 1992, 1995 by
* M. E.(Gene) Heskett
* EMail to: wdtv@wdtv.com
* USE: gsort [-c] [directory]
* omit directory name for current
* omit '-c' for UnDel compatibility
* produces sorted disk directories
* for up to 1016 filenames per dir
* by way of an increase in the
* buffersize for lg $7F sector directories
*
* April 92, adding a -c option. Doesn't
* compact the dir unless -c present
* on cmnd line, else re-writes deleted
* entry's at end of dir now so
* UnDel can find them!
* 11/05/92, Version 10
* I can no longer discount a couple of
* reports I received that it hung on other
* peoples machines while in the sort routine,
* it actually did it to me twice.
* I hope this fixes that, see the docs please!
* Well, so much for version 10. Under the
* right set of conditions,it empties the directory!

* So here's version 12, 11 got skipped, was a
* trial fix that didn't work, no clues to the
* real problem till 10, then 11 hit me, of all people!
* Version 11 did leave a trail even a Brownie could
* follow tho, so the fix needed became obvious

* And now (with a tiny bit of fanfare noise)
* comes version 14. Why? Well, I just noticed
* that one of my editors makes a scratchfile
* using a ".ext" on the name. The ".ext" is
* removed by the rename but gsort brings it
* (the name extension) back in its attempts
* to be UnDel friendly. So this is really
* just another darned bugfix release.

bufsiz              equ       $7E00               USE EVEN NUMBERS HERE!

                    ifp1
                    use       defsfile
                    endc

                    mod       len,name,prgrm+objct,reent+4,entry,dsiz

path                rmb       1                   I/O path number
errnum              rmb       1                   save errnum(regs.B) here
compact             rmb       1                   tally for compaction enable
fixend              rmb       2                   for end of name fixer
clrptr              rmb       2                   to compare for clearing of end of entry
pointer             rmb       2                   filename pointer
pointer2            rmb       2                   comparison pointer
lastbuff            rmb       2                   for end of buffer ptr
buffer              rmb       bufsiz              directory buffer
                    rmb       300                 stack
                    rmb       200                 parameters
dsiz                equ       .

name                fcs       /GSort/             so multiview will use this!
                    fcb       14                  edition number up so override load
                    fcc       /(c) 1990, 1991, 1992, 1995 by M. E. Heskett /
current             fcs       /./                 current directory

************************************
* do window like original gsort does
* but just a one liner!
Owset               fcb       $1b,$22
Owprms              fcb       $01,$03,$03
                    fcb       Owend-tickle+2      width equ len of string
                    fcb       $01,$02,$03
select              fcb       $1b,$21
tickle              fcc       / GSort Ver.14 -> Sorting...../
Owend               fcb       $1b,$23
Wdatend             equ       *

******** SUBROUTINE 'SETUP' ***********
* first, see if -c option given
SETUP               lda       ,X+
                    cmpa      #'-
                    beq       SETUP1              yup got minus sign
                    cmpa      #$20                space?
                    beq       SETUP               yup, go
                    cmpa      #$0D                end of cmnd line?
                    bne       OOPS                nope, leave B alone
                    ldb       #$01                only one arg, use '.' dir
OOPS                leax      -1,X                restore pointer
                    rts                           PARAMS DONE

**************
SETUP1              lda       ,X+
                    anda      #$DF                make uppercase
                    cmpa      #'C
                    bne       OPTERR              very simple way out

**************
SETC                inc       <compact
                    bra       SETUP

***************************
* now skips any bad option!
OPTERR              lda       #E$IllArg
                    sta       <errnum             stash for later reference
                    bra       SETUP               and otherwise ignore it

************************
* first clear the buffer
entry               pshs      d,x,y               save it while zeroing buffer out
                    leax      buffer,u
                    leay      bufsiz,x
                    sty       <lastbuff
clrloop             clr       ,x+
                    cmpx      <lastbuff
                    bne       clrloop
                    puls      d,x,y
                    clra
                    sta       <errnum             clear the errnum tally
                    sta       <compact            clear the compaction flag too
                    bsr       SETUP
                    lbcs      out4                wrong option or ???

********************
* open the directory
                    decb                          parameters passed?
                    bne       open
                    leax      <current,pcr        no, use current "." directory

* Paul Jerkatis suggested non-shareable attribute
* in case of access conflicts
#open               lda       #updat.+dir.+share. update, non-share mode
open                lda       #updat.+dir.        update
                    os9       I$Open              open the directory
                    lbcs      out                 exit with error
                    sta       <path               else save the path number
                    bsr       skipdots            omit directory and parent

**************************
* make small prompt window
makscr              pshs      x,y
                    leax      Owset,pcr
                    ldy       #tickle-Owset
                    lda       #$01
                    os9       I$Write             make overlay window, small
                    bcc       continue
                    stb       <errnum             save it
                    cmpb      #203                illegal mode?
                    lbne      out                 with error
continue            leax      tickle,pcr
                    ldy       #Owend-tickle
                    lda       #$01
                    os9       I$Write
                    puls      x,y
                    lbcs      out2                with error but close window

*********************** get directory entries
* This process guarantees that the first char
* of each entry will be non-zero UNLESS
* its the next slot past the end of the data
getdir              leax      buffer,u
getentry            cmpx      <lastbuff           enough mem for next entry?
                    bmi       mavail              not outta memory yet
                    comb                          set error
                    ldb       #207
                    bra       error
mavail              clr       ,x                  end marker if not filled
                    leay      32,x                establish next pointer
                    sty       <pointer2           save it
                    ldy       #32                 length of entry
                    lda       <path
                    os9       I$Read              get the entry
                    bcs       error
                    tst       ,x                  see if its a deleted file
                    bne       okname              not a deleted entry

* this should fix to be non-discriminatory
* to a deleted filename, set at maxval
* so it sorts to bottom of list
                    lda       #$7F                1stchar to bottom of list
                    sta       ,x                  sorts empty to end of sorted dir

okname              tfr       x,y                 else save x to y, use y
                    ldb       #31                 the stopper
endloop             decb                          zero fails, checks 29 chars only
                    beq       getentry            is bad entry, get next
* else keep on looking
                    lda       ,y+                 end of name with set msb?
                    bpl       endloop             go look some more
* oops, its negative, make positive
                    anda      #$7F                clear minus (M.S.) bit
* now, was it an $80 from the disk?
* looking for V9,10,11 leftovers folks
                    beq       getentry            ba-bahhdd garbage stopper!
                    sta       -1,y                return to filename

******** y now marks end of name+1
* CLEANUP after rename, del & OS9's re-use
* of a deleted entry's space
cleanup             leax      29,x                offset x to end of namespace
                    stx       <clrptr             save for the compare below
clearbuf            cmpy      <clrptr             are we done right now?
                    bpl       clearend            V9 was BEQ! coulda failed
                    clr       ,y+                 else clear with post-inc
                    bra       clearbuf            & go check again
clearend            ldx       <pointer2           get the +32,x
                    bra       getentry            go get the next entry

*********** SUBROUTINE SKIPDOTS ************
* resets file pointer to skip . and .. entries
skipdots            pshs      u                   save u register
                    ldx       #0                  MS 16 bits of desired position
                    ldu       #64                 LS 16 bits of desired position
                    os9       I$Seek
                    puls      u
                    lbcs      out2                exit with error
                    rts

************** ERROR CHECKER **************
* if EOF, its ok, we came here from getdir
error               cmpb      #e$eof              end of file?
                    lbne      out2                exit with other error

****** NOW SORT AND OUTPUT EACH ENTRY ******
****** its eof, save it in clrptr
                    stx       <clrptr             is now end of dir in memory

*** reset file position for writing sorted entries
                    bsr       skipdots            reset directory pointer

************* sort directory entries
** start at top of data each sort pass
sort                leax      buffer,u            buffer address

* we might not have original x value on loop-back
sort1               stx       <pointer            save filename pointer
                    leay      32,x                point to next filename
sort2               lda       ,x                  check for zero at [x]
                    bmi       higher
                    beq       setend              if, its end of sort, no more data
                    bpl       sort3               good name, sort it
* its negative, been sorted, skip to next name
higher              tfr       y,x                 if minus (msb set), sorted
                    bra       sort1

* Now check for more data avail, if not then
* the present name is the winner of the sort
* for this pass, go write it & fix it maxhi
sort3               cmpy      <clrptr             end of valid data buffer?
                    bcc       output              x wins, write it.  V9=beq

* well, we missed that one, now cmp 1st chars
                    cmpa      ,y                  compare chars

* if [,x] higher, isn't lowest avail name
                    bhi       higher              not lowest avail name, do a skip for now

* if [,x] lower, keep x but check next name
                    blo       lower2              no match, continue sort

* it's the same first char, and its non-zero!
                    sty       <pointer2           we'll want it back

* ok, first chars same, check rest of name
* by looping to compare the names
compare             lda       ,x+                 filename character
* if=0 then end of name has been found
                    beq       lower               end of filename

* still have valid chars
                    cmpa      ,y+                 compare chars
                    beq       compare             if same, keep on looking

* oh oh, they're not same, which way off?
                    blo       lower               x is still winner, continue

* else x just lost, y is winner, restart sort at [y]
                    ldx       <pointer2           new filename pointer
                    bra       sort1               continue sort

* INC to next name X is being compared to
* come here if pointers need recharged
lower               ldx       <pointer            retrieve present x
                    ldy       <pointer2           and y
* speed opt, come here if pointers still good
lower2              leay      32,y                new comparison
                    bra       sort2               try again
*************** END OF SORT ********
********** Now output sorted entries
* one at a time as found, and fix 1st char to maxhi
output              lda       ,x                  get 1st char
                    cmpa      #$7F                =deleted entry
                    bne       output1             not a deleted entry
                    clr       ,x                  else 'del' the name again
                    tst       <compact            if <>, skip
                    bne       com                 if -c used, go, this ones empty

* we save this entry, deleted or not
* we get here with the last char of the name
* less than $7F, to do an 'fcs' we need to
* set the last chars D7 bit
* first, save x in y so we can use y
output1             tfr       x,y                 save x, use y for this
                    leax      30,x                set absolute ending address
                    stx       <fixend             at the ,y+ value
                    tfr       y,x                 recover x
fixloop             ldd       ,x+                 get chars to regs.a
                    cmpx      <fixend             y got an inc above
                    bcc       twnty9              no carry=end of name anyway
                    tstb                          end of name?
                    bne       fixloop             no, look some more
twnty9              ora       #%10000000          set msbit
                    sta       -1,x                return to filename
                    tfr       y,x                 recover original x
********************************
* here it could write a one char
* deleted file with that one char
* set to $80 at "twnty9" above
*********** get the first character
                    lda       ,x                  was that the first char?
*********** and compare to $80
                    cmpa      #$80                if $80, is deleted,saved 1 char
*********** if not, skip the re-delete
                    bne       wrtntry             they raise he!! with os9
                    clr       ,x                  DELETE IT AGAIN!
* now normal 'fcs' form or empty, write it back out
wrtntry             lda       <path
                    ldy       #32                 length of entry
                    os9       I$Write
                    bcs       out2

* set 1st char MSB so sort skips over
com                 lda       ,x                  take out of memory valid list
                    ora       #$80                set sorted indicator
                    sta       ,x                  and stuff it back in memory
                    bra       sort                and go get the next entry

***************SETEND*****************
* terminate directory - fix length etc
setend              lda       <path
                    ldb       #ss.pos             file pointer function
                    pshs      u                   save it for later
                    os9       I$GetStt            get pointer position
                    bcs       out3
                    ldb       #ss.size            file size function
                    os9       I$SetStt            set eof at pointer
                    bcs       out3
                    clrb
out3                puls      u
out2                pshs      cc,d,x,y
                    ldb       <errnum
                    cmpb      #203                illegal mode?
                    beq       out4                skip closing window if it wasn't opened
                    clrb
                    leax      Owend,pcr
                    ldy       #Wdatend-Owend
                    lda       #$01
                    os9       I$Write             end the window
out4                puls      cc,d,x,y            we don't care if an error here!
                    lda       <path
                    os9       I$Close
                    bcs       out                 report this one if err
                    ldb       <errnum             else option err?
                    beq       out                 nope
                    cmpb      #203                illegal mode?
                    beq       errout
                    comb                          oh-oh we got one
                    ldb       <errnum             reports error of our ways
out                 os9       F$Exit              auto closes open path
errout              clrb
* andcc #$FE clear carry?
                    bra       out

                    emod
len                 equ       *
                    end

