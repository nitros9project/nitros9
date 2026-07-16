***************************************
**
idlin               fcc       "OS/9 Super Sleuth (CC) "
                    fcb       $04
                    fcc       " c1982 by CSC, Conyers GA 30207"
                    fcb       $04
                    fcc       " enter ? for help"
                    fcb       $04,$00
helps               fcc       " operational commands:"
                    fcb       $04
                    fcc       "  d/v-disassemble/view program"
                    fcb       $04
                    fcc       "  f-exit to OS/9"
                    fcb       $04
                    fcc       "  q/m-query/modify object code"
                    fcb       $04
                    fcc       "  t-fill addresses with value"
                    fcb       $04
                    fcc       "  u-enter OS/9 command"
                    fcb       $04
                    fcc       "  w-write new object code path"
                    fcb       $04
                    fcc       "  y-find hex string in code"
                    fcb       $04
                    fcc       " address range commands:"
                    fcb       $04
                    fcc       "  a=fdb,c=fcc,h=fcb,i=instr,"
                    fcc       "j=instr+chr,k=kill,r=rmb"
                    fcb       $04
                    fcc       " mode change commands:"
                    fcb       $04
croil               equ       *+8
                    fcc       "  b-flip x-assembler switch"
                    fcb       $04
equil               equ       *+8
                    fcc       "  e-flip separate-label switch"
                    fcb       $04
posil               equ       *+8
                    fcc       "  p-flip position-ind. switch"
                    fcb       $04
cpuil               equ       *+10
                    fcc       "  z-change cpu mode"
                    fcb       $04
                    fcc       " miscellaneous commands:"
                    fcb       $04
                    fcc       "  g-specify auxiliary i/o path"
                    fcb       $04
                    fcc       "  l-list control information"
                    fcb       $04
                    fcc       "  n-new range or memory module"
                    fcb       $04
offil               equ       *+7
                    fcc       "  o-set offset load value "
                    fcb       $04
disim               equ       *+11
                    fcc       "  s-specify input path "
                    fcb       $07,$04
lxfer               equ       *+7
                    fcc       "  x-set xfer-address "
                    fcb       $07,$04,$00
shotab              fcc       "     "
                    fcc       ".0 .1 .2 .3 .4 .5 .6 .7 "
                    fcb       $04
                    fcc       ".8 .9 .a .b .c .d .e .f "
                    fcb       $04
shota1              fcc       " 01234567"
                    fcb       $04
                    fcc       "89abcdef"
                    fcb       $04
shota2              fcc       "/start/=</end/=>"
                    fcc       "/adr=!/chr=#/hex=(/ins=)/inc=*/kil=+/rmb="
                    fcb       $22
                    fcc       "/scrn/quit/prev/addr/ ?"
                    fcb       $00
loss9               fcc       " OS/9"
                    fcb       $04
lflex               fcc       " Flex"
                    fcb       $04
phace               fcc       " Phase "
                    fcb       $07,$04
disom               fcc       " output path name "
                    fcb       $07,$04
prtnm               fcc       " printer path name "
                    fcb       $07,$04
altnm               fcc       " auxiliary"
                    fcb       $07,$04
lenter              fcc       " enter"
                    fcc       " p(printer), t(terminal),"
                    fcc       " b(both), n(no output) "
                    fcb       $07,$04
lmode               fcc       " 0=6800/2/8,1=6801/3,2=6502,5=[14]6805,9=6809 "
                    fcb       $04
lon                 fcc       " on"
                    fcb       $04
loff                fcc       " off"
                    fcb       $04
ltext               fcc       "module "
                    fcb       $04
ldata               fcc       "storage"
                    fcb       $04
lxtnt               fcc       "extent "
lstar               fcc       " start="
                    fcb       $04
lendr               fcc       " end="
                    fcb       $04
lvalue              fcc       " value="
                    fcb       $04
vshell              fcs       "shell"
badfil              fcc       " bad format!"
                    fcb       $07,$04
tabov               fcc       " table overflow!"
                    fcb       $07,$04
invrg               fcc       " bad range!"
beeps               fcb       $07,$04             bell
errirz              fcc       "error on input path"
errirl              equ       *-errirz+1
                    fcb       $07,$04
errorz              fcc       "error on output path"
errorl              equ       *-errorz+1
                    fcb       $07,$04
errarz              fcc       "error on auxiliary path"
errarl              equ       *-errarz+1
                    fcb       $07,$04
errprz              fcc       "error on printer path"
errprl              equ       *-errprz+1
                    fcb       $07,$04
errexc              fcc       "error in OS/9 call"
errexl              equ       *-errexc+1
                    fcb       $07,$04
bequb               fcb       $03
                    fcc       "equ"
                    fcb       $05,$04
bequa               fcc       "*+"
                    fcb       $04
orges               fcb       $03
                    fcc       "org"
                    fcb       $05,$24,$04         $
rmbes               fcb       $03
                    fcc       "rmb"
                    fcb       $05,$24,$04         $
sysdef              fcb       $03
                    fcc       "ifp1"
                    fcb       $0d,$03
                    fcc       "use"
                    fcb       $05
                    fcc       "/DD/DEFS/"
                    fcc       "defsfile"          level 1.2/2.x
                    fcb       $0d,$03
                    fcc       "endc"
                    fcb       $0d,$03
                    fcc       "ttl Code by CSC OS/9 Super Sleuth3 "
                    fcb       $0d
