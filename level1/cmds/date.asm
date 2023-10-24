********************************************************************
* Date - Print Date/Time
*
* $Id$
*
* Greetings;                                     September 25, 1996
*
* This 'Date' module, date5, has been expanded a wee bit to
* make it smart enough to handle dates to the year 2099.
*
* In order to have it do it in a math conversion, I would have had to
* make the 8 bit math it does into 16 bit, and there aren't enough
* registers in the 6809 to pull that off in a reasonable code size.
* So it still does 8 bit math, but only has a 1900-2099 year total
* range.  This is more than the recently converted clock for the Disto
* 4n1 I just uploaded, as that clock now has a range from 1980 to 2079.
* A simple subtraction determines if it prints a leading 20, and the
* contents of the register after the subtraction, or it reloads the
* string pointer to point at 19 and reloads the year register to get
* the year 00-99 to print.
*
* This contains no 6309 specific code, so Nitros9 and a 6309 cpu
* are not required to use it, box stock is fine.
*
* Gene Heskett, <gene_heskett@wvlink.mpl.com>
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   5      1996/09/25  Gene Heskett
* Made Y2K compliant.
*
*   6      1999/05/07  Boisy G. Pitre
* Made compliant with 1900-2155.
*
*   7      2003/01/14  Boisy G. Pitre
* New option is now -t, code compacted a bit.
*
*   8      2004/06/07  Rodney V. Hamilton
* Compacted date conversion and printing.

                    nam       Date
                    ttl       Print Date/Time

                    ifp1
                    use       defsfile
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       8

                    mod       eom,name,tylg,atrv,start,size

                    org       0
sysyear             rmb       1
sysmonth            rmb       1
sysday              rmb       1
syshour             rmb       1
sysmin              rmb       1
syssec              rmb       1
bufptr              rmb       2
buffer              rmb       40
                    rmb       400
size                equ       .

name                fcs       /Date/
                    fcb       edition

MonTable            fcs       '???'
                    fcs       'January'
                    fcs       'February'
                    fcs       'March'
                    fcs       'April'
                    fcs       'May'
                    fcs       'June'
                    fcs       'July'
                    fcs       'August'
                    fcs       'September'
                    fcs       'October'
                    fcs       'November'
                    fcs       'December'

start               pshs      x
                    leax      sysyear,u
                    leau      buffer,u
                    stu       <bufptr
                    os9       F$Time
                    bsr       Add2Buff            go print the date in buffer
                    ldd       [,s++]              now, did we have a -t
                    andb      #$DF
                    cmpd      #$2D54              -T?
                    bne       PrBuff              wasn't
                    ldd       #C$SPAC*256+C$SPAC  else space it out
                    std       ,u++
                    bsr       DoTime              and go add the time to the buffer
PrBuff              lda       #C$CR               terminate the line to print
                    sta       ,u+
                    lda       #1                  standard out
                    ldx       <bufptr
                    ldy       #40
                    os9       I$WritLn            and go print it
                    bcs       Exit
                    clrb
Exit                os9       F$Exit

DoTime              ldb       <syshour
                    bsr       Byte2ASC
                    ldb       <sysmin
                    bsr       L00AB
                    ldb       <syssec
L00AB               lda       #':
                    sta       ,u+
                    bra       Byte2ASC

Add2Buff            leay      >MonTable,pcr       point to month table
                    ldb       <sysmonth           get month byte
                    beq       L00C4               branch if zero (illegal)
                    cmpb      #12                 compare against last month of year
                    bhi       L00C4               if too high, branch
L00BD               lda       ,y+                 get byte
                    bpl       L00BD               keep going if hi bit not set
                    decb                          else decrement month
                    bne       L00BD               if not 0, keep going
L00C4               bsr       PrtStrng
                    ldb       <sysday
                    bsr       Byte2ASC
                    ldd       #C$COMA*256+C$SPAC  get comma and space in D
                    std       ,u++                store in buffer and increment twice
                    lda       <sysyear            get year
                    ldb       #19-1               century in B
CntyLp              incb                          add a century
                    suba      #100                subtract 100 yrs
                    bhs       CntyLp              until yr<0
                    adda      #100                restore year to 00-99 range
                    pshs      a                   save year
                    bsr       Byte2ASC            print century
                    puls      b                   restore year & print

* write B reg to buffer as 2-digit decimal ASCII
* we don't need to do 100s digit, value are 00-99
Byte2ASC            lda       #'0-1               start A out just below $30 (0)
Tens                inca                          inc it
                    subb      #10                 subtract 10
                    bcc       Tens                if result >= 0, continue
                    sta       ,u+                 else save 10's digit
                    addb      #'0+10
                    stb       ,u+                 and 1's digit
                    rts

*  *  *  *  *  *  *  *  *  *  *
* make fcs strings printable
PrtStrng            lda       ,y
                    anda      #$7F
                    sta       ,u+
                    lda       ,y+
                    bpl       PrtStrng
                    lda       #C$SPAC
                    sta       ,u+
                    rts

*  *  *  *  *  *  *  *  *  *  *
* all done here folks
                    emod
eom                 equ       *
                    end

