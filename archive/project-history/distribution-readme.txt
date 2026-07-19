***************
NitrOS-9 ReadMe
***************

Welcome to NitrOS-9!

DISTRIBUTION
============
There are two double-sided 40 track DSK images ending in '_ds40_1.dsk',
and '_ds40_2.dsk' for disks 1 and 2, respectively.  For those with
3.5" 720K drives, an 80 track DSK image ending in '_ds80.dsk' is also
included in the distribution.

USING THE DISK IMAGES
=====================
If you wish to transfer the disk images to a floppy disk for use with a
real CoCo, follow the steps below:

WINDOWS/DOS:

1. Download and install the latest version of DSKINI/RETRIEVE at
   http://www.nitros9.org/

2. Insert a blank double-sided floppy in to your drive (we assume B:)

3. Type the following command, replacing the name of the image:

             DSKINI /T40 /D B: <diskimagefile>     (360K 5.25" floppy disk)
             DSKINI /T80 /D B: <diskimagefile>     (720K 3.5"  floppy disk)

   Where <diskimagefile> is the image file you want to transfer to the
   floppy disk.  The image file transfer should start.  When it is done,
   take out the disk and try booting your CoCo with it.

Repeat steps 2-3 for each additional disk.


LINUX:

1. Download and install the latest version of fdutils from
   http://fdutils.linux.lu/

2. Once installed, edit the /usr/local/etc/mediaprm file and add the
   following lines at the end of the file:

     "COCO360":
      DS DD sect=18 cyl=40 ssize=256 tpi=48

     "COCO720":
      DS DD sect=18 cyl=80 ssize=256 tpi=96

3. Insert your blank floppy into the drive on your Linux box.

4. Type the following command:

             setfdprm /dev/fd1 coco360    (360K 5.25" floppy disk)
             setfdprm /dev/fd1 coco720    (720K 3.5"  floppy disk)

   This assumes your floppy drive is /dev/fd1.  You may need to make
   adjustments to the above commands for your environment.

5. After typing the setfdprm command, the floppy drive unit should spin
   for a second then stop. Type this command:

             dd if=<diskimagefile> of=/dev/fd1

   Where <diskimagefile> is the image file you want to transfer to the
   floppy disk.  The image file transfer should start.  When it is done,
   take out the disk and try booting your CoCo with it.

Repeat steps 3-5 for each additional disk.


NOTES
=====
Unfortunately, many of the FDC chipsets shipping on PC motherboards do NOT
understand, and will probably crash your PC when a 256 byte/sector disk
read or write is attempted. The Asus M2n-SLI Deluxe board is one such board.

When using DriveWire, the appropriate for your machine .dsk
file can be downloaded and mounted directly as a fully read/write
virtual disk. Please see for instance the tutorial at
http://www.cocopedia.com/wiki/index.php/Getting_Started_with_DriveWire

