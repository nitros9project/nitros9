* Set flags for Real comparison.
* Shared by Basic09 and RunB; keep byte-for-byte stable.
RLCMP               pshs      y
                    andcc     #Entire+FIRQMask+HalfCrry+IRQMask
                    lda       8,y
                    bne       RLCM50
                    lda       2,y
                    beq       RLCM30
RLCM10              lda       5,y
RLCM15              anda      #$01
                    bne       RLCM30
RLCM20              andcc     #Entire+FIRQMask+HalfCrry+IRQMask
                    orcc      #Negative
RLCM30              puls      pc,y

RLCM50              lda       2,y
                    bne       RLCM60
                    lda       $B,y
                    eora      #$01
                    bra       RLCM15

RLCM60              lda       $B,y
                    eora      5,y
                    anda      #$01
                    bne       RLCM10
                    leau      6,y
                    lda       5,y
                    anda      #$01
                    beq       RLCM65
                    exg       u,y
RLCM65              ldd       1,u
                    cmpd      1,y
                    bne       RLCM30
                    ldd       3,u
                    cmpd      3,y
                    bne       RLCM70
                    lda       5,u
                    cmpa      5,y
                    beq       RLCM30
RLCM70              bcs       RLCM20
                    andcc     #Entire+FIRQMask+HalfCrry+IRQMask
                    puls      pc,y
