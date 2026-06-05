********************************************************************
* SID - SIDIRQ device descriptor (/sid)
*
* Purpose
* -------
* This is the OS-9 device descriptor that exposes the SIDIRQ driver
* (sidirq.dr) under the well-known path name "/sid".  When init or a
* program does I$Attach on "/sid", the OS-9 IOMan looks up this
* descriptor module, pulls the manager name ("SCF") and driver name
* ("SIDIRQ") from it, loads them if not already in memory, and binds
* the device to the named driver instance.
*
* Hardware
* --------
* The X-SID cartridge is mapped at port $FF40 via MPI slot 1.  Bank
* selection (MPI $FF7F) is handled entirely by the driver during its
* IRQ service; nothing here in the descriptor touches it.  The
* hardware page byte (DD.HPg, $FF) means "not paged" because the SID
* registers live in the fixed I/O page in the upper 8 KB and are not
* MMU-mappable on the CoCo 3.
*
* Manager
* -------
* /sid is layered on top of SCF (Sequential Character Format) even
* though it is a write-only, position-less audio stream.  Reasons:
*   1. SCF is already loaded in every NitrOS-9 boot image we ship --
*      no extra manager module needed.
*   2. SCF gives us the standard SS.SetStt / SS.GetStt path-status
*      plumbing for free, which is how the streaming protocol works
*      (SS.SidPrep / SS.SidWrite / SS.SidStart, etc.; see sid.d).
* Reads against /sid will be rejected by the driver with E$Read; the
* descriptor itself does not need to suppress them.
*
* Open Mode
* ---------
* UPDAT. (= READ. + WRITE.) is set so callers may open /sid for
* update access.  Read attempts fail at the driver, but accepting
* update at open time keeps the standard "open for I/O" idiom
* working without forcing callers to specify write-only.
*
* Edition / Revision
* ------------------
* Edition 1, Rev 0 -- shipped with the Phase D chunked-write driver
* (see sidirq.asm header for the load-protocol history).  Bump Edtn
* on any user-visible behavior change so OS-9 picks the newest copy
* when multiple are present in memory.
********************************************************************

                    nam       SID
                    ttl       /sid device descriptor for SIDIRQ driver

                    ifp1
                    use       defsfile
                    endc

Edtn                equ       1                   ; descriptor edition
rev                 equ       0                   ; descriptor revision

* OS-9 module header.  ModSize is computed at "ModSize equ *" below;
* the linker plus the trailing emod fix up the size, CRC, and parity.
                    mod       ModSize,DvcNam,Devic+Objct,ReEnt+rev,MgrNam,DrvNam

                    fcb       UPDAT.              ; DD.Mode: open modes allowed (read+write)
                    fcb       $FF                 ; DD.HPg : hardware page ($FF = not paged / fixed I/O)
                    fdb       $FF40               ; DD.Hrd : hardware port address (X-SID base)
                    fcb       OptSize             ; DD.OPT : size of option table that follows
OptStart            fcb       DT.SCF              ; PD.DTP : device type (SCF: char stream)
OptSize             equ       *-OptStart          ; computed option table size

MgrNam              fcs       "SCF"               ; IOMan looks up this manager module
DrvNam              fcs       "SIDIRQ"            ; IOMan looks up this driver module
DvcNam              fcs       "SID"               ; user-visible name; mounted as "/sid"
                    fcb       Edtn                ; trailing edition byte (per OS-9 convention)

                    emod
ModSize             equ       *
                    end
