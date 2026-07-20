*     TCCCHD descriptor: Hard disk driver descriptor for OS9
*     Copyright (C) 1990,1991,1992,1993,1994,1995,1996 Robert E. Brose II
*
*     This program is free software; you can redistribute it and/or modify
*     it under the terms of the GNU General Public License as published by
*     the Free Software Foundation; either version 2 of the License, or
*     (at your option) any later version.
*
*      This program is distributed in the hope that it will be useful,
*      but WITHOUT ANY WARRANTY; without even the implied warranty of
*      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*      GNU General Public License for more details.
*
*      You should have received a copy of the GNU General Public License
*      along with this program; if not, write to the Free Software
*      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

* DISTO version 124/125/126 descriptor h4 170 meg seagate drive

                    nam       disto.descriptor    (h4)
                    ttl       device descriptor for seagate st2209n

                    ifp1
                    use       defsfile
                    endc

verson              equ       $02
                    mod       endmod,hdnam,devic+objct,reent+verson,hdmgr,hddrv

                    fcb       $ff                 mode
                    fcb       $07                 port msb l2
                    fdb       $ff70               port lsb's
                    fcb       hdnam-*-1           init table size
                    fcb       $01                 dev type 1=rbf
                    fcb       $00                 logical drive number (0-3)
                    fcb       $00                 step rate and retry options
                    fcb       $80                 device type 80=hd
                    fcb       $11                 media density
* bit 7 = Enable PHYSICAL format = 1 (logical format always enabled).
* bit 6 = Drive init = 1 (ONLY for st506 drives & wd1002/adaptec/xebec cont).
* bit 5 = LUN (2nd drive = 1) (only on st506 drives with external controller)
* bit 4 = Recal on first access = 1 (Needed for normal embeded scsi drives)
* bits 0 - 3 = SCSI ID IN BINARY. ID0=1, ID1=2, ID2=4 (may change some day!)

                    fdb       $0ae5               tracks per drive, see below
                    fcb       $08                 number of sides
                    fcb       $01                 verify writes 1=no verify
                    fdb       $20                 default sectors/track (32 sectors per physical track)
                    fdb       $20                 track 0 sectors
                    fcb       $1                  interleave
                    fcb       $20                 default allocation in sectors

* added definitions
* actual drive charcteristics for init routine
* NOT USED FOR EMBEDED DRIVES
* First Physical Drive (lun 0)

                    fdb       $0                  cylinders
                    fcb       $0                  number of heads
                    fdb       $0                  reduced write current starting cylinder
                    fdb       $0                  write precomp starting cylinder
                    fcb       $0                  max eec error burst length to be corrected

* Second physical drive (lun 1)

                    fdb       $0
                    fcb       $0
                    fdb       $0
                    fdb       $0
                    fcb       $0

* drive offsets (this is in GROUPS OF 256 SECTORS!)
* can be used to logically partition 1 physical drive into up to
* 4 logical drives.
* I always use a least an offset of 1 to allow for possible os9 boot
* track on the drive, also if it's a used PC drive, the first few
* cyls are where all the errors are :-)

                    fdb       1                   drive 0
                    fdb       1                   drive 1
                    fdb       1                   drive 2
                    fdb       1                   drive 3

* Multipak slot select (Only used for DISTO Host adapter)

                    fcb       1                   slot for mpak scs 0=slot 1  1=slot 2  2=slot 3  3=slot4  $ff=no mapk

* note that the drive name is unrelated to the physical or logical drive
* number.

HDNAM               fcs       "H4"
HDMGR               fcs       "RBF"

* note the name here. DI1024, DIS512 and DI256 are DISTO DRIVERS of various
* sector sizes. TC1024, TCC512 and TCCCHD are the equivalents for the TC3 host
* adapter. DBHSHD for 256 byte/sector st506 style external controllers which
* require handshaking on each byte of a data transfer (i.e. adaptec). DIDBHS
* for the same thing with a DISTO host adapter.

HDDRV               fcs       "DIS512"
                    fdb       $0                  room for patching
                    emod
endmod              equ       *
                    end
