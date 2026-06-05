                    IFNE      SID.D-1

SID.D               SET       1

********************************************************************
* SidDefs - X-SID polyphonic audio driver (/sid) definitions
*
* SetStt/GetStt codes for sidirq.dr, the VSYNC-IRQ-driven driver
* that owns a Color Computer X-SID cart at $FF40 (MPI slot 1).
*
* Stream load flow (client side):
*   SS.SidPrep   total_len                  ; allocate, reset
*   SS.SidWrite  chunk_ptr, chunk_len        ; (repeat until full)
*   SS.SidStart                              ; begin playback
*   poll SS.SidActv until LoadState != 2     ; wait for finish
*
* Edt/Rev   YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*    1      2026/06/04  Stephen J. Spiller
* Initial release covering the Phase D chunked-write protocol.
********************************************************************

                    NAM       SidDefs
                    TTL       /sid SetStt/GetStt definitions

* --- GetStt codes (I$GetStt) ---
SS.SidCnt           equ       $90                 return 60 Hz tick counter in R$X
SS.SidActv          equ       $96                 return LoadState in R$X (0/1/2)

* --- SetStt codes (I$SetStt) ---
SS.SidClr           equ       $91                 clear tick counter
SS.SidChrp          equ       $92                 chirp test pattern enable (R$X low bit)
SS.SidPrep          equ       $93                 reset+set stream length (R$Y = bytes)
SS.SidStart         equ       $94                 begin playback after WritePos==StreamLen
SS.SidStop          equ       $95                 silence voices and stop
SS.SidWrite         equ       $97                 push chunk (R$X = src, R$Y = byte count)

* --- Limits ---
SidMaxStream        equ       16384               driver buffer size (max stream bytes)
SidMinStream        equ       9                   8-byte header + at least 1 data byte

*   End of sid.d

                    ENDC

