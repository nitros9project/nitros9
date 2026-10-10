* s9_d0 - the Chars16 font image as a page-aligned, single-block OS-9 data module (s9gui links it).
* The image is cmds/Chars16.asm assembled raw to ../.mods/SYS/Chars16.img.
                    use       defsfile
                    mod       eom,name,Data,ReEnt
                    fdb       payloadend-payload  the image's length
                    fcc       /UD/
                    fcb       1
name                fcs       /s9_d0/
                    fill      0,$100-*
payload             includebin ../.mods/SYS/Chars16.img
payloadend          equ       *
* A data module shorter than $1D00 could be linked into slot 7 and push the score page to slot 6
                    fill      0,$1CFD-*           $1CFD + the CRC = $1D00 bytes: never slot 7
                    fill      0,(-*-3)&$FF
                    emod
eom                 equ       *
                    end
