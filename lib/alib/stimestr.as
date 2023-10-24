*****************************************

* Get current system time as an ascii string.


* OTHER MODULES NEEDED: DATESTR

* ENTRY:  X=buffer for ascii

* EXIT: all registers preserved (except cc)

                    nam       Get                 System Time String
                    ttl       Assembler Library Module


                    section   .text

STIMESTR
                    pshs      x,y
                    tfr       x,y                 ascii buffer to Y
                    leas      -7,s                buffer for time packet
                    tfr       s,x
                    os9       F$Time              get system time
                    lbsr      DATESTR             convert to ascii in Y buffer
                    leas      7,s
                    puls      x,y,pc

                    endsect
t
