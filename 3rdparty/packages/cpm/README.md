CP/M Emulator for OS-9 L2 6809

This is an emulator to run native CP/M Z-80 applications on OS-9 file system. 

A full Z-80 virtual machine is provided with 56K of TPA. All system calls are translated to OS-9 similars. It runs better in 
6309 machines using NitrOS-9 6309 L2 versions.

The application uses the current folder as if it was drive A: No drive B: support. You can run applications but not the CP/M per se.

No CP/M diskette format is supported. You must port all the files to OS-9 filesystem prior to use.

Besides the native OS-9 terminal, two other terminal emulations are provided: DEC VT-52 and Kaypro-II. 
To use one of these two call cpm with -v or -k parameter. No parameter means native OS-9 terminal.

Together the emulator are being provided some disks. Find for a script in every disk like 'ws' for WS.COM, 'turbo' for TURBO.COM, etc. 
Just run the scripts and it will provide a nice green on black 80x24 window terminal emulation.

But you can call anytime as:

	cpm [-k|-v] PROGRAM.COM
	
You can copy cpm to your local /DD/CMDS folder as well. 

Happy CP/M'ing...
