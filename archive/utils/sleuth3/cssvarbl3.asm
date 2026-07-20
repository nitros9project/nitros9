***************************************
**
                    org       $0000
**
tabsiz              equ       $4000               default table space
**
prermb              equ       .                   see cssconst for these variables
fcbxx               rmb       7
fccxx               rmb       6
inst1               rmb       1
inst2               rmb       1
inst3               rmb       1
inst4               rmb       1
inst5               rmb       33
fdbxx               rmb       6
zlabel              rmb       2
ulabel              rmb       2
xlabel              rmb       2
lnames              rmb       10
names               rmb       37
loptes              rmb       10
optes               rmb       37
pshpul              rmb       16
prelen              equ       (.-prermb)
**
temps               equ       .                   start of work areas
baddr               rmb       2                   output of xbadr
caddr               rmb       2                   current addr
daddr               rmb       2                   hold addr
eaddr               rmb       2                   end addr
gaddr               rmb       2                   hold addr
iaddr               rmb       2                   instr save area ptr
maddr               rmb       2                   hold addr
oaddr               rmb       2                   offset addr
paddr               rmb       2                   hold addr
qaddr               rmb       2                   hold addr
raddr               rmb       2                   hold addr
saddr               rmb       2                   curr mem addr
xaddr               rmb       2                   xfer addr
zaddr               rmb       2                   hold addr
rmblth              rmb       2                   rmb length
faddr               rmb       2                   start addr
taddr               rmb       2                   end addr
types               rmb       2                   type table start
typee               rmb       2                   type table end
typem               rmb       2                   map table end
addre               rmb       2                   addr table end
stkadr              rmb       2                   stack hold addr
saves               rmb       2                   s-reg hold area
savew               rmb       2                   hold area for write routine
savex               rmb       2                   x-reg hold area
aoptab              rmb       2                   optabx addr
aintab              rmb       2                   intabx addr
asuftb              rmb       2                   suftbx addr
adrptr              rmb       2                   address ptr
alimit              rmb       2                   limit addr ptr
mystk               rmb       2                   top of stack
**
insbeg              equ       .                   first instr field
fllth               rmb       1                   length
fllts               rmb       1                   length from table
flopc               rmb       1                   instr
flsuf               rmb       1                   suffix
flmod               rmb       1                   mode
flspc               rmb       1                   special flag
flimm               rmb       1                   immediate
flinx               rmb       1                   indexed
flind               rmb       1                   indirect
flpls               rmb       1                   plus count
flmin               rmb       1                   minus count
flreg               rmb       1                   reg id
flamf               rmb       1                   addr mode field
floff               rmb       1                   offset id
flisw               rmb       1                   instr save switch
flabl               rmb       1                   labelled
flpos               rmb       1                   pos-ind flag
worka               rmb       1                   work area
instd               rmb       1                   default type
instr               rmb       1                   instr byte
instx               rmb       1                   type
insty               rmb       1                   type
instz               rmb       1                   type hold
**
insxx               equ       .                   name
inam0               rmb       1                   name letter 0
inam1               rmb       1                   name letter 1
inam2               rmb       1                   name letter 2
inam3               rmb       1                   name letter 3
inam4               rmb       1                   name letter 4
inam5               rmb       1                   name letter 5
insend              equ       .                   last instr field
inamx               rmb       1                   eot
**
cchar               rmb       1                   curr char
horptr              rmb       1                   horizontal pos
vrtptr              rmb       1                   vertical pos
phase               rmb       1                   phase number
pmode               rmb       1                   cpu mode
maxln               rmb       1                   max number items/line
escswt              rmb       1                   escape return switch
modmsk              rmb       1                   mode mask
posfl               rmb       1                   pos-ind switch
crtfl               rmb       1                   console switch
prnfl               rmb       1                   printer switch
disif               rmb       1                   disk input switch
disof               rmb       1                   disk output switch
getfl               rmb       1                   alt input switch
noecho              rmb       1                   no-echo flag
confl               rmb       1                   console flag
prtfl               rmb       1                   printer flag
dskfl               rmb       1                   disk flag
equfl               rmb       1                   equ flag
crofl               rmb       1                   cross-assembler flag
dorgs               rmb       1                   org flag
comand              rmb       1                   command character
column              rmb       1                   column number
defalt              rmb       1                   default memory type
**
objhdr              equ       .                   object module header
obiden              rmb       2                   ident ($87cd)
obsize              rmb       2                   size
obname              rmb       2                   name offset
obtyla              rmb       1                   type and language
obatre              rmb       1                   attributes and revision
obpari              rmb       1                   header parity check (xor)
obxfer              rmb       2                   xfer address
obstor              rmb       2                   storage address
objlth              equ       .-objhdr            object header length
**
crcacc              rmb       3                   crc accumulator
svcflg              rmb       1                   svc(ff)/none(00) indicator
os9flx              rmb       1                   os9(ff)/flex(00) indicator
lauorz              rmb       1                   u/z temp label name prefix
zulabe              rmb       1                   u/z label name prefix
objos9              equ       .-objhdr            object header length
**
inlrec              rmb       3                   random record index
curmod              rmb       3                   index of current module
nxtmod              rmb       3                   index of next module
scfopg              rmb       1                   pause flag
scfopp              rmb       1                   pause flag
ttyswt              rmb       1                   tty initialization switch
**
*
* buffers and I/O blocks
*
iobfc               equ       0                   function code
iobba               equ       1                   buffer address
iobbl               equ       3                   buffer length
iobfd               equ       5                   path descriptor
iobca               equ       7                   next char address
iobcc               equ       9                   char counter
ioblen              equ       16                  length of i/o block
buflen              equ       512                 length of i/o buffer
bufaux              equ       256                 length of auxiliary i/o buffer
buftrm              equ       256                 length of terminal i/o buffer
fnmlen              equ       128                 length of path name
read                equ       1                   read block raw
rdln                equ       2                   read block edited
write               equ       3                   write block raw
wrln                equ       4                   write block edited
**
                    rmb       ((((.+$00ff)/$100)*$100)-.) round to 256 bytes
