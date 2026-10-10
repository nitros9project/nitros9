********************************************************************
* Palette.asm - Studio-9: UmePalette, the sixteen CLUT 0 colors
*
* s9.asm includes it (use Palette.asm) and loads it into CLUT 0 entries 0-15 at start. The S9 Editor's
* palette editor imports and exports this file; make piano-keys matches the piano key images to it.
* Rebuild and restart s9 to apply edits (no live reload).
* Four bytes an entry in VICKY's order BLUE, GREEN, RED, alpha; the comment gives R,G,B in decimal,
* then the index, then what the color is used for (the editor shows it on the swatch).
********************************************************************
* Seeded with the OS-9 text palette the WildBits cores boot with (the C64 colors). Editing an entry
* changes every dot of that nibble; the symbol pictures pick their nibbles in cmds/UmeSymbols16.asm.
UmePalette          equ       *
                    fcb       $00,$00,$00,$00     0,0,0         0  
                    fcb       $FF,$FF,$FF,$00     255,255,255   1  
                    fcb       $33,$44,$AA,$00     170,68,51     2  
                    fcb       $40,$00,$40,$00     64,0,64       3  
                    fcb       $80,$00,$80,$00     128,0,128     4  
                    fcb       $F3,$B5,$A3,$00     163,181,243   5  
                    fcb       $80,$00,$00,$00     0,0,128       6  
                    fcb       $FF,$00,$00,$00     0,0,255       7  
                    fcb       $62,$50,$2F,$00     47,80,98      8  
                    fcb       $00,$00,$EC,$00     236,0,0       9  pressed black piano key face
                    fcb       $00,$FF,$FF,$00     255,255,0     10 
                    fcb       $33,$33,$33,$00     51,51,51      11 
                    fcb       $77,$77,$77,$00     119,119,119   12 
                    fcb       $BB,$BB,$BB,$00     187,187,187   13 
                    fcb       $40,$40,$40,$00     64,64,64      14 
                    fcb       $00,$00,$00,$00     0,0,0         15 
