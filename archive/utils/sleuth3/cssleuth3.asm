******************************************
**
                    nam       CSC                 OS/9 Super Sleuth c1982
**
******************************************
**                                      **
**   CSC OS/9 Super Sleuth    c1982     **
**                                      **
** Computer Systems Consultants, Inc.   **
** E. M. Pass, Ph.D.                    **
** 1454 Latta Lane NW                   **
** Conyers, GA 30207                    **
**                                      **
******************************************
** Updates for OS9 Level 2 1990-1995
** M. E. (Gene) Heskett
** 291 Garton Avenue
** Weston, WV 26452
******************************************
** More Updates for NitrOS9 Level 2
** Bill Pierce 04/2016
** ooogalapasooo@aol.com
******************************************
**
vn                  equ       $04                 version number
**
                    mod       endmod,namemd,Prgrm+Objct,ReEnt+vn,start,endmem
**
namemd              fcs       "Sleuth3"
                    fcb       $0d
**
                    fcc       "CSC OS/9 Super Sleuth  c1982 v"
                    fcb       $0d
                    fcc       "All Rights Reserved by"
                    fcb       $0d
                    fcc       "E. M. (Bud) Pass, Ph.D."
                    fcb       $0d
                    fcc       "Computer Systems Consultants, Inc."
                    fcb       $0d
                    fcc       "1454 Latta Lane, Conyers, GA 30207"
                    fcb       $0d
                    fcc       "Telephone Number 404-483-1717/4570"
                    fcb       $0d
********************** OS/9 uses *************************
* this module is for OS/9 library definitions

                    use       defsfile

******************** cssvarbl ****************************
* this module contains variables used by the disassembler
* in performing its requested operations; of the entire
* disassembler, the only portions which should vary during
* execution are the variables in this module.
                    ttl       *** cssvarbl ***
                    use       cssvarbl3.asm
endmem              equ       .
******************** cssinitz ****************************
* this module contains the external address table,
* the initialization routines, the command interpreter.
                    ttl       *** cssinitz ***
                    fcc       "*** cssinitz ***"
                    use       cssinitz3.asm
******************** cssmiscl ****************************
* this module contains several utility-type routines,
* generally called from the command interpreter.
                    ttl       *** cssmiscl ***
                    fcc       "*** cssmiscl ***"
                    use       cssmiscl3.asm
******************** cssauxil ****************************
* this module contains routines which control auxiliary
* input and output; auxiliary input is handled by fooling
* the character input routine by making it read from the
* auxiliary file rather than from the terminal; auxiliary
* output is handled by formatting a file with data
* simulating command interpreter input.
                    ttl       *** cssauxil ***
                    fcc       "*** cssauxil ***"
                    use       cssauxil3.asm
******************** cssdmptb ****************************
* this module contains the routine which lists internal
* control tables to the output device.
                    ttl       *** cssdmptb ***
                    fcc       "*** cssdmptb ***"
                    use       cssdmptb3.asm
******************** cssshowc ****************************
* this module contains routines which implement the full
* screen display and modification of object program code;
* the specific nature of a given system and terminal is
* provided by other library files which must be included
* by the user to suit a given situation.
                    ttl       *** cssshowc ***
                    fcc       "*** cssshowc ***"
                    use       cssshowc3.asm
******************** cssdkdsk ****************************
* this module provides routines which obtain the input
* and output file names from the input device.
                    ttl       *** cssdkdsk ***
                    fcc       "*** cssdkdsk ***"
                    use       cssdkdsk3.asm
******************** cssinput ****************************
* this module provides a routine which stores an address
* range and type in a table, a routine which scans and
* verifies such a range, and a routine which obtains an
* entire input line from an input device.
                    ttl       *** cssinput ***
                    fcc       "*** cssinput ***"
                    use       cssinput3.asm
******************** csszapcd ****************************
* this module contains routines to assist in the editing
* and decoding an object module; two routines allow the
* inquiry and modification of the object program contents;
* modifications are stored in a table, rather than being
* actually applied to the program; one routine allows the
* locating of strings of hex characters within the object
* program; another routine outputs a OS/9-formatted
* object program from the current object program, possibly
* with user-specified modifications.
                    ttl       *** csszapcd ***
                    fcc       "*** csszapcd ***"
                    use       csszapcd3.asm
******************** cssdisas ****************************
* this module contains routines which disassemble the
* object program; the source of the object program must
* already be known; the destination is determined by these
* routines; actual formatting of the disassembled listing
* and disk output is done by other modules.
                    ttl       *** cssdisas ***
                    fcc       "*** cssdisas ***"
                    use       cssdisas3.asm
******************** cssgetcd ****************************
* this module contains routines which return the object
* program byte and type at a given address; if the address
* is outside of the specified address range or is in an
* ignored range of addresses, zero is returned.
                    ttl       *** cssgetcd ***
                    fcc       "*** cssgetcd ***"
                    use       cssgetcd3.asm
******************** cssiafcb ****************************
* this module contains routines used by the disassembler
* routine to assist in disassembly of the object program;
* one handles case of memory with character and hex types;
* two determine if a given address has been or is to be
* labelled; several routines handle equ and org statements
* as required by object program code and memory types;
* two routines provide logic to handle the beginning and
* ending of the disassembly output.
                    ttl       *** cssiafcb ***
                    fcc       "*** cssiafcb ***"
                    use       cssiafcb3.asm
******************** cssmapdk ****************************
* this module maps an input object program on disk; the
* program code is not brought into memory from disk except
* one sector at a time; this routine builds the table
* entries to allow the location of any byte of a program
* in terms of relative byte displacement in file.
                    ttl       *** cssmapdk ***
                    fcc       "*** cssmapdk ***"
                    use       cssmapdk3.asm
******************** cssoutcd ****************************
* this module formats the disassembled output listing and
* disk file; although the listing contains hex address,
* object code, and formatting spaces, only the actual
* disassembled source code is placed on the disk output.
                    ttl       *** cssoutcd ***
                    fcc       "*** cssoutcd ***"
                    use       cssoutcd3.asm
******************** cssxiort ****************************
* this module contains the i/o handlers which interface
* with the primitive OS/9 i/o routines; they are
* necessary in order to control the diversion of input and
* output from and to disk terminal.
                    ttl       *** cssxiort ***
                    fcc       "*** cssxiort ***"
                    use       cssxiort3.asm
******************** cssconst ****************************
* this module consists of most constants used by the
* disassembler during its processing of object code; it
* also contains text for the menu and the address table
* used by the command interpreter to vector single-letter
* commands to the corresponding routines.
                    ttl       *** cssconst ***
                    fcc       "*** cssconst ***"
                    use       cssconst3.asm
******************** cssparam ****************************
* this module must be selected by the user to provide the
* details of the terminal to be used; comments in the
* module provide the required information to be entered.
                    ttl       *** cssparam ***
                    fcc       "*** cssparam ***"
                    use       cssparam3.asm
******************** csstable ****************************
* this module contains the tables used by the disassembler
* in order to decode the operation codes and to associate
* the mnemonic names with them.
                    ttl       *** csstable ***
                    fcc       "*** csstable ***"
                    use       csstable3.asm
********************
                    emod
endmod              equ       *
                    end