**
inbuff              rmb       buflen              input buffer
oarea               equ       .                   temp screen area
otbuff              rmb       buflen              output buffer
harea               equ       .                   temp screen area
prbuff              rmb       buflen              printer buffer
axbuff              rmb       bufaux              auxiliary input buffer
tibuff              rmb       buftrm              terminal input buffer
tobuff              rmb       buftrm              terminal output buffer
**
infile              rmb       fnmlen              input path name
inblok              rmb       ioblen              input path rb
otfile              rmb       fnmlen              output path name
otblok              rmb       ioblen              output path rb
prfile              rmb       fnmlen              printer path name
prblok              rmb       ioblen              printer path rb
axfile              rmb       fnmlen              auxiliary path name
axblok              rmb       ioblen              auxiliary path rb
tiblok              rmb       ioblen              terminal input rb
toblok              rmb       ioblen              terminal output rb
**
scfolg              rmb       32                  scfman orig get options
scfolp              rmb       32                  scfman orig put options
scfwkg              rmb       32                  scfman work get options
scfwkp              rmb       32                  scfman work put options
**
locstk              rmb       512                 local save area
**
endpr               equ       .                   end program storage
                    rmb       tabsiz              reserve area for tables
tempe               equ       .                   end of tables
endprg              equ       .                   end of program
**
scrnwd              equ       12+4                screen width 4,8,16
scrbyt              equ       (scrnwd*16)         screen byte count
scrwid              equ       scrnwd              screen data width
scrhex              equ       (scrnwd*2-1)        screen hex end
scrals              equ       (scrnwd*2)          screen alpha start
scrale              equ       (scrnwd*3-2)        screen alpha end
