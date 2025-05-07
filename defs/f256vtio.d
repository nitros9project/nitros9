                    IFNE      F256VTIO.D-1
F256VTIO.D          SET       1

********************************************************************
* vtio definitions for the F256
*
* Everything that the vtio driver needs is defined here, including
* static memory definitions.

* Constant definitions.
KBufSz              EQU       8                   the circular buffer size

* Driver static memory.
                    ORG       V.SCF
V.CurRow            RMB       1                   current row where the next character goes
V.CurCol            RMB       1                   current column where the next character goes
V.CapsLck           RMB       1                   CAPS LOCK key up/down flag ($00 = up)
V.KySns             RMB       1                   key sense flags
V.LEDStates         RMB       1                   PS/2 LED flags (bit 2 = CAPS Lock, bit 1 = NUM Lock, bit 0 = Scroll Lock)
V.EscVect           RMB       2                   escape vector handle
V.Reverse           RMB       1                   reverse video flag ($00 = off, $FF = on)
V.IBufH             RMB       1                   input buffer head pointer
V.IBufT             RMB       1                   input buffer tail pointer
V.SSigID            RMB       1                   data ready process ID
V.SSigSg            RMB       1                   data ready signal code
V.ScTyp             RMB       1                   screen type
V.WWidth            RMB       1                   window width
V.WHeight           RMB       1                   window height
V.FBCol             RMB       1                   currently selected foreground and background color
V.BordCol           RMB       1                   currently selected border color
V.KeyDrvMPtr        RMB       2                   keydrv module address
V.KeyDrvEPtr        RMB       2                   keydrv entry point address
		    ifgt      Level-1
V.MSDrvMPtr         RMB       2                   mouse module address
V.MSDrvEPtr         RMB       2                   mouse entry point address
V.MouseVect	    RMB	      2
V.MSButtons	    RMB	      1		          keeps the buttons for the SetStat call
V.MSTimer	    RMB	      1                   this hides the cursor if inactive for more than 4 seconds
		    endc
V.KeyDrvStat        equ       .
                    RMB       8

V.EscParms          RMB       20
* DWSet Parameters
V.DWType            set       V.EscParms+0
V.DWStartX          set       V.EscParms+1
V.DWStartY          set       V.EscParms+2
V.DWWidth           set       V.EscParms+3
V.DWHeight          set       V.EscParms+4
V.DWFore            set       V.EscParms+5
V.DWBack            set       V.EscParms+6
V.DWBorder          set       V.EscParms+7



                    ifgt      Level-1                                            
********************************************************************
* vtio Graphics definitions for the F256 - 53 bytes + 
********************************************************************

V.ST		    RMB	      1			   screen type 0=Term 1=Gfx

* VICKY MASTER CONTROL REGISTER to enable graphics and capabilities
* | 7 |   6   |    5   |   4  |    3   |   2   |   1   |   0  |
* | X | GAMMA | SPRITE | TILE | BITMAP | GRAPH | OVRLY | TEXT |
* |   -----   | FON_SET|FON_OV| MON_SLP| DBL_Y | DBL_X | CLK70|
* $FFC0 MASTER_CTRL_REG_L, MASTER_CTRL_REG_H
* See constants below for settings used with SS.DSCrn in vtio

V.V_MCR		    RMB	      2			  2 bytes for Vicky Control Register

* VICKY LAYER CONTROL REGISTER to set bitmaps and/or tile maps for display
* | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
* | - |   LAYER1  | - |  LAYER 0  |
* |       ------      |  LAYER 2  |
* 000=BM0 001=BM1 010=BM2 100=TM0 101=TM1 110=TM2
* $FFC2 VKY_RESERVED_00, VKY_RESERVED_01
* See SS.PScrn in vtio

V.V_LayerCTL	   RMB	      2

* BITMAPS
* Store starting page for bitmaps, and CLUT# and bitmap enable bits.  Must be in first 512K RAM.
* $01_0000-$07_FFFF (OS9 Memory Blocks $01-$3F)
* Byte 1 of Bitmap register is CLUT(4 CLUTS:0-3)/Enable
* | 7 | 6 | 5 | 4 | 3 | 2 | 1 |   0    |
* |       -----       |  CLUT | ENABLE |
* Next 3 bytes in register used for physical 19 bit address for bitmap
* Max address is 07FFFF (must be in 1st 512K), which is 19 bits
* Store block# and then convert to 19 bit address in driver

V.BM0Blk	    RMB	      1			  bitmap0 block
V.BM0Cl_En	    RMB	      1			  bitmap0 |clut|enable|
V.BM1Blk	    RMB	      1			  bitmap1 block
V.BM1Cl_En	    RMB	      1			  bitmap1 |clut|enable|
V.BM2Blk	    RMB	      1			  bitmap2 block
V.BM2Cl_En	    RMB	      1			  bitmap2 |clut|enable|

* CLUT - need to store mirror of CLUT data so switching windows will work
* Store block# where high 4k is CLUT mirror.  Could store in last 4k of BM blocks.

