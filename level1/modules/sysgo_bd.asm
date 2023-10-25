* SysGo - with config file

                    ifp1
                    use       defsfile
                    endc

                    ttl       Code by CSC OS/9 Super Sleuth v3.0

verson              equ       $03

                    mod       endmod,namemd,Prgrm+Objct,verson,start,endmem

                    org       0
White.              rmb       1
Blue.               rmb       1
Black.              rmb       1
Green.              rmb       1
Red.                rmb       1
Yellow.             rmb       1
Magenta.            rmb       1
Cyan.               rmb       1

                    org       $0000
u0000               rmb       $0020
u0020               rmb       $002A
u004A               rmb       $0027
u0071               rmb       $028F
u0300               rmb       $0050
u0350               rmb       $0001
endmem              equ       .

                    nam       SysGo
x0000               equ       $0000
x0001               equ       $0001
x0010               equ       $0010
x0050               equ       $0050
x0068               equ       $0068
x006B               equ       $006B
x0073               equ       $0073
x00AD               equ       $00AD
x0350               equ       $0350
xFFA8               equ       $FFA8
z0000               equ       $0000
z000D               equ       *

namemd              fcs       "SysGo"
                    fcb       $06
                    fcc       "Copyright Bob Devries & Don Berrie"
                    fcc       "Adapted to NitrOS9 by Bill Pierce 2017"

banner              equ       *
                    fcb       $2,$33,$20,$1b,$32,Red.
                    fcc       "NITROS-9 "
                    fcb       $1b,$32,Green.
                    fcc       "LEVEL 2 "
                    fcb       $1b,$32,Blue.
                    fcc       "v03.03.00 "
                    fcb       $1b,$32,Red.
                    fcc       "COPYRIGHT 2017"
*			fcb		$0D,$0A
                    fcb       $2,$39,$21,$1b,$32,Green.
                    fcc       "THE "
                    fcb       $1b,$32,Blue.
                    fcc       "NITROS-9 "
                    fcb       $1b,$32,Red.
                    fcc       "DEVELOPEMENT "
                    fcb       $1b,$32,Green.
                    fcc       "TEAM"
*			fcb		$0D,$0A
                    fcb       $2,$3f,$22,$1b,$32,Blue.
                    fcc       "ALL "
                    fcb       $1b,$32,Red.
                    fcc       "RIGHTS "
                    fcb       $1b,$32,Green.
                    fcc       "RESERVED"
                    fcb       $0D,$0A,$0A
                    fcb       $1b,$32,Black.
DefDrv              equ       *
                    fcc       "/DD"
                    fcb       $0D
DefDrv2             equ       *
                    fcc       "/DD/"
DefCmds             equ       *
                    fcc       "Cmds"
                    fcb       $0D
                    fcc       ",,,,,"
ShellT              equ       *
                    fcc       "Shell"
                    fcb       $0D
                    fcc       ",,,,,"
AutoEx              equ       *
                    fcc       "AutoEx"
                    fcb       $0D
                    fcc       ",,,,,"
Startup             equ       *
                    fcc       "STARTUP -P"
                    fcb       $0D
                    fcc       ",,,,,"
Imortal             equ       *
                    fcc       "i=/1 "
z0120               equ       *
                    fcb       $0D
                    fcc       ",,,,,"
CfgFile             equ       *
                    fcc       "/dd/SYS/sysgo.cfg"
                    fcb       $0D,$0A
z013A               equ       *
                    fcc       "Z"
                    fcb       $01
                    fcb       $01
                    fcb       $00
                    fcb       $00
                    fcb       $00
Error1              equ       *
                    fcb       $0D,$0A
                    fcc       "                          /dd/SYS/sysgo.cfg   ...   Not Found"
                    fcb       $0D,$0A
                    fcc       "                          Using system defaults"
                    fcb       $0D,$0A
Error2              equ       *
                    fcb       $0D,$0A
                    fcc       "                          Error in sysgo.cfg"
                    fcb       $0D,$0A
                    fcc       "                          Configuration file not used"
                    fcb       $0D,$0A
start               equ       *
                    leax      z0338,pcr
                    os9       F$Icpt
                    os9       F$ID
                    ldb       #$80
                    os9       F$SPrior
                    leax      banner,pcr
                    ldy       #DefDrv-banner
                    lda       #$01
                    os9       I$Write
                    leax      z013A,pcr
                    os9       F$STime
                    leax      DefCmds,pcr
                    lda       #$04
                    os9       I$ChgDir
                    leax      DefDrv,pcr
                    lda       #$03
                    os9       I$ChgDir
                    bcs       LoadCfg
                    leax      DefDrv2,pcr
                    lda       #$04
                    os9       I$ChgDir
LoadCfg             equ       *
                    pshs      u,y
                    lda       #$01
                    leax      CfgFile,pcr
                    os9       I$Open
                    bcs       PrtErr1
                    leax      u0300,u
                    ldy       #x0050
                    os9       I$ReadLn
                    bcs       PrtErr2
                    sty       u0350,u
                    os9       I$Close
                    bra       z02B0
PrtErr1             equ       *
                    leax      Error1,pcr
                    ldy       #x0073
                    lda       #$01
                    os9       I$Write
                    bra       z029B
PrtErr2             equ       *
                    leax      Error2,pcr
                    ldy       #x0068
                    lda       #$01
                    os9       I$Write
z029B               equ       *
                    ldb       #$0B
                    stb       u0350,u
                    leax      Imortal,pcr
                    leay      u0300,u
z02A9               equ       *
                    lda       ,x+
                    sta       ,y+
                    decb
                    bpl       z02A9
z02B0               equ       *
                    os9       F$ID
                    bcs       z0333
                    leax      u0000,u
                    os9       F$GPrDsc
                    bcs       z0333
                    leay      u0000,u
                    leax      x0000,pcr
                    ldb       #$01
                    os9       F$MapBlk
                    bcs       z0333
                    lda       #$55
                    sta       u0071,u
                    ldd       u004A,u
                    leau      d,u
                    leau      u0020,u
                    leay      $20,y
                    ldb       #$0F
z02DA               equ       *
                    lda       b,y
                    sta       b,u
                    decb
                    bpl       z02DA
                    leax      ShellT,pcr
                    leau      Startup,pcr
                    ldd       #$0100
                    ldy       #x0010
                    os9       F$Fork
                    bcs       z0333
                    os9       F$Wait
                    leax      AutoEx,pcr
                    leau      z0120,pcr
                    ldd       #$0100
                    ldy       #x0001
                    os9       F$Fork
                    bcs       z030F
                    os9       F$Wait
z030F               equ       *
                    puls      u,y
                    leax      u0300,u
                    leay      u0000,u
                    ldb       x0350
z031A               equ       *
                    lda       ,x+
                    sta       ,y+
                    decb
                    bne       z031A
                    leax      ShellT,pcr
                    leau      u0300,u
                    ldd       #$0100
                    ldy       #x0350
                    os9       F$Chain
z0333               equ       *
                    clr       xFFA8
                    jmp       <x006B
z0338               equ       *
                    rti
                    emod
endmod              equ       *
                    end

