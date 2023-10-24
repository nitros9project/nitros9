************************************
*
* This file contains the names for the various window
* commands avail for CoCo3 Level 2 OS9.

* History: File created 88/04/24 - Bob van der Poel

* Note that all these constants begin with a "W"

                    ttl       Window Definitions

                    section   .text

WBColor             equ       $1b33               background color
WBoldSw             equ       $1b3d               bold switch
WBorder             equ       $1b34               border color
WCWArea             equ       $1b25               change working area
WDefColr            equ       $1b30               set default color
WDfnGPBuf           equ       $1b28               define get/put buffer
WDWEnd              equ       $1b24               device window end
WDWProtSw           equ       $1b36               device window protect
WDWSet              equ       $1b20               device window set
WFColor             equ       $1b32               foreground color
WFont               equ       $1b3a               select font
WGCSet              equ       $1b39               graphics cursor set
WGetBlk             equ       $1b2c               get block
WGPLoad             equ       $1b2b               get/put buffer load
WKilBuf             equ       $1b2a               kill get/put buffer
WLSet               equ       $1b2f               logic set
WOWEnd              equ       $1b23               overlay window end
WOWSet              equ       $1b22               overlay window set
WPalette            equ       $1b31               change palette
WPropSw             equ       $1b3f               proportional switch
WPSet               equ       $1b2e               Pattern set
WPutBlk             equ       $1b2d               put block
WScaleSw            equ       $1b35               scale switch
WSelect             equ       $1b21               select window
WTCharSw            equ       $1b3c               transparent char switch

* drawing commands

WArc3P              equ       $1b52               draw arc
WBar                equ       $1b4a               draw bar
WRBar               equ       $1b4b               draw bar relative
WBox                equ       $1b48               draw box
WRBox               equ       $1b49               draw box relative
WCircle             equ       $1b50               draw circle
WEllipse            equ       $1b51               draw ellipse
WFFill              equ       $1b4f               flood fill
WLine               equ       $1b44               draw line
WRLine              equ       $1b45               draw line relative
WLineM              equ       $1b46               draw line and move
WRLineM             equ       $1b47               draw line relative and move
WPoint              equ       $1b42               set point
WRPoint             equ       $1b43               set point relative
WPutGC              equ       $1b4e               put graphics cursor
WSetDPtr            equ       $1b40               set draw pointer
WRSetDPtr           equ       $1b41               set draw pointer relative

* Text commands

* these are one byte codes...

WHomeCur            equ       $01                 home cursor
WPosCur             equ       $02                 position cursor
WErasLn             equ       $03                 erase line
WErasEOL            equ       $04                 erase to end of line
WErasEOS            equ       $0b                 erase to end of screen
WErase              equ       $0c                 erase screen and home cursor
WCurR               equ       $06                 move cursor right one pos
WCurL               equ       $08                 move cursor left one pos
WCurUp              equ       $09                 move cursor up one line
WCurDn              equ       $0a                 move cursor down one line
WBell               equ       $07                 rings terminal bell
WCr                 equ       $0d                 sends a carriage return

* two byte codes...

WCurOff             equ       $0520               turn off cursor
WCurOn              equ       $0521               turn  on cursor
WRvOn               equ       $1f20               reverse video on
WRvOff              equ       $1f21               reverse video off
WUlOn               equ       $1f22               underlining on
WUlOff              equ       $1f23               underlineing off
WBlnkOn             equ       $1f24               blinking on
WBlnkOff            equ       $1f25               blinking off
WInsLn              equ       $1f30               insert line at cursor
WDelLn              equ       $1f31               delete current line


                    endsect


