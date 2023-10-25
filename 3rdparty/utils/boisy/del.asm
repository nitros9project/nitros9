********************************************************
* Del - An enhanced version.
*
* By: Boisy G. Pitre
*     Southern Station, Box 8455
*     Hattiesburg, MS  39406-8455
*     Internet:  bgpitre@seabass.st.usm.edu
*
* 03/19/92 - Added comments to program
* ??/??/?? - Wrote program

                    nam       Del
                    ttl       program module

                    ifp1
                    use       defsfile
                    endc

                    mod       Size,Name,Prgrm+Objct,ReEnt+1,Start,Fin

Mode                rmb       1                   access mode byte
Stack               rmb       200
Parms               rmb       200
Fin                 equ       .

Name                fcs       /Del/
                    fcb       $06                 Edition number

Start               lda       #WRITE.             default to current directory
                    sta       Mode

Parse               lda       ,x+                 get next char
                    cmpa      #$20                is it a space?
                    beq       Parse               yep, continue parsing
                    cmpa      #$0D                is it eoln?
                    beq       Done                yep, we're through
                    cmpa      #'-                 is it a dash (option)
                    beq       GetOpt              yep, parse option
                    leax      -1,x                else back up one char
                    bra       DelFile             and kill the file

GetOpt              lda       ,x+                 get char
                    anda      #$DF                make uppercase
                    cmpa      #'X                 is it X?
                    beq       ChMode              yep, set mode to execute
                    bra       Parse               else resume parsing

ChMode              lda       #WRITE.+EXEC.       delete in current exec dir.
                    sta       Mode                and save mode

DelFile             lda       Mode                get current access mode
                    os9       I$DeletX            delete the file
                    bcc       Parse               if not error, continue parsing
                    cmpb      #214                is the error "no permission"?
                    bne       Error               no, fatal error
                    os9       F$PErr              else print the error

NextName            lda       ,x+                 advance to next name
                    cmpa      #$20
                    beq       Parse
                    cmpa      #$0D
                    beq       Done
                    bra       NextName

Done                clrb
Error               os9       F$Exit

                    emod
Size                equ       *
                    end

