* Parse sign bit terminated string to convert it to a
* null terminated string. Note: if X and Y are the same
* the existing string will be overwritten -- don't do this
* with psects...

* OTHER MODULES NEEDED: none

* ENTRY: X=start of sign bit terminated string
*        Y=buffer for null terminated string

* EXIT: D=string size (not including null)
*       All other regs (except cc) preserved


                    nam       Parse               sign-bit terminated string
                    ttl       Assembler Library Module


                    section   .text


PARSNSTR
                    pshs      x
                    lbsr      STRHCPY             copy string
                    tfr       y,x                 point to moved string
                    lbsr      STRHLEN             find length of string
                    pshs      d                   size
                    leax      d,x
                    lda       ,-x                 get final byte
                    anda      #%01111111          clear sign bit
                    clrb                          add null terminator
                    std       ,x
                    puls      d,x,pc


                    endsect

