Package: Basic09 1.1.0
Release Date: January 5, 2003

This release of Basic09 for the Tandy Color Computer 1/2/3 represents
the first community-based release since the discontinuation of the CoCo
in the 1980s.

What's New
==========
Other than 6309 support, there aren't any significant changes to Basic09.
RunB for 6309 and 6809 are almost identical, and only differ by one byte,
which is due to the register stack differences of the 6309.  The Basic09
module for each processor differs considerably, however.

The 6309 verison of Basic09 is optimized for the 6309 processor and should
be noticably faster than its 6809 counterpart.

With additional integration work, the 6309 version of RunB will contain
the same 6309 optimizations as Basic09.  This will appear in a future release
of this package.

The gfx, syscall and inkey subroutine modules are also included, as well
as gfx2, the graphics module for OS-9 Level Two and NitrOS-9.

Installation
============
1.  Change into the directory that holds the diskette:

	chd /d0

2. Included in the package are two install scripts:  install6809 and
install6309.  Both scripts will copy modules to the /DD device.  Run
the script that corresponds to your processor.

3. Once the script is complete, all modules should be in the appropriate
places on your /DD device.

4. For OS-9 Level Two systems, you may want to merge runb, gfx2, gfx,
syscall and inkey together for better memory usage with packed Basic09
programs.  To do this, type:

	chd /dd/cmds
	merge runb gfx2 gfx syscall inkey>new_runb
	del runb
	rename new_runb runb
	attr runb e pe

