* Generated from MAME CC0 Astro Blaster schematic circuit model.
* PCM: signed 16-bit big endian, 8000 samples/sec, shared gain.
ASoundBlocks equ 27
ASoundSIDBlock equ 26
ASoundSIDFrames equ 240
ASoundSIDBytes equ 960
ASoundSIDWarp equ 3840
ASoundCount equ 8
ASoundDirectory
                    fcb 0 ; laser1
                    fdb 0,16000
                    fcb 1 ; laser2
                    fdb 7808,16000
                    fcb 3 ; short_explosion
                    fdb 7424,24000
                    fcb 6 ; long_explosion
                    fdb 6848,40000
                    fcb 11 ; bonus
                    fdb 5888,12800
                    fcb 13 ; sonar
                    fdb 2304,16000
                    fcb 15 ; refill
                    fdb 1920,35198
                    fcb 19 ; asteroids
                    fdb 4350,47998