V.CLUTBlk	    RMB	      1			  block where high 4k mirrored CLUT data,0=Default CLUT
V.CLUT              RMB       1			  which CLUTs are active 00001111

* TILE MAPS - 3 tile maps.  Registers are 12 bytes, 2 are reserved and
* 3 are the plysical address for the Tile Set.  Use Blk# for address here.
* So only need 8 bytes per tile map.  In the Map each tile is 2 bytes
* byte0=Tile number, byte1=CLUT+Tile Set. So relationship between Tile Map
* and Tile Set is set in the actual tile map data, not here.
* A tile map could be 2.4K (40x30) to 132K (256x256)

V.TM0	    	    RMB	     1	     	  	  bit4 is yile size (1=8x8,0=16x16) bit0 is enable
V.TM0Blk	    RMB	     1			  starting block# of Tile Map
V.TM0MapX	    RMB	     1			  map size X (max 255)
V.TM0MapY	    RMB	     1			  map size Y (max 255)
V.TM0ScrlX          RMB      2			  2 bytes for scroll X info
V.TM0ScrlY          RMB      2			  2 bytes for scroll Y info		    
V.TM1	    	    RMB	     1	     	  	  bit4 is tile size (1=8x8,0=16x16) bit0 is enable
V.TM1Blk	    RMB	     1			  starting block# of tile set
V.TM1MapX	    RMB	     1			  map size X (max 255)
V.TM1MapY	    RMB	     1			  map size Y (max 255)
V.TM1ScrlX          RMB      2			  2 bytes for scroll X info
V.TM1ScrlY          RMB      2			  2 bytes for scroll Y info
V.TM2	    	    RMB	     1	     	  	  bit4 is tile size (1=8x8,0=16x16) bit0 is enable
V.TM2Blk	    RMB	     1			  starting block# of tile set
V.TM2MapX	    RMB	     1			  map size X (max 255)
V.TM2MapY	    RMB	     1			  map size Y (max 255)
V.TM2ScrlX          RMB      2			  2 bytes for scroll X info
V.TM2ScrlY          RMB      2			  2 bytes for scroll Y info

* TILE SETS - there are 8 tile sets.  Tile Set registers contain a physical address, and
* a Square bit to determine if Tile Set is LINEAR or SQUARE
* Tile Sets are either 16K (8x8) or 64K (16x16)

V.TS0Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS0SQR	    RMB	     1			  square or linear (bit 3)
V.TS1Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS1SQR	    RMB	     1			  square or linear (bit 3)
V.TS2Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS2SQR	    RMB	     1			  square or linear (bit 3)
V.TS3Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS3SQR	    RMB	     1			  square or linear (bit 3)
V.TS4Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS4SQR	    RMB	     1			  square or linear (bit 3)
V.TS5Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS5SQR	    RMB	     1			  square or linear (bit 3)
V.TS6Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS6SQR	    RMB	     1			  square or linear (bit 3)
V.TS7Blk	    RMB	     1 	    	   	  starting block# of tile set
V.TS7SQR	    RMB	     1			  square or linear (bit 3)

* GRAPHICS CURSORS,LINES, COLORS
V.GCX	            RMB	     2			  graphics cursor X
V.GCY		    RMB	     1			  graphics cursor Y
V.GCOLOR	    RMB	     1			  graphics color
V.LX		    RMB	     2			  line coordiate for X
V.LY		    RMB	     1			  line coordinate for Y
V.GCADDR	    RMB	     3			  address of cursor on screen
V.GCAD8K	    RMB	     2			  address in 8K window
V.GMAPBLK	    RMB	     2			  mapped in logical address of block
V.FONTPATH	    FCC	     \/dd/sys/fonts/\
V.FONTNAME	    RMB	     33

* Start of Line Interrupt Handling
*V.SOLOnOff          RMB	     1
*V.SOLCurr  	    RMB	     1
*V.SOLMax   	    RMB	     1
*V.SOLTable 	    RMB	     32
                    endc

V.InBuf             RMB       KBufSz              the input buffer
                    RMB       250-.
V.Last              EQU       .

* Borrow 7 bytes (16 bytes available in Level 1) from "CoCo" specific area of system globals for F256's use.
                    org       D.IRQTmp
D.Bell              rmb       2
D.TnCnt             rmb       1
D.OrgAlt            rmb       2
D.SndPrcID          rmb       1
D.KySns             rmb       1

* F256K-specific section
* Borrow 9 bytes from "CoCo" specific area of system globals for F256's use.
                    org       D.WDAddr
D.RowState          RMB       9
D.F256KKyDn         RMB       1

* SS.KySns bit locations
SHIFTBIT	equ	 %00000001
CTRLBIT	equ	 %00000010
ALTBIT	equ	 %00000100
UPBIT	equ	 %00001000
DOWNBIT	equ	 %00010000
LEFTBIT	equ	 %00100000
RIGHTBIT	equ	 %01000000
SPACEBIT	equ	 %10000000

                    ENDC
