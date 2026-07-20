# Required utilities:

* make
* lwtools
* A reasonably modern Nitros9 with the 'ccbkrn' module and Gary's SD drivers installed on /dd (default in modern Nitros9 builds).  "cat" or "dd" this rbf image to your SD card.  

# Optional utilities:

* toolshead
* de1flash (for flashing de1 board from linux w/ the quartus gui)

# To Install:

* build the ROM image via "make rom.img".
* burn the resultant file, rom.img to rom slot 2 of your CoCoFPGA. - this means burning rom.img to flash address 3fc000 in your cocofpga's flash ram.

I use something like this:

quartus_pgm -m jtag -o 'p;de1flash.sof'
quartus_stp -t de1flash.tcl write rom.img@0x3fc000

# To use:

Set your cocofpga's switch to mpi slot 2 and turn it on.  It boots fast, so don't blink.