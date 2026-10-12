* Exact SP0250 frames decoded by the original 808b speech ROM.
SP_AssetOffset equ 24799
SP_AssetBytes equ 46680
SP_AssetBlocks equ 6
SpeechWordDirectory
                    fcb 0 ; original speech command $01
                    fdb 0,780
                    fcb 0 ; original speech command $02
                    fdb 780,2025
                    fcb 0 ; original speech command $03
                    fdb 2805,840
                    fcb 0 ; original speech command $04
                    fdb 3645,1620
                    fcb 0 ; original speech command $05
                    fdb 5265,1515
                    fcb 0 ; original speech command $06
                    fdb 6780,1800
                    fcb 1 ; original speech command $07
                    fdb 388,3120
                    fcb 1 ; original speech command $08
                    fdb 3508,2760
                    fcb 1 ; original speech command $09
                    fdb 6268,1890
                    fcb 1 ; original speech command $0A
                    fdb 8158,975
                    fcb 2 ; original speech command $0B
                    fdb 941,1605
                    fcb 2 ; original speech command $0C
                    fdb 2546,1065
                    fcb 2 ; original speech command $0D
                    fdb 3611,825
                    fcb 2 ; original speech command $0E
                    fdb 4436,780
                    fcb 2 ; original speech command $0F
                    fdb 5216,855
                    fcb 2 ; original speech command $10
                    fdb 6071,915
                    fcb 2 ; original speech command $11
                    fdb 6986,1245
                    fcb 3 ; original speech command $12
                    fdb 39,1020
                    fcb 3 ; original speech command $13
                    fdb 1059,1230
                    fcb 3 ; original speech command $14
                    fdb 2289,705
                    fcb 3 ; original speech command $15
                    fdb 2994,990
                    fcb 3 ; original speech command $16
                    fdb 3984,750
                    fcb 3 ; original speech command $17
                    fdb 4734,1020
                    fcb 3 ; original speech command $18
                    fdb 5754,1035
                    fcb 3 ; original speech command $19
                    fdb 6789,975
                    fcb 3 ; original speech command $1A
                    fdb 7764,885
                    fcb 4 ; original speech command $1B
                    fdb 457,765
                    fcb 4 ; original speech command $1C
                    fdb 1222,735
                    fcb 4 ; original speech command $1D
                    fdb 1957,825
                    fcb 4 ; original speech command $1E
                    fdb 2782,855
                    fcb 4 ; original speech command $1F
                    fdb 3637,3750
                    fcb 4 ; original speech command $20
                    fdb 7387,2625
                    fcb 5 ; original speech command $21
                    fdb 1820,120
                    fcb 5 ; original speech command $22
                    fdb 1940,2130
                    fcb 5 ; original speech command $23
                    fdb 4070,1650
SpeechPhraseDirectory
                    fdb SpeechPhrase00-SpeechPhraseDirectory
                    fdb SpeechPhrase01-SpeechPhraseDirectory
                    fdb SpeechPhrase02-SpeechPhraseDirectory
                    fdb SpeechPhrase03-SpeechPhraseDirectory
                    fdb SpeechPhrase04-SpeechPhraseDirectory
                    fdb SpeechPhrase05-SpeechPhraseDirectory
                    fdb SpeechPhrase06-SpeechPhraseDirectory
                    fdb SpeechPhrase07-SpeechPhraseDirectory
                    fdb SpeechPhrase08-SpeechPhraseDirectory
                    fdb SpeechPhrase09-SpeechPhraseDirectory
                    fdb SpeechPhrase10-SpeechPhraseDirectory
                    fdb SpeechPhrase11-SpeechPhraseDirectory
                    fdb SpeechPhrase12-SpeechPhraseDirectory
                    fdb SpeechPhrase13-SpeechPhraseDirectory
                    fdb SpeechPhrase14-SpeechPhraseDirectory
                    fdb SpeechPhrase15-SpeechPhraseDirectory
                    fdb SpeechPhrase16-SpeechPhraseDirectory
                    fdb SpeechPhrase17-SpeechPhraseDirectory
                    fdb SpeechPhrase18-SpeechPhraseDirectory
                    fdb SpeechPhrase19-SpeechPhraseDirectory
                    fdb SpeechPhrase20-SpeechPhraseDirectory
                    fdb SpeechPhrase21-SpeechPhraseDirectory
                    fdb SpeechPhrase22-SpeechPhraseDirectory
                    fdb SpeechPhrase23-SpeechPhraseDirectory
                    fdb SpeechPhrase24-SpeechPhraseDirectory
                    fdb SpeechPhrase25-SpeechPhraseDirectory
                    fdb SpeechPhrase26-SpeechPhraseDirectory
                    fdb SpeechPhrase27-SpeechPhraseDirectory
                    fdb SpeechPhrase28-SpeechPhraseDirectory
                    fdb SpeechPhrase29-SpeechPhraseDirectory
                    fdb SpeechPhrase30-SpeechPhraseDirectory
                    fdb SpeechPhrase31-SpeechPhraseDirectory
                    fdb SpeechPhrase32-SpeechPhraseDirectory
                    fdb SpeechPhrase33-SpeechPhraseDirectory
                    fdb SpeechPhrase34-SpeechPhraseDirectory
                    fdb SpeechPhrase35-SpeechPhraseDirectory
                    fdb SpeechPhrase36-SpeechPhraseDirectory
                    fdb SpeechPhrase37-SpeechPhraseDirectory
                    fdb SpeechPhrase38-SpeechPhraseDirectory
                    fdb SpeechPhrase39-SpeechPhraseDirectory
                    fdb SpeechPhrase40-SpeechPhraseDirectory
                    fdb SpeechPhrase41-SpeechPhraseDirectory
                    fdb SpeechPhrase42-SpeechPhraseDirectory
                    fdb SpeechPhrase43-SpeechPhraseDirectory
                    fdb SpeechPhrase44-SpeechPhraseDirectory
                    fdb SpeechPhrase45-SpeechPhraseDirectory
                    fdb SpeechPhrase46-SpeechPhraseDirectory
                    fdb SpeechPhrase47-SpeechPhraseDirectory
