As the decades pass, we will lose some of the history of how we got to
where we are.  This file is to help us remember, even if it records bits
and pieces, rather than a whole story.

----

L. Curtis Boyle:

NitrOS-9 was started by Bill Nobel, Wes Gale, and myself (although I was
a few days later than the other two), and then Alan Dekok joined in later
as well. OS-9 "Level 3", as Alan called it, was his way to expand system
memory, although it won't work with DriveWire at all in it's current state
(Bill was looking into the at one point). Version 3 was the one by over
a dozen developers in the late 1980's and was planned to be sold through
Tandy. The main head of that project was Kevin Darling, and a version of
it was released by Brother Jeremy, but it's not the most advanced version
that Kevin talked about in his history of the project. Some of it has made
it into NitrOS9 (some directly ported like GShell, serial mouse drivers,
etc.) and some clean room style (original code but same functionality)
and other parts are not in NitrOS-9 currently.

We did a series of group interviews going through the history of NitrOS-9 not too long ago; that would be a good place to start. We didn’t get everyone we had hoped for (Wes Gale was unable to make it although he had planned to, for example), but we got a good mix from the various eras of NitrOS-9.

Part 1 (aired Aug 20, 2022) - Episode 275 - First decade of NitrOS9 - L. Curtis Boyle, Bill Nobel, Alan Dekok (Wes Gale couldn't make it)
  https://www.youtube.com/live/QRbl-Br8fjg?si=v2SOm6MC5Ac1974o

Part 2 (aired Nov 2, 2022) - Episode 286 - Second decade of NitrOS9 - passing the code over to Boisy Pitre
  https://www.youtube.com/live/2YWkZepe7UU?si=pqy7gLoFpES4-97j

Part 3 (aired May 27, 2023) - Coco Nation Show #314  (William Astle, Jeff Teunissen, Tormod Volden, David Ladd). This is mostly the open source era (the last 10 years)
  https://www.youtube.com/live/9qttp0SAeV8?si=QNr7IBHPG5OtGoZs

Boisy Pitre:

It was around 1998 that I got Alan DeKok's "TuneUp" which was a series of
patches to make OS-9 Level 2 run faster on a CoCo 3. By that time, there
were a myriad of patches online for various system modules, enhancements to
commands, etc. I began to think of how we could build a working OS-9 system
from source for the CoCo 3, and thus began a series of disassemblies of all
the system and command modules. It was slow at first. Diassemblies were not
very well commented, but at least we had the start of a source base. At some
point, I also incorporated the 6309 modules that NitrOS-9 had improved upon,
making a conditional assembly for both the 6309 and 6809.

Alongside this effort, I started working on cross development tools like `mamou`,
a 6809 cross-assembler, and Toolshed, a set of utilities for manipulating the
contents of disk images. These tools would allow someone to build the entire
OS-9 operating system on a modern system and then create disk images that could be
transferred to a physical floppy disk for booting. At the time I was using Linux
for cross-development, so those tools were developed there.

Around 2000, I began to put the work under source code control and inviting 
collaborators who could help with the disassembly and commenting of OS-9 source.
I also disassembled OS-9 Level 1 modules for the CoCo 1 and CoCo 2 so those systems
could also have a complete source-to-binary build. Then, the consolidation of sources
between Level 1 and Level 2 started to commence.

Actually, it was this effort that bootstrapped DriveWire, which I created while
working in Boston in 2003. The disk images created by cross-assembly and Toolshed
were a natural media for disseminating over a serial cable hooked up to a modern
computer. By that time I had moved over to the Mac and that became my primary
development platform.

