* Native 6809 terminal input. Include defsfile and equates.asm first.
* SS.LiveKeys reads the CALLING VT, not the global keyboard registers.
* Background VTs return zero; the driver also drains queued characters.
*
* ReadTerminalKeys
*   X = ASTRO_KEY_BYTES destination; U = process static base.
*   Success: byte 0 sense bits, bytes 1..6 held key codes. C clear.
*   Failure: destination unchanged; C set, B = OS-9 error.
*   Preserves X,Y,U. D is a result/scratch register.
*   SS.LiveKeys RETURNS KEY BYTES IN U: never use that U as static base.
ReadTerminalKeys    pshs      d,x,y,u
                    lda       #ASTRO_INPUT_PATH
                    ldb       #SS.LiveKeys
                    os9       I$GetStt
                    bcs       ReadTerminalKeysError
* Preserve the returned key registers before recovering the output pointer.
                    pshs      a,x,y,u
                    ldx       RK_ReturnBytes+RK_ResultPointer,s ; stack offset: saved output pointer
                    lda       RK_ReturnSense,s ; stack offset: returned sense byte
                    sta       ASTRO_KEY_SENSE,x
                    ldd       RK_ReturnKeys12,s ; stack offset: returned X (keys 1,2)
                    std       ASTRO_KEY_CODES,x
                    ldd       RK_ReturnKeys34,s ; stack offset: returned Y (keys 3,4)
                    std       ASTRO_KEY_CODES+2,x
                    ldd       RK_ReturnKeys56,s ; stack offset: returned U (keys 5,6)
                    std       ASTRO_KEY_CODES+4,x
                    leas      RK_ReturnBytes,s
                    leas      RK_SavedDBytes,s ; discard saved D; return fresh C clear
                    andcc     #$FE
                    puls      x,y,u,pc
ReadTerminalKeysError
                    leas      RK_SavedDBytes,s ; discard saved D, preserving error B and C
                    puls      x,y,u,pc