SpeechPhrase00 fcb 0
SpeechPhrase01 fcb 5,0
SpeechPhrase02 fcb 30,33,33,7,0
SpeechPhrase03 fcb 29,0
SpeechPhrase04 fcb 28,0
SpeechPhrase05 fcb 27,0
SpeechPhrase06 fcb 26,0
SpeechPhrase07 fcb 25,0
SpeechPhrase08 fcb 24,0
SpeechPhrase09 fcb 23,0
SpeechPhrase10 fcb 22,0
SpeechPhrase11 fcb 21,0
SpeechPhrase12 fcb 20,0
SpeechPhrase13 fcb 0
SpeechPhrase14 fcb 0
SpeechPhrase15 fcb 6,0
SpeechPhrase16 fcb 0
SpeechPhrase17 fcb 6,0
SpeechPhrase18 fcb 8,0
SpeechPhrase19 fcb 1,1,33,2,29,33,3,29,4,0
SpeechPhrase20 fcb 1,1,33,2,28,33,3,29,4,0
SpeechPhrase21 fcb 1,1,33,2,27,33,3,29,4,0
SpeechPhrase22 fcb 1,1,33,2,26,33,3,29,4,0
SpeechPhrase23 fcb 1,1,33,2,25,33,3,29,4,0
SpeechPhrase24 fcb 1,1,33,2,24,33,3,29,4,0
SpeechPhrase25 fcb 1,1,33,2,23,33,3,29,4,0
SpeechPhrase26 fcb 1,1,33,2,22,33,3,29,4,0
SpeechPhrase27 fcb 1,1,33,2,29,33,3,28,4,0
SpeechPhrase28 fcb 1,1,33,2,28,33,3,28,4,0
SpeechPhrase29 fcb 1,1,33,2,27,33,3,28,4,0
SpeechPhrase30 fcb 1,1,33,2,26,33,3,28,4,0
SpeechPhrase31 fcb 1,1,33,2,25,33,3,28,4,0
SpeechPhrase32 fcb 1,1,33,2,24,33,3,28,4,0
SpeechPhrase33 fcb 1,1,33,2,23,33,3,28,4,0
SpeechPhrase34 fcb 1,1,33,2,22,33,3,28,4,0
SpeechPhrase35 fcb 9,10,33,33,11,0
SpeechPhrase36 fcb 9,12,0
SpeechPhrase37 fcb 31,33,32,0
SpeechPhrase38 fcb 30,13,15,0
SpeechPhrase39 fcb 29,14,15,33,33,7,0
SpeechPhrase40 fcb 28,13,15,0
SpeechPhrase41 fcb 27,13,15,0
SpeechPhrase42 fcb 26,13,15,0
SpeechPhrase43 fcb 16,17,10,0
SpeechPhrase44 fcb 16,18,0
SpeechPhrase45 fcb 16,19,0
SpeechPhrase46 fcb 34,33,33,35,0
SpeechPhrase47 fcb 30,13,15,33,33,35,0