lverso              fcb       $02
                    fcc       "verson"
                    fcb       $03
                    fcc       "equ"
                    fcb       $05,$24,$30,$04     $0
lnamem              fcb       $02
                    fcc       "namemd"
                    fcb       $03
                    fcc       "equ"
                    fcb       $05,$04
lxfera              fcb       $02
                    fcc       "xferad"
                    fcb       $03
                    fcc       "equ"
                    fcb       $05,$04
lmodul              fcc       "0000"
                    fcb       $03
                    fcc       "mod"
                    fcb       $05
                    fcc       "endmod,namemd,"
                    fcb       $04
llangs              fcc       "+Objct,"
                    fcb       $04
lreent              fcc       "ReEnt+"
                    fcb       $04
lversi              fcc       "verson,xferad,endmem"
                    fcb       $04
lemmod              fcb       $02
                    fcc       "endmem"
                    fcb       $04,$03
                    fcc       "equ"
                    fcb       $05,$2e,$04         .
endos9              fcb       $03
                    fcc       "emod"
                    fcb       $0d,$02
                    fcc       "endmod equ"
                    fcb       $05,$2a,$0d,$04     *
endes               fcb       $03
                    fcc       "end"
                    fcb       $05,$04
lcpcr               fcc       ",pcr"              ,pcr
                    fcb       $04
lposr               fcc       "pshs]*,a,b%"
                    fcc       "[lea*](($ffff-(!))+1),pcr%"
                    fcc       "[tfr]*,d%"
                    fcc       "[addd]2,s%"
                    fcc       "[puls]*,a,b"
                    fcb       $00
lposs               fcc       "pshs]u,a,b%"
                    fcc       "[leau]($fffa-(!)),pcr%"
                    fcc       "[pshs]u%"
                    fcc       "[tfr]s,d%"
                    fcc       "[addd],s++%"
                    fcc       "[puls]u,a,b"
                    fcb       $00
ltypes              fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcc       "Prgrm"
                    fcb       $04,$04,$04
                    fcc       "Sbrtn"
                    fcb       $04,$04,$04
                    fcc       "Multi"
                    fcb       $04,$04,$04
                    fcc       "Data"
                    fcb       $04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcb       $04,$04,$04,$04,$04,$04,$04,$04
                    fcc       "Systm"
                    fcb       $04,$04,$04
                    fcc       "FlMgr"
                    fcb       $04,$04,$04
                    fcc       "Drivr"
                    fcb       $04,$04,$04
                    fcc       "Devic"
                    fcb       $04
**
predef              equ       *
pfcbxx              fcb       $03
                    fcc       "fcb"
                    fcb       $05,$24,$04         $
pfccxx              fcb       $03
                    fcc       "fcc"
                    fcb       $05,$22             "
pinst1              fcb       $00,$00,$00,$00,$00
                    fcc       "                                "
pfdbxx              fcb       $03
                    fcc       "fdb"
                    fcb       $05,$04
pzlabel             fcb       $7a,$04             z
pulabel             fcb       $75,$04             u
pxlabel             fcb       $78,$04             x
plnames             fcc       " title   "
                    fcb       $04
pnames              fcb       $03
                    fcc       "nam"
                    fcb       $05
                    fcc       "                                "
ploptes             fcc       " options "
                    fcb       $04
poptes              fcb       $03
                    fcc       "opt"
                    fcb       $05
                    fcc       "                                "
* pshpul contains 6809 reg names for psh and pul
ppshpu              fcb       $70,$63,$73,$00,$79,$00,$78,$00 pc s  y  x
                    fcb       $64,$70,$62,$00,$61,$00,$63,$63 dp b  a  cc
preend              equ       *
* ifeq h6309-1
* wpshpu cintains 6309 reg name for pshxw and pulxw
*wpshpu
* fcb $77,$00 w
*wpshend equ *
* ldst309 contains reg names for 6309 load store ops
*ldst309 fcb $77,$00,$71,$00,$66,$00,$65,$00 w q f e
*ldstend equ *
* endc
*
** command table for command interpreter
coman               equ       *                   command table
                    fdb       helpme-coman        ?
                    fdb       gtype-coman         a
                    fdb       fcrof-coman         b
                    fdb       gtype-coman         c
                    fdb       disas-coman         d
                    fdb       fequf-coman         e
                    fdb       fexit-coman         f
                    fdb       auxino-coman        g
                    fdb       gtype-coman         h
                    fdb       gtype-coman         i
                    fdb       gtype-coman         j
                    fdb       gtype9-coman        k
                    fdb       dmptab-coman        l
                    fdb       examin-coman        m
                    fdb       newrng-coman        n
                    fdb       oload-coman         o
                    fdb       fposf-coman         p
                    fdb       showaa-coman        q
                    fdb       gtype9-coman        r
                    fdb       diskd-coman         s
                    fdb       fillup-coman        t
                    fdb       doscom-coman        u
                    fdb       disas-coman         v
                    fdb       writem-coman        w
                    fdb       sxfer-coman         x
                    fdb       findst-coman        y
                    fdb       setmod-coman        z
**db setmod-coman z
