* Native packed-BCD addition from original $3FFF/$414E.
* A = points in tens, X game. Preserve D,X,Y,U. Rendering appends the
* original fixed zero; a BCD $05 award is 50 points, not five.
AddPlayerScore   pshs      d,x,y,u
                    tst       GS_DemoActive,x
                    bne       ScoreReturn
                    leay      GS_ScorePlayer1,x
                    tst       GS_CurrentPlayer,x
                    beq       ScoreSelectReady
                    leay      GS_ScorePlayer2,x
ScoreSelectReady lbsr      AddScoreBCD
                    tst       GS_DoubleScore,x
                    beq       ScoreAddReturn
                    lda       SC_Award,s ; stack offset: saved award A
                    lbsr      AddScoreBCD
ScoreAddReturn   lbsr      UpdatePlayerRanks
ScoreReturn
                    puls      d,x,y,u,pc
* Y native big-endian packed score. A/CC scratch; preserve B,X,Y,U.
AddScoreBCD      adda      1,y
                    daa
                    sta       1,y
                    lda       ,y
                    adca      #0
                    daa
                    sta       ,y
                    rts
