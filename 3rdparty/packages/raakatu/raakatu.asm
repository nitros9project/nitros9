;##$CPU 6809
;##$OriginalBinary raakatu.bin

;##-
;##- Menu structure for CodeToWeb HTML generator
;##-
;##Menu     3                 "Engine"
;##MenuLink Start                    "Program Entry"
;##MenuLink GetKey                   "Get a Key"
;##MenuLink DecodeBuffer             "Decode Input Buffer"
;##MenuLink DecodeWord               "Decode Single Word"
;##MenuLink InputWordTables          "GAME VOCABULARY"
;##MenuLink RAM                      "RAM Usage"
;##MenuLink PrintPackedMessage       "Print Packed Message"
;##MenuLink PrintCharacterAutoWrap   "Print Character (with auto-wrap)"
;##MenuLink UnpackBytes              "Unpack 2 bytes into 3 characters"
;##MenuLink FeedbackPrompts          "Feedback Prompts"
;##MenuLink PhraseList               "List of phrase forms"
;##-
;##Menu     2                    "Virtual Machine"
;##MenuLink ProcessCommand             "Process a Direct or Common Command"
;##MenuLink CommandJumpTable           "VM Command Jump Table"
;##MenuLink RoomDescriptions           "Information for each room"
;##MenuLink ObjectData                 "Object data"
;##MenuLink GeneralCommands            "General command handling"
;##MenuLink HelperCommands             "List of helper commands each with an ID"
;##-
;##Menu     1                   "Script Commands"
;##MenuLink Com00_MoveActiveObjectToRoomAndLook         "00: Move active object to room and print room description"
;##MenuLink Com01_IsObjectInPackOrRoom                  "01: Check if requested object is here (in pack or room)"
;##MenuLink Com02_CheckObjectIsOwnedByActive            "02: Check if object is owned by active object"
;##MenuLink Com03_IsObjectYAtX                          "03: Check if requested object at target location"
;##MenuLink Com04_PrintSYSTEMOrPlayerMessage            "04: Print message if SYSTEM or Player"
;##MenuLink Com05_IsRandomLessOrEqual                   "05: If last random is less than or equal"
;##MenuLink Com06_Inventory                             "06: Print inventory"
;##MenuLink Com07_Look                                  "07: Print room description"
;##MenuLink Com08_CompareObjectToFirstNoun              "08: Compare object to first noun"
;##MenuLink Com09_CompareObjectToSecondNoun             "09: Command object to second noun"
;##MenuLink Com0A_CompareToPhraseForm                   "0A: Compare value to current phrase form"
;##MenuLink Com0B_Switch                                "0B: Switch-statement. Execute a script based on a compare function."
;##MenuLink Com0C_FAIL                                  "0C: FAIL"
;##MenuLink Com0D_ExecutePassingList                    "0D: Execute a list of commands as long as they succeed"
;##MenuLink Com0E_ExecuteFailingList                    "0E: Execute a list of commands as long as they fail"
;##MenuLink Com0F_PickUpObject                          "0F: Pick up object"
;##MenuLink Com10_DropObject                            "10: Drop object"
;##MenuLink Com11_Print1stNounShortName                 "11: Print 1st noun short name"
;##MenuLink Com12_Print2ndNounShortName                 "12: Print 2nd noun short name"
;##MenuLink Com13_PhraseWithRoom1st2nd                  "13: Process phrase with room, 2nd noun, then 1st noun"
;##MenuLink Com14_ExecuteCommandAndReverseReturn        "14: Execute a command and reverse the return"
;##MenuLink Com15_CheckObjBits                          "15: Check object bits"
;##MenuLink Com16_PrintVarShortName                     "16: Print var short name"
;##MenuLink Com17_MoveObjectXToLocationY                "17: Move object to new location"
;##MenuLink Com18_CheckVarOwnedByActiveObject           "18: Check var object owned by active object"
;##MenuLink Com19_MoveActiveObjectToRoom                "19: Move active object to room"
;##MenuLink Com1A_SetVarObjectTo1stNoun                 "1A: Set var object to first noun"
;##MenuLink Com1B_SetVarObjectTo2ndNoun                 "1B: Set var object to second noun"
;##MenuLink Com1C_SetVarObject                          "1C: Set var object"
;##MenuLink Com1D_AttackObject                          "1D: Attack object"
;##MenuLink Com1E_SwapObjects                           "1E: Swap objects"
;##MenuLink Com1F_PrintMessage                          "1F: Print message"
;##MenuLink Com20_CheckActiveObject                     "20: Check active object"
;##MenuLink Com21_RunGeneralWithTempPhrase              "21: Execute general script with temporary phrase and nouns"
;##MenuLink Com22_CompareHealthToValue                  "22: Compare health to value"
;##MenuLink Com23_HealVarObject                         "23: Heal var object"
;##MenuLink Com24_EndlessLoop                           "24: Endless loop"
;##MenuLink Com25_RestartGame                           "25: Restart game"
;##MenuLink Com26_PrintScore                            "26: Print score"
;##-

;##RAM

;##+0088..  printCursor           screen pointer used by BASIC
;
;##+01A7..  tmp1A7                used in decoding the input
;##+01A9    tmp1A9                used in comparing X to Y
;##+01AA    not1AA                never used
;##+01AB    tmp1AB                used in lots of places
;##+01AC    not1AC                never used
;##+01AD    tmp1AD                used in the phrase decoding
;##+01AE    not1AE                never used
;##+01AF    not1AF                never used
;##+01B0    not1B0                never used
;##+01B1    not1B1                never used
;##+01B2    tmp1B2                used in word decoding
;##+01B3    verbWord              input verb word number
;##+01B4    perpWord              preposition word number
;##+01B5    prepGiven             preposition given flag
;##+01B6    phrasePrep            used in phrase decoding
;##+01B7    adjWord               adjective word number
;##+01B8    commandTarg           target object of input command
;##+01B9    not1B9                cleared before decode but never used
;##+01BA    lsbAdj1               screen LSB of 1st adjective
;##+01BB    lsbVerb               screen LSB of verb
;##+01BC    lsbCursor             screen lsb used in decoding the input line
;##+01BD    lsbError              screen lsb used for flashing error messages
;##+01BE    lastChar              last character printed to screen
;##+01BF      VAR_OBJ_NUMBER      variable object number
;##+01C0..    VAR_OBJ_DATA        variable object data
;##+01C2    not1C2                never used
;##+01C3      FIRST_NOUN_NUM      first input noun number
;##+01C4    firstNounAdj          first input noun adjective word number
;##+01C5    firstNounLSB          first input noun screen LSB
;##+01C6..    FIRST_NOUN_DATA     first input noun object data
;##+01C8    firstNounParams       first input noun parameter bits
;##+01C9      SECOND_NOUN_NUM     second input noun number
;##+01CA    secondNounAdj         second input noun adjective word number
;##+01CB    secondNounLSB         second input noun noun screen LSB
;##+01CC..    SECOND_NOUN_DATA    second input noun object data
;##+01CE    secondNounParams      second input noun parameter bits
;##+01CF    tmp1CF                another screen pointer used in decode
;##+01D0    tmp1DO                used in making index of data fields
;##+01D1      PHRASE_FORM         decoded phrase form
;##+01D2      ACTIVE_OBJ_NUM      active object
;##+01D3..    ACTIVE_OBJ_DATA     active object data
;##+01D5      CUR_ROOM            current room number
;##+01D6..    CUR_ROOM_DATA       current room data
;##+01D8..  nextToken             used in decoding input
;##+01DA    tmp1DA                used in unpacking bytes
;##+01DB    tmp1DB                used in unpacking bytes
;##+01DC    tmp1DC                used in unpacking bytes
;##+01DD    tmp1DD                used in unpacking bytes
;##+01DE    tmp1DE                used in unpacking bytes
;##+01DF    tmp1DF                used in unpacking bytes
;##+01E0    tmp1EO                used in unpacking bytes
;##+01E1    tmp1E1                used in making index of data fields
;##+01E2    tmp1E2                used in input processing
;##+01E3    tillMORE              rows left until MORE prompt (not used here)
;
; $01E4     inputTokens           input token buffer
; $03FF     stack                 top of stack (just below screen memory)

                    nam       Raaka-Tu
                    ttl       program module

* Disassembled 2004/07/13 07:31:17 by Disasm v1.5 (C) 1988 by RML

                    ifp1
                    use       os9.d
                    endc

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00

topmod              equ       $C000

                    mod       eom,name,tylg,atrv,start,size

                    rmb       $01A7
u01A7               rmb       1                   ..  tmp1A7                used in decoding the input
u01A8               rmb       1                   ..  tmp1A7                used in decoding the input
u01A9               rmb       1                   tmp1A9                used in comparing X to Y
u01AA               rmb       1                   not1AA                never used
u01AB               rmb       1                   tmp1AB                used in lots of places
u01AC               rmb       1                   not1AC                never used
u01AD               rmb       1                   tmp1AD                used in the phrase decoding
u01AE               rmb       1                   not1AE                never used
u01AF               rmb       1                   not1AF                never used
u01B0               rmb       1                   not1B0                never used
u01B1               rmb       1                   not1B1                never used
u01B2               rmb       1                   tmp1B2                used in word decoding
u01B3               rmb       1                   verbWord              input verb word number
u01B4               rmb       1                   perpWord              preposition word number
u01B5               rmb       1                   prepGiven             preposition given flag
u01B6               rmb       1                   phrasePrep            used in phrase decoding
u01B7               rmb       1                   adjWord               adjective word number
u01B8               rmb       1                   commandTarg           target object of input command
u01B9               rmb       1                   not1B9                cleared before decode but never used
u01BA               rmb       1                   lsbAdj1               screen LSB of 1st adjective
u01BB               rmb       1                   lsbVerb               screen LSB of verb
u01BC               rmb       1                   lsbCursor             screen lsb used in decoding the input line
u01BD               rmb       1                   lsbError              screen lsb used for flashing error messages
u01BE               rmb       1                   lastChar              last character printed to screen
u01BF               rmb       1                   VAR_OBJ_NUMBER      variable object number
u01C0               rmb       2                   ..    VAR_OBJ_DATA        variable object data
u01C2               rmb       1                   not1C2                never used
u01C3               rmb       1                   FIRST_NOUN_NUM      first input noun number
u01C4               rmb       1                   firstNounAdj          first input noun adjective word number
u01C5               rmb       1                   firstNounLSB          first input noun screen LSB
u01C6               rmb       2                   ..    FIRST_NOUN_DATA     first input noun object data
u01C8               rmb       1                   firstNounParams       first input noun parameter bits
u01C9               rmb       1                   SECOND_NOUN_NUM     second input noun number
u01CA               rmb       1                   secondNounAdj         second input noun adjective word number
u01CB               rmb       1                   secondNounLSB         second input noun noun screen LSB
u01CC               rmb       2                   ..    SECOND_NOUN_DATA    second input noun object data
u01CE               rmb       1                   secondNounParams      second input noun parameter bits
u01CF               rmb       1                   tmp1CF                another screen pointer used in decode
u01D0               rmb       1                   tmp1DO                used in making index of data fields
u01D1               rmb       1                   PHRASE_FORM         decoded phrase form
u01D2               rmb       1                   ACTIVE_OBJ_NUM      active object
u01D3               rmb       2                   ..    ACTIVE_OBJ_DATA     active object data
u01D5               rmb       1                   CUR_ROOM            current room number
u01D6               rmb       2                   ..    CUR_ROOM_DATA       current room data
u01D8               rmb       2                   ..  nextToken             used in decoding input
u01DA               rmb       1                   tmp1DA                used in unpacking bytes
u01DB               rmb       1                   tmp1DB                used in unpacking bytes
u01DC               rmb       1                   tmp1DC                used in unpacking bytes
u01DD               rmb       1                   tmp1DD                used in unpacking bytes
u01DE               rmb       1                   tmp1DE                used in unpacking bytes
u01DF               rmb       1                   tmp1DF                used in unpacking bytes
u01E0               rmb       1                   tmp1EO                used in unpacking bytes
u01E1               rmb       1                   tmp1E1                used in making index of data fields
u01E2               rmb       1                   tmp1E2                used in input processing
u01E3               rmb       1                   tillMORE              rows left until MORE prompt (not used here)
;
u01E4,u               rmb       $21b                inputTokens           input token buffer
u03FF               equ       .                   stack                 top of stack (just below screen memory)
size                equ       .

name                equ       *
                    fcs       /raakatu/
                    fcb       $00

;##Start
start               equ       *
                    lda       #$1D                ; Player object ...
                    sta       u01D2,u               ; ... is the active object number
                    ldb       #$96                ; Starting ...
                    stb       u01D5,u               ; ... room
                    leax      L1523,pc            ; Room descriptions
                    lbsr      L0A1F               ; Find room data
                    stx       u01D6,u               ; Store current room data
                    lbsr      L0D4A               ; Print room description
                    lda       #$0D                ; Print ...
                    lbsr      L1184               ; ... CR

 os9 F$Exit
 
;##MainLoop
L0630
                    lbsr      L0ACC               ; Get user input
L0637               clr       u01B7,u               ; Adjective word number
                    clr       u01BA,u               ; LSB of 1st adjective in buffer (not used)
                    clr       u01BB,u               ; LSB of verb
                    clr       u01B2,u               ; Misc
                    clr       u01B3,u               ; Verb word number
                    clr       u01B9,u               ; Never used again
                    clr       u01B8,u               ; Target object of command (not used)
                    clr       u01B4,u               ; Preposition number
                    clr       u01B5,u               ; Preposition given flag (not 0 if given)
                    clr       u01BF,u               ; VAR object number
                    clr       u01C3,u               ; 1st noun word number
                    clr       u01C9,u               ; 2nd noun word number
                    ldb       #$1D                ; Player object ...
                    stb       u01D2,u               ; ... is active object
                    lbsr      L1133               ; Get player object data
                    stx       u01D3,u               ; Active object's data
                    lbsr      L0A42               ; Skip length
                    ldb       ,X                  ; Get player location
                    stb       u01D5,u               ; Current room
                    leax      L1523,pc            ; Room scripts
                    lbsr      L0A1F               ; Find sublist ... script for room
                    stx       u01D6,u               ; Script for current room
*                    ldx       #u01E3,u              ; Input token list area
                    leax      u01E3,u              ; Input token list area
                    stx       u01D8,u               ; Where decoder fills in
                    clr       ,X                  ; Empty token ... clear the list
                    ldx       #$05E0              ; Bottom row is input buffer
L0682               lbsr      L0B42               ; Decode input word
                    beq       L0692               ; All words done
L0687               lda       ,X+                 ; Next character
                    cmpa      #$60                ; A space?
                    beq       L0682               ; Yes ... decode next
                    cmpx      #$0600              ; End of input buffer?
                    bne       L0687               ; No ... look for next word
L0692               cmpx      #$0600              ; End of input buffer?

                    bne       L0682               ; No ... keep looking
                    clr       [u01D8,u]             ; Terminate token list
*                    ldx       #u01E3,u              ; Input buffer
                    leax       u01E3,u              ; Input buffer
                    lda       ,X                  ; List number of first word
                    lbeq      L0736               ; Nothing entered
                    cmpa      #$02                ; First word a noun?

                    bne       L06B7               ; No ... move on
                    leax      1,X                 ; Point to word number
                    lda       ,X                  ; Get word number
                    leax      -1,X                ; Back to list number
                    cmpa      #$06                ; Living things (people, dogs, etc) are <6

                    bcc       L06B7               ; Not a living thing
                    sta       u01B8,u               ; Remember living thing. We are giving them a command so process normally
                    leax      3,X                 ; Next word

L06B7               lda       ,X+                 ; Word list

                    beq       L0736               ; End of list ... go process
                    ldb       ,X                  ; Word number to B
                    ldu       ,X++                ; LSB to LSB of U
                    pshs      X                   ; Hold token buffer
                    deca                          ; List 1? Verbs?

                    bne       L06E5               ; No ... continue

; I believe the goal here was to allow multiple verbs given on an input line
; to be translated to a single verb. The code finds a replacement list for the
; newly given verb and then runs the list two bytes at a time comparing one
; of the entries to the last given verb and storing the second byte if there
; is a match. I believe that is what is SUPPOSED to happen, but I believe the
; code has a bug or two. It actually does nothing at all. The replacement
; list for BEDLAM and RAAKATU is empty so the code is never used anyway.
;
                    leax      L1333-1,pc          ;  Multi verb translation list (empty list for BEDLAM and RAAKATU)
                    lbsr      L0A1F               ;  Look for an entry for the given verb

                    bcc       L06DF               ;  No entry ... use the word as-is
                    lbsr      L0A42               ;  Skip length of entry
L06CF               lbsr      L0A58               ;  End of list?
                    tfr       B,A                 ;  ?? Held in A but ...

                    bcc       L06DF               ;  Reached end of list. This input is the verb.
                    ldb       ,X+                 ;  ??
                    lda       ,X+                 ;  ?? ... A is mangled here?
                    cmpb      u01B3,u               ;  ?? Compare to 01B3 ...

                    bne       L06CF               ;  Continue running list
L06DF               stb       u01B3,u               ;  ?? ... then store if equal?
                    lbra      L0731               ;  Continue with next word

L06E5               deca                          ;  List 2 Noun
                    bne       L071E               ;  Not a noun
                    tst       u01B5,u               ;  Has prepostion been given?

                    beq       L070D               ;  No ... this is first noun
*                    ldx       #u01C9,u              ;  2nd noun area
                    leax       u01C9,u              ;  2nd noun area
L06F0               stb       ,X+                 ;  Store word number
                    lda       u01B7,u               ;  Last adjective
                    sta       ,X+                 ;  Keep with noun
                    lda       u01BA,u               ;  LSB of adjective
                    sta       ,X                  ;  Keep with noun

                    bne       L0702               ;  There was one ... go on
                    tfr       U,D                 ;  Use LSB of ...
                    stb       ,X                  ;  ... noun if no adjective
L0702               clr       u01B7,u               ;  Adjective moved
                    clr       u01B5,u               ;  Preposition moved
                    clr       u01BA,u               ;  LSB moved

                    bra       L0731               ;  Continue with next word

L070D               ldx       u01C3,u               ;  Copy ...
                    stx       u01C9,u               ;  ... any ...
                    ldx       u01C5,u               ;  ... first noun ...
                    stx       u01CB,u               ;  ... to second
*                    ldx       #u01C3,u              ;  First word area
                    leax       u01C3,u              ;  First word area

                    bra       L06F0               ;  Go fill out first word

L071E               deca                          ;  List 3 Adjective

                    bne       L072B               ;  Not a proposition
                    stb       u01B7,u               ;  Store adjective number
                    tfr       U,D                 ;  Store ...
                    stb       u01BA,u               ;  ... adjective LSB in buffer

                    bra       L0731               ;  Continue with next word

L072B               stb       u01B4,u               ;  Preposition
                    stb       u01B5,u               ;  Preoposition given (noun should follow)
L0731               puls      X                   ;  Restore token pointer
                    lbra      L06B7               ;  Next word


L0736               tst       u01B3,u               ;  Verb given?
                    lbeq      L0995               ;  No ... ?VERB? error
*                    ldx       #u01C9,u              ;  Second noun
                    leax       u01C9,u              ;  Second noun
                    lbsr      L0822               ;  Decode it (only returns if OK)
                    sta       u01C9,u               ;  Hold target object index
                    stx       u01CC,u               ;  Hold target object pointer
*                    ldx       #u01C3,u              ;  First noun
                    leax       u01C3,u              ;  First noun
                    lbsr      L0822               ;  Decode it (only returns if OK)
                    sta       u01C3,u               ;  Hold target object index
                    stx       u01C6,u               ;  Hold target object pointer
                    clr       u01B5,u               ;  Clear preposition flag

                    ldx       u01C6,u               ;  Pointer to first noun object data
                    lda       u01C3,u               ;  First noun index

                    beq       L0767               ;  No first noun ... store a 0
                    lbsr      L0A42               ;  Skip ID and load end
                    leax      2,X                 ;  Skip 2 bytes
                    lda       ,X                  ;  Object parameter bits
L0767               sta       u01C8,u               ;  Hold first noun's parameter bits

                    ldx       u01CC,u               ;  Pointer to second noun object data
                    lda       u01C9,u               ;  Second noun number

                    beq       L0779               ;  No second noun ... store 0
                    lbsr      L0A42               ;  Skip ID and load end
                    leax      2,X                 ;  Skip 2 bytes
                    lda       ,X                  ;  Object parameter bits
L0779               sta       u01CE,u               ;  Hold second noun's parameter bits

                    leax      L135B,pc            ;  Syntax list
L077F               lda       ,X                  ;  End of list?
                    lbeq      L0951               ;  Yes ... "?PHRASE?"
                    lda       u01B3,u               ;  Verb ...
                    cmpa      ,X+                 ;  ... matches?

                    bne       L07E7               ;  No ... move to next entry
                    lda       ,X                  ;  Phrase's proposition
                    sta       u01B6,u               ;  Hold it
                    lda       u01B4,u               ;  Preposition word number

                    beq       L079A               ;  None given ... skip prep check
                    cmpa      ,X                  ;  Given prep matches?

                    bne       L07E7               ;  No ... move to next phrase
L079A               leax      1,X                 ;  Skip to next phrase component
                    lda       ,X                  ;  First noun required by phrase

                    beq       L07B4               ;  Not given in phrase ... skip check
                    lda       u01C3,u               ;  1st noun index

                    bne       L07BB               ;  Requested by phrase but not given by user ... next phrase
                    lda       u01BB,u               ;  LSB of verb ...
                    sta       u01BD,u               ;  ... to location of error
*                    ldy       #u01C3,u              ;  Descriptor for 1st noun
                    leay       u01C3,u              ;  Descriptor for 1st noun
                    lbsr      L08D2               ;  Decode 1st noun as per phrase

                    bra       L07BB               ;  We just processed a first one. We know it is there.
L07B4               lda       u01C3,u               ;  Is there a 1st noun?

                    lbne      L0951               ; No ... next entry
L07BB               leax      1,X                 ; Next in phrase
                    lda       ,X                  ; Phrase wants a second noun?

                    beq       L07DA               ; No ... skip
                    lda       u01C9,u               ; User given 2nd noun

                    bne       L07E1               ; Yes ... use this phrase
                    lda       u01BC,u               ; Location of ...
                    sta       u01BD,u               ; ... error on screen
                    lda       #$01                ; Set preposition ...
                    sta       u01B5,u               ; ... flag to YES
*                    ldy       #u01C9,u              ; 2nd noun index
                    leay       u01C9,u              ; 2nd noun index
                    lbsr      L08D2               ; Decode 2nd noun as per phrase

                    bra       L07E1               ; Use this

L07DA               lda       u01C9,u               ; Is there a second noun?
                    lbne      L0951               ; No ... phrase error
L07E1               leax      1,X                 ; Get matched ...
                    lda       ,X                  ; ... phrase number

                    bra       L07F0               ; Store and continue
L07E7               leax      1,X                 ; Skip ...
                    leax      1,X                 ; ... to ...
                    leax      2,X                 ; ... next entry
                    lbra      L077F               ; Keep looking

; Unlike BEDLAM, there is no giving a command to something else. Just
; ignore any commanded object and give the phrase to the user.

L07F0               sta       u01D1,u               ; Store the phrase number
                    ldx       #$05FF              ; Move cursor to ...
                    stx       >$88                ; ... end of line
                    lda       #$0D                ; Print ...
                    lbsr      L1184               ; ... CR
                    lda       u01C3,u               ; First noun given?

                    bne       L080E               ; Yes ... keep what we have
                    ldx       u01CC,u               ; Move 2nd ...
                    stx       u01C6,u               ; ... noun to ...
                    lda       u01C9,u               ; ... first ...
                    sta       u01C3,u               ; ... descriptor
L080E               leax      L323C,pc            ; General command scripts
                    lbsr      L0A42               ; Skip over end delta
                    lbsr      L0C03               ; Execute script
                    lbsr      L0F66               ; Allow objects to move
                    lda       #$0D                ; Print ...
                    lbsr      L1184               ; ... CR
                    lbra      L0630               ; Top of game loop


; This function decodes the NOUN descriptor pointed to by X. The AJECTIVE-NOUN
; pair is compared to all objects in the room (and pack). If no adjective
; is given and there are multiple matching objects (like multiple doors with
; different colors) then the "?WHICH?" prompt is given. If there is no
; matching object then "?WHAT?" is given. If this function returns then
; the mapping was successful.
;
; @param X pointer to the noun descriptor to decode
; @return A index of target object
; @return X pointer to target object data
;
L0822               clr       u01BF,u               ; Input object number
                    ldb       ,X+                 ; Word number of noun
                    stb       u01B2,u               ; Hold it

                    bne       L082E               ; Real object ... go decode
                    clra                          ; Not found
                    rts                           ; Out
L082E               lda       ,X+                 ; Noun's adjective
                    sta       u01B7,u               ; Hold it
                    lda       ,X                  ; LSB of word in buffer
                    sta       u01CF,u               ; Hold it
                    leax      L20FF,pc            ; Object data
                    lbsr      L0A1F               ; Get pointer to next object that matches word

                    bcc       L089A               ; Not found
L0840               pshs      Y                   ; Hold end of object data
                    pshs      X                   ; Hold pointer to noun descriptor
                    lda       u01E1,u               ; Index of object in the object list
                    sta       u01E2,u               ; Remember this
                    lbsr      L08AA               ; Is object in this room or on player?

                    bne       L08A6               ; No ... can't be target ... out
                    lda       u01B7,u               ; Noun's adjective

                    beq       L0873               ; No adjective ... skip this
                    puls      X                   ; Restore pointer to noun descriptor
                    pshs      X                   ; Hold it again
                    lbsr      L0A42               ; Skip the id and end
                    leax      3,X                 ; Skip the object data
                    ldb       #$01                ; Look up adjective ...
                    lbsr      L0A27               ; ... list for object

                    bcc       L0873               ; No adjective ... ignore
                    lbsr      L0A42               ; Skip the id and length
L0867               lbsr      L0A58               ; End of adjective list?

                    bcc       L08A6               ; Yes ... no match ... next object
                    lda       u01B7,u               ; Adjective
                    cmpa      ,X+                 ; In this list?

                    bne       L0867               ; No ... keep searching list
L0873               puls      X                   ; Restore object pointer
                    lda       u01BF,u               ; Last object index that matched
                    lbne      L098C               ; Multiple matches ... do "?WHICH?"
                    lda       u01E2,u               ; Object index
                    sta       u01BF,u               ; Current guess at matching object index
                    stx       u01C0,u               ; Input object data
L0885               lbsr      L0A42               ; Skip id and end
                    tfr       Y,X                 ; Next object
                    puls      Y                   ; End of object data
                    ldb       u01B2,u               ; Restore word number of noun
                    lda       u01E2,u               ; Current object index
                    sta       u01E1,u               ; Start count for next pass
                    lbsr      L0A27               ; Find next matching object

                    bcs       L0840               ; Got one ... go test it
L089A               ldx       u01C0,u               ; Object data to X
                    lda       u01BF,u               ; Object found?

                    bne       L08A5               ; Yes ...  out
                    lbra      L0948               ; No ... "?WHAT?"
L08A5               rts                           ; Done
L08A6               puls      X                   ; Restore object pointer

                    bra       L0885               ; Do next object

; This function checks if the target object is in the current room or being
; held by the active object.
;
; @param X pointer to target object
; @return Z=1 for yes or Z=0 for no
;
L08AA               lbsr      L0A42               ; Skip size
                    lda       u01D5,u               ; Current room number
                    cmpa      ,X                  ; Is object in room?

                    beq       L08A5               ; Yes ... return OK
                    lda       ,X                  ; Get object's room number

                    beq       L08CF               ; 0 ... fail
                    cmpa      #$FF                ; FF ...

                    beq       L08A5               ; ... return OK
                    bita      #$80                ; Upper bit of object location set ...

                    bne       L08CF               ; ... then fail
                    ldb       ,X                  ; Location again
                    cmpb      u01D2,u               ; Being held by the active object?

                    beq       L08A5               ; Yes ... return OK
                    leax      L20FF,pc            ; Strange. 117D does this too.
                    lbsr      L1133               ; Get object's container object (if any)

                    bra       L08AA               ; Repeat check
L08CF               ora       #$01                ; Mark failure
                    rts                           ; Out

; This function fills the noun descriptor pointed to by Y with the object
; in current room or on user that matches the parameter value from the
; phrase script. If there is not exactly one such object then flash an error
; like "WITH ?WHAT?" using the current preposition or just "?WHAT?" if there
; isn't one.
;
; @param Y pointer to noun descriptor to fill
; @param X pointer to phrase data
; @return descriptor filled out with object
;
L08D2               pshs      X                   ; Hold phrase data pointer
                    clr       u01B2,u               ; Found word flag
                    clr       u01E1,u               ; Object index starts at 0
                    pshs      Y                   ; Hold noun descriptor
                    lda       ,X                  ; Object parameter mask bits
                    sta       u01AB,u               ; Hold
                    leax      L20FF,pc            ; Object data
                    lbsr      L0A42               ; Skip ID and load end
L08E7               lbsr      L0A58               ; At end of object data?

                    bcc       L092C               ; Yes ... done
                    inc       u01E1,u               ; Bump object index
                    pshs      Y                   ; Hold end of object
                    pshs      X                   ; Hold pointer to object
                    lbsr      L08AA               ; Is object in room or on player?
                    puls      X                   ; Restore pointer to object

                    bne       L0927               ; No ... next object
                    ldb       ,X                  ; Object word number
                    stx       u01D8,u               ; Pointer to object data
                    lbsr      L0A42               ; Skip ID and load end
                    leax      2,X                 ; Point to object parameters
                    lda       ,X                  ; Get parameters
                    anda      u01AB,u               ; Compare to phrase data ...
                    cmpa      u01AB,u               ; ... this is a strange way to do it

                    bne       L0921               ; Not a match ... next word
                    lda       u01B2,u               ; Already got a word number?

                    bne       L095A               ; Yes ... error
                    stb       u01B2,u               ; Found word number
                    lda       ,X                  ; Remember ...
                    sta       u01B7,u               ; ... object parameters
                    ldx       u01D8,u               ; Remember ...
                    stx       u01AD,u               ; ... object pointer
L0921               exg       X,Y                 ; Start of next object to X
                    puls      Y                   ; Restore end of object pointer

                    bra       L08E7               ; Continue with next object
L0927               lbsr      L0A42               ; Skip ID and load end

                    bra       L0921               ; Try next object
L092C               lda       u01B2,u               ; Did we find an object word?

                    beq       L095A               ; No .... error
                    puls      Y                   ; Noun descriptor
                    ldx       u01AD,u               ; Object data pointer
                    lda       u01E1,u               ; New ...
                    sta       ,Y                  ; ... object number
                    leay      3,Y                 ; New ...
                    stx       ,Y++                ; ... pointer to object data
                    lda       u01B7,u               ; New ...
                    sta       ,Y                  ; ... object parameters
                    puls      X                   ; Restore phrase data pointer
                    clra                          ; Set Z=1
                    rts                           ; Done

L0948               leay      L1343,pc            ; "?WHAT?"
                    lda       u01CF,u               ; LSB of screen location

                    bra       L099B               ; Go flash error and try again

L0951               leay      L1352,pc            ; "?PHRASE?"
                    lda       u01BC,u               ; LSB of screen location

                    bra       L099B               ; Go flash error and try again

L095A               lda       u01B5,u               ; Preposition given?

                    beq       L0983               ; No ... just plain "?WHAT?"
                    lda       u01B4,u               ; Preposition word number?

                    bne       L0983               ; No word ... just plain "?WHAT?"
                    leax      L3ECF,pc            ; Prepositions list
L0967               ldb       ,X                  ; Length of word

                    beq       L0983               ; Reached the end ... do "?WHAT?"
                    pshs      X                   ; Hold start of word
                    ldb       ,X+                 ; Get length again
                    abx                           ; Point to end of word
                    lda       u01B6,u               ; Target preposition
                    cmpa      ,X+                 ; Matches?

                    beq       L097B               ; Yes ... error includes this word
                    puls      A,B                 ; Restore stack

                    bra       L0967               ; Next word
L097B               puls      Y                   ; Word text to Y
                    lda       u01BD,u               ; LSB of error message
                    lbsr      L09E1               ; Push preposition word
L0983               leay      L1343,pc            ; "?WHAT?"
                    lda       u01BD,u               ; LSB of screen location

                    bra       L099B               ; Go flash error and try again
L098C               leay      L134A,pc            ; "?WHICH"?
                    lda       u01CF,u               ; LSB of screen location

                    bra       L099B               ; Go flash error and try again
L0995               leay      L133C,pc            ; "?VERB?"

                    lda       #$E0                ; LSB of start of input line
L099B
*               lds       #$03FF              ; Reset the stack (we jump back into the main loop)
                    ldx       #$05E0              ; Error goes at start of line
                    lbsr      L09E1               ; Push error message on and pause
L09A5               lda       ,Y                  ; Get length
                    sta       u01AB,u               ; Hold in counter
                    pshs      X                   ; Hold X
L09AC               lda       #$60                ; SPACE
                    sta       ,X+                 ; Flash off ...
                    dec       u01AB,u               ; ... error ...

                    bne       L09AC               ; ... word
                    lbsr      L09D6               ; Long delay
                    puls      X                   ; Restore insertion point
                    decb                          ; All flashes done?

                    bne       L09D1               ; No ... keep flashing error word
                    lda       ,Y                  ; Size of error word
                    inca                          ; Plus the extra space
                    sta       u01AB,u               ; Hold counter
L09C3               lbsr      L0ADB               ; Close up the ...
                    dec       u01AB,u               ; ... error ...

                    bne       L09C3               ; ... word
                    lbsr      L0A63               ; Get input line
                    lbra      L0637               ; Continue processing
L09D1               lbsr      L0A00               ; Flash message and pause

                    bra       L09A5               ; Continue flashing and read new line

;Long delay
L09D6               lda       #$32                ; Outer loop counts
L09D8               dec       u01AB,u               ; Decrease inner count (doesn't matter what's there)

                    bne       L09D8               ; Kill inner time
                    deca                          ; All 256 loops done?

                    bne       L09D8               ; No ... keep pausing
                    rts                           ; Done

L09E1               sta       u01AB,u               ; Hold LSB of cursor
                    ldd       #$05E0              ; Start of input line
                    ldb       u01AB,u               ; Replace LSB
                    tfr       D,X                 ; Place for error word in X
                    lda       ,Y                  ; Get length of message
                    inca                          ; Plus a space after
                    sta       u01AB,u               ; Store length
                    pshs      Y                   ; Hold message
L09F4               lbsr      L0B06               ; Slide right past insertion point
                    dec       u01AB,u               ; Space opened up?

                    bne       L09F4               ; No ... open all the spaces for the error word
                    puls      Y                   ; Restore pointer
                    ldb       #$08                ; 8 flashes
L0A00               lda       ,Y                  ; Count again
                    sta       u01AB,u               ; Size of word
                    pshs      Y,X,B               ; Hold all
                    leay      1,Y                 ; Skip size
L0A09               lda       ,Y+                 ; Copy error word ...
                    sta       ,X+                 ; ... to screen
                    dec       u01AB,u               ; All done?

                    bne       L0A09               ; No ... go back and do all
                    leax      1,X                 ; Bump ...
                    tfr       X,D                 ; ... LSB ...
                    stb       u01BD,u               ; ... of screen pointer
                    lbsr      L09D6               ; Long pause
                    puls      B,X,Y               ; Restore
                    rts                           ; Done

; FindSublist
; Find a sublist by ID within a master list.
; X=pointer to master list
; B=sublist ID
; Return sublist pointer in X
; Return C=0 if not found, C=1 if found
L0A1F               leax      1,X                 ; Skip list ID
                    lbsr      L0A44               ; Read end of list to Y
                    clr       u01E1,u               ; Clear index of sublist
L0A27               lbsr      L0A58               ; Compare X to Y

                    bcs       L0A2D               ; X is smaller ... keep going
                    rts                           ; Done (C=0 not found)
L0A2D               inc       u01E1,u               ; Keep up with index of sublist
                    cmpb      ,X                  ; Is this the sublist we want?

                    beq       L0A3F               ; Found ... C=1 and out
                    pshs      Y                   ; Hold the end
                    lbsr      L0A42               ; Skip ID and read end of list to Y
                    tfr       Y,X                 ; Jump to the end of this list
                    puls      Y                   ; Restore the end of the master lsit

                    bra       L0A27               ; Keep looking for the sublist
;
L0A3F               orcc      #$01                ; C=1
                    rts                           ; Done

;##-SkipIDLoadEnd
; Skip the ID byte and load the end of the list in Y.
L0A42               leax      1,X                 ; Bump script pointer
;
;##LoadEnd
; Load the end of the list in Y.
L0A44               clra                          ; Upper is 0
                    pshs      B                   ; Hold lower
                    ldb       ,X+                 ; Get lower
                    bitb      #$80                ; One or two byte value?

                    beq       L0A53               ; Just a one byte ... use it
                    andb      #$7F                ; This is the ...
                    tfr       B,A                 ; ... MSB
                    ldb       ,X+                 ; Now get 2nd byte (LSB)
L0A53               leay      D,X                 ; Offset script
                    puls      B                   ; Restore B
                    rts                           ; Done

;##CompareXY
; Compare X to Y (flags = X - Y)
L0A58               sty       u01A9,u               ; Do compare ...
                    cmpx      u01A9,u               ; X - Y
                    rts                           ; Done

;##GetInputLine
L0A60               ldx       #$05E0              ; Start of bottom row
L0A63               lbsr      L0B23               ; Slide bottom row to right after cursor and draw cursor
L0A66               lbsr      L0B2B               ; Get a key from the keyboard
                    cmpa      #$15                ;

                    beq       L0A8D               ; Swap cursor and character to left
                    cmpa      #$5D                ; ']' ?

                    beq       L0AA0               ; Swap cursor and character to right
                    cmpa      #$09                ; Backspace

                    beq       L0AB3               ; Go handle backspace
                    cmpa      #$0D                ; CR?

                    beq       L0AC8               ; Handle it and out
                    cmpa      #$0C                ; BREAK?

                    beq       L0ACC               ; Yes ... clear the row
                    cmpa      #$08                ; Backspace?

                    beq       L0ABC               ; Yes go handle
                    cmpx      #$05FF              ; At the end of the screen?

                    beq       L0A66               ; Yes ... ignore and get another
                    lbsr      L0B06               ; Slide bottom row beyond insertion
                    sta       ,X+                 ; Store character

                    bra       L0A66               ; Go get another character

L0A8D               cmpx      #$05E0              ; Nothing typed?

                    beq       L0A66               ; Yes ... ignore and get another
                    leax      -1,X                ; Swap ...
                    lda       ,X+                 ; ... cursor ...
                    sta       ,X                  ; ... and ...
                    leax      -1,X                ; ... character ...
                    lda       #$CF                ; ... to the ...
                    sta       ,X                  ; ... left

                    bra       L0A66               ; Go get another character

L0AA0               cmpx      #$05FF              ; End of screen?

                    beq       L0A66               ; Yes ... go get another key
                    leax      1,X                 ; Swap ...
                    lda       ,X                  ; ... cursor ...
                    leax      -1,X                ; ... and ...
                    sta       ,X+                 ; ... character ...
                    lda       #$CF                ; ... to the ...
                    sta       ,X                  ; ... right

                    bra       L0A66               ; Go get another key
;
L0AB3               lbsr      L0ADB               ; Back off trailing cursor block
                    lda       #$CF                ; Store ...
                    sta       ,X                  ; ... cursor block

                    bra       L0A66               ; Go get another key
;
L0ABC               cmpx      #$05E0              ; At the start of the row?

                    beq       L0A66               ; Yes ... go get another key
                    leax      -1,X                ; Back up one character
                    lbsr      L0ADB               ; Erase the end

                    bra       L0A66               ; Go get another key
;
L0AC8               lbsr      L0ADB               ; Back off cursor character
L0ACB               rts                           ; Done
;
L0ACC               ldx       #$05E0              ; Start of bottom row
                    ldb       #$20                ; 32 characters on the row
                    lda       #$60                ; SPACE character
L0AD3               sta       ,X+                 ; Clear ...
                    decb                          ; ... the ...

                    bne       L0AD3               ; ... bottom row
                    lbra      L0A60               ; Go get another key
;
L0ADB               tfr       X,U                 ; Hold X
                    leay      1,X                 ; Clear trailing ...
                    lda       #$60                ; ... cursor ...
                    sta       ,X                  ; ... block
;
                    cmpy      #$0600              ; End of screen?

                    beq       L0ACB               ; Yes out
                    cmpy      #$0601              ; End of screen?

                    beq       L0ACB               ; Yes out
                    cmpy      #$0602              ; End of screen?

                    beq       L0ACB               ; Yes out
L0AF5               lda       ,Y+                 ; Back ...
                    sta       ,X+                 ; ... up ...
                    cmpy      #$0600              ; ... row ...

                    bne       L0AF5               ; ... over cursor
                    lda       #$60                ; Clear last ...
                    sta       ,X                  ; ... character
                    tfr       U,X                 ; Restore X
                    rts                           ; Done
;
L0B06               cmpx      #$0600              ; Past end of screen?

                    beq       L0B22               ; Yes ... out
                    stx       u01A7,u               ; Hold insertion point
                    ldx       #$0600              ; End+1
                    ldy       #$05FF              ; End
L0B15               ldb       ,-Y                 ; Slide bottom row ...
                    stb       ,-X                 ; ... to the right
                    cmpx      u01A7,u               ; At the insertion point?

                    bne       L0B15               ; No ... slide all
                    ldb       #$60                ; SPACE
                    stb       ,X                  ; Clear first character
L0B22               rts                           ; Done
;
L0B23               lbsr      L0B06               ; Slide row over from cursor
                    lda       #$CF                ; Cursor character (white block)
                    sta       ,X                  ; Cursor to screen
                    rts                           ; Done

;##-GetKey
L0B2B               lbsr      L12A8               ; Get random number every key
*L0B2E          jsr       [$A000]             ; Get key from user
                    lbsr      os9read
                    tsta                          ; Anything pressed?

                    beq       L0B2B               ; No ... keep waiting
                    cmpa      #$41                ; Letter 'A'

                    bcc       L0B3F               ; Greater or equal ... use it
                    cmpa      #$20                ; Space

                    bcs       L0B3F               ; Lower .... use it
                    adda      #$40                ; Not really sure why. '!' becomes 'a'.
L0B3F               rts                           ; Done


;##DecodeBuffer
; X=input buffer on screen (1 before)
; 1D8=pointer to result token list
; Return 1CF LSB of first word
; Return 1BB LSB of next word
; Return list of 3-byte tokens filled into buffer pointed to by 1D8:
;   NN WW PP
;     NN = list number
;     WW = word number
;     PP = LSB of word on screen
;
L0B40               leax      1,X                 ; Next in buffer
;
L0B42               tfr       X,D                 ; Hold ...
                    stb       u01CF,u               ; ... LSB of first word (could be ignored)
                    cmpx      #$0600              ; End of buffer?

                    beq       L0B3F               ; Yes ... out
                    lda       ,X                  ; Next in input
                    cmpa      #$60                ; Valid character?

                    bcc       L0B40               ; No ... skip till we find one
                    leay      L3C29,pc            ; Word token table
                    lbsr      L0B8B               ; Try first list

                    beq       L0B42               ; Found a match ... ignore it
                    ldb       #$01                ; Staring list number
L0B5D               leay      1,Y                 ; Next list of words
                    lbsr      L0B8B               ; Try and match

                    beq       L0B6C               ; Found a match ... record it
                    incb                          ; Next list of words
                    cmpb      #$05                ; All tried?

                    bne       L0B5D               ; No ... go back and try all
                    ora       #$01                ; Not-zero ... error
                    rts                           ; Done

L0B6C               exg       X,Y                 ; X to Y
                    ldx       u01D8,u               ; Current result token pointer
                    stb       ,X+                 ; Store list number
                    sta       ,X+                 ; Store word number
                    lda       u01CF,u               ; Start of word
                    sta       ,X+                 ; Store word start
                    stx       u01D8,u               ; Bump result token pointer
                    exg       X,Y                 ; Restore X
                    cmpb      #$01                ; Is this the first (VERB) list?

                    bne       L0B89               ; No ... skip marking
                    lda       u01BC,u               ; Mark the input buffer location ...
                    sta       u01BB,u               ; ... of the verb
L0B89               clra                          ; OK
                    rts                           ; Return

;##DecodeWord
; Y=input match table
; X=pointer to input buffer word
; Return word data in A if found
; Return is-zero if found, not-zero if not found
; Return 1AB with word data (if found)
; Return 1BC with LSB of pointer-to-next-word
;
; 1A7,1A8 Temporary
; 1AB Temporary
; 1D0 Temporary
;
L0B8B               lda       ,Y                  ; Length of word

                    bne       L0B92               ; It is a word ... go check it
                    ora       #$01                ; End of list ...
                    rts                           ; ... return not-zero
L0B92               sta       u01AB,u               ; Temporary
                    sta       u01D0,u               ; Temporary
                    pshs      X                   ; Hold pointer to input word
                    leay      1,Y                 ; Skip over word length in table
L0B9C               lda       ,X                  ; Character from input (from screen)
                    cmpa      #$60                ; Space?

                    beq       L0BF5               ; Yes. Didn't match the target word. Next.
                    cmpx      #$0600              ; Past screen (end of buffer)?

                    beq       L0BF5               ; Yes. Didn't match the target word. next
                    cmpa      #$60                ; Valid character?

                    bcs       L0BAF               ; Yes ... do compare
                    leax      1,X                 ; No ... skip this

                    bra       L0B9C               ; Look for valid character
L0BAF               cmpa      ,Y                  ; Matches target word?

                    bne       L0BF5               ; No ... next word
                    leax      1,X                 ; Next in input
                    leay      1,Y                 ; Next in match
                    dec       u01AB,u               ; All done?

                    bne       L0B9C               ; No ... keep looking
                    lda       u01D0,u               ; Original length
                    cmpa      #$06                ; Six letter input?

                    beq       L0BC9               ; Yes ... could be truncated. That's enough of a match.
                    lda       ,X                  ; Next from screen
                    cmpa      #$60                ; Space? End of word?

                    bcs       L0BFC               ; No. Try next word
L0BC9               lda       ,Y                  ; Get the word data
                    puls      Y                   ; Drop the input buffer pointer
                    sta       u01AB,u               ; Hold the word data
L0BD0               lda       ,X                  ; Next in input buffer?
                    cmpa      #$60                ; Is it a space?

                    beq       L0BE2               ; Yes ... ready for next word
                    stx       u01A7,u               ; Start of next word (in case end of buffer)
                    cmpx      #$0600              ; Is this the end of the input buffer?

                    beq       L0BE8               ; Yes. Done
                    leax      1,X                 ; Skip to next input word

                    bra       L0BD0               ; Keep looking for input
L0BE2               stx       u01A7,u               ; Pointer to ending space
                    inc       u01A8,u               ; Point to next character past space (start of next word)
L0BE8               lda       u01A8,u               ; Keep ...
                    sta       u01BC,u               ; ... only LSB
                    lda       u01AB,u               ; Return word data in A
                    clr       u01A7,u               ; return is-zero for found
                    rts                           ; Done
;
L0BF5               leay      1,Y                 ; Skip next in word data
                    dec       u01AB,u               ; All skipped

                    bne       L0BF5               ; No ... skip all
L0BFC               puls      X                   ; Restore pointer to word
                    leay      1,Y                 ; Skip word data
                    lbra      L0B8B               ; Keep trying

;##ProcessCommand
; Either a direct command or a common command
L0C03               lda       ,X+                 ; Next in script
                    tfr       A,B                 ; Hold original command
                    bita      #$80                ; Upper bit set?

                    beq       L0C1E               ; No ... do commands
                    pshs      Y,X                 ; Hold
                    leax      L37FA,pc            ; Common commands
                    lbsr      L0A1F               ; Find common command

                    bcc       L0C1B               ; Not found ... skip
                    lbsr      L0A42               ; Skip length of command
                    lbsr      L0C03               ; Execute command
L0C1B               puls      X,Y                 ; Restore
                    rts                           ; Out

L0C1E               tfr       B,A                 ; Hold original command
L0C20               leay      L12E5,pc            ; Function table
                    asla                          ; Jump to ...
                    jmp       [A,Y]               ; ... command

;##Com0D_ExecutePassingList
; Execute a list of commands as long as they pass. Either way end pointing one
; past end.
; Data: LENGTH + list of command
L0C27               lbsr      L0A44               ; Read length of command
L0C2A               lbsr      L0A58               ; Are we past the end?

                    bcc       L0C3B               ; Yes ... end successfully
                    pshs      Y                   ; Hold the end
                    lbsr      L0C03               ; Execute the command
                    puls      Y                   ; Restore the end

                    beq       L0C2A               ; Command successful? Yes ... keep processing
                    exg       X,Y                 ; Fail ... put us at the end
                    rts                           ; Done
L0C3B               exg       X,Y                 ; Point to end of list
                    clra                          ; Z=1 ... success
                    rts                           ; Done

;##Com0E_ExecuteFailingList
L0C3F               lbsr      L0A44               ; Load the end
L0C42               lbsr      L0A58               ; Reached end of list?

                    bcc       L0C53               ; Yes ... error
                    pshs      Y                   ; Hold end of command
                    lbsr      L0C03               ; Execute command
                    puls      Y                   ; Restore end

                    bne       L0C42               ; Command failed ... try next
                    exg       X,Y                 ; Set script pointer to end of list
                    rts                           ; Out
;
L0C53               exg       X,Y                 ; Set script pointer to end of list
                    ora       #$01                ; Return fail
                    rts                           ; Done

;##Com0B_Switch
L0C58               lbsr      L0A44               ; Get size of switch list
                    ldb       ,X+                 ; Get function to call
L0C5D               lbsr      L0A58               ; End of options?

                    bcc       L0C53               ; Yes ... out with error
                    pshs      Y                   ; Hold total switch size
                    pshs      B                   ; Hold function to call
                    tfr       B,A                 ; Call the ...
                    lbsr      L0C20               ; ... target function
                    puls      B                   ; Restore function to call

                    beq       L0C78               ; Got our script ... go do it
                    lbsr      L0A44               ; Size of pass script
                    exg       X,Y                 ; Skip over this option
                    puls      Y                   ; End of script

                    bra       L0C5D               ; Keep looking
L0C78               lbsr      L0A44               ; Skip length
                    lbsr      L0C03               ; Execute
                    puls      X                   ; Restore script
                    rts                           ; Done

;##Com00_MoveActiveObjectToRoomAndLook
L0C81               lbsr      L0C8D               ; Move active object to new room
                    pshs      X                   ; Hold script
                    lbsr      L0D4A               ; Print room description and objects
                    puls      X                   ; Restore script
                    clra                          ; OK
                    rts                           ; Done

;##Com19_MoveActiveObjectToRoom
L0C8D               lda       ,X+                 ; New room number
                    pshs      X                   ; Hold script
                    sta       u01D5,u               ; Store new actvie room number
                    tfr       A,B                 ; Store ...
                    leax      L1523,pc            ; ... pointer ...
                    lbsr      L0A1F               ; ... to ...
                    stx       u01D6,u               ; ... new room
                    ldx       u01D3,u               ; Active object
                    lbsr      L0A42               ; Skip size
                    lda       u01D5,u               ; New location
                    sta       ,X                  ; Move object to active room
                    puls      X                   ; Restore script
                    clra                          ; OK
                    rts                           ; Done

;##Com1A_SetVarObjectTo1stNoun
L0CAE               ldu       u01C6,u               ; Copy 1st noun ...
                    stu       u01C0,u               ; ... data pointer
                    lda       u01C3,u               ; Copy 1st noun ...
                    sta       u01BF,u               ; ... object number
                    clra                          ; Z=1 for OK
                    rts                           ; Done

;##Com1B_SetVarObjectTo2ndNoun
L0CBC               ldu       u01CC,u               ; Copy 2nd noun ...
                    stu       u01C0,u               ; ... data pointer
                    lda       u01C9,u               ; Copy 2nd noun ...
                    sta       u01BF,u               ; ... object number
                    clra                          ; Z=1 for OK
                    rts                           ; Done

;##Com1C_SetVarObject
L0CCA               ldb       ,X+                 ; Get object number from script
                    pshs      X                   ; Hold script pointer
                    stb       u01BF,u               ; Store target object number

                    beq       L0CD9               ; 0 ... no-object
                    lbsr      L1133               ; Find object data
                    stx       u01C0,u               ; Store target object data
L0CD9               puls      X                   ; Restore script
                    clra                          ; Return OK
                    rts                           ; Done

;##Com21_RunGeneralWithTempPhrase
L0CDD               ldu       u01C6,u               ; 1st noun data ...
                    pshs      U                   ; ... on stack
                    ldu       u01CC,u               ; 2nd noun data ...
                    pshs      U                   ; ... on stack
                    lda       u01C9,u               ; 2nd noun number
                    ldb       u01C3,u               ; 1st noun number
                    pshs      B,A                 ; Hold these
                    lda       u01D1,u               ; Phrase number
                    pshs      A                   ; Hold it
                    lda       ,X+                 ; New temporary ...
                    sta       u01D1,u               ; ... phrase number
                    ldd       ,X++                ; Temporary 1st and 2nd noun numbers
                    stb       u01AB,u               ; Hold 2nd noun for now
                    pshs      X                   ; Hold script
                    sta       u01C3,u               ; Temporary 1st noun
                    tfr       A,B                 ; To B (for lookup)

                    beq       L0D0D               ; Not one ... skip
                    lbsr      L1133               ; Lookup object in B
                    stx       u01C6,u               ; Temporary 1st noun data
L0D0D               ldb       u01AB,u               ; Temporary 2nd noun ...
                    stb       u01C9,u               ; ... index

                    beq       L0D1B               ; There isn't one ... skip
                    lbsr      L1133               ; Lookup object in B
                    stx       u01CC,u               ; Temporary 2nd noun
L0D1B               leax      L323C,pc            ; General commands
                    lbsr      L0A42               ; Skip ID and length
                    lbsr      L0C03               ; Execute general script
                    tfr       CC,A                ; Hold the result ...
                    sta       u01AB,u               ; ... for a moment
                    puls      Y                   ;
                    puls      A                   ;
                    sta       u01D1,u               ; Restore ...
                    puls      A,B                 ; ... phrase ...
                    stb       u01C3,u               ; ... and ...
                    sta       u01C9,u               ; ... nouns
                    puls      U                   ;
                    stu       u01CC,u               ;
                    puls      U                   ;
                    stu       u01C6,u               ;
                    exg       X,Y                 ;
                    lda       u01AB,u               ;
                    tfr       A,CC                ; Restore result
L0D49               rts                           ; Done

; Print room description
L0D4A               lda       u01D2,u               ; Actiuve object number
                    cmpa      #$1D                ; Is this the SYSTEM object?

                    bne       L0D49               ; No ... return
                    ldx       u01D6,u               ; Current room script
                    lbsr      L0A42               ; Skip length
                    leax      1,X                 ;
                    ldb       #$03                ; You are in DESCRIPTION script
                    lbsr      L0A27               ; Get room description

                    bcc       L0D65               ; No room description ... print objects in room
                    leax      1,X                 ; Assume length is one byte
                    lbsr      L114C               ; Print the packed message
;
; Print object descriptions
;
L0D65               leax      L20FF,pc            ; Object data
                    lbsr      L0A42               ; Skip length
L0D6B               pshs      Y                   ; Hold end
                    lbsr      L0A42               ; Skip this object's length
                    lda       u01D5,u               ; Current room
                    cmpa      ,X                  ; Object in room?

                    bne       L0D89               ; No ... next object
                    leax      3,X                 ; Skip data
                    ldb       #$03                ; Get description ...
                    lbsr      L0A27               ; ... field

                    bcc       L0D89               ; No description ... next object
                    leax      1,X                 ; Skip length
                    pshs      Y                   ; Hold end of object
                    lbsr      L114C               ; Print description
                    puls      Y                   ; Restore length
L0D89               exg       X,Y                 ; Next object
                    puls      Y                   ; End of objects
                    lbsr      L0A58               ; All done?

                    bcs       L0D6B               ; No ... keep printing
L0D92               rts                           ; Done

;##Com01_IsObjectInPackOrRoom
L0D93               ldb       ,X+                 ; Get object number from script
                    pshs      X                   ; Hold script pointer
                    lbsr      L1133               ; Get object data
                    lbsr      L08AA               ; See if it is in pack or room
                    puls      X                   ; Restore script
                    rts                           ; Out

;##Com20_CheckActiveObject
L0DA0               lda       u01D2,u               ; Active object
                    cmpa      ,X+                 ; Matches target?
                    rts                           ; Done

;##Com02_CheckObjectIsOwnedByActive
L0DA6               ldb       ,X+
                    lbra      L0F5F

;##Com03_IsObjectYAtX
; Check to see if an object is at a target location.
L0DAB               ldd       ,X++                ; Room and object
                    pshs      X                   ; Hold script
                    sta       u01AB,u               ; Remember the room
                    lbsr      L1133               ; Locate the object
                    lbsr      L0A42               ; Skip the length
                    ldd       ,X++                ; Get the room to A
                    cmpa      u01AB,u               ; Is this object in the target place?
                    puls      X                   ; Restore script
                    rts                           ; Out

;##Com0C_FAIL
; Always fail
L0DC0               ora       #$01                ; Set the fail flag
                    rts                           ; Done

;##Com04_PrintSYSTEMOrPlayerMessage
L0DC3               lda       u01D2,u               ; Active object
                    cmpa      #$1D                ; Is this the player?


                    bne       L0DD8               ; No ... must be system

;##Com1F_PrintMessage
L0DCA               ldb       #$1D                ; Player number
                    pshs      X                   ; Hold script
                    lbsr      L1133               ; Look up Player
                    lbsr      L08AA               ; Is Player in current room?
                    puls      X                   ; Restore

                    beq       L0DDF               ; Yes ... do printing
L0DD8               lbsr      L0A44               ; Skip to ...
                    exg       X,Y                 ; ... end of packed message.

                    bra       L0DE2               ; Return OK but no printing
L0DDF               lbsr      L114C               ; Print packed message at X
L0DE2               clra                          ; OK
L0DE3               rts                           ; Done

;##Com07_Look
L0DE4               lbsr      L0D4A               ; Print room description
                    clra                          ; OK
                    rts                           ; Done

;##Com06_Inventory
L0DE9               pshs      X                   ; Hold script pointer
L0DEB               lda       #$0D                ; Print ...
                    lbsr      L1184               ; ... CR
                    leax      L20FF,pc            ; Objects
                    lbsr      L0A42               ; Skip size of objects
;
L0DF6               lbsr      L0A58               ; CompareXY

                    bcc       L0E1F               ; End of list ... out
                    pshs      Y                   ; Hold end of master list of objects
                    lbsr      L0A42               ; Get pointer to next object
                    ldb       ,X                  ; Object location
                    cmpb      u01D2,u               ; Active object?

                    bne       L0E19               ; No ... skip this object
                    leax      3,X                 ; Skip data
                    ldb       #$02                ; Find short name ...
                    lbsr      L0A27               ; ... string

                    bcc       L0E19               ; No short name ... skip
                    leax      1,X                 ; Skip the 02 data id
                    pshs      Y                   ; Hold next-object
                    lbsr      L1143               ; Print packed message and CR
                    puls      Y                   ; Restore next-object
L0E19               exg       X,Y                 ; Move to next object
                    puls      Y                   ; End of master list

                    bra       L0DF6               ; Do all objects
L0E1F               clra                          ; Success
                    puls      X                   ; Restore script pointer
                    rts                           ; Done

;##Com08_CompareObjectToFirstNoun
L0E23               ldu       u01C6,u               ; 1st noun data
                    lda       u01C3,u               ; 1st noun number
;
L0E29               stu       u01D8,u               ; Hold
                    tsta                          ; Is there an object?

                    beq       L0E3F               ; No ... error
                    ldb       ,X+                 ; Object number from script
                    pshs      X                   ; Hold script
                    lbsr      L1133               ; Find object
                    exg       X,Y                 ; Pointer of found object to Y
                    puls      X                   ; Restore script pointer
                    cmpy      u01D8,u               ; Object the same?
                    rts                           ; Done
L0E3F               tstb                          ; B can't be 0 ... Z=0 error
                    rts                           ; Done

;##Com09_CompareObjectToSecondNoun
L0E41               ldu       u01CC,u               ; 2nd noun data
                    lda       u01C9,u               ; 2nd noun number

                    bra       L0E29               ; Do compare

;##Com0A_CompareToPhraseForm
L0E49               ldb       ,X+                 ; Compare from script ...
                    cmpb      u01D1,u               ; ... to phrase form
                    rts                           ; Done

;##Com0F_PickUpObject
; Move noun object to pack.
L0E4F               pshs      X                   ; Hold script
                    ldx       u01C0,u               ; Pointer to noun object
                    lbsr      L0A42               ; Skip length
                    lda       u01D2,u               ; Back pack "location" value
                    sta       ,X                  ; Move object to pack
                    clra                          ; OK
                    puls      X                   ; Restore script
                    rts                           ; Done

;##Com10_DropObject
; Move noun object to current room.
L0E60               pshs      X                   ; Hold script
                    ldx       u01C0,u               ; Pointer to noun object
                    lbsr      L0A42               ; Skip length
                    lda       u01D5,u               ; Current room
                    sta       ,X                  ; Move object to room
                    puls      X                   ; Restore script
                    clra                          ; Done
                    rts                           ; Out

;##Com13_PhraseWithRoom1st2nd
L0E71               pshs      X                   ; Save script
                    ldx       u01D6,u               ; Current room script
                    lbsr      L0A42               ; Skip id and length
                    leax      1,X                 ; Skip
                    ldb       #$04                ; Get ...
                    lbsr      L0A27               ; ... phrase script

                    bcc       L0E8A               ; No phrase script ... skip
                    lbsr      L0A42               ; Skip id and length
                    lbsr      L0C03               ; Execute

                    beq       L0EC5               ; Move passed ... OK and out
L0E8A               lda       u01C9,u               ; Is there a 2nd noun?

                    beq       L0EA6               ; No ... skip
                    ldx       u01CC,u               ; Second noun data
                    lbsr      L0A42               ; Skip ...
                    leax      3,X                 ; ... object header
                    ldb       #$06                ; Get "noun is second" ...
                    lbsr      L0A27               ; ... phrase script

                    bcc       L0EA6               ; None ... move on
                    lbsr      L0A42               ; Skip header
                    lbsr      L0C03               ; Execute script

                    beq       L0EC5               ; Script passed ... OK and out
L0EA6               lda       u01C3,u               ; Is there a 1st noun?

                    bne       L0EB0               ; Yes ... go do it
L0EAB               puls      X                   ; Restore script
                    ora       #$01                ; Nobody took the phrase ..
                    rts                           ; .. error and and out
L0EB0               ldx       u01C6,u               ; First noun data
                    lbsr      L0A42               ; Skip ...
                    leax      3,X                 ; ... object header
                    ldb       #$07                ; Get "noun is first" ...
                    lbsr      L0A27               ; ... phrase script

                    bcc       L0EAB               ; None ... error and out
                    lbsr      L0A42               ; Skip the id and length
                    lbsr      L0C03               ; Execute script (use return)
L0EC5               puls      X                   ; Restore script pointer
                    rts                           ; Done

;##Com16_PrintVarShortName
L0EC8               pshs      X                   ; Save script pointer
                    ldx       u01C0,u               ; Var noun data
                    lda       u01BF,u               ; Var noun index

                    bra       L0EDA               ; Print short name

;##Com11_Print1stNounShortName
L0ED2               pshs      X                   ; Save script pointer
                    ldx       u01C6,u               ; 1st noun data
                    lda       u01C3,u               ; 1st noun index
;

L0EDA               beq       L0EC5               ; Return Z=1 return
                    ldb       #$1D                ; User object
                    pshs      X                   ; Hold noun data
                    lbsr      L1133               ; Lookup user object
                    lbsr      L08AA               ; User in current room?
                    puls      X                   ; Restore noun data

                    bne       L0EFB               ; Not in current room ... skip print
                    lbsr      L0A42               ; Skip object ...
                    leax      3,X                 ; ... header
                    ldb       #$02                ; Get object ...
                    lbsr      L0A27               ; ... short name

                    bcc       L0EFB               ; No short name ... out with OK
                    leax      1,X                 ; Skip the 2
                    lbsr      L114C               ; Print packed message at X
L0EFB               puls      X                   ; Restore script
                    clra                          ; Return ...
                    rts                           ; ... OK

;##Com12_Print2ndNounShortName
L0EFF               pshs      X                   ; Save script pointer
                    ldx       u01CC,u               ; 2nd noun data
                    lda       u01C9,u               ; 2nd noun index

                    bra       L0EDA               ; Print short name

;##Com15_CheckObjBits
; Check target bits in an object.
L0F09               pshs      X                   ; Hold script pointer
                    ldx       u01C0,u               ; Input object pointer
                    lda       u01BF,u               ; Var object number

                    beq       L0F21               ; No object ... return error
                    lbsr      L0A42               ; Skip the pointer-to-next object
                    leax      2,X                 ; Skip to data byte
                    lda       ,X                  ; Get the object data
                    puls      X                   ; Restore the script
                    anda      ,X                  ; Mask off all but target bits
                    eora      ,X+                 ; Check target bits  (a 1 result in a pass)
                    rts                           ; Done

L0F21               puls      X                   ; Restore script pointer
                    leax      1,X                 ; Skip data
                    ora       #$01                ; Set error
                    rts                           ; Return

;##Com14_ExecuteCommandAndReverseReturn
L0F28               lbsr      L0C03               ; Execute command

                    bne       L0F30               ; Command returned a non-zero ... return zero
                    ora       #$01                ; Command returned a zero ... return non-zerio
                    rts                           ; Done
L0F30               clra                          ; Zero
                    rts                           ; Done

;##Com17_MoveObjectXToLocationY
L0F32               ldb       ,X+                 ; Get object number
                    pshs      X                   ; Hold script
                    lbsr      L1133               ; Find object
                    lbsr      L0A42               ; Skip over length
                    puls      Y                   ; Script to Y
                    lda       ,Y+                 ; Get new location
                    sta       ,X                  ; Set object's new location
                    exg       X,Y                 ; X now past data
                    clra                          ; OK
L0F45               rts                           ; Done

;##Com18_CheckVarOwnedByActiveObject
L0F46               pshs      X                   ; Save script pointer
                    ldx       u01C0,u               ; Var object data
L0F4B               lbsr      L0A42               ; Skip length
                    ldb       ,X                  ; Location
                    puls      X                   ; Restore script
                    lbeq      L08CF               ; Out-of-game ... error and out
                    cmpb      u01D2,u               ; Is this the active object?

                    beq       L0F45               ; Yes ... return OK
                    bitb      #$80                ; Test upper bit

                    bne       L0F45               ; It is in a room ... error and out
;
L0F5F               pshs      X                   ; Hold script
                    lbsr      L1133               ; Look up owner object

                    bra       L0F4B               ; Check again

; Execute any turn-scripts on the objects
L0F66               leax      L20FF,pc            ; Start of object data
                    clr       u01D0,u               ; Object number
                    lbsr      L0A42               ; Skip length
L0F6F               lbsr      L0A58               ; End of objects?

                    bcc       L0F45               ; Yes ... out
                    inc       u01D0,u               ; Next object number
                    pshs      Y                   ; Hold end-of-objects
                    lbsr      L0A42               ; Skip length
                    lda       ,X                  ; Location
                    sta       u01AB,u               ; Hold
                    pshs      Y                   ; End of object
                    lda       ,X                  ; Location

                    beq       L0FC9               ; If it is out-of-game it doesn't get a turn
                    leax      3,X                 ; Skip data
                    ldb       #$08                ; Turn-script
                    lbsr      L0A27               ; Find turn script

                    bcc       L0FC9               ; Nothing to do ... next object
                    lbsr      L0A42               ; Skip length
                    pshs      X                   ; Hold pointer
                    lbsr      L12A8               ; Generate random number
                    ldb       u01D0,u               ; Current object number ...
                    stb       u01D2,u               ; ... is now the active object
                    lbsr      L1133               ; Get its data pointer
                    stx       u01D3,u               ; Hold pointer to active object data
                    ldb       u01AB,u               ; Object's location
L0FA7               tstb                          ; Check upper bit

                    bmi       L0FB8               ; If in a room ... go handle
                    lbsr      L1133               ; Get object's owner
                    lbsr      L0A42               ; Skip length
                    ldb       ,X                  ; Get owner location

                    bne       L0FA7               ; Still in game ... find room location of owner chain
                    puls      X                   ; Restore pointer

                    bra       L0FC9               ; Next object
L0FB8               stb       u01D5,u               ; Objects location
                    leax      L1523,pc            ; Get room ...
                    lbsr      L0A1F               ; ... scripts for object
                    stx       u01D6,u               ; Hold
                    puls      X                   ; Restore turn-script
                    lbsr      L0C03               ; Execute turn-script
L0FC9               puls      X                   ; Restore
                    puls      Y                   ; Restore

                    bra       L0F6F               ; Next object

;##Com05_IsRandomLessOrEqual
L0FCF               pshs      x
                    leax      L1338,pc            ; Random value
                    lda       ,x
                    puls      x

                    cmpa      ,X+                 ; Compare random value to script

                    bcs       L0FDB               ; If less than ... OK

                    beq       L0FDB               ; If the same ... OK
L0FD8               ora       #$01                ; Greater than ... FAIL
                    rts                           ; Done
L0FDB               clra                          ; Less than or equal ... OK
                    rts                           ; Done

;##Com1D_AttackObject
L0FDD               lda       ,X+                 ; Get attack value
                    sta       u01AB,u               ; Hold attack value
                    pshs      X                   ; Hold script
                    ldx       u01C0,u               ; Target object data
                    lbsr      L0A42               ; Skip length
                    leax      3,X                 ; Skip object data
                    pshs      X                   ; Hold X ...
                    pshs      Y                   ; ... and Y
                    ldb       #$09                ; Get target's ...
                    lbsr      L0A27               ; ... combat info

                    bcc       L1020               ; Not found. Do nothing (return OK)
                    lbsr      L0A42               ; Skip length
                    leax      1,X                 ; Hit points
                    lda       ,X                  ; Hit points
                    suba      u01AB,u               ; Subtract attack from hit points

                    bcc       L1004               ; Not negative ... keep it
                    clra                          ; Floor the hit points
L1004               sta       ,X                  ; New hit points
                    puls      Y                   ; Restore ...
                    puls      X                   ; ... X and Y
                    tsta                          ; Hit points zero?

                    beq       L1011               ; Yes ... object dies
L100D               puls      X                   ; Restore list
                    clra                          ; Return OK
                    rts                           ; Done

;Handle object being killed
L1011               ldb       #$0A                ; Object being killed script
                    lbsr      L0A27               ; Find a script for handling being killed

                    bcc       L100D               ; Not found ... nothing happens (return OK)
                    lbsr      L0A42               ; Skip id and length
                    lbsr      L0C03               ; Execute "being killed" script

                    bra       L100D               ; Done (return OK)

L1020               puls      Y                   ; Reset ...
                    puls      X                   ; ... stack

                    bra       L100D               ; Return OK

;##Com1E_SwapObjects
L1026               ldb       ,X+                 ; 1st object number
                    lda       ,X+                 ; 2nd object
                    sta       u01AB,u               ; Hold second object
                    pshs      X                   ; Hold script
                    lbsr      L1133               ; Look up object
                    lbsr      L0A42               ; Skip length
                    tfr       X,U                 ; 1st object pointer to U
                    ldb       u01AB,u               ; 2nd object
                    lbsr      L1133               ; Look up object
                    lbsr      L0A42               ; Skip length
                    lda       ,X                  ; Swap ...
                    ldb       ,U                  ; ... location ...
                    sta       ,U                  ; ... of ...
                    stb       ,X                  ; ... objects

                    puls      X                   ; Restore script pointer
                    clra                          ; Z=1 OK
                    rts                           ; Done

;##Com22_CompareHealthToValue
L104C               lda       ,X+                 ; Get value
                    pshs      X                   ; Hold script pointer
                    sta       u01AB,u               ; Hold value
                    ldx       u01C0,u               ; Var object data
                    lbsr      L0A42               ; Skip length
                    leax      3,X                 ; Skip data
                    ldb       #$09                ; Get object ...
                    lbsr      L0A27               ; ... hit points

                    bcc       L1070               ; Doesn't have any ... error and out
                    lbsr      L0A42               ; Skip length
                    leax      1,X                 ; Get current ...
                    lda       ,X                  ; ... hit points
                    cmpa      u01AB,u               ; Compare hit points to value

                    bcs       L1075               ; Less than ..

                    beq       L1075               ; ... or equal ... OK and out
L1070               puls      X                   ; Restore script
                    ora       #$01                ; Error
                    rts                           ; Done
L1075               puls      X                   ; Restore script
                    clra                          ; OK
                    rts                           ; Done

;##Com23_HealVarObject
L1079               lda       ,X+                 ; Get healing value
                    sta       u01AB,u               ; Hold it
                    pshs      X                   ; Hold script
                    ldx       u01C0,u               ; Var object data
                    lbsr      L0A42               ; Skip length
                    leax      3,X                 ; Skip data
                    ldb       #$09                ; Get object ...
                    lbsr      L0A27               ; ... hit points

                    bcc       L1075               ; No entry ... do nothing (but OK)
                    lbsr      L0A42               ; Skip length
                    ldd       ,X                  ; Get HP info
                    addb      u01AB,u               ; Add to health
                    sta       u01AB,u               ; Max value
                    cmpb      u01AB,u               ; Over the max?

                    bcs       L10A2               ; No ... keep it
                    ldb       u01AB,u               ; Use max value
L10A2               leax      1,X                 ; Store ...
                    stb       ,X                  ; ... new health

                    bra       L1075               ; OK out

;##Com25_RestartGame
; No return to script
L10A8               lda       #$0D                ; Print first ...
                    lbsr      L1184               ; ... CR
                    lda       #$0D                ; Print second ...
                    lbsr      L1184               ; ... CR
                    lbra      start               ; Restart game

;##Com24_EndlessLoop

L10B5               bra       L10B5               ; Spin forever

; This snippet of code is never called by anyone, but this is a print
; for null-terminate ASCII strings. Presumably the PrintScore function
; used this at one time.

L10B7               lda       ,Y+                 ; Get next character

                    beq       L10C4               ; Null means done
                    pshs      Y                   ; Hold Y
                    lbsr      L1184               ; Print character
                    puls      Y                   ; Restore Y

                    bra       L10B7               ; Keep going
L10C4               rts                           ; Done

;##Com26_PrintScore
; Second byte of object data is points. If the object is in the
; treasure room (dropped or carried) it counts double.
L10C5               pshs      X
                    clr       u01AF,u               ; Score tally
                    clr       u01B0,u
                    lda       u01D5,u               ; Player location
                    cmpa      #$96                ; Player in the treasure room?

                    bne       L10D7               ; No ... regular score
                    inc       u01B0,u               ; Yes ... carried objects count double
L10D7               leax      L20FF,pc            ; Object data
                    lbsr      L0A42               ; Skip header
L10DD               lbsr      L0A58               ; Reached end?

                    bcc       L110F               ; Yes ... move on
                    pshs      Y                   ; Hold end
                    lbsr      L0A42               ; Skip object length
                    ldb       ,X+                 ; Get owner
                    cmpb      #$96                ; Treasure room?

                    beq       L10F1               ; Yes ... count it
                    cmpb      #$1D                ; Carried by user?

                    bne       L1109               ; No ... next object
L10F1               lda       u01AF,u               ; Score tally
                    adda      ,X                  ; Add to score value
                    daa                           ; Decimal adjust
                    sta       u01AF,u               ; New score
                    cmpb      #$96                ; Treasure room?

                    beq       L1103               ; Yes ... counts double
                    tst       u01B0,u               ; Player in treasure room?

                    beq       L1109               ; No ... just count once
L1103               adda      ,X                  ; Double ...
                    daa                           ; ... the ...
                    sta       u01AF,u               ; ... score value
L1109               tfr       Y,X                 ; Next object
                    puls      Y                   ; Restore end of list

                    bra       L10DD               ; Do all objects
;
L110F               lda       u01AF,u               ; Score value
                    asra                          ; Left ...
                    asra                          ; ... most ...
                    asra                          ; ... digit ...
                    asra                          ; ... value
                    adda      #$30                ; Convert to ASCII
                    lbsr      L1184               ; Print the left digit
                    lda       u01AF,u               ; Score value
                    anda      #$0F                ; Mask off the right digit
                    adda      #$30                ; Convert ot ASCII
                    lbsr      L1184               ; Print the right digit
                    lda       #$2E                ; Print ...
                    lbsr      L1184               ; ... "."
                    lda       #$20                ; Print ...
                    lbsr      L1184               ; ... SPACE
                    puls      X                   ; Restore script
                    clra                          ; OK
                    rts                           ; Done

; Find object index in B
L1133               leax      L20FF,pc            ; Start of objects
                    lbsr      L0A42               ; Skip end
L1139               decb                          ; Found desired object?

                    beq       L10C4               ; Yes ... out OK
                    lbsr      L0A42               ; Length of object
                    exg       X,Y                 ; Next object

                    bra       L1139               ; Keep looking

; Print packed message and CR
L1143               lbsr      L114C               ; Print packed message at X
                    lda       #$0D                ; Print ...
                    lbsr      L1184               ; ... CR
                    rts                           ; Done

;##PrintPackedMessage
; X points to compressed string. First byte (or two) is the length.
L114C               clra                          ; Assume MSB is 0
                    ldb       ,X                  ; Get length
                    bitb      #$80                ; Is it single byte length?

                    beq       L1157               ; Yes ... use D
                    lda       ,X+                 ; Get the ...
                    anda      #$7F                ; ... MSB and ...
L1157               ldb       ,X+                 ; ... LSB
                    std       u01AB,u               ; Store byte count
L115C               ldd       u01AB,u               ; Number of bytes left in message
                    cmpd      #$0002              ; Less than 2?

                    bcs       L1173               ; Yes ... these aren't compressed
                    lbsr      L11EC               ; Decompress and print two bytes pointed to by X
                    ldd       u01AB,u               ; Get byte count
                    subd      #$0002              ; Handled 2
                    std       u01AB,u               ; Store count

                    bra       L115C               ; Keep decompressing
L1173               tstb                          ; Any characters on the end to print?

                    beq       L117E               ; No ... skip
                    lda       ,X+                 ; Get character
                    lbsr      L1184               ; Print the character
                    decb                          ; Decrement count

                    bra       L1173               ; Keeop going
L117E               lda       #$20                ; Print ...
                    lbsr      L1184               ; ... space on end
                    rts                           ; Done

;##PrintCharacterAutoWrap
; Print character in A to screen. This handles auto word-wrapping and
; auto MORE prompting.
;
L1184               pshs      B,A                 ; Hold B and A
                    lda       u01BE,u               ; Last printed character
                    cmpa      #$20                ; Last printed a space?
                    bne       L11A7               ; No ... print this
                    puls      A,B                 ; Hold
                    cmpa      #$20                ; Space now?
                    beq       L11EA               ; Yes ... just ignore
                    cmpa      #$2E                ; A '.' ?
                    beq       L119F               ; Yes. Ignore leading space.
                    cmpa      #$3F                ; A '?' ?
                    beq       L119F               ; Yes. Ignore leading space.
                    cmpa      #$21                ; A '!' ?
                    bne       L11A9               ; Yes. Ignore leading space.
L119F               ldu       >$88                ; Back screen ...
                    leau      -1,U                ; ... pointer up ...
                    stu       >$88                ; ... over ignored space
                    bra       L11A9               ; Store and print
L11A7               puls      A,B                 ; Restore A and B
L11A9               sta       u01BE,u               ; Last printed character
*L11AC          jsr       [$A002]             ; Output character
                    lbsr      os9write
                    lda       >$89                ; LSB of screen position
                    cmpa      #$FE                ; Reached end of screen?
                    bcs       L11EA               ; No ... done
                    ldu       >$88                ; Cursor position
                    leau      $-21,U              ; Back up to end of current row
                    lda       #$0D                ; CR ...
*L11BD          jsr       [$A002]             ; ... to screen
                    lbsr      os9write
L11C1               lda       ,U                  ; Find the ...
                    cmpa      #$60                ; ... space before ...
                    beq       L11CB               ; ... the last ...
                    leau      -1,U                ; ... word ...
                    bra       L11C1               ; ... on the line
L11CB               leau      1,U                 ; Now pointing to last word on line
                    lda       ,U                  ; Get next character in buffer
                    cmpa      #$60                ; Is it a space?
                    beq       L11EA               ; Yes ... all done
                    pshs      B                   ; Hold B
                    ldb       #$60                ; Put ...
                    stb       ,U                  ; ... space
                    puls      B                   ; Restore B
                    cmpa      #$60                ; Make sure ...
                    bcs       L11E1               ; ... upper ...
                    suba      #$40                ; ... case
L11E1               sta       u01BE,u               ; Last printed character
*L11E4          jsr       [$A002]             ; Output to screen
                    lbsr      os9write
                    bra       L11CB               ; Move overhang to next line
L11EA               rts                           ; Done
                    rts                           ; OOPS

; UnpackBytes
; Unpack three characters stored in 2 bytes pointed to by X and print to screen.
; Every 2 bytes holds 3 characters. Each character can be from 0 to 39.
; 40*40*40 = 64000 ... totally ingenious.
;
L11EC               leay      L12A4,pc            ;
                    ldb       #$03                ;
                    pshs      x
                    leax      L12A1,pc
                    stb       ,x
                    puls      x
                    lda       ,X+                 ;
                    sta       u01DE,u               ;
                    lda       ,X+                 ;
                    sta       u01DD,u               ;
                    leay      3,Y                 ;
L1201               ldu       #$0028              ;
                    pshs      x
                    leax      L12A2,pc
                    stu       ,x
                    puls      x
                    lda       #$11                ;
                    sta       u01DA,u               ;
                    clr       u01DB,u               ;
                    clr       u01DC,u               ;
L1212               rol       u01DE,u               ;
                    rol       u01DD,u               ;
                    dec       u01DA,u               ;

                    beq       L1256               ;
                    lda       #$00                ;
                    adca      #$00                ; This algorithm is identical to the decompression
                    asl       u01DC,u               ; used in Pyramid2000. Check the comments there for
                    rol       u01DB,u               ; more detail.
                    adda      u01DC,u               ;
                    pshs      x
                    leax      L12A3,pc
                    suba      ,x
                    puls      x
                    sta       u01E0,u               ;
L1230               lda       u01DB,u               ;
                    pshs      x
                    leax      L12A2,pc
                    sbca      ,x
                    puls      x
                    sta       u01DF,u               ;
                    bcc       L1246               ;
                    ldd       u01DF,u

                    pshs      x
                    leax      L12A2,pc
                    addd      u01DF,u
                    puls      x

                    std       u01DB,u               ;
                    bra       L124C               ;
L1246               ldd       u01DF,u               ;
                    std       u01DB,u               ;
; Compliment C flag and continue
L124C               bcs       L1252               ;
                    orcc      #$01                ;
                    bra       L1212               ;
L1252               andcc     #$FE                ;
                    bra       L1212               ;
; Process the result of the division
L1256               ldd       u01DB,u
                    pshs      x
                    leax      L1279,pc
                    addd      ,x
                    puls      x
                    tfr       D,U                 ;
                    lda       ,U                  ;
                    sta       ,-Y                 ;
                    pshs      x
                    leax      L12A1,pc
                    dec       ,x
                    puls      x
                    lbne      L1201               ;
                    leay      L12A4,pc            ;
                    ldb       #$03                ;
L126D               lda       ,Y+                 ;
                    lbsr      L1184               ; Print character
                    decb                          ;

                    bne       L126D               ;
                    ldd       u01AB,u               ;
                    rts                           ;

; Character translation table
;     ?  !  2  .  "  '  <  >  /  0  3  A  B  C  D  E
L1279               fcb       $3C,$3E,$2F,$30,$33,$41,$42,$43,$44,$45
;     F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U
                    fcb       $4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55
                    fcb       $2C,$2E
;     V  W  X  Y  Z  -  ,  .

L12A1               fcb       $00                 ; Temporaries for decompression algorithm above
L12A2               fcb       $00
L12A3               fcb       $00
L12A4               fcb       $00,$00,$00,$00

; Generate random number
L12A8               pshs      X,B                 ; Random number generator. Uses seed at 13B8.
                    leax      L1338,pc            ;
                    ldb       #$17                ;
                    lda       ,X                  ;
L12B1               leax      1,X                 ;
                    orcc      #$01                ;
                    anda      #$06                ;

                    beq       L12C0               ;
                    cmpa      #$06                ;
                    orcc      #$01                ;
                    beq       L12C0               ;
                    clra                          ;
L12C0               lda       ,X                  ;
                    bcs       L12C7               ;
                    lsra                          ;
                    bra       L12CA               ;
L12C7               lsra                          ;
                    ora       #$80                ;
L12CA               sta       ,X                  ;
                    leax      -1,X                ;
                    lda       ,X                  ;
                    bcs       L12D5               ;
                    lsra                          ;
                    bra       L12D8               ;
L12D5               lsra                          ;
                    ora       #$80                ;
L12D8               anda      #$FE                ;
                    sta       ,X                  ;
                    decb                          ;
                    bne       L12B1
                    pshs      x
                    leax      L1339,pc            ;
                    lda       ,x                  ;
                    puls      x
                    puls      B,X                 ;
                    rts                           ;

; -----------------------------------------------------------------------------------------------------------------
; Data Here Down
; -----------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------
; Data Here Down
; -----------------------------------------------------------------------------------------------------------------

;##CommandJumpTable
L12E5               fdb       L0C81+topmod
                    fdb       L0D93+topmod
                    fdb       L0DA6+topmod
                    fdb       L0DAB+topmod
                    fdb       L0DC3+topmod
                    fdb       L0FCF+topmod
                    fdb       L0DE9+topmod
                    fdb       L0DE4+topmod
                    fdb       L0E23+topmod
                    fdb       L0E41+topmod
                    fdb       L0E49+topmod
                    fdb       L0C58+topmod
                    fdb       L0DC0+topmod
                    fdb       L0C27+topmod
                    fdb       L0C3F+topmod
                    fdb       L0E4F+topmod
                    fdb       L0E60+topmod
                    fdb       L0ED2+topmod
                    fdb       L0EFF+topmod
                    fdb       L0E71+topmod
                    fdb       L0F28+topmod
                    fdb       L0F09+topmod
                    fdb       L0EC8+topmod
                    fdb       L0F32+topmod
                    fdb       L0F46+topmod
                    fdb       L0C8D+topmod
                    fdb       L0CAE+topmod
                    fdb       L0CBC+topmod
                    fdb       L0CCA+topmod
                    fdb       L0FDD+topmod
                    fdb       L1026+topmod
                    fdb       L0DCA+topmod
                    fdb       L0DA0+topmod
                    fdb       L0CDD+topmod
                    fdb       L104C+topmod
                    fdb       L1079+topmod
                    fdb       L10B5+topmod
                    fdb       L10A8+topmod
                    fdb       L10C5+topmod

; Multi-verb replacement list (code doesn't work that uses this anyway)
L1333               fcb       $00                 ; List is the length. List is pointed to by 1331 which is ignored

; Random number seed
L1334               fcb       $12,$23,$44,$1D
L1338               fcb       $27

L1339               fcb       $4D,$2D,$13

;##FeedbackPrompts
; "?VERB?"
L133C               fcb       $06,$3F,$56,$45,$52,$42,$3F
;
; "?WHAT?"
L1343               fcb       $06,$3F,$57,$48,$41,$54,$3F
;
; "?WHICH?"
L134A               fcb       $07,$3F,$57,$48,$49,$43,$48,$3F
;
; "?PHRASE?"
L1352               fcb       $08,$3F,$50,$48,$52,$41,$53,$45,$3F

;##PhraseList
L135B               fcb       $05,$00,$00,$00,$01 ; 01: NORTH *     *          *
L1360               fcb       $06,$00,$00,$00,$02 ; 02: SOUTH *     *          *
L1365               fcb       $07,$00,$00,$00,$03 ; 03: EAST *      *          *
L136A               fcb       $08,$00,$00,$00,$04 ; 04: WEST *      *          *
L136F               fcb       $09,$00,$20,$00,$05 ; 05: GET *       ..C.....   *
L1374               fcb       $34,$07,$00,$80,$05 ; 05: PICK UP     *          u.......
L1379               fcb       $34,$07,$80,$00,$05 ; 05: PICK UP     u.......   *
L137E               fcb       $0A,$00,$20,$00,$06 ; 06: DROP *      ..C.....   *
L1383               fcb       $0A,$05,$80,$80,$0F ; 0F: DROP IN     u.......   u.......
L1388               fcb       $0A,$06,$00,$88,$16 ; 16: DROP OUT    *          u...A...
L138D               fcb       $0B,$00,$00,$00,$07 ; 07: INVENT *    *          *
L1392               fcb       $01,$00,$04,$00,$08 ; 08: READ *      .....X..   *
L1397               fcb       $04,$02,$10,$40,$09 ; 09: ATTACK WITH ...P....   .v......
L139C               fcb       $0C,$00,$00,$00,$0A ; 0A: LOOK *      *          *
L13A1               fcb       $0C,$03,$00,$80,$0B ; 0B: LOOK AT     *          u.......
L13A6               fcb       $0C,$04,$00,$80,$0C ; 0C: LOOK UNDER  *          u.......
L13AB               fcb       $0C,$05,$00,$80,$10 ; 10: LOOK IN     *          u.......
L13B0               fcb       $03,$03,$40,$10,$0D ; 0D: THROW AT    .v......   ...P....
L13B5               fcb       $03,$05,$80,$80,$39 ; 39: THROW IN    u.......   u.......
L13BA               fcb       $03,$08,$00,$20,$06 ; 06: THROW DOWN  *          ..C.....
L13BF               fcb       $03,$01,$80,$10,$0E ; 0E: THROW TO    u.......   ...P....
L13C4               fcb       $0D,$01,$80,$10,$0E ; 0E: GIVE TO     u.......   ...P....
L13C9               fcb       $0E,$00,$80,$00,$0B ; 0B: EXAMIN *    u.......   *
L13CE               fcb       $0E,$05,$00,$80,$0B ; 0B: EXAMIN IN   *          u.......
L13D3               fcb       $0F,$00,$80,$00,$11 ; 11: OPEN *      u.......   *
L13D8               fcb       $0F,$02,$80,$80,$3A ; 3A: OPEN WITH   u.......   u.......
L13DD               fcb       $10,$00,$80,$00,$12 ; 12: PULL *      u.......   *
L13E2               fcb       $10,$08,$00,$80,$12 ; 12: PULL DOWN   *          u.......
L13E7               fcb       $10,$06,$00,$80,$05 ; 05: PULL OUT    *          u.......
L13EC               fcb       $10,$06,$80,$00,$05 ; 05: PULL OUT    u.......   *
L13F1               fcb       $10,$07,$00,$80,$2D ; 2D: PULL UP     *          u.......
L13F6               fcb       $10,$07,$80,$00,$2D ; 2D: PULL UP     u.......   *
L13FB               fcb       $11,$02,$88,$88,$14 ; 14: LIGHT WITH  u...A...   u...A...
L1400               fcb       $12,$00,$80,$00,$15 ; 15: EAT *       u.......   *
L1405               fcb       $13,$06,$00,$88,$16 ; 16: BLOW OUT    *          u...A...
L140A               fcb       $14,$00,$88,$00,$16 ; 16: EXTING *    u...A...   *
L140F               fcb       $15,$00,$80,$00,$17 ; 17: CLIMB *     u.......   *
L1414               fcb       $15,$07,$00,$80,$17 ; 17: CLIMB UP    *          u.......
L1419               fcb       $15,$08,$00,$80,$17 ; 17: CLIMB DOWN  *          u.......
L141E               fcb       $15,$09,$00,$80,$17 ; 17: CLIMB OVER  *          u.......
L1423               fcb       $15,$0C,$00,$80,$17 ; 17: CLIMB ON    *          u.......
L1428               fcb       $15,$05,$00,$00,$36 ; 36: CLIMB IN    *          *
L142D               fcb       $15,$05,$00,$80,$36 ; 36: CLIMB IN    *          u.......
L1432               fcb       $15,$06,$00,$00,$37 ; 37: CLIMB OUT   *          *
L1437               fcb       $15,$06,$00,$80,$37 ; 37: CLIMB OUT   *          u.......
L143C               fcb       $15,$04,$00,$80,$38 ; 38: CLIMB UNDER *          u.......
L1441               fcb       $16,$00,$80,$00,$18 ; 18: RUB *       u.......   *
L1446               fcb       $18,$00,$00,$00,$1A ; 1A: ??? *       *          *
L144B               fcb       $05,$01,$00,$00,$01 ; 01: NORTH TO    *          *
L1450               fcb       $06,$01,$00,$00,$02 ; 02: SOUTH TO    *          *
L1455               fcb       $07,$01,$00,$00,$03 ; 03: EAST TO     *          *
L145A               fcb       $08,$01,$00,$00,$04 ; 04: WEST TO     *          *
L145F               fcb       $0A,$08,$00,$20,$06 ; 06: DROP DOWN   *          ..C.....
L1464               fcb       $0A,$08,$20,$00,$06 ; 06: DROP DOWN   ..C.....   *
L1469               fcb       $0A,$0A,$20,$80,$06 ; 06: DROP BEHIND ..C.....   u.......
L146E               fcb       $0A,$04,$20,$80,$06 ; 06: DROP UNDER  ..C.....   u.......
L1473               fcb       $0A,$0C,$20,$80,$06 ; 06: DROP ON     ..C.....   u.......
L1478               fcb       $0C,$07,$00,$00,$0A ; 0A: LOOK UP     *          *
L147D               fcb       $0C,$08,$00,$00,$0A ; 0A: LOOK DOWN   *          *
L1482               fcb       $0C,$09,$80,$00,$0B ; 0B: LOOK OVER   u.......   *
L1487               fcb       $0C,$09,$00,$80,$0B ; 0B: LOOK OVER   *          u.......
L148C               fcb       $0C,$0B,$00,$00,$0A ; 0A: LOOK AROUND *          *
L1491               fcb       $0C,$0A,$00,$00,$0A ; 0A: LOOK BEHIND *          *
L1496               fcb       $0C,$0B,$00,$80,$1B ; 1B: LOOK AROUND *          u.......
L149B               fcb       $0C,$0A,$00,$80,$1C ; 1C: LOOK BEHIND *          u.......
L14A0               fcb       $32,$00,$00,$00,$21 ; 21: PLUGH *     *          *
L14A5               fcb       $2B,$00,$00,$00,$22 ; 22: SCREAM *    *          *
L14AA               fcb       $2D,$00,$00,$00,$23 ; 23: QUIT *      *          *
L14AF               fcb       $2C,$00,$00,$00,$25 ; 25: LEAVE *     *          *
L14B4               fcb       $2C,$00,$20,$00,$06 ; 06: LEAVE *     ..C.....   *
L14B9               fcb       $21,$00,$00,$00,$25 ; 25: GO *        *          *
L14BE               fcb       $21,$01,$00,$80,$3D ; 3D: GO TO       *          u.......
L14C3               fcb       $21,$05,$00,$80,$36 ; 36: GO IN       *          u.......
L14C8               fcb       $21,$06,$00,$80,$37 ; 37: GO OUT      *          u.......
L14CD               fcb       $21,$04,$00,$80,$38 ; 38: GO UNDER    *          u.......
L14D2               fcb       $21,$07,$00,$80,$17 ; 17: GO UP       *          u.......
L14D7               fcb       $21,$08,$00,$80,$17 ; 17: GO DOWN     *          u.......
L14DC               fcb       $21,$0B,$00,$80,$26 ; 26: GO AROUND   *          u.......
L14E1               fcb       $23,$00,$80,$00,$27 ; 27: KICK *      u.......   *
L14E6               fcb       $23,$08,$00,$80,$27 ; 27: KICK DOWN   *          u.......
L14EB               fcb       $23,$05,$00,$80,$27 ; 27: KICK IN     *          u.......
L14F0               fcb       $24,$02,$10,$80,$28 ; 28: FEED WITH   ...P....   u.......
L14F5               fcb       $24,$01,$80,$10,$29 ; 29: FEED TO     u.......   ...P....
L14FA               fcb       $28,$00,$00,$00,$2C ; 2C: SCORE *     *          *
L14FF               fcb       $1C,$00,$80,$00,$2D ; 2D: LIFT *      u.......   *
L1504               fcb       $1F,$00,$00,$00,$2F ; 2F: WAIT *      *          *
L1509               fcb       $1F,$0B,$00,$00,$2F ; 2F: WAIT AROUND *          *
L150E               fcb       $09,$07,$00,$00,$2F ; 2F: GET UP      *          *
L1513               fcb       $20,$09,$00,$80,$34 ; 34: JUMP OVER   *          u.......
L1518               fcb       $20,$05,$00,$80,$36 ; 36: JUMP IN     *          u.......
L151D               fcb       $20,$06,$00,$80,$37 ; 37: JUMP OUT    *          u.......
L1522               fcb       $00


;##RoomDescriptions
L1523               fcb       $00,$8B,$D9         ; Script list size=0BD9
L1526               fcb       $81,$5E,$00         ;   Script number=81 size=005E data=00
L1529               fcb       $03,$52             ;     Data tag=03 size=0052
L152B               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$5F,$17,$46,$48 ;       YOU ARE IN A SMALL ROOM WITH GRANITE WALLS
L1537               fcb       $39,$17,$DB,$9F,$56,$D1,$09,$71,$D0,$B0,$7F,$7B ;       AND FLOOR. THERE IS A SMALL OPENING TO THE
L1543               fcb       $F3,$17,$0D,$8D,$90,$14,$08,$58,$81,$8D,$1B,$B5 ;       EAST AND A LARGE HOLE IN THE CEILING.
L154F               fcb       $5F,$BE,$5B,$B1,$4B,$7B,$55,$45,$8E,$91,$11,$8A ;       .
L155B               fcb       $F0,$A4,$91,$7A,$89,$17,$82,$17,$47,$5E,$66,$49 ;       .
L1567               fcb       $90,$14,$03,$58,$3B,$16,$B7,$B1,$A9,$15,$DB,$8B ;       .
L1573               fcb       $83,$7A,$5F,$BE,$D7,$14,$43,$7A,$CF,$98 ;       .
L157D               fcb       $04,$07             ;     Data tag=04 size=0007
L157F               fcb       $0B,$05             ;         Command_0B_SWITCH size=05
L1581               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1583               fcb       $02                 ;           IF_NOT_JUMP address=1586
L1584               fcb       $00,$82             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=82
L1586               fcb       $82,$80,$C4,$00     ;   Script number=82 size=00C4 data=00
L158A               fcb       $03,$80,$AB         ;     Data tag=03 size=00AB
L158D               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$3B,$16,$B7,$B1 ;       YOU ARE IN A LARGE RECTANGULAR ROOM. ON THE
L1599               fcb       $2F,$17,$FB,$55,$C7,$98,$54,$8B,$39,$17,$FF,$9F ;       FLOOR OF THE EAST SIDE OF THE ROOM IS AN
L15A5               fcb       $C0,$16,$82,$17,$48,$5E,$81,$8D,$91,$AF,$96,$64 ;       INTRICATE ORIENTAL RUG STRETCHING BETWEEN
L15B1               fcb       $DB,$72,$95,$5F,$15,$BC,$FF,$78,$B8,$16,$82,$17 ;       THE NORTH AND SOUTH WALLS. IN THE EAST WALL
L15BD               fcb       $54,$5E,$3F,$A0,$D5,$15,$90,$14,$D0,$15,$F3,$BF ;       IS A HUGE CARVED WOODEN DOOR. TO THE SOUTH,
L15C9               fcb       $16,$53,$51,$5E,$07,$B2,$BB,$9A,$14,$8A,$6B,$C4 ;       A SMALL HOLE LEADS TO A DARK PASSAGE WAY.
L15D5               fcb       $0C,$BA,$7D,$62,$90,$73,$C4,$6A,$91,$62,$30,$60 ;       .
L15E1               fcb       $82,$17,$50,$5E,$BE,$A0,$03,$71,$33,$98,$47,$B9 ;       .
L15ED               fcb       $53,$BE,$0E,$D0,$2F,$8E,$D0,$15,$82,$17,$47,$5E ;       .
L15F9               fcb       $66,$49,$F3,$17,$F3,$8C,$4B,$7B,$4A,$45,$77,$C4 ;       .
L1605               fcb       $D3,$14,$0F,$B4,$19,$58,$36,$A0,$83,$61,$81,$5B ;       .
L1611               fcb       $1B,$B5,$6B,$BF,$5F,$BE,$61,$17,$82,$C6,$03,$EE ;       .
L161D               fcb       $5F,$17,$46,$48,$A9,$15,$DB,$8B,$E3,$8B,$0B,$5C ;       .
L1629               fcb       $6B,$BF,$46,$45,$35,$49,$DB,$16,$D3,$B9,$9B,$6C ;       .
L1635               fcb       $1B,$D0,$2E         ;       .
L1638               fcb       $04,$13             ;     Data tag=04 size=0013
L163A               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L163C               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L163E               fcb       $02                 ;           IF_NOT_JUMP address=1641
L163F               fcb       $00,$81             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=81
L1641               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1642               fcb       $02                 ;           IF_NOT_JUMP address=1645
L1643               fcb       $00,$83             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=83
L1645               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1646               fcb       $06                 ;           IF_NOT_JUMP address=164D
L1647               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L1649               fcb       $20,$1D             ;               Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L164B               fcb       $8B                 ;               CommonCommand_8B
L164C               fcb       $81                 ;               CommonCommand_81
L164D               fcb       $83,$3A,$00         ;   Script number=83 size=003A data=00
L1650               fcb       $03,$2A             ;     Data tag=03 size=002A
L1652               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$FB,$14,$4B,$B2 ;       YOU ARE IN A DARK PASSAGE WAY WHICH SLOPES
L165E               fcb       $55,$A4,$09,$B7,$59,$5E,$3B,$4A,$23,$D1,$13,$54 ;       UP AND TO THE SOUTH.
L166A               fcb       $C9,$B8,$F5,$A4,$B2,$17,$90,$14,$16,$58,$D6,$9C ;       .
L1676               fcb       $DB,$72,$47,$B9,$77,$BE ;       .
L167C               fcb       $04,$0B             ;     Data tag=04 size=000B
L167E               fcb       $0B,$09             ;         Command_0B_SWITCH size=09
L1680               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1682               fcb       $02                 ;           IF_NOT_JUMP address=1685
L1683               fcb       $00,$82             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=82
L1685               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1686               fcb       $02                 ;           IF_NOT_JUMP address=1689
L1687               fcb       $00,$84             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=84
L1689               fcb       $84,$67,$00         ;   Script number=84 size=0067 data=00
L168C               fcb       $03,$53             ;     Data tag=03 size=0053
L168E               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$82,$BF ;       YOU ARE AT THE TOP OF A PASSAGE WHICH SLOPES
L169A               fcb       $B8,$16,$7B,$14,$55,$A4,$09,$B7,$59,$5E,$85,$73 ;       DOWN AND TO THE NORTH. THERE IS A CORRIDOR
L16A6               fcb       $15,$71,$82,$8D,$4B,$62,$89,$5B,$83,$96,$33,$98 ;       TO THE EAST AND ANOTHER TO THE WEST.
L16B2               fcb       $6B,$BF,$5F,$BE,$99,$16,$C2,$B3,$56,$F4,$F4,$72 ;       .
L16BE               fcb       $4B,$5E,$C3,$B5,$E1,$14,$73,$B3,$84,$5B,$89,$17 ;       .
L16CA               fcb       $82,$17,$47,$5E,$66,$49,$90,$14,$03,$58,$06,$9A ;       .
L16D6               fcb       $F4,$72,$89,$17,$82,$17,$59,$5E,$66,$62,$2E ;       .
L16E1               fcb       $04,$0F             ;     Data tag=04 size=000F
L16E3               fcb       $0B,$0D             ;         Command_0B_SWITCH size=0D
L16E5               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L16E7               fcb       $02                 ;           IF_NOT_JUMP address=16EA
L16E8               fcb       $00,$83             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=83
L16EA               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L16EB               fcb       $02                 ;           IF_NOT_JUMP address=16EE
L16EC               fcb       $00,$A1             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A1
L16EE               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L16EF               fcb       $02                 ;           IF_NOT_JUMP address=16F2
L16F0               fcb       $00,$85             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=85
L16F2               fcb       $85,$44,$00         ;   Script number=85 size=0044 data=00
L16F5               fcb       $03,$26             ;     Data tag=03 size=0026
L16F7               fcb       $63,$BE,$CB,$B5,$C3,$B5,$73,$17,$1B,$B8,$E6,$A4 ;       THIS IS A T SHAPED ROOM WITH EXITS EAST,
L1703               fcb       $39,$17,$DB,$9F,$56,$D1,$07,$71,$96,$D7,$C7,$B5 ;       SOUTH, AND WEST.
L170F               fcb       $66,$49,$15,$EE,$36,$A1,$73,$76,$8E,$48,$F7,$17 ;       .
L171B               fcb       $17,$BA             ;       .
L171D               fcb       $04,$19             ;     Data tag=04 size=0019
L171F               fcb       $0B,$17             ;         Command_0B_SWITCH size=17
L1721               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1723               fcb       $02                 ;           IF_NOT_JUMP address=1726
L1724               fcb       $00,$84             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=84
L1726               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1727               fcb       $02                 ;           IF_NOT_JUMP address=172A
L1728               fcb       $00,$86             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=86
L172A               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L172B               fcb       $0C                 ;           IF_NOT_JUMP address=1738
L172C               fcb       $0D,$0A             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=10
L172E               fcb       $00,$88             ;               Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=88
L1730               fcb       $14                 ;               Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L1731               fcb       $0D,$05             ;                 Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L1733               fcb       $20,$1D             ;                   Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L1735               fcb       $01,$07             ;                   Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=07(StatueWest)
L1737               fcb       $82                 ;                   CommonCommand_82
L1738               fcb       $86,$3F,$00         ;   Script number=86 size=003F data=00
L173B               fcb       $03,$2F             ;     Data tag=03 size=002F
L173D               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$39,$17,$DB,$9F ;       YOU ARE IN A ROOM WITH GRAY STONE WALLS.
L1749               fcb       $56,$D1,$09,$71,$DB,$B0,$66,$17,$0F,$A0,$F3,$17 ;       PASSAGES LEAD NORTH AND EAST.
L1755               fcb       $0D,$8D,$52,$F4,$65,$49,$77,$47,$CE,$B5,$86,$5F ;       .
L1761               fcb       $99,$16,$C2,$B3,$90,$14,$07,$58,$66,$49,$2E ;       .
L176C               fcb       $04,$0B             ;     Data tag=04 size=000B
L176E               fcb       $0B,$09             ;         Command_0B_SWITCH size=09
L1770               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1772               fcb       $02                 ;           IF_NOT_JUMP address=1775
L1773               fcb       $00,$85             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=85
L1775               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1776               fcb       $02                 ;           IF_NOT_JUMP address=1779
L1777               fcb       $00,$87             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=87
L1779               fcb       $87,$44,$00         ;   Script number=87 size=0044 data=00
L177C               fcb       $03,$2F             ;     Data tag=03 size=002F
L177E               fcb       $63,$BE,$CB,$B5,$C3,$B5,$39,$17,$8E,$C5,$39,$17 ;       THIS IS A ROUND ROOM WITH HIGH WALLS. THE
L178A               fcb       $DB,$9F,$56,$D1,$0A,$71,$7A,$79,$F3,$17,$0D,$8D ;       ONLY OPENING IS TO THE WEST.
L1796               fcb       $56,$F4,$DB,$72,$16,$A0,$51,$DB,$F0,$A4,$91,$7A ;       .
L17A2               fcb       $D5,$15,$89,$17,$82,$17,$59,$5E,$66,$62,$2E ;       .
L17AD               fcb       $04,$10             ;     Data tag=04 size=0010
L17AF               fcb       $0B,$0E             ;         Command_0B_SWITCH size=0E
L17B1               fcb       $0A,$05             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=05 phrase="05: GET *       ..C.....   *       "
L17B3               fcb       $07                 ;           IF_NOT_JUMP address=17BB
L17B4               fcb       $0D,$05             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L17B6               fcb       $08,$08             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=08(GoldRing
L17B8               fcb       $19,$8C             ;               Command_19_MOVE_ACTIVE_OBJECT_TO_ROOM room=8C
L17BA               fcb       $0C                 ;               Command_0C_FAIL
L17BB               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L17BC               fcb       $02                 ;           IF_NOT_JUMP address=17BF
L17BD               fcb       $00,$86             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=86
L17BF               fcb       $88,$79,$00         ;   Script number=88 size=0079 data=00
L17C2               fcb       $03,$57             ;     Data tag=03 size=0057
L17C4               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$8C,$17,$90,$78 ;       YOU ARE IN A TRIANGULAR ROOM WITH OPENINGS
L17D0               fcb       $2E,$6F,$23,$49,$01,$B3,$59,$90,$82,$7B,$C2,$16 ;       IN THE EAST AND WEST CORNERS. THERE IS A
L17DC               fcb       $93,$61,$C5,$98,$D0,$15,$82,$17,$47,$5E,$66,$49 ;       STATUE IN THE SOUTH CORNER WITH BOW AND
L17E8               fcb       $90,$14,$19,$58,$66,$62,$E1,$14,$CF,$B2,$AF,$B3 ;       ARROW.
L17F4               fcb       $82,$17,$2F,$62,$D5,$15,$7B,$14,$FB,$B9,$67,$C0 ;       .
L1800               fcb       $D0,$15,$82,$17,$55,$5E,$36,$A1,$05,$71,$B8,$A0 ;       .
L180C               fcb       $23,$62,$56,$D1,$04,$71,$6B,$A1,$8E,$48,$94,$14 ;       .
L1818               fcb       $09,$B3,$2E         ;       .
L181B               fcb       $04,$1D             ;     Data tag=04 size=001D
L181D               fcb       $0B,$1B             ;         Command_0B_SWITCH size=1B
L181F               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1821               fcb       $0B                 ;           IF_NOT_JUMP address=182D
L1822               fcb       $0E,$09             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=9
L1824               fcb       $0D,$05             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L1826               fcb       $20,$1D             ;                 Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L1828               fcb       $01,$07             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=07(StatueWest)
L182A               fcb       $82                 ;                 CommonCommand_82
L182B               fcb       $00,$85             ;               Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=85
L182D               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L182E               fcb       $0B                 ;           IF_NOT_JUMP address=183A
L182F               fcb       $0E,$09             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=9
L1831               fcb       $0D,$05             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L1833               fcb       $20,$1D             ;                 Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L1835               fcb       $01,$06             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=06(StatueEast)
L1837               fcb       $82                 ;                 CommonCommand_82
L1838               fcb       $00,$89             ;               Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=89
L183A               fcb       $89,$5D,$00         ;   Script number=89 size=005D data=00
L183D               fcb       $03,$3F             ;     Data tag=03 size=003F
L183F               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$47,$B9 ;       YOU ARE AT THE SOUTH END OF THE GREAT
L184B               fcb       $53,$BE,$8E,$61,$B8,$16,$82,$17,$49,$5E,$63,$B1 ;       CENTRAL HALLWAY. EXITS EXIST IN THE EAST AND
L1857               fcb       $05,$BC,$9E,$61,$CE,$B0,$9B,$15,$11,$8D,$5F,$4A ;       WEST WALLS.
L1863               fcb       $3A,$15,$8D,$7B,$3A,$15,$66,$7B,$D0,$15,$82,$17 ;       .
L186F               fcb       $47,$5E,$66,$49,$90,$14,$19,$58,$66,$62,$F3,$17 ;       .
L187B               fcb       $0D,$8D,$2E         ;       .
L187E               fcb       $04,$19             ;     Data tag=04 size=0019
L1880               fcb       $0B,$17             ;         Command_0B_SWITCH size=17
L1882               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1884               fcb       $0C                 ;           IF_NOT_JUMP address=1891
L1885               fcb       $0D,$0A             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=10
L1887               fcb       $00,$88             ;               Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=88
L1889               fcb       $14                 ;               Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L188A               fcb       $0D,$05             ;                 Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L188C               fcb       $20,$1D             ;                   Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L188E               fcb       $01,$06             ;                   Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=06(StatueEast)
L1890               fcb       $82                 ;                   CommonCommand_82
L1891               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1892               fcb       $02                 ;           IF_NOT_JUMP address=1895
L1893               fcb       $00,$90             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=90
L1895               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1896               fcb       $02                 ;           IF_NOT_JUMP address=1899
L1897               fcb       $00,$8A             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8A
L1899               fcb       $8A,$3A,$00         ;   Script number=8A size=003A data=00
L189C               fcb       $03,$26             ;     Data tag=03 size=0026
L189E               fcb       $63,$BE,$CB,$B5,$C3,$B5,$73,$17,$1B,$B8,$E6,$A4 ;       THIS IS A T SHAPED ROOM WITH EXITS EAST,
L18AA               fcb       $39,$17,$DB,$9F,$56,$D1,$07,$71,$96,$D7,$C7,$B5 ;       SOUTH, AND WEST.
L18B6               fcb       $66,$49,$15,$EE,$36,$A1,$73,$76,$8E,$48,$F7,$17 ;       .
L18C2               fcb       $17,$BA             ;       .
L18C4               fcb       $04,$0F             ;     Data tag=04 size=000F
L18C6               fcb       $0B,$0D             ;         Command_0B_SWITCH size=0D
L18C8               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L18CA               fcb       $02                 ;           IF_NOT_JUMP address=18CD
L18CB               fcb       $00,$89             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=89
L18CD               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L18CE               fcb       $02                 ;           IF_NOT_JUMP address=18D1
L18CF               fcb       $00,$8B             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8B
L18D1               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L18D2               fcb       $02                 ;           IF_NOT_JUMP address=18D5
L18D3               fcb       $00,$8D             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8D
L18D5               fcb       $8B,$3F,$00         ;   Script number=8B size=003F data=00
L18D8               fcb       $03,$2F             ;     Data tag=03 size=002F
L18DA               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$39,$17,$DB,$9F ;       YOU ARE IN A ROOM WITH GREY STONE WALLS.
L18E6               fcb       $56,$D1,$09,$71,$7B,$B1,$66,$17,$0F,$A0,$F3,$17 ;       PASSAGES LEAD NORTH AND EAST.
L18F2               fcb       $0D,$8D,$52,$F4,$65,$49,$77,$47,$CE,$B5,$86,$5F ;       .
L18FE               fcb       $99,$16,$C2,$B3,$90,$14,$07,$58,$66,$49,$2E ;       .
L1909               fcb       $04,$0B             ;     Data tag=04 size=000B
L190B               fcb       $0B,$09             ;         Command_0B_SWITCH size=09
L190D               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L190F               fcb       $02                 ;           IF_NOT_JUMP address=1912
L1910               fcb       $00,$8A             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8A
L1912               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1913               fcb       $02                 ;           IF_NOT_JUMP address=1916
L1914               fcb       $00,$8C             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8C
L1916               fcb       $8C,$44,$00         ;   Script number=8C size=0044 data=00
L1919               fcb       $03,$2F             ;     Data tag=03 size=002F
L191B               fcb       $63,$BE,$CB,$B5,$C3,$B5,$39,$17,$8E,$C5,$39,$17 ;       THIS IS A ROUND ROOM WITH HIGH WALLS. THE
L1927               fcb       $DB,$9F,$56,$D1,$0A,$71,$7A,$79,$F3,$17,$0D,$8D ;       ONLY OPENING IS TO THE WEST.
L1933               fcb       $56,$F4,$DB,$72,$16,$A0,$51,$DB,$F0,$A4,$91,$7A ;       .
L193F               fcb       $D5,$15,$89,$17,$82,$17,$59,$5E,$66,$62,$2E ;       .
L194A               fcb       $04,$10             ;     Data tag=04 size=0010
L194C               fcb       $0B,$0E             ;         Command_0B_SWITCH size=0E
L194E               fcb       $0A,$05             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=05 phrase="05: GET *       ..C.....   *       "
L1950               fcb       $07                 ;           IF_NOT_JUMP address=1958
L1951               fcb       $0D,$05             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L1953               fcb       $08,$08             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=08(GoldRing
L1955               fcb       $19,$87             ;               Command_19_MOVE_ACTIVE_OBJECT_TO_ROOM room=87
L1957               fcb       $0C                 ;               Command_0C_FAIL
L1958               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1959               fcb       $02                 ;           IF_NOT_JUMP address=195C
L195A               fcb       $00,$8B             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8B
L195C               fcb       $8D,$4D,$00         ;   Script number=8D size=004D data=00
L195F               fcb       $03,$3D             ;     Data tag=03 size=003D
L1961               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$DF,$16,$96,$BE ;       YOU ARE IN A PETITE CHAMBER. THERE IS A
L196D               fcb       $45,$5E,$4F,$72,$74,$4D,$56,$F4,$F4,$72,$4B,$5E ;       LARGER ROOM TO THE NORTH AND A PASSAGE TO
L1979               fcb       $C3,$B5,$3B,$16,$B7,$B1,$94,$AF,$3F,$A0,$89,$17 ;       THE WEST.
L1985               fcb       $82,$17,$50,$5E,$BE,$A0,$03,$71,$33,$98,$52,$45 ;       .
L1991               fcb       $65,$49,$77,$47,$89,$17,$82,$17,$59,$5E,$66,$62 ;       .
L199D               fcb       $2E                 ;       .
L199E               fcb       $04,$0B             ;     Data tag=04 size=000B
L19A0               fcb       $0B,$09             ;         Command_0B_SWITCH size=09
L19A2               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L19A4               fcb       $02                 ;           IF_NOT_JUMP address=19A7
L19A5               fcb       $00,$8A             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8A
L19A7               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L19A8               fcb       $02                 ;           IF_NOT_JUMP address=19AB
L19A9               fcb       $00,$8E             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8E
L19AB               fcb       $8E,$80,$A2,$00     ;   Script number=8E size=00A2 data=00
L19AF               fcb       $03,$3B             ;     Data tag=03 size=003B
L19B1               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$3B,$16,$B7,$B1 ;       YOU ARE IN A LARGE ROOM WHICH SMELLS OF
L19BD               fcb       $39,$17,$DB,$9F,$23,$D1,$13,$54,$E7,$B8,$0D,$8D ;       DECAYING FLESH. THERE ARE EXITS NORTH AND
L19C9               fcb       $B8,$16,$FF,$14,$1B,$53,$91,$7A,$56,$15,$5A,$62 ;       SOUTH.
L19D5               fcb       $56,$F4,$F4,$72,$43,$5E,$5B,$B1,$23,$63,$0B,$C0 ;       .
L19E1               fcb       $04,$9A,$53,$BE,$8E,$48,$61,$17,$82,$C6,$2E ;       .
L19EC               fcb       $04,$62             ;     Data tag=04 size=0062
L19EE               fcb       $0B,$60             ;         Command_0B_SWITCH size=60
L19F0               fcb       $0A,$02             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L19F2               fcb       $02                 ;           IF_NOT_JUMP address=19F5
L19F3               fcb       $00,$8D             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8D
L19F5               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L19F6               fcb       $59                 ;           IF_NOT_JUMP address=1A50
L19F7               fcb       $0E,$57             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=87
L19F9               fcb       $0D,$1D             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=29
L19FB               fcb       $01,$1E             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1E(LiveGargoyle)
L19FD               fcb       $20,$1D             ;                 Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L19FF               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1A00               fcb       $17,$5F,$BE,$73,$15,$C1,$B1,$3F,$DE,$B6,$14,$5D ;                   THE GARGOYLE BLOCKS THE WAY NORTH.
L1A0C               fcb       $9E,$D6,$B5,$DB,$72,$1B,$D0,$99,$16,$C2,$B3,$2E ;                   .
L1A18               fcb       $0D,$34             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=52
L1A1A               fcb       $20,$1D             ;                 Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L1A1C               fcb       $01,$0A             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=0A(StoneGargoyle)
L1A1E               fcb       $17,$0A,$00         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=0A(StoneGargoyle) location=00
L1A21               fcb       $17,$1E,$8E         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1E(LiveGargoyle) location=8E
L1A24               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1A25               fcb       $28,$5F,$BE,$73,$15,$C1,$B1,$3F,$DE,$E1,$14,$35 ;                   THE GARGOYLE COMES TO LIFE AND JUMPS DOWN TO
L1A31               fcb       $92,$89,$17,$43,$16,$5B,$66,$8E,$48,$FF,$15,$ED ;                   BLOCK YOUR WAY!
L1A3D               fcb       $93,$09,$15,$03,$D2,$6B,$BF,$89,$4E,$8B,$54,$C7 ;                   .
L1A49               fcb       $DE,$99,$AF,$39,$4A ;                   .
L1A4E               fcb       $00,$8F             ;               Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8F
L1A50               fcb       $8F,$3A,$00         ;   Script number=8F size=003A data=00
L1A53               fcb       $03,$2E             ;     Data tag=03 size=002E
L1A55               fcb       $63,$BE,$CB,$B5,$C3,$B5,$7B,$17,$F3,$8C,$01,$B3 ;       THIS IS A TALL ROOM CARVED OF STONE WITH A
L1A61               fcb       $45,$90,$40,$49,$F3,$5F,$C3,$9E,$09,$BA,$5B,$98 ;       SINGLE EXIT TO THE SOUTH.
L1A6D               fcb       $56,$D1,$03,$71,$5B,$17,$BE,$98,$47,$5E,$96,$D7 ;       .
L1A79               fcb       $89,$17,$82,$17,$55,$5E,$36,$A1,$9B,$76 ;       .
L1A83               fcb       $04,$07             ;     Data tag=04 size=0007
L1A85               fcb       $0B,$05             ;         Command_0B_SWITCH size=05
L1A87               fcb       $0A,$02             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1A89               fcb       $02                 ;           IF_NOT_JUMP address=1A8C
L1A8A               fcb       $00,$8E             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=8E
L1A8C               fcb       $90,$80,$A2,$00     ;   Script number=90 size=00A2 data=00
L1A90               fcb       $03,$56             ;     Data tag=03 size=0056
L1A92               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$04,$9A ;       YOU ARE AT THE NORTH END OF THE GREAT
L1A9E               fcb       $53,$BE,$8E,$61,$B8,$16,$82,$17,$49,$5E,$63,$B1 ;       CENTRAL HALLWAY. EXITS EXIST IN THE EAST AND
L1AAA               fcb       $05,$BC,$9E,$61,$CE,$B0,$9B,$15,$11,$8D,$5F,$4A ;       WEST WALLS. THERE IS A DOOR ON THE NORTH
L1AB6               fcb       $3A,$15,$8D,$7B,$3A,$15,$66,$7B,$D0,$15,$82,$17 ;       WALL.
L1AC2               fcb       $47,$5E,$66,$49,$90,$14,$19,$58,$66,$62,$F3,$17 ;       .
L1ACE               fcb       $0D,$8D,$56,$F4,$F4,$72,$4B,$5E,$C3,$B5,$09,$15 ;       .
L1ADA               fcb       $A3,$A0,$03,$A0,$5F,$BE,$99,$16,$C2,$B3,$F3,$17 ;       .
L1AE6               fcb       $17,$8D             ;       .
L1AE8               fcb       $04,$47             ;     Data tag=04 size=0047
L1AEA               fcb       $0B,$45             ;         Command_0B_SWITCH size=45
L1AEC               fcb       $0A,$02             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1AEE               fcb       $02                 ;           IF_NOT_JUMP address=1AF1
L1AEF               fcb       $00,$89             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=89
L1AF1               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1AF2               fcb       $02                 ;           IF_NOT_JUMP address=1AF5
L1AF3               fcb       $00,$A0             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A0
L1AF5               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1AF6               fcb       $36                 ;           IF_NOT_JUMP address=1B2D
L1AF7               fcb       $0E,$34             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=52
L1AF9               fcb       $0D,$14             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=20
L1AFB               fcb       $01,$1B             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1B(ClosedDoor)
L1AFD               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1AFE               fcb       $10,$5F,$BE,$09,$15,$A3,$A0,$89,$4E,$A5,$54,$DB ;                   THE DOOR BLOCKS PASSAGE.
L1B0A               fcb       $16,$D3,$B9,$BF,$6C ;                   .
L1B0F               fcb       $0D,$1C             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=28
L1B11               fcb       $00,$91             ;                 Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=91
L1B13               fcb       $17,$1B,$91         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1B(ClosedDoor) location=91
L1B16               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1B17               fcb       $12,$5F,$BE,$09,$15,$A3,$A0,$C9,$54,$B5,$B7,$AF ;                   THE DOOR CLOSES BEHIND YOU.
L1B23               fcb       $14,$90,$73,$1B,$58,$3F,$A1 ;                   .
L1B2A               fcb       $17,$1C,$00         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1C(OpenDoor) location=00
L1B2D               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1B2E               fcb       $02                 ;           IF_NOT_JUMP address=1B31
L1B2F               fcb       $00,$92             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=92
L1B31               fcb       $91,$80,$8F,$00     ;   Script number=91 size=008F data=00
L1B35               fcb       $03,$22             ;     Data tag=03 size=0022
L1B37               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$CB,$17,$4E,$C5 ;       YOU ARE IN A VAULT WITH A LARGE DOOR TO THE
L1B43               fcb       $FB,$17,$53,$BE,$4E,$45,$31,$49,$46,$5E,$44,$A0 ;       SOUTH.
L1B4F               fcb       $89,$17,$82,$17,$55,$5E,$36,$A1,$9B,$76 ;       .
L1B59               fcb       $04,$68             ;     Data tag=04 size=0068
L1B5B               fcb       $0B,$66             ;         Command_0B_SWITCH size=66
L1B5D               fcb       $0A,$02             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1B5F               fcb       $2F                 ;           IF_NOT_JUMP address=1B8F
L1B60               fcb       $0E,$2D             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=45
L1B62               fcb       $0D,$10             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=16
L1B64               fcb       $01,$1B             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1B(ClosedDoor)
L1B66               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1B67               fcb       $0C,$5F,$BE,$09,$15,$A3,$A0,$4B,$7B,$2F,$B8,$9B ;                   THE DOOR IS SHUT.
L1B73               fcb       $C1                 ;                   .
L1B74               fcb       $0D,$19             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=25
L1B76               fcb       $00,$90             ;                 Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=90
L1B78               fcb       $17,$1B,$90         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1B(ClosedDoor) location=90
L1B7B               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1B7C               fcb       $0F,$5F,$BE,$09,$15,$A3,$A0,$C9,$54,$B5,$B7,$89 ;                   THE DOOR CLOSES AGAIN.
L1B88               fcb       $14,$D0,$47,$2E     ;                   .
L1B8C               fcb       $17,$1C,$00         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1C(OpenDoor) location=00
L1B8F               fcb       $11                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=11 phrase="11: OPEN *      u.......   *       "
L1B90               fcb       $32                 ;           IF_NOT_JUMP address=1BC3
L1B91               fcb       $0E,$30             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=48
L1B93               fcb       $0D,$10             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=16
L1B95               fcb       $08,$1C             ;                 Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=1C(OpenDoor
L1B97               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1B98               fcb       $0C,$8D,$7B,$8E,$14,$63,$B1,$FB,$5C,$5F,$A0,$1B ;                   ITS ALREADY OPEN.
L1BA4               fcb       $9C                 ;                   .
L1BA5               fcb       $0D,$1C             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=28
L1BA7               fcb       $08,$1B             ;                 Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=1B(ClosedDoor
L1BA9               fcb       $17,$1C,$91         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1C(OpenDoor) location=91
L1BAC               fcb       $17,$1B,$00         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=1B(ClosedDoor) location=00
L1BAF               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1BB0               fcb       $12,$64,$B7,$B7,$C6,$B0,$C6,$D6,$6A,$DB,$72,$81 ;                   SCRUUUUUNG THE DOOR OPENS.
L1BBC               fcb       $5B,$91,$AF,$F0,$A4,$5B,$BB ;                   .
L1BC3               fcb       $92,$4B,$00         ;   Script number=92 size=004B data=00
L1BC6               fcb       $03,$3B             ;     Data tag=03 size=003B
L1BC8               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$9E,$61 ;       YOU ARE AT THE ENTRANCE TO A LONG DARK
L1BD4               fcb       $D0,$B0,$9B,$53,$6B,$BF,$4E,$45,$11,$A0,$FB,$14 ;       TUNNEL WHICH LEADS WEST. THERE IS A PASSAGE
L1BE0               fcb       $4B,$B2,$70,$C0,$6E,$98,$FA,$17,$DA,$78,$3F,$16 ;       EAST.
L1BEC               fcb       $0D,$47,$F7,$17,$17,$BA,$82,$17,$2F,$62,$D5,$15 ;       .
L1BF8               fcb       $7B,$14,$55,$A4,$09,$B7,$47,$5E,$66,$49,$2E ;       .
L1C03               fcb       $04,$0B             ;     Data tag=04 size=000B
L1C05               fcb       $0B,$09             ;         Command_0B_SWITCH size=09
L1C07               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1C09               fcb       $02                 ;           IF_NOT_JUMP address=1C0C
L1C0A               fcb       $00,$90             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=90
L1C0C               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1C0D               fcb       $02                 ;           IF_NOT_JUMP address=1C10
L1C0E               fcb       $00,$93             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=93
L1C10               fcb       $93,$22,$00         ;   Script number=93 size=0022 data=00
L1C13               fcb       $03,$12             ;     Data tag=03 size=0012
L1C15               fcb       $C7,$DE,$94,$14,$4B,$5E,$96,$96,$DB,$72,$54,$59 ;       YOU ARE IN THE DARK TUNNEL.
L1C21               fcb       $D6,$83,$98,$C5,$57,$61 ;       .
L1C27               fcb       $04,$0B             ;     Data tag=04 size=000B
L1C29               fcb       $0B,$09             ;         Command_0B_SWITCH size=09
L1C2B               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1C2D               fcb       $02                 ;           IF_NOT_JUMP address=1C30
L1C2E               fcb       $00,$92             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=92
L1C30               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1C31               fcb       $02                 ;           IF_NOT_JUMP address=1C34
L1C32               fcb       $00,$94             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=94
L1C34               fcb       $94,$58,$00         ;   Script number=94 size=0058 data=00
L1C37               fcb       $03,$3B             ;     Data tag=03 size=003B
L1C39               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$9E,$61 ;       YOU ARE AT THE ENTRANCE TO A LONG DARK
L1C45               fcb       $D0,$B0,$9B,$53,$6B,$BF,$4E,$45,$11,$A0,$FB,$14 ;       TUNNEL WHICH LEADS EAST. THERE IS A PASSAGE
L1C51               fcb       $4B,$B2,$70,$C0,$6E,$98,$FA,$17,$DA,$78,$3F,$16 ;       WEST.
L1C5D               fcb       $0D,$47,$23,$15,$17,$BA,$82,$17,$2F,$62,$D5,$15 ;       .
L1C69               fcb       $7B,$14,$55,$A4,$09,$B7,$59,$5E,$66,$62,$2E ;       .
L1C74               fcb       $04,$18             ;     Data tag=04 size=0018
L1C76               fcb       $0B,$16             ;         Command_0B_SWITCH size=16
L1C78               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1C7A               fcb       $02                 ;           IF_NOT_JUMP address=1C7D
L1C7B               fcb       $00,$93             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=93
L1C7D               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1C7E               fcb       $0F                 ;           IF_NOT_JUMP address=1C8E
L1C7F               fcb       $0E,$0D             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=13
L1C81               fcb       $0D,$09             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=9
L1C83               fcb       $20,$1D             ;                 Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L1C85               fcb       $03,$00,$16         ;                 Command_03_IS_OBJECT_AT_LOCATION object=16(DeadSerpent) location=00
L1C88               fcb       $17,$15,$95         ;                 Command_17_MOVE_OBJECT_TO_LOCATION object=15(LiveSerpent) location=95
L1C8B               fcb       $0C                 ;                 Command_0C_FAIL
L1C8C               fcb       $00,$95             ;               Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=95
L1C8E               fcb       $95,$32,$00         ;   Script number=95 size=0032 data=00
L1C91               fcb       $03,$20             ;     Data tag=03 size=0020
L1C93               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$3B,$16,$B7,$B1 ;       YOU ARE IN A LARGE ROOM WITH A SINGLE EXIT
L1C9F               fcb       $39,$17,$DB,$9F,$56,$D1,$03,$71,$5B,$17,$BE,$98 ;       EAST.
L1CAB               fcb       $47,$5E,$96,$D7,$23,$15,$17,$BA ;       .
L1CB3               fcb       $04,$0D             ;     Data tag=04 size=000D
L1CB5               fcb       $0B,$0B             ;         Command_0B_SWITCH size=0B
L1CB7               fcb       $0A,$36             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L1CB9               fcb       $01                 ;           IF_NOT_JUMP address=1CBB
L1CBA               fcb       $8F                 ;             CommonCommand_8F
L1CBB               fcb       $17                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L1CBC               fcb       $01                 ;           IF_NOT_JUMP address=1CBE
L1CBD               fcb       $8F                 ;             CommonCommand_8F
L1CBE               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1CBF               fcb       $02                 ;           IF_NOT_JUMP address=1CC2
L1CC0               fcb       $00,$94             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=94
L1CC2               fcb       $96,$30,$00         ;   Script number=96 size=0030 data=00
L1CC5               fcb       $03,$18             ;     Data tag=03 size=0018
L1CC7               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$FF,$14,$97,$9A ;       YOU ARE IN A DENSE DARK DAMP JUNGLE.
L1CD3               fcb       $FB,$14,$4B,$B2,$4F,$59,$0C,$A3,$91,$C5,$FF,$8B ;       .
L1CDF               fcb       $04,$13             ;     Data tag=04 size=0013
L1CE1               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L1CE3               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1CE5               fcb       $02                 ;           IF_NOT_JUMP address=1CE8
L1CE6               fcb       $00,$A3             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A3
L1CE8               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1CE9               fcb       $02                 ;           IF_NOT_JUMP address=1CEC
L1CEA               fcb       $00,$A4             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A4
L1CEC               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1CED               fcb       $02                 ;           IF_NOT_JUMP address=1CF0
L1CEE               fcb       $00,$97             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=97
L1CF0               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1CF1               fcb       $02                 ;           IF_NOT_JUMP address=1CF4
L1CF2               fcb       $00,$A4             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A4
L1CF4               fcb       $97,$30,$00         ;   Script number=97 size=0030 data=00
L1CF7               fcb       $03,$18             ;     Data tag=03 size=0018
L1CF9               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$FB,$14,$4B,$B2 ;       YOU ARE IN A DARK DENSE DAMP JUNGLE.
L1D05               fcb       $F0,$59,$9B,$B7,$4F,$59,$0C,$A3,$91,$C5,$FF,$8B ;       .
L1D11               fcb       $04,$13             ;     Data tag=04 size=0013
L1D13               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L1D15               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1D17               fcb       $02                 ;           IF_NOT_JUMP address=1D1A
L1D18               fcb       $00,$A2             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A2
L1D1A               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1D1B               fcb       $02                 ;           IF_NOT_JUMP address=1D1E
L1D1C               fcb       $00,$96             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=96
L1D1E               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1D1F               fcb       $02                 ;           IF_NOT_JUMP address=1D22
L1D20               fcb       $00,$A3             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A3
L1D22               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1D23               fcb       $02                 ;           IF_NOT_JUMP address=1D26
L1D24               fcb       $00,$98             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=98
L1D26               fcb       $98,$40,$00         ;   Script number=98 size=0040 data=00
L1D29               fcb       $03,$28             ;     Data tag=03 size=0028
L1D2B               fcb       $6C,$BE,$29,$A1,$16,$71,$DB,$72,$F0,$81,$BF,$6D ;       THROUGH THE JUNGLE YOU SEE THE EAST WALL OF
L1D37               fcb       $51,$18,$55,$C2,$1B,$60,$5F,$BE,$23,$15,$F3,$B9 ;       A GREAT TEMPLE.
L1D43               fcb       $0E,$D0,$11,$8A,$83,$64,$84,$15,$96,$5F,$7F,$17 ;       .
L1D4F               fcb       $E6,$93,$DB,$63     ;       .
L1D53               fcb       $04,$13             ;     Data tag=04 size=0013
L1D55               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L1D57               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1D59               fcb       $02                 ;           IF_NOT_JUMP address=1D5C
L1D5A               fcb       $00,$9B             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9B
L1D5C               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1D5D               fcb       $02                 ;           IF_NOT_JUMP address=1D60
L1D5E               fcb       $00,$99             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=99
L1D60               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1D61               fcb       $02                 ;           IF_NOT_JUMP address=1D64
L1D62               fcb       $00,$97             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=97
L1D64               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1D65               fcb       $02                 ;           IF_NOT_JUMP address=1D68
L1D66               fcb       $00,$9E             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9E
L1D68               fcb       $99,$44,$00         ;   Script number=99 size=0044 data=00
L1D6B               fcb       $03,$2C             ;     Data tag=03 size=002C
L1D6D               fcb       $83,$7A,$45,$45,$E3,$8B,$10,$B2,$C4,$6A,$59,$60 ;       IN A CLEARING BEFORE YOU STANDS THE SOUTH
L1D79               fcb       $5B,$B1,$C7,$DE,$66,$17,$8E,$48,$D6,$B5,$DB,$72 ;       WALL OF A GREAT TEMPLE.
L1D85               fcb       $47,$B9,$53,$BE,$0E,$D0,$11,$8A,$83,$64,$84,$15 ;       .
L1D91               fcb       $96,$5F,$7F,$17,$E6,$93,$DB,$63 ;       .
L1D99               fcb       $04,$13             ;     Data tag=04 size=0013
L1D9B               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L1D9D               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1D9F               fcb       $02                 ;           IF_NOT_JUMP address=1DA2
L1DA0               fcb       $00,$9F             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9F
L1DA2               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1DA3               fcb       $02                 ;           IF_NOT_JUMP address=1DA6
L1DA4               fcb       $00,$96             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=96
L1DA6               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1DA7               fcb       $02                 ;           IF_NOT_JUMP address=1DAA
L1DA8               fcb       $00,$98             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=98
L1DAA               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1DAB               fcb       $02                 ;           IF_NOT_JUMP address=1DAE
L1DAC               fcb       $00,$9A             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9A
L1DAE               fcb       $9A,$59,$00         ;   Script number=9A size=0059 data=00
L1DB1               fcb       $03,$41             ;     Data tag=03 size=0041
L1DB3               fcb       $6C,$BE,$29,$A1,$16,$71,$DB,$72,$F0,$59,$9B,$B7 ;       THROUGH THE DENSE UNDERGROWTH, YOU CAN SEE
L1DBF               fcb       $8E,$C5,$31,$62,$09,$B3,$76,$BE,$51,$18,$45,$C2 ;       THE GREAT BRONZE GATES ON THE WEST WALL OF
L1DCB               fcb       $83,$48,$A7,$B7,$82,$17,$49,$5E,$63,$B1,$04,$BC ;       THE TEMPLE.
L1DD7               fcb       $00,$B3,$5B,$E3,$16,$6C,$4B,$62,$03,$A0,$5F,$BE ;       .
L1DE3               fcb       $F7,$17,$F3,$B9,$0E,$D0,$11,$8A,$96,$64,$DB,$72 ;       .
L1DEF               fcb       $EF,$BD,$FF,$A5,$2E ;       .
L1DF4               fcb       $04,$13             ;     Data tag=04 size=0013
L1DF6               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L1DF8               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1DFA               fcb       $02                 ;           IF_NOT_JUMP address=1DFD
L1DFB               fcb       $00,$9B             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9B
L1DFD               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1DFE               fcb       $02                 ;           IF_NOT_JUMP address=1E01
L1DFF               fcb       $00,$99             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=99
L1E01               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1E02               fcb       $02                 ;           IF_NOT_JUMP address=1E05
L1E03               fcb       $00,$9C             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9C
L1E05               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1E06               fcb       $02                 ;           IF_NOT_JUMP address=1E09
L1E07               fcb       $00,$A4             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A4
L1E09               fcb       $9B,$4D,$00         ;   Script number=9B size=004D data=00
L1E0C               fcb       $03,$35             ;     Data tag=03 size=0035
L1E0E               fcb       $6C,$BE,$29,$A1,$03,$71,$73,$15,$0B,$A3,$96,$96 ;       THROUGH A GAP IN THE JUNGLE YOU CAN SEE THE
L1E1A               fcb       $DB,$72,$F0,$81,$BF,$6D,$51,$18,$45,$C2,$83,$48 ;       NORTH WALL OF A MAGNIFICENT TEMPLE.
L1E26               fcb       $A7,$B7,$82,$17,$50,$5E,$BE,$A0,$19,$71,$46,$48 ;       .
L1E32               fcb       $B8,$16,$7B,$14,$89,$91,$08,$99,$D7,$78,$B3,$9A ;       .
L1E3E               fcb       $EF,$BD,$FF,$A5,$2E ;       .
L1E43               fcb       $04,$13             ;     Data tag=04 size=0013
L1E45               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L1E47               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1E49               fcb       $02                 ;           IF_NOT_JUMP address=1E4C
L1E4A               fcb       $00,$A2             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A2
L1E4C               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1E4D               fcb       $02                 ;           IF_NOT_JUMP address=1E50
L1E4E               fcb       $00,$9D             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9D
L1E50               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1E51               fcb       $02                 ;           IF_NOT_JUMP address=1E54
L1E52               fcb       $00,$9A             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9A
L1E54               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1E55               fcb       $02                 ;           IF_NOT_JUMP address=1E58
L1E56               fcb       $00,$98             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=98
L1E58               fcb       $9C,$3A,$00         ;   Script number=9C size=003A data=00
L1E5B               fcb       $03,$26             ;     Data tag=03 size=0026
L1E5D               fcb       $C7,$DE,$94,$14,$55,$5E,$50,$BD,$90,$5A,$C4,$6A ;       YOU ARE STANDING BEFORE THE WEST ENTRANCE OF
L1E69               fcb       $59,$60,$5B,$B1,$5F,$BE,$F7,$17,$F3,$B9,$9E,$61 ;       THE TEMPLE.
L1E75               fcb       $D0,$B0,$9B,$53,$C3,$9E,$5F,$BE,$7F,$17,$E6,$93 ;       .
L1E81               fcb       $DB,$63             ;       .
L1E83               fcb       $04,$0F             ;     Data tag=04 size=000F
L1E85               fcb       $0B,$0D             ;         Command_0B_SWITCH size=0D
L1E87               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1E89               fcb       $02                 ;           IF_NOT_JUMP address=1E8C
L1E8A               fcb       $00,$9D             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9D
L1E8C               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1E8D               fcb       $02                 ;           IF_NOT_JUMP address=1E90
L1E8E               fcb       $00,$9F             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9F
L1E90               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1E91               fcb       $02                 ;           IF_NOT_JUMP address=1E94
L1E92               fcb       $00,$9A             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9A
L1E94               fcb       $9D,$80,$B3,$00     ;   Script number=9D size=00B3 data=00
L1E98               fcb       $03,$12             ;     Data tag=03 size=0012
L1E9A               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$04,$9A ;       YOU ARE AT THE NORTH WALL.
L1EA6               fcb       $53,$BE,$0E,$D0,$9B,$8F ;       .
L1EAC               fcb       $04,$80,$9B         ;     Data tag=04 size=009B
L1EAF               fcb       $0B,$80,$98         ;         Command_0B_SWITCH size=98
L1EB2               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1EB4               fcb       $02                 ;           IF_NOT_JUMP address=1EB7
L1EB5               fcb       $00,$9B             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9B
L1EB7               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1EB8               fcb       $02                 ;           IF_NOT_JUMP address=1EBB
L1EB9               fcb       $00,$9E             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9E
L1EBB               fcb       $17                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L1EBC               fcb       $80,$88             ;           IF_NOT_JUMP address=1F46
L1EBE               fcb       $0D,$80,$85         ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=133
L1EC1               fcb       $08,$21             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=21(Vines
L1EC3               fcb       $0E,$80,$80         ;               Command_0E_EXECUTE_LIST_WHILE_FAIL size=128
L1EC6               fcb       $0D,$54             ;                 Command_0D_EXECUTE_LIST_WHILE_PASS size=84
L1EC8               fcb       $05,$7F             ;                   Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=7F
L1ECA               fcb       $04                 ;                   Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1ECB               fcb       $2A,$C7,$DE,$DE,$14,$64,$7A,$89,$17,$82,$17,$54 ;                     YOU CLIMB TO THE ROOF.  AS YOU STEP ON THE
L1ED7               fcb       $5E,$38,$A0,$3B,$F4,$4B,$49,$C7,$DE,$66,$17,$D3 ;                     ROOF, IT COLLAPSES.
L1EE3               fcb       $61,$03,$A0,$5F,$BE,$39,$17,$E6,$9E,$D6,$15,$E1 ;                     .
L1EEF               fcb       $14,$FB,$8C,$17,$A7,$5B,$BB ;                     .
L1EF6               fcb       $17,$36,$00         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=36(Jungle) location=00
L1EF9               fcb       $17,$29,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=29(Floor) location=FF
L1EFC               fcb       $17,$2A,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=2A(Exit) location=FF
L1EFF               fcb       $17,$2B,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=2B(Passage) location=FF
L1F02               fcb       $17,$2C,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=2C(Hole) location=FF
L1F05               fcb       $17,$2D,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=2D(Corridor) location=FF
L1F08               fcb       $17,$2E,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=2E(Corner) location=FF
L1F0B               fcb       $17,$31,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=31(Hallway) location=FF
L1F0E               fcb       $17,$34,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=34(Entrance) location=FF
L1F11               fcb       $17,$35,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=35(Tunnel) location=FF
L1F14               fcb       $17,$3A,$FF         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=3A(Ceiling) location=FF
L1F17               fcb       $17,$3C,$00         ;                   Command_17_MOVE_OBJECT_TO_LOCATION object=3C(Object3C) location=00
L1F1A               fcb       $00,$81             ;                   Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=81
L1F1C               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L1F1D               fcb       $28,$4B,$49,$C7,$DE,$DE,$14,$64,$7A,$16,$EE,$DB ;                   AS YOU CLIMB, THE VINE GIVES WAY AND YOU
L1F29               fcb       $72,$10,$CB,$49,$5E,$CF,$7B,$D9,$B5,$3B,$4A,$8E ;                   FALL TO THE GROUND.
L1F35               fcb       $48,$51,$18,$48,$C2,$46,$48,$89,$17,$82,$17,$49 ;                   .
L1F41               fcb       $5E,$07,$B3,$57,$98 ;                   .
L1F46               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1F47               fcb       $02                 ;           IF_NOT_JUMP address=1F4A
L1F48               fcb       $00,$9C             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9C
L1F4A               fcb       $9E,$25,$00         ;   Script number=9E size=0025 data=00
L1F4D               fcb       $03,$11             ;     Data tag=03 size=0011
L1F4F               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$95,$5F ;       YOU ARE AT THE EAST WALL.
L1F5B               fcb       $19,$BC,$46,$48,$2E ;       .
L1F60               fcb       $04,$0F             ;     Data tag=04 size=000F
L1F62               fcb       $0B,$0D             ;         Command_0B_SWITCH size=0D
L1F64               fcb       $0A,$01             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L1F66               fcb       $02                 ;           IF_NOT_JUMP address=1F69
L1F67               fcb       $00,$9D             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9D
L1F69               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1F6A               fcb       $02                 ;           IF_NOT_JUMP address=1F6D
L1F6B               fcb       $00,$9F             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9F
L1F6D               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1F6E               fcb       $02                 ;           IF_NOT_JUMP address=1F71
L1F6F               fcb       $00,$98             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=98
L1F71               fcb       $9F,$26,$00         ;   Script number=9F size=0026 data=00
L1F74               fcb       $03,$12             ;     Data tag=03 size=0012
L1F76               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$47,$B9 ;       YOU ARE AT THE SOUTH WALL.
L1F82               fcb       $53,$BE,$0E,$D0,$9B,$8F ;       .
L1F88               fcb       $04,$0F             ;     Data tag=04 size=000F
L1F8A               fcb       $0B,$0D             ;         Command_0B_SWITCH size=0D
L1F8C               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1F8E               fcb       $02                 ;           IF_NOT_JUMP address=1F91
L1F8F               fcb       $00,$9C             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9C
L1F91               fcb       $03                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1F92               fcb       $02                 ;           IF_NOT_JUMP address=1F95
L1F93               fcb       $00,$9E             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9E
L1F95               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L1F96               fcb       $02                 ;           IF_NOT_JUMP address=1F99
L1F97               fcb       $00,$99             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=99
L1F99               fcb       $A0,$20,$00         ;   Script number=A0 size=0020 data=00
L1F9C               fcb       $03,$14             ;     Data tag=03 size=0014
L1F9E               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$CF,$17,$7B,$B4 ;       YOU ARE IN A VERY SMALL ROOM.
L1FAA               fcb       $E3,$B8,$F3,$8C,$01,$B3,$DB,$95 ;       .
L1FB2               fcb       $04,$07             ;     Data tag=04 size=0007
L1FB4               fcb       $0B,$05             ;         Command_0B_SWITCH size=05
L1FB6               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L1FB8               fcb       $02                 ;           IF_NOT_JUMP address=1FBB
L1FB9               fcb       $00,$90             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=90
L1FBB               fcb       $A1,$2C,$00         ;   Script number=A1 size=002C data=00
L1FBE               fcb       $03,$20             ;     Data tag=03 size=0020
L1FC0               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$5F,$17,$46,$48 ;       YOU ARE IN A SMALL ROOM WITH A SINGLE EXIT
L1FCC               fcb       $39,$17,$DB,$9F,$56,$D1,$03,$71,$5B,$17,$BE,$98 ;       EAST.
L1FD8               fcb       $47,$5E,$96,$D7,$23,$15,$17,$BA ;       .
L1FE0               fcb       $04,$07             ;     Data tag=04 size=0007
L1FE2               fcb       $0B,$05             ;         Command_0B_SWITCH size=05
L1FE4               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L1FE6               fcb       $02                 ;           IF_NOT_JUMP address=1FE9
L1FE7               fcb       $00,$84             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=84
L1FE9               fcb       $A2,$30,$00         ;   Script number=A2 size=0030 data=00
L1FEC               fcb       $03,$18             ;     Data tag=03 size=0018
L1FEE               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$FB,$14,$4B,$B2 ;       YOU ARE IN A DARK DAMP DENSE JUNGLE.
L1FFA               fcb       $4F,$59,$06,$A3,$9D,$61,$4C,$5E,$91,$C5,$FF,$8B ;       .
L2006               fcb       $04,$13             ;     Data tag=04 size=0013
L2008               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L200A               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L200C               fcb       $02                 ;           IF_NOT_JUMP address=200F
L200D               fcb       $00,$A4             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A4
L200F               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L2010               fcb       $02                 ;           IF_NOT_JUMP address=2013
L2011               fcb       $00,$96             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=96
L2013               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L2014               fcb       $02                 ;           IF_NOT_JUMP address=2017
L2015               fcb       $00,$A3             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A3
L2017               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L2018               fcb       $02                 ;           IF_NOT_JUMP address=201B
L2019               fcb       $00,$97             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=97
L201B               fcb       $A3,$30,$00         ;   Script number=A3 size=0030 data=00
L201E               fcb       $03,$18             ;     Data tag=03 size=0018
L2020               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$FF,$14,$97,$9A ;       YOU ARE IN A DENSE DAMP DARK JUNGLE.
L202C               fcb       $FB,$14,$D3,$93,$54,$59,$CC,$83,$91,$C5,$FF,$8B ;       .
L2038               fcb       $04,$13             ;     Data tag=04 size=0013
L203A               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L203C               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L203E               fcb       $02                 ;           IF_NOT_JUMP address=2041
L203F               fcb       $00,$A4             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A4
L2041               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L2042               fcb       $02                 ;           IF_NOT_JUMP address=2045
L2043               fcb       $00,$A2             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A2
L2045               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L2046               fcb       $02                 ;           IF_NOT_JUMP address=2049
L2047               fcb       $00,$96             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=96
L2049               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L204A               fcb       $02                 ;           IF_NOT_JUMP address=204D
L204B               fcb       $00,$97             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=97
L204D               fcb       $A4,$30,$00         ;   Script number=A4 size=0030 data=00
L2050               fcb       $03,$18             ;     Data tag=03 size=0018
L2052               fcb       $C7,$DE,$94,$14,$4B,$5E,$83,$96,$FB,$14,$D3,$93 ;       YOU ARE IN A DAMP DARK DENSE JUNGLE.
L205E               fcb       $54,$59,$C6,$83,$9D,$61,$4C,$5E,$91,$C5,$FF,$8B ;       .
L206A               fcb       $04,$13             ;     Data tag=04 size=0013
L206C               fcb       $0B,$11             ;         Command_0B_SWITCH size=11
L206E               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L2070               fcb       $02                 ;           IF_NOT_JUMP address=2073
L2071               fcb       $00,$A3             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A3
L2073               fcb       $01                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L2074               fcb       $02                 ;           IF_NOT_JUMP address=2077
L2075               fcb       $00,$A2             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A2
L2077               fcb       $02                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L2078               fcb       $02                 ;           IF_NOT_JUMP address=207B
L2079               fcb       $00,$96             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=96
L207B               fcb       $04                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L207C               fcb       $02                 ;           IF_NOT_JUMP address=207F
L207D               fcb       $00,$A3             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A3
L207F               fcb       $A5,$2C,$00         ;   Script number=A5 size=002C data=00
L2082               fcb       $03,$20             ;     Data tag=03 size=0020
L2084               fcb       $C7,$DE,$94,$14,$4B,$5E,$96,$96,$DB,$72,$A5,$B7 ;       YOU ARE IN THE SECRET PASSAGE WHICH LEADS
L2090               fcb       $76,$B1,$DB,$16,$D3,$B9,$9B,$6C,$23,$D1,$13,$54 ;       EAST.
L209C               fcb       $E3,$8B,$0B,$5C,$95,$5F,$9B,$C1 ;       .
L20A4               fcb       $04,$07             ;     Data tag=04 size=0007
L20A6               fcb       $0B,$05             ;         Command_0B_SWITCH size=05
L20A8               fcb       $0A,$03             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L20AA               fcb       $02                 ;           IF_NOT_JUMP address=20AD
L20AB               fcb       $00,$A6             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A6
L20AD               fcb       $A6,$50,$00         ;   Script number=A6 size=0050 data=00
L20B0               fcb       $03,$2C             ;     Data tag=03 size=002C
L20B2               fcb       $C7,$DE,$94,$14,$43,$5E,$16,$BC,$DB,$72,$8E,$61 ;       YOU ARE AT THE END OF THE PASSAGE. THERE IS
L20BE               fcb       $B8,$16,$82,$17,$52,$5E,$65,$49,$77,$47,$56,$F4 ;       A HOLE IN THE CEILING.
L20CA               fcb       $F4,$72,$4B,$5E,$C3,$B5,$A9,$15,$DB,$8B,$83,$7A ;       .
L20D6               fcb       $5F,$BE,$D7,$14,$43,$7A,$CF,$98 ;       .
L20DE               fcb       $04,$1F             ;     Data tag=04 size=001F
L20E0               fcb       $0B,$1D             ;         Command_0B_SWITCH size=1D
L20E2               fcb       $0A,$04             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L20E4               fcb       $02                 ;           IF_NOT_JUMP address=20E7
L20E5               fcb       $00,$A5             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A5
L20E7               fcb       $17                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L20E8               fcb       $05                 ;           IF_NOT_JUMP address=20EE
L20E9               fcb       $0D,$03             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L20EB               fcb       $08,$2C             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=2C(Hole
L20ED               fcb       $91                 ;               CommonCommand_91
L20EE               fcb       $36                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L20EF               fcb       $05                 ;           IF_NOT_JUMP address=20F5
L20F0               fcb       $0D,$03             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L20F2               fcb       $08,$2C             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=2C(Hole
L20F4               fcb       $91                 ;               CommonCommand_91
L20F5               fcb       $37                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=37 phrase="37: CLIMB OUT   *          *       "
L20F6               fcb       $05                 ;           IF_NOT_JUMP address=20FC
L20F7               fcb       $0D,$03             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L20F9               fcb       $08,$2C             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=2C(Hole
L20FB               fcb       $91                 ;               CommonCommand_91
L20FC               fcb       $33                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=33 phrase="??"
L20FD               fcb       $01                 ;           IF_NOT_JUMP address=20FF
L20FE               fcb       $91                 ;             CommonCommand_91
; ENDOF 1523

;##ObjectData
; Objects are referenced by index in this list with the first object being "Object 1".
; The first three data bytes are as follows AA BB CC:
;   AA = location. If >80 then it is a room. If <80 then it is held by an object.
;   BB = score points
;   CC = --CPAXOL
;    C=1 if object can be carried
;    P=1 if object is a person;
;    A=1 if open/close-able
;    X=1 if lock/unlock-able
;    O=1 if closed
;    L=1 if locked
;
; Objects can have various fields tagged as follows:
;   01 = list of adjectives (size+bytes) not used in RAAKATU
;   02 = short name (packed string)
;   03 = long description (packed string)
;   04 (never used)
;   05 (never used)
;   06 = command handling if object is second noun (script)
;   07 = command handling if object is first noun (script)
;   08 = turn-script executed for objects turn in game (script)
;   09 = hitpoint information (2 bytess) AA BB. AA=max hit points  BB=current hit points
;   0A = script executed with killed (script)
;   0B = script executed if command is given to object (script) not used in RAAKATU
;
L20FF               fcb       $00,$91,$3A         ; Number=00 size=113A
; Object_01 Object1
L2102               fcb       $01,$03             ;   Number=01 size=0003
L2104               fcb       $00,$00,$00         ;     room=00 scorePoints=00 bits=00 *
; Object_02 Object2
L2107               fcb       $03,$03             ;   Number=03 size=0003
L2109               fcb       $00,$00,$00         ;     room=00 scorePoints=00 bits=00 *
; Object_03 Rug
L210C               fcb       $06,$48             ;   Number=06 size=0048
L210E               fcb       $82,$00,$80         ;     room=82 scorePoints=00 bits=80 u.......
L2111               fcb       $02                 ;     02 SHORT NAME
L2112               fcb       $02,$E9,$B3         ;       RUG
L2115               fcb       $07,$3F             ;     07 COMMAND HANDLING IF FIRST NOUN
L2117               fcb       $0B,$3D             ;       Command_0B_SWITCH size=3D
L2119               fcb       $0A,$0C             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=0C phrase="0C: LOOK UNDER  *          u......."
L211B               fcb       $01                 ;         IF_NOT_JUMP address=211D
L211C               fcb       $8C                 ;           CommonCommand_8C
L211D               fcb       $36                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L211E               fcb       $01                 ;         IF_NOT_JUMP address=2120
L211F               fcb       $8A                 ;           CommonCommand_8A
L2120               fcb       $33                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=33 phrase="??"
L2121               fcb       $01                 ;         IF_NOT_JUMP address=2123
L2122               fcb       $8A                 ;           CommonCommand_8A
L2123               fcb       $34                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=34 phrase="34: JUMP OVER   *          u......."
L2124               fcb       $01                 ;         IF_NOT_JUMP address=2126
L2125               fcb       $8A                 ;           CommonCommand_8A
L2126               fcb       $35                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=35 phrase="??"
L2127               fcb       $01                 ;         IF_NOT_JUMP address=2129
L2128               fcb       $8B                 ;           CommonCommand_8B
L2129               fcb       $2D                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=2D phrase="2D: PULL UP     *          u......."
L212A               fcb       $01                 ;         IF_NOT_JUMP address=212C
L212B               fcb       $8C                 ;           CommonCommand_8C
L212C               fcb       $26                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=26 phrase="26: GO AROUND   *          u......."
L212D               fcb       $28                 ;         IF_NOT_JUMP address=2156
L212E               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L212F               fcb       $26,$C7,$DE,$D3,$14,$E6,$96,$16,$EE,$DB,$72,$E9 ;             YOU CAN'T, THE RUG STRETCHES ALL THE WAY
L213B               fcb       $B3,$66,$17,$76,$B1,$1F,$54,$C3,$B5,$F3,$8C,$5F ;             ACROSS THE ROOM.
L2147               fcb       $BE,$F3,$17,$43,$DB,$B9,$55,$CB,$B9,$5F,$BE,$39 ;             .
L2153               fcb       $17,$FF,$9F         ;             .
; Object_04 DoorCarvings
L2156               fcb       $09,$5E             ;   Number=09 size=005E
L2158               fcb       $82,$00,$84         ;     room=82 scorePoints=00 bits=84 u....X..
L215B               fcb       $02                 ;     02 SHORT NAME
L215C               fcb       $03,$81,$5B,$52     ;       DOOR
L2160               fcb       $07,$54             ;     07 COMMAND HANDLING IF FIRST NOUN
L2162               fcb       $0E,$52             ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=82
L2164               fcb       $0D,$22             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=34
L2166               fcb       $0A,$08             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2168               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2169               fcb       $1E,$5F,$BE,$D3,$14,$13,$B4,$C5,$98,$C0,$16,$82 ;             THE CARVINGS ON THE DOOR SAY, "DO NOT
L2175               fcb       $17,$46,$5E,$44,$A0,$53,$17,$B3,$E0,$49,$1B,$99 ;             ENTER."
L2181               fcb       $16,$07,$BC,$BF,$9A,$1C,$B5 ;             .
L2188               fcb       $0D,$2C             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=44
L218A               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L218B               fcb       $0A,$0B             ;             Command_0A_COMPARE_TO_PHRASE_FORM val=0B phrase="0B: LOOK AT     *          u......."
L218D               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L218E               fcb       $27,$C7,$DE,$C6,$22,$9B,$15,$5B,$CA,$6B,$BF,$2B ;             YOU'LL HAVE TO GO TO THE EAST SIDE OF THE
L219A               fcb       $6E,$6B,$BF,$5F,$BE,$23,$15,$F3,$B9,$46,$B8,$51 ;             ROOM TO DO THAT.
L21A6               fcb       $5E,$96,$64,$DB,$72,$01,$B3,$56,$90,$C6,$9C,$D6 ;             .
L21B2               fcb       $9C,$56,$72,$2E     ;             .
; Object_05 Food
L21B6               fcb       $0C,$2A             ;   Number=0C size=002A
L21B8               fcb       $84,$00,$A0         ;     room=84 scorePoints=00 bits=A0 u.C.....
L21BB               fcb       $03                 ;     03 DESCRIPTION
L21BC               fcb       $0D,$5F,$BE,$5B,$B1,$4B,$7B,$01,$68,$0A,$58,$2F ;       THERE IS FOOD HERE.
L21C8               fcb       $62,$2E             ;       .
L21CA               fcb       $07,$11             ;     07 COMMAND HANDLING IF FIRST NOUN
L21CC               fcb       $0D,$0F             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=15
L21CE               fcb       $0A,$15             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L21D0               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L21D1               fcb       $04,$F4,$4F,$AB,$A2 ;           BURP!
L21D6               fcb       $17,$05,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=05(Food) location=00
L21D9               fcb       $1C,$1D             ;         Command_1C_SET_VAR_OBJECT object=1D (USER)
L21DB               fcb       $23,$0F             ;         Command_23_HEAL_VAR_OBJECT value=0F
L21DD               fcb       $02                 ;     02 SHORT NAME
L21DE               fcb       $03,$01,$68,$44     ;       FOOD
; Object_06 StatueEast
L21E2               fcb       $0D,$2A             ;   Number=0D size=002A
L21E4               fcb       $88,$00,$80         ;     room=88 scorePoints=00 bits=80 u.......
L21E7               fcb       $02                 ;     02 SHORT NAME
L21E8               fcb       $04,$FB,$B9,$67,$C0 ;       STATUE
L21ED               fcb       $07,$05             ;     07 COMMAND HANDLING IF FIRST NOUN
L21EF               fcb       $0D,$03             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L21F1               fcb       $0A,$12             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L21F3               fcb       $8D                 ;         CommonCommand_8D
L21F4               fcb       $03                 ;     03 DESCRIPTION
L21F5               fcb       $18,$5F,$BE,$66,$17,$8F,$49,$4B,$5E,$C8,$B5,$DB ;       THE STATUE IS FACING THE EAST DOOR.
L2201               fcb       $46,$AB,$98,$5F,$BE,$23,$15,$F3,$B9,$81,$5B,$1B ;       .
L220D               fcb       $B5                 ;       .
; Object_07 StatueWest
L220E               fcb       $0D,$2A             ;   Number=0D size=002A
L2210               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L2213               fcb       $02                 ;     02 SHORT NAME
L2214               fcb       $04,$FB,$B9,$67,$C0 ;       STATUE
L2219               fcb       $07,$05             ;     07 COMMAND HANDLING IF FIRST NOUN
L221B               fcb       $0D,$03             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L221D               fcb       $0A,$12             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L221F               fcb       $8D                 ;         CommonCommand_8D
L2220               fcb       $03                 ;     03 DESCRIPTION
L2221               fcb       $18,$5F,$BE,$66,$17,$8F,$49,$4B,$5E,$C8,$B5,$DB ;       THE STATUE IS FACING THE WEST DOOR.
L222D               fcb       $46,$AB,$98,$5F,$BE,$F7,$17,$F3,$B9,$81,$5B,$1B ;       .
L2239               fcb       $B5                 ;       .
; Object_08 GoldRing
L223A               fcb       $12,$44             ;   Number=12 size=0044
L223C               fcb       $8C,$05,$A4         ;     room=8C scorePoints=05 bits=A4 u.C..X..
L223F               fcb       $03                 ;     03 DESCRIPTION
L2240               fcb       $14,$54,$45,$91,$7A,$B8,$16,$53,$15,$75,$98,$09 ;       A RING OF FINEST GOLD IS HERE.
L224C               fcb       $BC,$BE,$9F,$D5,$15,$9F,$15,$7F,$B1 ;       .
L2255               fcb       $02                 ;     02 SHORT NAME
L2256               fcb       $06,$3E,$6E,$14,$58,$91,$7A ;       GOLD RING
L225D               fcb       $07,$21             ;     07 COMMAND HANDLING IF FIRST NOUN
L225F               fcb       $0D,$1F             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=31
L2261               fcb       $0A,$08             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2263               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2264               fcb       $1B,$5F,$BE,$D0,$15,$64,$B7,$EE,$7A,$C0,$7A,$2F ;           THE INSCRIPTION READS, "RING OF MOTION."
L2270               fcb       $17,$0D,$47,$FC,$ED,$10,$B2,$D1,$6A,$8F,$64,$03 ;           .
L227C               fcb       $A1,$27,$A0,$22     ;           .
; Object_09 Sword
L2280               fcb       $0E,$42             ;   Number=0E size=0042
L2282               fcb       $A1,$00,$E4         ;     room=A1 scorePoints=00 bits=E4 uvC..X..
L2285               fcb       $03                 ;     03 DESCRIPTION
L2286               fcb       $19,$5F,$BE,$5B,$B1,$4B,$7B,$4E,$45,$31,$49,$55 ;       THERE IS A LARGE SWORD LAYING NEARBY.
L2292               fcb       $5E,$44,$D2,$0E,$58,$4B,$4A,$AB,$98,$63,$98,$03 ;       .
L229E               fcb       $B1,$2E             ;       .
L22A0               fcb       $07,$18             ;     07 COMMAND HANDLING IF FIRST NOUN
L22A2               fcb       $0D,$16             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=22
L22A4               fcb       $0A,$08             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L22A6               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L22A7               fcb       $12,$2C,$1D,$5F,$A0,$D3,$B3,$B8,$16,$43,$16,$57 ;           "PROPERTY OF LIEYUCHNEBST"
L22B3               fcb       $63,$28,$54,$BD,$5F,$23,$BC ;           .
L22BA               fcb       $02                 ;     02 SHORT NAME
L22BB               fcb       $08,$54,$8B,$9B,$6C,$81,$BA,$33,$B1 ;       LARGE SWORD
; Object_0A StoneGargoyle
L22C4               fcb       $0F,$6B             ;   Number=0F size=006B
L22C6               fcb       $8E,$00,$80         ;     room=8E scorePoints=00 bits=80 u.......
L22C9               fcb       $03                 ;     03 DESCRIPTION
L22CA               fcb       $34,$5F,$BE,$5B,$B1,$4B,$7B,$4A,$45,$FF,$78,$35 ;       THERE IS A HIDEOUS STONE GARGOYLE PERCHED ON
L22D6               fcb       $A1,$66,$17,$0F,$A0,$73,$15,$C1,$B1,$3F,$DE,$DF ;       A LEDGE ABOVE THE NORTH PASSAGE.
L22E2               fcb       $16,$1A,$B1,$F3,$5F,$03,$A0,$4E,$45,$01,$60,$43 ;       .
L22EE               fcb       $5E,$08,$4F,$56,$5E,$DB,$72,$04,$9A,$53,$BE,$55 ;       .
L22FA               fcb       $A4,$09,$B7,$DB,$63 ;       .
L22FF               fcb       $07,$24             ;     07 COMMAND HANDLING IF FIRST NOUN
L2301               fcb       $0D,$22             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=34
L2303               fcb       $0A,$0B             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=0B phrase="0B: LOOK AT     *          u......."
L2305               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2306               fcb       $1E,$5F,$BE,$5B,$B1,$EA,$48,$94,$5F,$D6,$B5,$C4 ;           THERE APPEARS TO BE DRIED BLOOD ON HIS
L2312               fcb       $9C,$46,$5E,$07,$B2,$04,$58,$81,$8D,$11,$58,$8A ;           CLAWS!
L231E               fcb       $96,$4B,$7B,$BB,$54,$C9,$D2 ;           .
L2325               fcb       $02                 ;     02 SHORT NAME
L2326               fcb       $0A,$09,$BA,$5B,$98,$14,$6C,$4B,$6E,$DB,$8B ;       STONE GARGOYLE
; Object_0B AlterA
L2331               fcb       $22,$58             ;   Number=22 size=0058
L2333               fcb       $95,$00,$80         ;     room=95 scorePoints=00 bits=80 u.......
L2336               fcb       $03                 ;     03 DESCRIPTION
L2337               fcb       $32,$68,$4D,$AF,$A0,$51,$18,$55,$C2,$50,$BD,$0B ;       BEFORE YOU STANDS AN ALTAR, STAINED WITH THE
L2343               fcb       $5C,$83,$48,$4E,$48,$46,$49,$66,$17,$D0,$47,$F3 ;       BLOOD OF COUNTLESS SACRIFICES.
L234F               fcb       $5F,$56,$D1,$16,$71,$DB,$72,$89,$4E,$73,$9E,$C3 ;       .
L235B               fcb       $9E,$47,$55,$C6,$9A,$65,$62,$53,$17,$B3,$55,$05 ;       .
L2367               fcb       $67,$6F,$62         ;       .
L236A               fcb       $07,$10             ;     07 COMMAND HANDLING IF FIRST NOUN
L236C               fcb       $0B,$0E             ;       Command_0B_SWITCH size=0E
L236E               fcb       $0A,$12             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L2370               fcb       $01                 ;         IF_NOT_JUMP address=2372
L2371               fcb       $8E                 ;           CommonCommand_8E
L2372               fcb       $0C                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=0C phrase="0C: LOOK UNDER  *          u......."
L2373               fcb       $01                 ;         IF_NOT_JUMP address=2375
L2374               fcb       $8E                 ;           CommonCommand_8E
L2375               fcb       $38                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=38 phrase="38: CLIMB UNDER *          u......."
L2376               fcb       $05                 ;         IF_NOT_JUMP address=237C
L2377               fcb       $0D,$03             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L2379               fcb       $00,$A5             ;             Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A5
L237B               fcb       $90                 ;             CommonCommand_90
L237C               fcb       $02                 ;     02 SHORT NAME
L237D               fcb       $0D,$89,$4E,$73,$9E,$FB,$B9,$8F,$7A,$03,$58,$3B ;       BLOOD STAINED ALTAR
L2389               fcb       $8E,$52             ;       .
; Object_0C Idol
L238B               fcb       $23,$2F             ;   Number=23 size=002F
L238D               fcb       $95,$05,$A0         ;     room=95 scorePoints=05 bits=A0 u.C.....
L2390               fcb       $03                 ;     03 DESCRIPTION
L2391               fcb       $20,$49,$45,$BE,$9F,$83,$61,$09,$79,$15,$8A,$50 ;       A GOLDEN IDOL STANDS IN THE CENTER OF THE
L239D               fcb       $BD,$0B,$5C,$83,$7A,$5F,$BE,$D7,$14,$BF,$9A,$91 ;       ROOM.
L23A9               fcb       $AF,$96,$64,$DB,$72,$01,$B3,$DB,$95 ;       .
L23B2               fcb       $02                 ;     02 SHORT NAME
L23B3               fcb       $08,$3E,$6E,$F0,$59,$C6,$15,$B3,$9F ;       GOLDEN IDOL
; Object_0D BronzeGates
L23BC               fcb       $27,$80,$9A         ;   Number=27 size=009A
L23BF               fcb       $9C,$00,$80         ;     room=9C scorePoints=00 bits=80 u.......
L23C2               fcb       $03                 ;     03 DESCRIPTION
L23C3               fcb       $34,$AF,$6E,$73,$49,$79,$4F,$AF,$9B,$73,$15,$F5 ;       GREAT BRONZE GATES ENGRAVED WITH IMAGES OF
L23CF               fcb       $BD,$30,$15,$AB,$6E,$66,$CA,$FB,$17,$53,$BE,$63 ;       SERPENTS STAND SILENTLY BEFORE YOU.
L23DB               fcb       $7A,$B5,$6C,$B8,$16,$57,$17,$1F,$B3,$CD,$9A,$66 ;       .
L23E7               fcb       $17,$8E,$48,$5B,$17,$F0,$8B,$13,$BF,$AF,$14,$04 ;       .
L23F3               fcb       $68,$5B,$5E,$3F,$A1 ;       .
L23F8               fcb       $07,$55             ;     07 COMMAND HANDLING IF FIRST NOUN
L23FA               fcb       $0B,$53             ;       Command_0B_SWITCH size=53
L23FC               fcb       $0A,$11             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=11 phrase="11: OPEN *      u.......   *       "
L23FE               fcb       $20                 ;         IF_NOT_JUMP address=241F
L23FF               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2400               fcb       $1E,$5F,$BE,$73,$15,$F5,$BD,$94,$14,$4E,$5E,$5D ;             THE GATES ARE LOCKED, YOU CAN NOT OPEN THEM.
L240C               fcb       $9E,$16,$60,$51,$18,$45,$C2,$83,$48,$06,$9A,$C2 ;
L2418               fcb       $16,$83,$61,$5F,$BE,$DB,$95 ;             .
L241F               fcb       $36                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L2420               fcb       $10                 ;         IF_NOT_JUMP address=2431
L2421               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2422               fcb       $0E,$5F,$BE,$73,$15,$F5,$BD,$94,$14,$45,$5E,$85 ;             THE GATES ARE CLOSED.
L242E               fcb       $8D,$17,$60         ;             .
L2431               fcb       $17                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L2432               fcb       $19                 ;         IF_NOT_JUMP address=244C
L2433               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2434               fcb       $17,$5F,$BE,$73,$15,$F5,$BD,$94,$14,$56,$5E,$2B ;             THE GATES ARE TOO SMOOTH TO CLIMB.
L2440               fcb       $A0,$F1,$B8,$02,$A1,$89,$17,$DE,$14,$64,$7A,$2E ;             .
L244C               fcb       $34                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=34 phrase="34: JUMP OVER   *          u......."
L244D               fcb       $01                 ;         IF_NOT_JUMP address=244F
L244E               fcb       $89                 ;           CommonCommand_89
L244F               fcb       $02                 ;     02 SHORT NAME
L2450               fcb       $08,$79,$4F,$AF,$9B,$73,$15,$F5,$BD ;       BRONZE GATES
; Object_0E UnpulledLever
L2459               fcb       $16,$59             ;   Number=16 size=0059
L245B               fcb       $91,$00,$A0         ;     room=91 scorePoints=00 bits=A0 u.C.....
L245E               fcb       $02                 ;     02 SHORT NAME
L245F               fcb       $04,$F8,$8B,$23,$62 ;       LEVER
L2464               fcb       $03                 ;     03 DESCRIPTION
L2465               fcb       $16,$44,$45,$EF,$60,$AE,$D0,$F3,$5F,$F8,$8B,$23 ;       A BEJEWELED LEVER IS ON ONE WALL.
L2471               fcb       $62,$4B,$7B,$03,$A0,$0F,$A0,$F3,$17,$17,$8D ;       .
L247C               fcb       $07,$36             ;     07 COMMAND HANDLING IF FIRST NOUN
L247E               fcb       $0D,$34             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=52
L2480               fcb       $0A,$12             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L2482               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2483               fcb       $2F,$56,$45,$D2,$B0,$09,$15,$A3,$A0,$5F,$A0,$8B ;           A TRAP DOOR OPENS ABOVE YOU.  GOLD DUST
L248F               fcb       $9A,$B9,$46,$5B,$CA,$C7,$DE,$3B,$F4,$3E,$6E,$06 ;           FILLS THE ROOM AND DROWNS YOU.
L249B               fcb       $58,$66,$C6,$53,$15,$0D,$8D,$82,$17,$54,$5E,$3F ;           .
L24A7               fcb       $A0,$90,$14,$06,$58,$09,$B3,$8B,$9A,$C7,$DE,$2E ;           .
L24B3               fcb       $81                 ;         CommonCommand_81
; Object_0F PulledLever
L24B4               fcb       $16,$42             ;   Number=16 size=0042
L24B6               fcb       $00,$05,$A0         ;     room=00 scorePoints=05 bits=A0 u.C.....
L24B9               fcb       $03                 ;     03 DESCRIPTION
L24BA               fcb       $12,$44,$45,$EF,$60,$AE,$D0,$F3,$5F,$F8,$8B,$23 ;       A BEJEWELED LEVER IS HERE.
L24C6               fcb       $62,$4B,$7B,$F4,$72,$DB,$63 ;       .
L24CD               fcb       $02                 ;     02 SHORT NAME
L24CE               fcb       $0A,$6C,$4D,$F7,$62,$E6,$8B,$3F,$16,$74,$CA ;       BEJEWELED LEVER
L24D9               fcb       $07,$1D             ;     07 COMMAND HANDLING IF FIRST NOUN
L24DB               fcb       $0D,$1B             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=27
L24DD               fcb       $0A,$12             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L24DF               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L24E0               fcb       $17,$5F,$BE,$3F,$16,$74,$CA,$D3,$14,$90,$96,$CE ;           THE LEVER CAN NO LONGER BE PULLED.
L24EC               fcb       $9C,$11,$A0,$23,$62,$5B,$4D,$6E,$A7,$E6,$8B,$2E ;           .
; Object_10 LeverPlaque
L24F8               fcb       $18,$80,$C5         ;   Number=18 size=00C5
L24FB               fcb       $91,$00,$84         ;     room=91 scorePoints=00 bits=84 u....X..
L24FE               fcb       $07,$80,$98         ;     07 COMMAND HANDLING IF FIRST NOUN
L2501               fcb       $0D,$80,$95         ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=149
L2504               fcb       $0A,$08             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2506               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2507               fcb       $80,$90,$9E,$C5,$BE,$9F,$33,$17,$1F,$54,$CE,$B5 ;           UNTOLD RICHES LIE WITHIN REACH, HERE- TO ANY
L2513               fcb       $1B,$79,$56,$D1,$90,$73,$2F,$17,$DA,$46,$0A,$EE ;           KNOWING, LIVING CREATURE. BE WARY THOUGH, NO
L251F               fcb       $2F,$62,$D6,$E7,$C3,$9C,$7B,$9B,$19,$87,$50,$D1 ;           MATTER WHAT THY CREED, THAT THOU HARNESS AND
L252B               fcb       $33,$70,$98,$8C,$91,$7A,$E4,$14,$96,$5F,$2F,$C6 ;           LIMIT THY POWERFUL GREED.  PULL THE LEVER TO
L2537               fcb       $44,$F4,$59,$5E,$43,$49,$82,$17,$29,$A1,$73,$76 ;           GAIN THY WEALTH, BE PREPARED TO ...
L2543               fcb       $EB,$99,$96,$91,$F4,$BD,$FA,$17,$73,$49,$73,$BE ;           .
L254F               fcb       $E4,$14,$26,$60,$16,$EE,$56,$72,$82,$17,$1B,$A1 ;           .
L255B               fcb       $54,$72,$75,$98,$C3,$B5,$33,$98,$8F,$8C,$73,$7B ;           .
L2567               fcb       $73,$BE,$E9,$16,$B4,$D0,$EE,$68,$84,$15,$26,$60 ;           .
L2573               fcb       $3B,$F4,$6E,$A7,$16,$8A,$DB,$72,$F8,$8B,$23,$62 ;           .
L257F               fcb       $6B,$BF,$0B,$6C,$96,$96,$FB,$75,$A3,$D0,$42,$8E ;           .
L258B               fcb       $04,$EE,$52,$5E,$72,$B1,$2F,$49,$16,$58,$DF,$9C ;           .
L2597               fcb       $DB,$F9             ;           .
L2599               fcb       $03                 ;     03 DESCRIPTION
L259A               fcb       $1F,$5F,$BE,$5B,$B1,$4B,$7B,$52,$45,$53,$8B,$1B ;       THERE IS A PLAQUE ON THE WALL ABOVE THE
L25A6               fcb       $C4,$03,$A0,$5F,$BE,$F3,$17,$F3,$8C,$B9,$46,$5B ;       LEVER.
L25B2               fcb       $CA,$5F,$BE,$3F,$16,$74,$CA,$2E ;       .
L25BA               fcb       $02                 ;     02 SHORT NAME
L25BB               fcb       $04,$FB,$A5,$A7,$AD ;       PLAQUE
; Object_11 UnlitCandle
L25C0               fcb       $19,$6F             ;   Number=19 size=006F
L25C2               fcb       $92,$00,$A8         ;     room=92 scorePoints=00 bits=A8 u.C.A...
L25C5               fcb       $03                 ;     03 DESCRIPTION
L25C6               fcb       $10,$45,$45,$8E,$48,$DB,$8B,$4B,$7B,$83,$7A,$5F ;       A CANDLE IS IN THE ROOM.
L25D2               fcb       $BE,$39,$17,$FF,$9F ;       .
L25D7               fcb       $02                 ;     02 SHORT NAME
L25D8               fcb       $04,$10,$53,$FF,$5A ;       CANDLE
L25DD               fcb       $07,$52             ;     07 COMMAND HANDLING IF FIRST NOUN
L25DF               fcb       $0B,$50             ;       Command_0B_SWITCH size=50
L25E1               fcb       $0A,$14             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=14 phrase="14: LIGHT WITH  u...A...   u...A..."
L25E3               fcb       $34                 ;         IF_NOT_JUMP address=2618
L25E4               fcb       $0E,$32             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=50
L25E6               fcb       $0D,$2F             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=47
L25E8               fcb       $09,$14             ;               Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=14(LitLamp
L25EA               fcb       $1E,$11,$12         ;               Command_1E_SWAP_OBJECTS objectA=11(UnlitCandle) objectB=12(LitCandle)
L25ED               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L25EE               fcb       $28,$5F,$BE,$D3,$14,$46,$98,$4B,$5E,$D0,$B5,$6B ;                 THE CANDLE IS NOW BURNING, A SWEET SCENT
L25FA               fcb       $A1,$F4,$4F,$10,$99,$33,$70,$55,$45,$A7,$D0,$15 ;                 PERMEATES THE ROOM.
L2606               fcb       $BC,$B0,$53,$12,$BC,$37,$62,$96,$5F,$4B,$62,$5F ;                 .
L2612               fcb       $BE,$39,$17,$FF,$9F ;                 .
L2617               fcb       $88                 ;             CommonCommand_88
L2618               fcb       $15                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L2619               fcb       $17                 ;         IF_NOT_JUMP address=2631
L261A               fcb       $0D,$15             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=21
L261C               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L261D               fcb       $12,$55,$BD,$F5,$BD,$F3,$17,$1E,$DA,$D6,$15,$D2 ;               TASTES WAXY, ITS POISONOUS!
L2629               fcb       $B5,$55,$9F,$19,$A0,$49,$C6 ;               .
L2630               fcb       $81                 ;             CommonCommand_81
; Object_12 LitCandle
L2631               fcb       $19,$80,$C6         ;   Number=19 size=00C6
L2634               fcb       $00,$00,$A8         ;     room=00 scorePoints=00 bits=A8 u.C.A...
L2637               fcb       $03                 ;     03 DESCRIPTION
L2638               fcb       $12,$45,$45,$8E,$48,$DB,$8B,$4B,$7B,$F4,$4F,$10 ;       A CANDLE IS BURNING DIMLY.
L2644               fcb       $99,$C6,$6A,$6E,$7A,$DB,$E0 ;       .
L264B               fcb       $02                 ;     02 SHORT NAME
L264C               fcb       $0A,$F4,$4F,$10,$99,$C5,$6A,$8E,$48,$DB,$8B ;       BURNING CANDLE
L2657               fcb       $07,$59             ;     07 COMMAND HANDLING IF FIRST NOUN
L2659               fcb       $0E,$57             ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=87
L265B               fcb       $0D,$1C             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=28
L265D               fcb       $0E,$04             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=4
L265F               fcb       $0A,$13             ;             Command_0A_COMPARE_TO_PHRASE_FORM val=13 phrase="??"
L2661               fcb       $0A,$14             ;             Command_0A_COMPARE_TO_PHRASE_FORM val=14 phrase="14: LIGHT WITH  u...A...   u...A..."
L2663               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2664               fcb       $14,$5F,$BE,$D3,$14,$46,$98,$4B,$5E,$C3,$B5,$EF ;             THE CANDLE IS ALREADY BURNING.
L2670               fcb       $8D,$13,$47,$BF,$14,$D3,$B2,$CF,$98 ;             .
L2679               fcb       $0D,$19             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=25
L267B               fcb       $0A,$16             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=16 phrase="16: DROP OUT    *          u...A..."
L267D               fcb       $1E,$11,$12         ;           Command_1E_SWAP_OBJECTS objectA=11(UnlitCandle) objectB=12(LitCandle)
L2680               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2681               fcb       $12,$5F,$BE,$D3,$14,$46,$98,$4B,$5E,$C7,$B5,$43 ;             THE CANDLE IS EXTINGUISHED.
L268D               fcb       $D9,$C7,$98,$5A,$7B,$17,$60 ;             .
L2694               fcb       $0D,$1C             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=28
L2696               fcb       $0A,$15             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L2698               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2699               fcb       $18,$C7,$DE,$2F,$17,$46,$48,$55,$DB,$87,$74,$B3 ;             YOU REALLY SHOULD PUT IT OUT FIRST.
L26A5               fcb       $8B,$76,$A7,$D6,$15,$C7,$16,$08,$BC,$3D,$7B,$9B ;             .
L26B1               fcb       $C1                 ;             .
L26B2               fcb       $08,$46             ;     08 TURN SCRIPT
L26B4               fcb       $0D,$44             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=68
L26B6               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L26B7               fcb       $24,$5F,$BE,$43,$16,$2E,$6D,$5C,$15,$DB,$9F,$5F ;           THE LIGHT FROM THE CANDLE SEEMS TO BE
L26C3               fcb       $BE,$D3,$14,$46,$98,$55,$5E,$2F,$60,$D6,$B5,$C4 ;           GROWING DIMMER.
L26CF               fcb       $9C,$49,$5E,$09,$B3,$91,$7A,$03,$15,$67,$93,$1B ;           .
L26DB               fcb       $B5                 ;           .
L26DC               fcb       $0B,$1C             ;         Command_0B_SWITCH size=1C
L26DE               fcb       $01,$1D             ;           Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L26E0               fcb       $07                 ;           IF_NOT_JUMP address=26E8
L26E1               fcb       $0D,$05             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L26E3               fcb       $1C,$1D             ;               Command_1C_SET_VAR_OBJECT object=1D (USER)
L26E5               fcb       $1D,$14             ;               Command_1D_ATTACK_OBJECT damage=14
L26E7               fcb       $0C                 ;               Command_0C_FAIL
L26E8               fcb       $1E                 ;           Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1E(LiveGargoyle)
L26E9               fcb       $07                 ;           IF_NOT_JUMP address=26F1
L26EA               fcb       $0D,$05             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L26EC               fcb       $1C,$1E             ;               Command_1C_SET_VAR_OBJECT object=1E (LiveGargoyle)
L26EE               fcb       $1D,$32             ;               Command_1D_ATTACK_OBJECT damage=32
L26F0               fcb       $0C                 ;               Command_0C_FAIL
L26F1               fcb       $15                 ;           Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=15(LiveSerpent)
L26F2               fcb       $07                 ;           IF_NOT_JUMP address=26FA
L26F3               fcb       $0D,$05             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L26F5               fcb       $1C,$15             ;               Command_1C_SET_VAR_OBJECT object=15 (LiveSerpent)
L26F7               fcb       $1D,$0F             ;               Command_1D_ATTACK_OBJECT damage=0F
L26F9               fcb       $0C                 ;               Command_0C_FAIL
; Object_13 CrypticRunes
L26FA               fcb       $18,$80,$84         ;   Number=18 size=0084
L26FD               fcb       $92,$00,$84         ;     room=92 scorePoints=00 bits=84 u....X..
L2700               fcb       $07,$5B             ;     07 COMMAND HANDLING IF FIRST NOUN
L2702               fcb       $0D,$59             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=89
L2704               fcb       $0A,$08             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2706               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2707               fcb       $55,$9E,$7A,$D6,$9C,$DB,$72,$70,$C0,$6E,$98,$30 ;           INTO THE TUNNEL ENTERS THE SEEKER, BRAVELY
L2713               fcb       $15,$F4,$BD,$D6,$B5,$DB,$72,$A7,$B7,$B4,$85,$04 ;           AND WISELY HE GOES. FOR HE WILL RECOGNIZE
L271F               fcb       $EE,$D8,$B0,$53,$61,$90,$14,$19,$58,$57,$7B,$FB ;           THE REAPER, AS THE LIGHT BEFORE HIM GLOWS.
L272B               fcb       $8E,$DB,$72,$37,$6E,$5B,$BB,$04,$68,$9F,$15,$FB ;           .
L2737               fcb       $17,$F3,$8C,$65,$B1,$00,$9F,$6F,$7C,$82,$17,$54 ;           .
L2743               fcb       $5E,$92,$5F,$46,$62,$95,$14,$82,$17,$4E,$5E,$7A ;           .
L274F               fcb       $79,$04,$BC,$59,$60,$5B,$B1,$8F,$73,$7E,$15,$85 ;           .
L275B               fcb       $A1,$2E             ;           .
L275D               fcb       $03                 ;     03 DESCRIPTION
L275E               fcb       $1C,$5F,$BE,$5B,$B1,$2F,$49,$E4,$14,$EE,$DE,$CB ;       THERE ARE CRYPTIC RUNES ABOVE THE TUNNEL.
L276A               fcb       $78,$F0,$B3,$4B,$62,$B9,$46,$5B,$CA,$5F,$BE,$8F ;       .
L2776               fcb       $17,$CF,$99,$9B,$8F ;       .
L277B               fcb       $02                 ;     02 SHORT NAME
L277C               fcb       $04,$F0,$B3,$4B,$62 ;       RUNES
; Object_14 LitLamp
L2781               fcb       $1B,$80,$B5         ;   Number=1B size=00B5
L2784               fcb       $A0,$00,$AC         ;     room=A0 scorePoints=00 bits=AC u.C.AX..
L2787               fcb       $03                 ;     03 DESCRIPTION
L2788               fcb       $14,$5F,$BE,$5B,$B1,$4B,$7B,$44,$45,$38,$C6,$91 ;       THERE IS A BURNING LAMP HERE.
L2794               fcb       $7A,$3B,$16,$D3,$93,$F4,$72,$DB,$63 ;       .
L279D               fcb       $07,$80,$8F         ;     07 COMMAND HANDLING IF FIRST NOUN
L27A0               fcb       $0E,$80,$8C         ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=140
L27A3               fcb       $0D,$1B             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=27
L27A5               fcb       $0E,$04             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=4
L27A7               fcb       $0A,$13             ;             Command_0A_COMPARE_TO_PHRASE_FORM val=13 phrase="??"
L27A9               fcb       $0A,$14             ;             Command_0A_COMPARE_TO_PHRASE_FORM val=14 phrase="14: LIGHT WITH  u...A...   u...A..."
L27AB               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L27AC               fcb       $13,$5F,$BE,$3B,$16,$D3,$93,$4B,$7B,$4C,$48,$86 ;             THE LAMP IS ALREADY BURNING.
L27B8               fcb       $5F,$44,$DB,$38,$C6,$91,$7A,$2E ;             .
L27C0               fcb       $0B,$6D             ;         Command_0B_SWITCH size=6D
L27C2               fcb       $0A,$16             ;           Command_0A_COMPARE_TO_PHRASE_FORM val=16 phrase="16: DROP OUT    *          u...A..."
L27C4               fcb       $12                 ;           IF_NOT_JUMP address=27D7
L27C5               fcb       $0D,$10             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=16
L27C7               fcb       $1E,$28,$14         ;               Command_1E_SWAP_OBJECTS objectA=28(UnlitLamp) objectB=14(LitLamp)
L27CA               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L27CB               fcb       $0B,$5F,$BE,$3B,$16,$D3,$93,$4B,$7B,$36,$A1,$2E ;                 THE LAMP IS OUT.
L27D7               fcb       $18                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=18 phrase="18: RUB *       u.......   *       "
L27D8               fcb       $2D                 ;           IF_NOT_JUMP address=2806
L27D9               fcb       $0D,$2B             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=43
L27DB               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L27DC               fcb       $26,$5F,$BE,$3B,$16,$D3,$93,$37,$6E,$D1,$B5,$97 ;                 THE LAMP GOES OUT. YOU MUST HAVE RUBBED IT
L27E8               fcb       $C6,$51,$18,$4F,$C2,$66,$C6,$9B,$15,$5B,$CA,$E4 ;                 THE WRONG WAY!
L27F4               fcb       $B3,$66,$4D,$D6,$15,$82,$17,$59,$5E,$00,$B3,$D9 ;                 .
L2800               fcb       $6A,$39,$4A         ;                 .
L2803               fcb       $1E,$28,$14         ;               Command_1E_SWAP_OBJECTS objectA=28(UnlitLamp) objectB=14(LitLamp)
L2806               fcb       $08                 ;           Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2807               fcb       $27                 ;           IF_NOT_JUMP address=282F
L2808               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2809               fcb       $25,$5F,$BE,$3B,$16,$D3,$93,$4B,$7B,$48,$55,$2F ;               THE LAMP IS COVERED WITH TARNISH AND YOU
L2815               fcb       $62,$19,$58,$82,$7B,$7B,$17,$D3,$B2,$13,$B8,$8E ;               CAN'T READ IT.
L2821               fcb       $48,$51,$18,$45,$C2,$85,$48,$14,$BC,$86,$5F,$D6 ;               .
L282D               fcb       $15,$2E             ;               .
L282F               fcb       $02                 ;     02 SHORT NAME
L2830               fcb       $08,$F4,$4F,$10,$99,$CE,$6A,$72,$48 ;       BURNING LAMP
; Object_15 LiveSerpent
L2839               fcb       $24,$81,$C0         ;   Number=24 size=01C0
L283C               fcb       $00,$00,$90         ;     room=00 scorePoints=00 bits=90 u..P....
L283F               fcb       $03                 ;     03 DESCRIPTION
L2840               fcb       $1C,$4E,$45,$31,$49,$55,$5E,$3A,$62,$9E,$61,$43 ;       A LARGE SERPENT LIES COILED ON THE FLOOR.
L284C               fcb       $16,$4B,$62,$3B,$55,$E6,$8B,$C0,$16,$82,$17,$48 ;       .
L2858               fcb       $5E,$81,$8D,$1B,$B5 ;       .
L285D               fcb       $09,$02,$3C,$3C     ;     09 HIT POINTS maxHitPoints=3C currentHitPoints=3C
L2861               fcb       $07,$80,$B3         ;     07 COMMAND HANDLING IF FIRST NOUN
L2864               fcb       $0B,$80,$B0         ;       Command_0B_SWITCH size=B0
L2867               fcb       $0A,$09             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=09 phrase="09: ATTACK WITH ...P....   .v......"
L2869               fcb       $80,$9A             ;         IF_NOT_JUMP address=2905
L286B               fcb       $0D,$80,$97         ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=151
L286E               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L286F               fcb       $09,$09             ;             Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=09(Sword
L2871               fcb       $0B,$80,$91         ;             Command_0B_SWITCH size=91
L2874               fcb       $05,$99             ;               Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=99
L2876               fcb       $2B                 ;               IF_NOT_JUMP address=28A2
L2877               fcb       $0D,$29             ;                 Command_0D_EXECUTE_LIST_WHILE_PASS size=41
L2879               fcb       $04                 ;                   Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L287A               fcb       $03,$C7,$DE,$52     ;                     YOUR
L287E               fcb       $12                 ;                   Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L287F               fcb       $04                 ;                   Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2880               fcb       $1F,$50,$B8,$CB,$87,$6B,$BF,$5F,$BE,$A3,$15,$33 ;                     SINKS TO THE HILT IN THE SERPENT'S SCALY
L288C               fcb       $8E,$83,$7A,$5F,$BE,$57,$17,$1F,$B3,$B5,$9A,$D5 ;                     BODY!
L2898               fcb       $B5,$0E,$53,$44,$DB,$93,$9E,$21 ;                     .
L28A0               fcb       $1D,$11             ;                   Command_1D_ATTACK_OBJECT damage=11
L28A2               fcb       $CC                 ;               Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=CC
L28A3               fcb       $2E                 ;               IF_NOT_JUMP address=28D2
L28A4               fcb       $0D,$2C             ;                 Command_0D_EXECUTE_LIST_WHILE_PASS size=44
L28A6               fcb       $04                 ;                   Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L28A7               fcb       $03,$C7,$DE,$52     ;                     YOUR
L28AB               fcb       $12                 ;                   Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L28AC               fcb       $04                 ;                   Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L28AD               fcb       $24,$6C,$BE,$85,$A1,$7B,$14,$29,$B8,$B4,$D0,$B8 ;                     THROWS A SHOWER OF SPARKS AS IT GLANCES OFF
L28B9               fcb       $16,$62,$17,$35,$49,$C3,$B5,$CB,$B5,$09,$BC,$50 ;                     THE WALL!
L28C5               fcb       $8B,$B5,$53,$B8,$16,$96,$64,$DB,$72,$0E,$D0,$AB ;                     .
L28D1               fcb       $89                 ;                     .
L28D2               fcb       $FF                 ;               Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FF
L28D3               fcb       $31                 ;               IF_NOT_JUMP address=2905
L28D4               fcb       $0D,$2F             ;                 Command_0D_EXECUTE_LIST_WHILE_PASS size=47
L28D6               fcb       $04                 ;                   Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L28D7               fcb       $2B,$5F,$BE,$57,$17,$1F,$B3,$B5,$9A,$CA,$B5,$86 ;                     THE SERPENT'S HEAD IS SEVERED FROM HIS BODY!
L28E3               fcb       $5F,$D5,$15,$57,$17,$74,$CA,$F3,$5F,$79,$68,$4A ;                     A MAGNIFICENT BLOW!
L28EF               fcb       $90,$4B,$7B,$F6,$4E,$EB,$DA,$4F,$45,$80,$47,$53 ;                     .
L28FB               fcb       $79,$B0,$53,$04,$BC,$89,$8D,$21 ;                     .
L2903               fcb       $1D,$FF             ;                   Command_1D_ATTACK_OBJECT damage=FF
L2905               fcb       $15                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L2906               fcb       $10                 ;         IF_NOT_JUMP address=2917
L2907               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2908               fcb       $0E,$76,$4D,$F4,$BD,$1B,$16,$F3,$8C,$73,$7B,$14 ;             BETTER KILL IT FIRST!
L2914               fcb       $67,$F1,$B9         ;             .
L2917               fcb       $08,$80,$C4         ;     08 TURN SCRIPT
L291A               fcb       $0D,$80,$C1         ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=193
L291D               fcb       $0E,$3E             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=62
L291F               fcb       $0D,$32             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=50
L2921               fcb       $14                 ;             Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L2922               fcb       $01,$1D             ;               Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2924               fcb       $0B,$19             ;             Command_0B_SWITCH size=19
L2926               fcb       $0A,$04             ;               Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L2928               fcb       $04                 ;               IF_NOT_JUMP address=292D
L2929               fcb       $21,$04,$00,$00     ;                 Command_21_EXECUTE_PHRASE phrase="04: WEST *      *          *       " first=00(NONE)  second=00(NONE)
L292D               fcb       $03                 ;               Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L292E               fcb       $04                 ;               IF_NOT_JUMP address=2933
L292F               fcb       $21,$03,$00,$00     ;                 Command_21_EXECUTE_PHRASE phrase="03: EAST *      *          *       " first=00(NONE)  second=00(NONE)
L2933               fcb       $01                 ;               Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L2934               fcb       $04                 ;               IF_NOT_JUMP address=2939
L2935               fcb       $21,$01,$00,$00     ;                 Command_21_EXECUTE_PHRASE phrase="01: NORTH *     *          *       " first=00(NONE)  second=00(NONE)
L2939               fcb       $02                 ;               Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L293A               fcb       $04                 ;               IF_NOT_JUMP address=293F
L293B               fcb       $21,$02,$00,$00     ;                 Command_21_EXECUTE_PHRASE phrase="02: SOUTH *     *          *       " first=00(NONE)  second=00(NONE)
L293F               fcb       $1F                 ;             Command_1F_PRINT_MESSAGE
L2940               fcb       $12,$5F,$BE,$57,$17,$1F,$B3,$B3,$9A,$74,$A7,$27 ;               THE SERPENT PURSUES YOU AND
L294C               fcb       $BA,$DB,$B5,$1B,$A1,$8E,$48 ;               .
L2953               fcb       $1F                 ;           Command_1F_PRINT_MESSAGE
L2954               fcb       $08,$5F,$BE,$57,$17,$1F,$B3,$B3,$9A ;             THE SERPENT
L295D               fcb       $0D,$7F             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=127
L295F               fcb       $01,$1D             ;           Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2961               fcb       $1C,$1D             ;           Command_1C_SET_VAR_OBJECT object=1D (USER)
L2963               fcb       $0B,$79             ;           Command_0B_SWITCH size=79
L2965               fcb       $05,$33             ;             Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=33
L2967               fcb       $23                 ;             IF_NOT_JUMP address=298B
L2968               fcb       $0D,$21             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=33
L296A               fcb       $1F                 ;                 Command_1F_PRINT_MESSAGE
L296B               fcb       $1D,$0C,$BA,$17,$7A,$33,$BB,$7B,$A6,$40,$B9,$E1 ;                   STRIKES, POISON COURSES THROUGH YOUR VEINS!
L2977               fcb       $14,$3D,$C6,$4B,$62,$6C,$BE,$29,$A1,$1B,$71,$34 ;                   .
L2983               fcb       $A1,$CF,$17,$9D,$7A,$21 ;                   .
L2989               fcb       $1D,$14             ;                 Command_1D_ATTACK_OBJECT damage=14
L298B               fcb       $99                 ;             Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=99
L298C               fcb       $16                 ;             IF_NOT_JUMP address=29A3
L298D               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L298E               fcb       $14,$0C,$BA,$17,$7A,$33,$BB,$C7,$DE,$09,$15,$37 ;                 STRIKES, YOU DODGE HIS LUNGE!
L299A               fcb       $5A,$A3,$15,$CE,$B5,$91,$C5,$EB,$5D ;                 .
L29A3               fcb       $CC                 ;             Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=CC
L29A4               fcb       $21                 ;             IF_NOT_JUMP address=29C6
L29A5               fcb       $0D,$1F             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=31
L29A7               fcb       $1F                 ;                 Command_1F_PRINT_MESSAGE
L29A8               fcb       $1B,$3B,$55,$0B,$8E,$D2,$B0,$06,$79,$43,$DB,$07 ;                   COILS RAPIDLY AROUND YOU AND CONSTRICTS!
L29B4               fcb       $B3,$33,$98,$C7,$DE,$90,$14,$05,$58,$1D,$A0,$F3 ;                   .
L29C0               fcb       $BF,$0D,$56,$21     ;                   .
L29C4               fcb       $1D,$14             ;                 Command_1D_ATTACK_OBJECT damage=14
L29C6               fcb       $FF                 ;             Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FF
L29C7               fcb       $16                 ;             IF_NOT_JUMP address=29DE
L29C8               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L29C9               fcb       $14,$16,$6C,$F4,$72,$CB,$B5,$17,$C0,$03,$8C,$04 ;                 GATHERS ITSELF FOR AN ATTACK.
L29D5               fcb       $68,$90,$14,$96,$14,$45,$BD,$5B,$89 ;                 .
L29DE               fcb       $0A,$15             ;     0A UPON DEATH SCRIPT
L29E0               fcb       $0D,$13             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=19
L29E2               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L29E3               fcb       $0E,$5F,$BE,$57,$17,$1F,$B3,$B3,$9A,$4B,$7B,$E3 ;           THE SERPENT IS DEAD.
L29EF               fcb       $59,$9B,$5D         ;           .
L29F2               fcb       $1E,$15,$16         ;         Command_1E_SWAP_OBJECTS objectA=15(LiveSerpent) objectB=16(DeadSerpent)
L29F5               fcb       $02                 ;     02 SHORT NAME
L29F6               fcb       $05,$B4,$B7,$F0,$A4,$54 ;       SERPENT
; Object_16 DeadSerpent
L29FC               fcb       $24,$40             ;   Number=24 size=0040
L29FE               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L2A01               fcb       $03                 ;     03 DESCRIPTION
L2A02               fcb       $1A,$4E,$45,$31,$49,$46,$5E,$86,$5F,$57,$17,$1F ;       A LARGE DEAD SERPENT LIES ON THE FLOOR.
L2A0E               fcb       $B3,$B3,$9A,$87,$8C,$D1,$B5,$96,$96,$DB,$72,$89 ;       .
L2A1A               fcb       $67,$C7,$A0         ;       .
L2A1D               fcb       $07,$15             ;     07 COMMAND HANDLING IF FIRST NOUN
L2A1F               fcb       $0D,$13             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=19
L2A21               fcb       $0A,$15             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L2A23               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2A24               fcb       $0F,$A8,$77,$4E,$5E,$E6,$A0,$7B,$16,$92,$14,$F6 ;           I'VE LOST MY APPETITE!
L2A30               fcb       $A4,$7F,$7B,$21     ;           .
L2A34               fcb       $02                 ;     02 SHORT NAME
L2A35               fcb       $08,$E3,$59,$15,$58,$3A,$62,$9E,$61 ;       DEAD SERPENT
; Object_17 Hands
L2A3E               fcb       $1F,$09             ;   Number=1F size=0009
L2A40               fcb       $FF,$00,$80         ;     room=FF scorePoints=00 bits=80 u.......
L2A43               fcb       $02                 ;     02 SHORT NAME
L2A44               fcb       $04,$50,$72,$0B,$5C ;       HANDS
; Object_18 Coin
L2A49               fcb       $20,$34             ;   Number=20 size=0034
L2A4B               fcb       $9C,$05,$A4         ;     room=9C scorePoints=05 bits=A4 u.C..X..
L2A4E               fcb       $03                 ;     03 DESCRIPTION
L2A4F               fcb       $14,$5F,$BE,$5B,$B1,$4B,$7B,$45,$45,$50,$9F,$C0 ;       THERE IS A COIN ON THE GROUND.
L2A5B               fcb       $16,$82,$17,$49,$5E,$07,$B3,$57,$98 ;       .
L2A64               fcb       $07,$14             ;     07 COMMAND HANDLING IF FIRST NOUN
L2A66               fcb       $0D,$12             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=18
L2A68               fcb       $0A,$08             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2A6A               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2A6B               fcb       $0E,$2C,$1D,$D5,$47,$F3,$5F,$5B,$4D,$C3,$B0,$1D ;           "PRAISED BE RAAKA-TU"
L2A77               fcb       $85,$5C,$C0         ;           .
L2A7A               fcb       $02                 ;     02 SHORT NAME
L2A7B               fcb       $03,$3B,$55,$4E     ;       COIN
; Object_19 TinySlot
L2A7F               fcb       $21,$7F             ;   Number=21 size=007F
L2A81               fcb       $88,$00,$80         ;     room=88 scorePoints=00 bits=80 u.......
L2A84               fcb       $03                 ;     03 DESCRIPTION
L2A85               fcb       $1D,$5F,$BE,$5B,$B1,$4B,$7B,$56,$45,$A3,$7A,$5E ;       THERE IS A TINY SLOT CUT IN THE NORTH WALL.
L2A91               fcb       $17,$F3,$A0,$36,$56,$D0,$15,$82,$17,$50,$5E,$BE ;       .
L2A9D               fcb       $A0,$19,$71,$46,$48,$2E ;       .
L2AA3               fcb       $02                 ;     02 SHORT NAME
L2AA4               fcb       $06,$90,$BE,$55,$DB,$86,$8D ;       TINY SLOT
L2AAB               fcb       $06,$53             ;     06 COMMAND HANDLING IF SECOND NOUN
L2AAD               fcb       $0D,$51             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=81
L2AAF               fcb       $0A,$0F             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=0F phrase="0F: DROP IN     u.......   u......."
L2AB1               fcb       $0E,$4D             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=77
L2AB3               fcb       $0D,$24             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=36
L2AB5               fcb       $14                 ;             Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L2AB6               fcb       $08,$18             ;               Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=18(Coin
L2AB8               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2AB9               fcb       $02,$5F,$BE         ;               THE
L2ABC               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L2ABD               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2ABE               fcb       $1A,$4B,$7B,$81,$BF,$B3,$14,$D6,$6A,$C8,$9C,$73 ;               IS TOO BIG TO FIT IN SUCH A TINY SLOT.
L2ACA               fcb       $7B,$83,$7A,$25,$BA,$03,$71,$83,$17,$7B,$9B,$C9 ;               .
L2AD6               fcb       $B8,$9B,$C1         ;               .
L2AD9               fcb       $0D,$25             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=37
L2ADB               fcb       $17,$06,$00         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=06(StatueEast) location=00
L2ADE               fcb       $17,$07,$88         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=07(StatueWest) location=88
L2AE1               fcb       $17,$18,$00         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=18(Coin) location=00
L2AE4               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2AE5               fcb       $1A,$5F,$BE,$66,$17,$8F,$49,$56,$5E,$38,$C6,$D6 ;               THE STATUE TURNS TO FACE THE WEST DOOR.
L2AF1               fcb       $B5,$C8,$9C,$D7,$46,$82,$17,$59,$5E,$66,$62,$09 ;               .
L2AFD               fcb       $15,$C7,$A0         ;               .
; Object_1A MessageUnderSlot
L2B00               fcb       $18,$53             ;   Number=18 size=0053
L2B02               fcb       $88,$00,$84         ;     room=88 scorePoints=00 bits=84 u....X..
L2B05               fcb       $03                 ;     03 DESCRIPTION
L2B06               fcb       $1C,$5F,$BE,$5B,$B1,$4B,$7B,$4F,$45,$65,$62,$77 ;       THERE IS A MESSAGE CARVED UNDER THE SLOT.
L2B12               fcb       $47,$D3,$14,$0F,$B4,$17,$58,$3F,$98,$96,$AF,$DB ;       .
L2B1E               fcb       $72,$C9,$B8,$9B,$C1 ;       .
L2B23               fcb       $02                 ;     02 SHORT NAME
L2B24               fcb       $0A,$14,$53,$66,$CA,$67,$16,$D3,$B9,$9B,$6C ;       CARVED MESSAGE
L2B2F               fcb       $07,$24             ;     07 COMMAND HANDLING IF FIRST NOUN
L2B31               fcb       $0D,$22             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=34
L2B33               fcb       $0A,$08             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L2B35               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2B36               fcb       $1E,$5F,$BE,$67,$16,$D3,$B9,$9B,$6C,$1B,$B7,$33 ;           THE MESSAGE SAYS, "SAFE PASSAGE FOR A
L2B42               fcb       $BB,$93,$1D,$5B,$66,$55,$A4,$09,$B7,$48,$5E,$A3 ;           PRICE."
L2B4E               fcb       $A0,$52,$45,$05,$B2,$DC,$63 ;           .
; Object_1B ClosedDoor
L2B55               fcb       $09,$3B             ;   Number=09 size=003B
L2B57               fcb       $90,$00,$80         ;     room=90 scorePoints=00 bits=80 u.......
L2B5A               fcb       $03                 ;     03 DESCRIPTION
L2B5B               fcb       $0D,$5F,$BE,$09,$15,$A3,$A0,$4B,$7B,$C9,$54,$A6 ;       THE DOOR IS CLOSED.
L2B67               fcb       $B7,$2E             ;       .
L2B69               fcb       $02                 ;     02 SHORT NAME
L2B6A               fcb       $03,$81,$5B,$52     ;       DOOR
L2B6E               fcb       $07,$22             ;     07 COMMAND HANDLING IF FIRST NOUN
L2B70               fcb       $0D,$20             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=32
L2B72               fcb       $0A,$11             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=11 phrase="11: OPEN *      u.......   *       "
L2B74               fcb       $17,$1B,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1B(ClosedDoor) location=00
L2B77               fcb       $17,$1C,$90         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1C(OpenDoor) location=90
L2B7A               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2B7B               fcb       $16,$7C,$B3,$6F,$B3,$27,$60,$2D,$60,$8B,$18,$5F ;           RRRRREEEEEEK - THE DOOR IS OPEN.
L2B87               fcb       $BE,$09,$15,$A3,$A0,$4B,$7B,$5F,$A0,$1B,$9C ;           .
; Object_1C OpenDoor
L2B92               fcb       $09,$30             ;   Number=09 size=0030
L2B94               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L2B97               fcb       $03                 ;     03 DESCRIPTION
L2B98               fcb       $12,$5F,$BE,$09,$15,$A3,$A0,$4B,$7B,$FB,$B9,$43 ;       THE DOOR IS STANDING OPEN.
L2BA4               fcb       $98,$AB,$98,$5F,$A0,$1B,$9C ;       .
L2BAB               fcb       $02                 ;     02 SHORT NAME
L2BAC               fcb       $03,$81,$5B,$52     ;       DOOR
L2BB0               fcb       $07,$12             ;     07 COMMAND HANDLING IF FIRST NOUN
L2BB2               fcb       $0D,$10             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=16
L2BB4               fcb       $0A,$11             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=11 phrase="11: OPEN *      u.......   *       "
L2BB6               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2BB7               fcb       $0C,$8D,$7B,$8E,$14,$63,$B1,$FB,$5C,$5F,$A0,$1B ;           ITS ALREADY OPEN.
L2BC3               fcb       $9C                 ;           .
; Object_1D USER
L2BC4               fcb       $FF,$80,$87         ;   Number=FF size=0087
L2BC7               fcb       $96,$00,$80         ;     room=96 scorePoints=00 bits=80 u.......
L2BCA               fcb       $0A,$76             ;     0A UPON DEATH SCRIPT
L2BCC               fcb       $0E,$74             ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=116
L2BCE               fcb       $0B,$07             ;         Command_0B_SWITCH size=07
L2BD0               fcb       $20,$1D             ;           Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L2BD2               fcb       $01                 ;           IF_NOT_JUMP address=2BD4
L2BD3               fcb       $81                 ;             CommonCommand_81
L2BD4               fcb       $23                 ;           Command_20_CHECK_ACTIVE_OBJECT object=23(Guards)
L2BD5               fcb       $01                 ;           IF_NOT_JUMP address=2BD7
L2BD6               fcb       $81                 ;             CommonCommand_81
L2BD7               fcb       $0D,$69             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=105
L2BD9               fcb       $1F                 ;           Command_1F_PRINT_MESSAGE
L2BDA               fcb       $66,$C7,$DE,$DB,$16,$CB,$B9,$36,$A1,$59,$F4,$F0 ;             YOU PASS OUT. WHEN YOU AWAKEN, YOU FIND
L2BE6               fcb       $72,$51,$18,$43,$C2,$0D,$D0,$A6,$61,$51,$18,$48 ;             YOURSELF CHAINED TO A BLOOD STAINED ALTAR. A
L2BF2               fcb       $C2,$8E,$7A,$51,$18,$3D,$C6,$40,$61,$DA,$14,$D0 ;             PRIEST IS KNEELING OVER YOU WITH A KNIFE. IT
L2BFE               fcb       $47,$F3,$5F,$6B,$BF,$44,$45,$81,$8D,$15,$58,$4B ;             LOOKS LIKE THIS IS IT.
L2C0A               fcb       $BD,$66,$98,$8E,$14,$54,$BD,$43,$F4,$EC,$16,$35 ;             .
L2C16               fcb       $79,$0B,$BC,$CD,$B5,$67,$98,$90,$8C,$D1,$6A,$74 ;             .
L2C22               fcb       $CA,$51,$18,$59,$C2,$82,$7B,$7B,$14,$13,$87,$7F ;             .
L2C2E               fcb       $66,$D6,$15,$49,$16,$A5,$9F,$43,$16,$9B,$85,$63 ;             .
L2C3A               fcb       $BE,$CB,$B5,$CB,$B5,$9B,$C1 ;             .
L2C41               fcb       $81                 ;           CommonCommand_81
L2C42               fcb       $08,$06             ;     08 TURN SCRIPT
L2C44               fcb       $0D,$04             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2C46               fcb       $1C,$1D             ;         Command_1C_SET_VAR_OBJECT object=1D (USER)
L2C48               fcb       $23,$05             ;         Command_23_HEAL_VAR_OBJECT value=05
L2C4A               fcb       $09,$02,$46,$46     ;     09 HIT POINTS maxHitPoints=46 currentHitPoints=46
; Object_1E LiveGargoyle
L2C4E               fcb       $0F,$81,$B4         ;   Number=0F size=01B4
L2C51               fcb       $00,$00,$90         ;     room=00 scorePoints=00 bits=90 u..P....
L2C54               fcb       $03                 ;     03 DESCRIPTION
L2C55               fcb       $25,$5F,$BE,$5B,$B1,$4B,$7B,$4A,$45,$FF,$78,$35 ;       THERE IS A HIDEOUS GARGOYLE BLOCKING THE
L2C61               fcb       $A1,$73,$15,$C1,$B1,$3F,$DE,$B6,$14,$5D,$9E,$91 ;       NORTH PASSAGE.
L2C6D               fcb       $7A,$82,$17,$50,$5E,$BE,$A0,$12,$71,$65,$49,$77 ;       .
L2C79               fcb       $47,$2E             ;       .
L2C7B               fcb       $02                 ;     02 SHORT NAME
L2C7C               fcb       $06,$14,$6C,$4B,$6E,$DB,$8B ;       GARGOYLE
L2C83               fcb       $09,$02,$FF,$FF     ;     09 HIT POINTS maxHitPoints=FF currentHitPoints=FF
L2C87               fcb       $07,$22             ;     07 COMMAND HANDLING IF FIRST NOUN
L2C89               fcb       $0D,$20             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=32
L2C8B               fcb       $0A,$15             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L2C8D               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2C8E               fcb       $1C,$DD,$72,$F3,$8C,$96,$5F,$51,$18,$4E,$C2,$11 ;           HE'LL EAT YOU LONG BEFORE YOU'LL EAT HIM!
L2C9A               fcb       $A0,$AF,$14,$04,$68,$5B,$5E,$1D,$A1,$F3,$8C,$96 ;           .
L2CA6               fcb       $5F,$A3,$15,$EB,$8F ;           .
L2CAB               fcb       $08,$81,$29         ;     08 TURN SCRIPT
L2CAE               fcb       $0D,$81,$26         ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=294
L2CB1               fcb       $01,$1D             ;         Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2CB3               fcb       $1C,$1D             ;         Command_1C_SET_VAR_OBJECT object=1D (USER)
L2CB5               fcb       $14                 ;         Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L2CB6               fcb       $01,$12             ;           Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=12(LitCandle)
L2CB8               fcb       $0B,$81,$1C         ;         Command_0B_SWITCH size=11C
L2CBB               fcb       $05,$19             ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=19
L2CBD               fcb       $2E                 ;           IF_NOT_JUMP address=2CEC
L2CBE               fcb       $0D,$2C             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=44
L2CC0               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L2CC1               fcb       $28,$5F,$BE,$73,$15,$C1,$B1,$3F,$DE,$81,$15,$75 ;                 THE GARGOYLE GORES YOU WITH HIS HORN AND
L2CCD               fcb       $B1,$51,$18,$59,$C2,$82,$7B,$A3,$15,$CA,$B5,$B8 ;                 RIPS YOUR GUTS OUT!
L2CD9               fcb       $A0,$90,$14,$14,$58,$ED,$7A,$51,$18,$23,$C6,$36 ;                 .
L2CE5               fcb       $6F,$D1,$B5,$71,$C6 ;                 .
L2CEA               fcb       $1D,$FF             ;               Command_1D_ATTACK_OBJECT damage=FF
L2CEC               fcb       $3F                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=3F
L2CED               fcb       $21                 ;           IF_NOT_JUMP address=2D0F
L2CEE               fcb       $0D,$1F             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=31
L2CF0               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L2CF1               fcb       $1B,$5F,$BE,$73,$15,$C1,$B1,$3F,$DE,$DE,$14,$05 ;                 THE GARGOYLE CLAWS YOU ACROSS THE CHEST!
L2CFD               fcb       $4A,$51,$18,$43,$C2,$B9,$55,$CB,$B9,$5F,$BE,$DA ;                 .
L2D09               fcb       $14,$66,$62,$21     ;                 .
L2D0D               fcb       $1D,$32             ;               Command_1D_ATTACK_OBJECT damage=32
L2D0F               fcb       $64                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=64
L2D10               fcb       $2E                 ;           IF_NOT_JUMP address=2D3F
L2D11               fcb       $0D,$2C             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=44
L2D13               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L2D14               fcb       $28,$C7,$DE,$4F,$15,$33,$61,$5F,$BE,$80,$15,$5A ;                 YOU FEEL THE GNASHING OF THE GARGOYLE'S
L2D20               fcb       $49,$91,$7A,$B8,$16,$82,$17,$49,$5E,$31,$49,$CE ;                 TEETH IN YOUR SIDE!
L2D2C               fcb       $A1,$A5,$5E,$7F,$17,$82,$62,$D0,$15,$51,$18,$23 ;                 .
L2D38               fcb       $C6,$46,$B8,$EB,$5D ;                 .
L2D3D               fcb       $1D,$32             ;               Command_1D_ATTACK_OBJECT damage=32
L2D3F               fcb       $A3                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=A3
L2D40               fcb       $3C                 ;           IF_NOT_JUMP address=2D7D
L2D41               fcb       $0D,$3A             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=58
L2D43               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L2D44               fcb       $36,$5F,$BE,$DE,$14,$05,$4A,$B8,$16,$82,$17,$49 ;                 THE CLAWS OF THE GARGOYLE RIP THROUGH YOUR
L2D50               fcb       $5E,$31,$49,$CE,$A1,$54,$5E,$D3,$7A,$6C,$BE,$29 ;                 ARM IN AN ATTEMPT TO REACH YOUR BODY!
L2D5C               fcb       $A1,$1B,$71,$34,$A1,$94,$14,$4B,$90,$83,$96,$83 ;                 .
L2D68               fcb       $96,$3F,$C0,$EE,$93,$89,$17,$2F,$17,$DA,$46,$51 ;                 .
L2D74               fcb       $18,$23,$C6,$F6,$4E,$EB,$DA ;                 .
L2D7B               fcb       $1D,$19             ;               Command_1D_ATTACK_OBJECT damage=19
L2D7D               fcb       $E1                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=E1
L2D7E               fcb       $3E                 ;           IF_NOT_JUMP address=2DBD
L2D7F               fcb       $0D,$3C             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=60
L2D81               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L2D82               fcb       $38,$5F,$BE,$73,$15,$C1,$B1,$3F,$DE,$4F,$16,$B7 ;                 THE GARGOYLE LUNGES AT YOUR FACE BUT YOU
L2D8E               fcb       $98,$C3,$B5,$1B,$BC,$34,$A1,$4B,$15,$9B,$53,$F6 ;                 PULL BACK.  HE BITES YOUR SHOULDER INSTEAD!
L2D9A               fcb       $4F,$51,$18,$52,$C2,$46,$C5,$AB,$14,$AF,$54,$4A ;                 .
L2DA6               fcb       $13,$44,$5E,$7F,$7B,$DB,$B5,$34,$A1,$5A,$17,$2E ;                 .
L2DB2               fcb       $A1,$F4,$59,$D0,$15,$FF,$B9,$F1,$46 ;                 .
L2DBB               fcb       $1D,$19             ;               Command_1D_ATTACK_OBJECT damage=19
L2DBD               fcb       $FF                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FF
L2DBE               fcb       $18                 ;           IF_NOT_JUMP address=2DD7
L2DBF               fcb       $0D,$16             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=22
L2DC1               fcb       $1F                 ;               Command_1F_PRINT_MESSAGE
L2DC2               fcb       $14,$C7,$DE,$09,$15,$37,$5A,$82,$17,$49,$5E,$31 ;                 YOU DODGE THE GARGOYLE'S HORN.
L2DCE               fcb       $49,$CE,$A1,$A5,$5E,$A9,$15,$E7,$B2 ;                 .
L2DD7               fcb       $0A,$2C             ;     0A UPON DEATH SCRIPT
L2DD9               fcb       $0D,$2A             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=42
L2DDB               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L2DDC               fcb       $22,$5F,$BE,$73,$15,$C1,$B1,$3F,$DE,$7B,$17,$B5 ;           THE GARGOYLE TAKES A FINAL BREATH AND THEN
L2DE8               fcb       $85,$7B,$14,$10,$67,$33,$48,$6F,$4F,$82,$49,$90 ;           EXPIRES.
L2DF4               fcb       $14,$16,$58,$F0,$72,$3A,$15,$94,$A5,$6F,$62 ;           .
L2DFF               fcb       $17,$1E,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1E(LiveGargoyle) location=00
L2E02               fcb       $17,$1F,$8E         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1F(DeadGargoyle) location=8E
; Object_1F DeadGargoyle
L2E05               fcb       $0F,$53             ;   Number=0F size=0053
L2E07               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L2E0A               fcb       $03                 ;     03 DESCRIPTION
L2E0B               fcb       $24,$5F,$BE,$5B,$B1,$4B,$7B,$5F,$BE,$FF,$14,$F3 ;       THERE IS THE DEAD CARCASS OF AN UGLY
L2E17               fcb       $46,$14,$53,$15,$53,$D1,$B5,$83,$64,$97,$96,$D3 ;       GARGOYLE NEARBY.
L2E23               fcb       $6D,$73,$15,$C1,$B1,$3F,$DE,$8F,$16,$2C,$49,$DB ;       .
L2E2F               fcb       $E0                 ;       .
L2E30               fcb       $07,$1D             ;     07 COMMAND HANDLING IF FIRST NOUN
L2E32               fcb       $0D,$1B             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=27
L2E34               fcb       $0A,$15             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L2E36               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2E37               fcb       $17,$7A,$C4,$CB,$06,$82,$17,$95,$7A,$BD,$15,$49 ;           UGH! I THINK I'M GOING TO BE SICK!
L2E43               fcb       $90,$50,$9F,$D6,$6A,$C4,$9C,$55,$5E,$DD,$78,$21 ;           .
L2E4F               fcb       $02                 ;     02 SHORT NAME
L2E50               fcb       $09,$E3,$59,$09,$58,$31,$49,$CE,$A1,$45 ;       DEAD GARGOYLE
; Object_20 Wall
L2E5A               fcb       $25,$32             ;   Number=25 size=0032
L2E5C               fcb       $FF,$00,$80         ;     room=FF scorePoints=00 bits=80 u.......
L2E5F               fcb       $07,$28             ;     07 COMMAND HANDLING IF FIRST NOUN
L2E61               fcb       $0B,$26             ;       Command_0B_SWITCH size=26
L2E63               fcb       $0A,$17             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L2E65               fcb       $20                 ;         IF_NOT_JUMP address=2E86
L2E66               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L2E67               fcb       $1E,$C7,$DE,$D3,$14,$90,$96,$F3,$A0,$C3,$54,$A3 ;             YOU CAN NOT CLIMB THE WALL, IT IS TOO
L2E73               fcb       $91,$5F,$BE,$F3,$17,$16,$8D,$D6,$15,$D5,$15,$89 ;             SMOOTH.
L2E7F               fcb       $17,$D5,$9C,$C1,$93,$77,$BE ;             .
L2E86               fcb       $34                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=34 phrase="34: JUMP OVER   *          u......."
L2E87               fcb       $01                 ;         IF_NOT_JUMP address=2E89
L2E88               fcb       $89                 ;           CommonCommand_89
L2E89               fcb       $02                 ;     02 SHORT NAME
L2E8A               fcb       $03,$0E,$D0,$4C     ;       WALL
; Object_21 Vines
L2E8E               fcb       $26,$29             ;   Number=26 size=0029
L2E90               fcb       $9D,$00,$80         ;     room=9D scorePoints=00 bits=80 u.......
L2E93               fcb       $03                 ;     03 DESCRIPTION
L2E94               fcb       $1E,$4E,$45,$31,$49,$50,$5E,$91,$62,$B5,$A0,$B8 ;       A LARGE NETWORK OF VINES CLINGS TO THE WALL.
L2EA0               fcb       $16,$D3,$17,$75,$98,$DE,$14,$91,$7A,$D6,$B5,$D6 ;
L2EAC               fcb       $9C,$DB,$72,$0E,$D0,$9B,$8F ;       .
L2EB3               fcb       $02                 ;     02 SHORT NAME
L2EB4               fcb       $04,$10,$CB,$4B,$62 ;       VINES
; Object_22 GoldenChopstick
L2EB9               fcb       $1E,$28             ;   Number=1E size=0028
L2EBB               fcb       $8F,$05,$A0         ;     room=8F scorePoints=05 bits=A0 u.C.....
L2EBE               fcb       $03                 ;     03 DESCRIPTION
L2EBF               fcb       $16,$5F,$BE,$5B,$B1,$4B,$7B,$49,$45,$BE,$9F,$83 ;       THERE IS A GOLDEN CHOPSTICK HERE.
L2ECB               fcb       $61,$29,$54,$26,$A7,$DD,$78,$9F,$15,$7F,$B1 ;       .
L2ED6               fcb       $02                 ;     02 SHORT NAME
L2ED7               fcb       $0B,$3E,$6E,$F0,$59,$DA,$14,$6D,$A0,$85,$BE,$4B ;       GOLDEN CHOPSTICK
; Object_23 Guards
L2EE3               fcb       $28,$80,$CA         ;   Number=28 size=00CA
L2EE6               fcb       $9C,$00,$90         ;     room=9C scorePoints=00 bits=90 u..P....
L2EE9               fcb       $03                 ;     03 DESCRIPTION
L2EEA               fcb       $27,$B8,$B7,$2B,$62,$09,$8A,$94,$C3,$0B,$5C,$14 ;       SEVERAL GUARDS CARRYING LETHAL CROSSBOWS
L2EF6               fcb       $53,$8B,$B4,$AB,$98,$F6,$8B,$4E,$72,$E4,$14,$E5 ;       TURN TO FACE YOU.
L2F02               fcb       $A0,$09,$4F,$D6,$B5,$38,$C6,$89,$17,$4B,$15,$9B ;       .
L2F0E               fcb       $53,$C7,$DE,$2E     ;       .
L2F12               fcb       $08,$80,$95         ;     08 TURN SCRIPT
L2F15               fcb       $0E,$80,$92         ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=146
L2F18               fcb       $0D,$2F             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=47
L2F1A               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L2F1B               fcb       $01,$1D             ;             Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2F1D               fcb       $0B,$29             ;           Command_0B_SWITCH size=29
L2F1F               fcb       $03,$9C,$23         ;             Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9C
L2F22               fcb       $07                 ;             IF_NOT_JUMP address=2F2A
L2F23               fcb       $0D,$05             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L2F25               fcb       $00,$9D             ;                 Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9D
L2F27               fcb       $01,$1D             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2F29               fcb       $86                 ;                 CommonCommand_86
L2F2A               fcb       $9F,$23             ;             Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9F
L2F2C               fcb       $07                 ;             IF_NOT_JUMP address=2F34
L2F2D               fcb       $0D,$05             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L2F2F               fcb       $00,$9C             ;                 Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9C
L2F31               fcb       $01,$1D             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2F33               fcb       $86                 ;                 CommonCommand_86
L2F34               fcb       $9E,$23             ;             Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9E
L2F36               fcb       $07                 ;             IF_NOT_JUMP address=2F3E
L2F37               fcb       $0D,$05             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L2F39               fcb       $00,$9F             ;                 Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9F
L2F3B               fcb       $01,$1D             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2F3D               fcb       $86                 ;                 CommonCommand_86
L2F3E               fcb       $9D,$23             ;             Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9D
L2F40               fcb       $07                 ;             IF_NOT_JUMP address=2F48
L2F41               fcb       $0D,$05             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L2F43               fcb       $00,$9E             ;                 Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9E
L2F45               fcb       $01,$1D             ;                 Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2F47               fcb       $86                 ;                 CommonCommand_86
L2F48               fcb       $0C                 ;           Command_0C_FAIL
L2F49               fcb       $0D,$5F             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=95
L2F4B               fcb       $01,$1D             ;           Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=1D(USER)
L2F4D               fcb       $1C,$1D             ;           Command_1C_SET_VAR_OBJECT object=1D (USER)
L2F4F               fcb       $1F                 ;           Command_1F_PRINT_MESSAGE
L2F50               fcb       $58,$A6,$1D,$51,$A0,$D0,$15,$06,$67,$33,$61,$79 ;             "STOP! INFIDEL DOG!", THE GUARDS LEVEL THEIR
L2F5C               fcb       $5B,$06,$07,$82,$17,$49,$5E,$94,$C3,$0B,$5C,$F8 ;             CROSSBOWS AND LOOSE THEIR BOLTS! YOUR BODY
L2F68               fcb       $8B,$33,$61,$5F,$BE,$23,$7B,$B9,$55,$D4,$B9,$85 ;             FALLS TO THE GROUND RIDDLED WITH THE SHAFTS!
L2F74               fcb       $A1,$90,$14,$0E,$58,$45,$A0,$56,$5E,$EB,$72,$84 ;             .
L2F80               fcb       $AF,$CE,$9F,$6B,$B5,$C7,$DE,$84,$AF,$93,$9E,$4B ;             .
L2F8C               fcb       $15,$0D,$8D,$89,$17,$82,$17,$49,$5E,$07,$B3,$33 ;             .
L2F98               fcb       $98,$06,$B2,$FF,$5A,$19,$58,$82,$7B,$82,$17,$55 ;             .
L2FA4               fcb       $5E,$48,$72,$09,$C0 ;             .
L2FA9               fcb       $81                 ;           CommonCommand_81
L2FAA               fcb       $02                 ;     02 SHORT NAME
L2FAB               fcb       $04,$23,$6F,$4D,$B1 ;       GUARDS
; Object_24 Object24
L2FB0               fcb       $29,$4C             ;   Number=29 size=004C
L2FB2               fcb       $1D,$00,$00         ;     room=1D scorePoints=00 bits=00 *
L2FB5               fcb       $08,$47             ;     08 TURN SCRIPT
L2FB7               fcb       $0B,$45             ;       Command_0B_SWITCH size=45
L2FB9               fcb       $03,$9C,$23         ;         Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9C
L2FBC               fcb       $0E                 ;         IF_NOT_JUMP address=2FCB
L2FBD               fcb       $0E,$0C             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=12
L2FBF               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FC1               fcb       $03,$9A,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=9A
L2FC4               fcb       $85                 ;               CommonCommand_85
L2FC5               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FC7               fcb       $03,$99,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=99
L2FCA               fcb       $87                 ;               CommonCommand_87
L2FCB               fcb       $9F,$23             ;         Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9F
L2FCD               fcb       $0E                 ;         IF_NOT_JUMP address=2FDC
L2FCE               fcb       $0E,$0C             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=12
L2FD0               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FD2               fcb       $03,$99,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=99
L2FD5               fcb       $85                 ;               CommonCommand_85
L2FD6               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FD8               fcb       $03,$98,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=98
L2FDB               fcb       $87                 ;               CommonCommand_87
L2FDC               fcb       $9E,$23             ;         Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9E
L2FDE               fcb       $0E                 ;         IF_NOT_JUMP address=2FED
L2FDF               fcb       $0E,$0C             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=12
L2FE1               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FE3               fcb       $03,$98,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=98
L2FE6               fcb       $85                 ;               CommonCommand_85
L2FE7               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FE9               fcb       $03,$9B,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=9B
L2FEC               fcb       $87                 ;               CommonCommand_87
L2FED               fcb       $9D,$23             ;         Command_03_IS_OBJECT_AT_LOCATION object=23(Guards) location=9D
L2FEF               fcb       $0E                 ;         IF_NOT_JUMP address=2FFE
L2FF0               fcb       $0E,$0C             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=12
L2FF2               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FF4               fcb       $03,$9B,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=9B
L2FF7               fcb       $85                 ;               CommonCommand_85
L2FF8               fcb       $0D,$04             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L2FFA               fcb       $03,$9A,$1D         ;               Command_03_IS_OBJECT_AT_LOCATION object=1D(USER) location=9A
L2FFD               fcb       $87                 ;               CommonCommand_87
; Object_25 GemA
L2FFE               fcb       $13,$30             ;   Number=13 size=0030
L3000               fcb       $9C,$00,$A0         ;     room=9C scorePoints=00 bits=A0 u.C.....
L3003               fcb       $02                 ;     02 SHORT NAME
L3004               fcb       $08,$EF,$A6,$51,$54,$4B,$C6,$AF,$6C ;       PRECIOUS GEM
L300D               fcb       $08,$21             ;     08 TURN SCRIPT
L300F               fcb       $0D,$1F             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=31
L3011               fcb       $03,$9C,$25         ;         Command_03_IS_OBJECT_AT_LOCATION object=25(GemA) location=9C
L3014               fcb       $0B,$1A             ;         Command_0B_SWITCH size=1A
L3016               fcb       $05,$33             ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=33
L3018               fcb       $03                 ;           IF_NOT_JUMP address=301C
L3019               fcb       $17,$25,$89         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=89
L301C               fcb       $66                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=66
L301D               fcb       $03                 ;           IF_NOT_JUMP address=3021
L301E               fcb       $17,$25,$94         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=94
L3021               fcb       $99                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=99
L3022               fcb       $03                 ;           IF_NOT_JUMP address=3026
L3023               fcb       $17,$25,$86         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=86
L3026               fcb       $CC                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=CC
L3027               fcb       $03                 ;           IF_NOT_JUMP address=302B
L3028               fcb       $17,$25,$8E         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=8E
L302B               fcb       $FF                 ;           Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FF
L302C               fcb       $03                 ;           IF_NOT_JUMP address=3030
L302D               fcb       $17,$25,$83         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=83
; Object_26 GemB
L3030               fcb       $13,$23             ;   Number=13 size=0023
L3032               fcb       $00,$05,$A0         ;     room=00 scorePoints=05 bits=A0 u.C.....
L3035               fcb       $02                 ;     02 SHORT NAME
L3036               fcb       $08,$EF,$A6,$51,$54,$4B,$C6,$AF,$6C ;       PRECIOUS GEM
L303F               fcb       $03                 ;     03 DESCRIPTION
L3040               fcb       $14,$5F,$BE,$5B,$B1,$4B,$7B,$52,$45,$65,$B1,$C7 ;       THERE IS A PRECIOUS GEM HERE.
L304C               fcb       $7A,$C9,$B5,$5B,$61,$F4,$72,$DB,$63 ;       .
; Object_27 HiddenGem
L3055               fcb       $2A,$32             ;   Number=2A size=0032
L3057               fcb       $FF,$00,$00         ;     room=FF scorePoints=00 bits=00 *
L305A               fcb       $02                 ;     02 SHORT NAME
L305B               fcb       $03,$01,$B3,$4D     ;       ROOM
L305F               fcb       $07,$28             ;     07 COMMAND HANDLING IF FIRST NOUN
L3061               fcb       $0D,$26             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=38
L3063               fcb       $0A,$0B             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=0B phrase="0B: LOOK AT     *          u......."
L3065               fcb       $01,$25             ;         Command_01_IS_OBJECT_IN_PACK_OR_ROOM object=25(GemA)
L3067               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3068               fcb       $20,$C7,$DE,$03,$15,$61,$B7,$74,$CA,$7B,$14,$EF ;           YOU DISCOVER A PRECIOUS GEM HIDDEN IN A
L3074               fcb       $A6,$51,$54,$4B,$C6,$AF,$6C,$A3,$15,$BF,$59,$8B ;           CREVICE.
L3080               fcb       $96,$83,$96,$E4,$14,$D3,$62,$BF,$53 ;           .
; Object_28 UnlitLamp
L3089               fcb       $1B,$62             ;   Number=1B size=0062
L308B               fcb       $00,$00,$AC         ;     room=00 scorePoints=00 bits=AC u.C.AX..
L308E               fcb       $02                 ;     02 SHORT NAME
L308F               fcb       $03,$4F,$8B,$50     ;       LAMP
L3093               fcb       $03                 ;     03 DESCRIPTION
L3094               fcb       $0E,$5F,$BE,$5B,$B1,$4B,$7B,$4E,$45,$72,$48,$9F ;       THERE IS A LAMP HERE.
L30A0               fcb       $15,$7F,$B1         ;       .
L30A3               fcb       $07,$48             ;     07 COMMAND HANDLING IF FIRST NOUN
L30A5               fcb       $0B,$46             ;       Command_0B_SWITCH size=46
L30A7               fcb       $0A,$14             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=14 phrase="14: LIGHT WITH  u...A...   u...A..."
L30A9               fcb       $1C                 ;         IF_NOT_JUMP address=30C6
L30AA               fcb       $0E,$1A             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=26
L30AC               fcb       $0D,$17             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=23
L30AE               fcb       $09,$12             ;               Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=12(LitCandle
L30B0               fcb       $1E,$28,$14         ;               Command_1E_SWAP_OBJECTS objectA=28(UnlitLamp) objectB=14(LitLamp)
L30B3               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L30B4               fcb       $10,$5F,$BE,$3B,$16,$D3,$93,$4B,$7B,$09,$9A,$BF ;                 THE LAMP IS NOW BURNING.
L30C0               fcb       $14,$D3,$B2,$CF,$98 ;                 .
L30C5               fcb       $88                 ;             CommonCommand_88
L30C6               fcb       $18                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=18 phrase="18: RUB *       u.......   *       "
L30C7               fcb       $19                 ;         IF_NOT_JUMP address=30E1
L30C8               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L30C9               fcb       $17,$29,$D1,$09,$15,$51,$18,$56,$C2,$90,$73,$DB ;             WHO DO YOU THINK YOU ARE, ALADDIN?
L30D5               fcb       $83,$1B,$A1,$2F,$49,$03,$EE,$46,$8B,$90,$5A,$3F ;             .
L30E1               fcb       $08                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L30E2               fcb       $0A                 ;         IF_NOT_JUMP address=30ED
L30E3               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L30E4               fcb       $08,$49,$1B,$99,$16,$14,$BC,$A4,$C3 ;             "DO NOT RUB"
; Object_29 Floor
L30ED               fcb       $2B,$09             ;   Number=2B size=0009
L30EF               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L30F2               fcb       $02                 ;     02 SHORT NAME
L30F3               fcb       $04,$89,$67,$A3,$A0 ;       FLOOR
; Object_2A Exit
L30F8               fcb       $2C,$0B             ;   Number=2C size=000B
L30FA               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L30FD               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L30FF               fcb       $93                 ;       CommonCommand_93
L3100               fcb       $02                 ;     02 SHORT NAME
L3101               fcb       $03,$23,$63,$54     ;       EXIT
; Object_2B Passage
L3105               fcb       $2D,$0D             ;   Number=2D size=000D
L3107               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L310A               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L310C               fcb       $93                 ;       CommonCommand_93
L310D               fcb       $02                 ;     02 SHORT NAME
L310E               fcb       $05,$55,$A4,$09,$B7,$45 ;       PASSAGE
; Object_2C Hole
L3114               fcb       $2E,$0B             ;   Number=2E size=000B
L3116               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L3119               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L311B               fcb       $93                 ;       CommonCommand_93
L311C               fcb       $02                 ;     02 SHORT NAME
L311D               fcb       $03,$7E,$74,$45     ;       HOLE
; Object_2D Corridor
L3121               fcb       $2F,$0E             ;   Number=2F size=000E
L3123               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L3126               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L3128               fcb       $93                 ;       CommonCommand_93
L3129               fcb       $02                 ;     02 SHORT NAME
L312A               fcb       $06,$44,$55,$06,$B2,$A3,$A0 ;       CORRIDOR
; Object_2E Corner
L3131               fcb       $30,$09             ;   Number=30 size=0009
L3133               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L3136               fcb       $02                 ;     02 SHORT NAME
L3137               fcb       $04,$44,$55,$74,$98 ;       CORNER
; Object_2F Bow
L313C               fcb       $31,$07             ;   Number=31 size=0007
L313E               fcb       $88,$00,$80         ;     room=88 scorePoints=00 bits=80 u.......
L3141               fcb       $02                 ;     02 SHORT NAME
L3142               fcb       $02,$09,$4F         ;       BOW
; Object_30 Arrow
L3145               fcb       $32,$09             ;   Number=32 size=0009
L3147               fcb       $88,$00,$80         ;     room=88 scorePoints=00 bits=80 u.......
L314A               fcb       $02                 ;     02 SHORT NAME
L314B               fcb       $04,$3C,$49,$6B,$A1 ;       ARROW
; Object_31 Hallway
L3150               fcb       $33,$0D             ;   Number=33 size=000D
L3152               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L3155               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L3157               fcb       $93                 ;       CommonCommand_93
L3158               fcb       $02                 ;     02 SHORT NAME
L3159               fcb       $05,$4E,$72,$B3,$8E,$59 ;       HALLWAY
; Object_32 Chamber
L315F               fcb       $34,$0A             ;   Number=34 size=000A
L3161               fcb       $8D,$00,$80         ;     room=8D scorePoints=00 bits=80 u.......
L3164               fcb       $02                 ;     02 SHORT NAME
L3165               fcb       $05,$1B,$54,$AF,$91,$52 ;       CHAMBER
; Object_33 Vault
L316B               fcb       $35,$09             ;   Number=35 size=0009
L316D               fcb       $91,$00,$80         ;     room=91 scorePoints=00 bits=80 u.......
L3170               fcb       $02                 ;     02 SHORT NAME
L3171               fcb       $04,$D7,$C9,$33,$8E ;       VAULT
; Object_34 Entrance
L3176               fcb       $36,$0E             ;   Number=36 size=000E
L3178               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L317B               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L317D               fcb       $93                 ;       CommonCommand_93
L317E               fcb       $02                 ;     02 SHORT NAME
L317F               fcb       $06,$9E,$61,$D0,$B0,$9B,$53 ;       ENTRANCE
; Object_35 Tunnel
L3186               fcb       $37,$0C             ;   Number=37 size=000C
L3188               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L318B               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L318D               fcb       $93                 ;       CommonCommand_93
L318E               fcb       $02                 ;     02 SHORT NAME
L318F               fcb       $04,$70,$C0,$6E,$98 ;       TUNNEL
; Object_36 Jungle
L3194               fcb       $38,$0C             ;   Number=38 size=000C
L3196               fcb       $FF,$00,$80         ;     room=FF scorePoints=00 bits=80 u.......
L3199               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L319B               fcb       $93                 ;       CommonCommand_93
L319C               fcb       $02                 ;     02 SHORT NAME
L319D               fcb       $04,$F0,$81,$BF,$6D ;       JUNGLE
; Object_37 Temple
L31A2               fcb       $39,$0C             ;   Number=39 size=000C
L31A4               fcb       $FF,$00,$80         ;     room=FF scorePoints=00 bits=80 u.......
L31A7               fcb       $07,$01             ;     07 COMMAND HANDLING IF FIRST NOUN
L31A9               fcb       $93                 ;       CommonCommand_93
L31AA               fcb       $02                 ;     02 SHORT NAME
L31AB               fcb       $04,$EF,$BD,$FF,$A5 ;       TEMPLE
; Object_38 Serpents
L31B0               fcb       $24,$0B             ;   Number=24 size=000B
L31B2               fcb       $9C,$00,$80         ;     room=9C scorePoints=00 bits=80 u.......
L31B5               fcb       $02                 ;     02 SHORT NAME
L31B6               fcb       $06,$B4,$B7,$F0,$A4,$0B,$C0 ;       SERPENTS
; Object_39 Pit
L31BD               fcb       $3A,$31             ;   Number=3A size=0031
L31BF               fcb       $82,$00,$80         ;     room=82 scorePoints=00 bits=80 u.......
L31C2               fcb       $07,$28             ;     07 COMMAND HANDLING IF FIRST NOUN
L31C4               fcb       $0B,$26             ;       Command_0B_SWITCH size=26
L31C6               fcb       $0A,$36             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L31C8               fcb       $01                 ;         IF_NOT_JUMP address=31CA
L31C9               fcb       $8A                 ;           CommonCommand_8A
L31CA               fcb       $33                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=33 phrase="??"
L31CB               fcb       $01                 ;         IF_NOT_JUMP address=31CD
L31CC               fcb       $8A                 ;           CommonCommand_8A
L31CD               fcb       $34                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=34 phrase="34: JUMP OVER   *          u......."
L31CE               fcb       $01                 ;         IF_NOT_JUMP address=31D0
L31CF               fcb       $8A                 ;           CommonCommand_8A
L31D0               fcb       $26                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=26 phrase="26: GO AROUND   *          u......."
L31D1               fcb       $17                 ;         IF_NOT_JUMP address=31E9
L31D2               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L31D3               fcb       $15,$5F,$BE,$5B,$B1,$4B,$7B,$EB,$99,$1B,$D0,$94 ;             THERE IS NO WAY AROUND THE PIT.
L31DF               fcb       $14,$30,$A1,$16,$58,$DB,$72,$96,$A5,$2E ;             .
L31E9               fcb       $17                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L31EA               fcb       $01                 ;         IF_NOT_JUMP address=31EC
L31EB               fcb       $8A                 ;           CommonCommand_8A
L31EC               fcb       $02                 ;     02 SHORT NAME
L31ED               fcb       $02,$96,$A5         ;       PIT
; Object_3A Ceiling
L31F0               fcb       $3B,$0A             ;   Number=3B size=000A
L31F2               fcb       $00,$00,$80         ;     room=00 scorePoints=00 bits=80 u.......
L31F5               fcb       $02                 ;     02 SHORT NAME
L31F6               fcb       $05,$AB,$53,$90,$8C,$47 ;       CEILING
; Object_3B AlterB
L31FC               fcb       $22,$39             ;   Number=22 size=0039
L31FE               fcb       $A5,$00,$80         ;     room=A5 scorePoints=00 bits=80 u.......
L3201               fcb       $02                 ;     02 SHORT NAME
L3202               fcb       $04,$4E,$48,$23,$62 ;       ALTER
L3207               fcb       $07,$2E             ;     07 COMMAND HANDLING IF FIRST NOUN
L3209               fcb       $0D,$2C             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=44
L320B               fcb       $0A,$12             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L320D               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L320E               fcb       $28,$C7,$DE,$D3,$14,$90,$96,$F3,$A0,$C8,$93,$56 ;           YOU CAN NOT MOVE THE ALTER FROM BENEATH IT,
L321A               fcb       $5E,$DB,$72,$4E,$48,$23,$62,$79,$68,$44,$90,$8F ;           IT IS TOO HEAVY.
L3226               fcb       $61,$82,$49,$D6,$15,$0B,$EE,$0B,$BC,$D6,$B5,$2B ;           .
L3232               fcb       $A0,$E3,$72,$9F,$CD ;           .
; Object_3C Object3C
L3237               fcb       $3C,$03             ;   Number=3C size=0003
L3239               fcb       $1D,$00,$80         ;     room=1D scorePoints=00 bits=80 u.......
; ENDOF 20FF


;##GeneralCommands
L323C               fcb       $00,$85,$BB,$0E,$85,$B8 ;   Command_0E_EXECUTE_LIST_WHILE_FAIL size=1464
L3242               fcb       $0D,$2C             ;     Command_0D_EXECUTE_LIST_WHILE_PASS size=44
L3244               fcb       $0E,$08             ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=8
L3246               fcb       $0A,$01             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=01 phrase="01: NORTH *     *          *       "
L3248               fcb       $0A,$02             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=02 phrase="02: SOUTH *     *          *       "
L324A               fcb       $0A,$03             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=03 phrase="03: EAST *      *          *       "
L324C               fcb       $0A,$04             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=04 phrase="04: WEST *      *          *       "
L324E               fcb       $0E,$20             ;       Command_0E_EXECUTE_LIST_WHILE_FAIL size=32
L3250               fcb       $13                 ;         Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3251               fcb       $0D,$1D             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=29
L3253               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3254               fcb       $19,$5F,$BE,$5B,$B1,$4B,$7B,$EB,$99,$1B,$D0,$89 ;             THERE IS NO WAY TO GO THAT DIRECTION.
L3260               fcb       $17,$81,$15,$82,$17,$73,$49,$94,$5A,$E6,$5F,$C0 ;             .
L326C               fcb       $7A,$2E             ;             .
L326E               fcb       $20,$1D             ;           Command_20_CHECK_ACTIVE_OBJECT object=1D(USER)
L3270               fcb       $0B,$85,$83         ;     Command_0B_SWITCH size=583
L3273               fcb       $0A,$05             ;       Command_0A_COMPARE_TO_PHRASE_FORM val=05 phrase="05: GET *       ..C.....   *       "
L3275               fcb       $21                 ;       IF_NOT_JUMP address=3297
L3276               fcb       $0E,$1F             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=31
L3278               fcb       $0D,$19             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=25
L327A               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L327B               fcb       $18                 ;             Command_18_CHECK_VAR_OBJECT_OWNED_BY_ACTIVE_OBJECT
L327C               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L327D               fcb       $13,$C7,$DE,$94,$14,$43,$5E,$EF,$8D,$13,$47,$D3 ;               YOU ARE ALREADY CARRYING THE
L3289               fcb       $14,$83,$B3,$91,$7A,$82,$17,$45 ;               .
L3291               fcb       $16                 ;             Command_16_PRINT_VAR_NOUN_SHORT_NAME
L3292               fcb       $84                 ;             CommonCommand_84
L3293               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3294               fcb       $83                 ;           CommonCommand_83
L3295               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3296               fcb       $0C                 ;             Command_0C_FAIL
L3297               fcb       $06                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=06 phrase="06: DROP *      ..C.....   *       "
L3298               fcb       $0C                 ;       IF_NOT_JUMP address=32A5
L3299               fcb       $0D,$0A             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=10
L329B               fcb       $1A                 ;           Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L329C               fcb       $10                 ;           Command_10_DROP_OBJECT
L329D               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L329E               fcb       $06,$F9,$5B,$9F,$A6,$9B,$5D ;             DROPPED.
L32A5               fcb       $08                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=08 phrase="08: READ *      .....X..   *       "
L32A6               fcb       $17                 ;       IF_NOT_JUMP address=32BE
L32A7               fcb       $0E,$15             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=21
L32A9               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L32AA               fcb       $0D,$12             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=18
L32AC               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L32AD               fcb       $0E,$89,$74,$D3,$14,$9B,$96,$1B,$A1,$63,$B1,$16 ;               HOW CAN YOU READ THE
L32B9               fcb       $58,$DB,$72         ;               .
L32BC               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L32BD               fcb       $84                 ;             CommonCommand_84
L32BE               fcb       $11                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=11 phrase="11: OPEN *      u.......   *       "
L32BF               fcb       $16                 ;       IF_NOT_JUMP address=32D6
L32C0               fcb       $0E,$14             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=20
L32C2               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L32C3               fcb       $0D,$11             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=17
L32C5               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L32C6               fcb       $0D,$EB,$99,$0F,$A0,$D3,$14,$91,$96,$F0,$A4,$82 ;               NO ONE CAN OPEN THE
L32D2               fcb       $17,$45             ;               .
L32D4               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L32D5               fcb       $84                 ;             CommonCommand_84
L32D6               fcb       $12                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=12 phrase="12: PULL *      u.......   *       "
L32D7               fcb       $21                 ;       IF_NOT_JUMP address=32F9
L32D8               fcb       $0E,$1F             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=31
L32DA               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L32DB               fcb       $0D,$1C             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=28
L32DD               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L32DE               fcb       $13,$33,$D1,$09,$15,$E6,$96,$51,$18,$4E,$C2,$98 ;               WHY DON'T YOU LEAVE THE POOR
L32EA               fcb       $5F,$56,$5E,$DB,$72,$81,$A6,$52 ;               .
L32F2               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L32F3               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L32F4               fcb       $04,$49,$48,$7F,$98 ;               ALONE.
L32F9               fcb       $09                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=09 phrase="09: ATTACK WITH ...P....   .v......"
L32FA               fcb       $81,$37             ;       IF_NOT_JUMP address=3433
L32FC               fcb       $0E,$81,$34         ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=308
L32FF               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3300               fcb       $1B                 ;             Command_1B_SET_VAR_OBJECT_TO_SECOND_NOUN
L3301               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3302               fcb       $0E,$03             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=3
L3304               fcb       $09,$17             ;               Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=17(Hands
L3306               fcb       $83                 ;               CommonCommand_83
L3307               fcb       $0E,$81,$29         ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=297
L330A               fcb       $0D,$1F             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=31
L330C               fcb       $14                 ;               Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L330D               fcb       $15,$40             ;                 Command_15_CHECK_OBJECT_BITS bits=40 .v......
L330F               fcb       $14                 ;               Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3310               fcb       $09,$17             ;                 Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=17(Hands
L3312               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3313               fcb       $0C,$C7,$DE,$D3,$14,$E6,$96,$AF,$15,$B3,$B3,$5F ;                 YOU CAN'T HURT THE
L331F               fcb       $BE                 ;                 .
L3320               fcb       $11                 ;               Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3321               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3322               fcb       $06,$56,$D1,$16,$71,$DB,$72 ;                 WITH THE
L3329               fcb       $12                 ;               Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L332A               fcb       $84                 ;               CommonCommand_84
L332B               fcb       $13                 ;             Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L332C               fcb       $0D,$1A             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=26
L332E               fcb       $1A                 ;               Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L332F               fcb       $14                 ;               Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3330               fcb       $15,$10             ;                 Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L3332               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3333               fcb       $12,$73,$7B,$77,$5B,$D0,$B5,$C9,$9C,$36,$A0,$89 ;                 IT DOES NO GOOD TO ATTACK A
L333F               fcb       $17,$96,$14,$45,$BD,$C3,$83 ;                 .
L3346               fcb       $11                 ;               Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3347               fcb       $84                 ;               CommonCommand_84
L3348               fcb       $0D,$80,$D7         ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=215
L334B               fcb       $1A                 ;               Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L334C               fcb       $0B,$80,$D3         ;               Command_0B_SWITCH size=D3
L334F               fcb       $09,$09             ;                 Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=09(Sword
L3351               fcb       $80,$99             ;                 IF_NOT_JUMP address=33EC
L3353               fcb       $0B,$80,$96         ;                   Command_0B_SWITCH size=96
L3356               fcb       $05,$52             ;                     Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=52
L3358               fcb       $28                 ;                     IF_NOT_JUMP address=3381
L3359               fcb       $0D,$26             ;                       Command_0D_EXECUTE_LIST_WHILE_PASS size=38
L335B               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L335C               fcb       $17,$4F,$45,$7A,$79,$FB,$C0,$6C,$BE,$66,$C6,$04 ;                           A MIGHTY THRUST, BUT IT MISSES THE
L3368               fcb       $EE,$73,$C6,$73,$7B,$D5,$92,$B5,$B7,$82,$17,$45 ;                           .
L3374               fcb       $16                 ;                         Command_16_PRINT_VAR_NOUN_SHORT_NAME
L3375               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3376               fcb       $0A,$7B,$50,$4D,$45,$49,$7A,$36,$92,$21,$62 ;                           BY A KILOMETER!
L3381               fcb       $A4                 ;                     Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=A4
L3382               fcb       $2D                 ;                     IF_NOT_JUMP address=33B0
L3383               fcb       $0D,$2B             ;                       Command_0D_EXECUTE_LIST_WHILE_PASS size=43
L3385               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3386               fcb       $1C,$89,$4E,$73,$9E,$F5,$B3,$F5,$72,$59,$15,$C2 ;                           BLOOD RUSHES FORTH AS YOU HAVE SLASHED THE
L3392               fcb       $B3,$95,$14,$51,$18,$4A,$C2,$CF,$49,$5E,$17,$5A ;                           .
L339E               fcb       $49,$F3,$5F,$5F,$BE ;                           .
L33A3               fcb       $16                 ;                         Command_16_PRINT_VAR_NOUN_SHORT_NAME
L33A4               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L33A5               fcb       $08,$83,$7A,$5F,$BE,$94,$14,$EB,$8F ;                           IN THE ARM!
L33AE               fcb       $1D,$0A             ;                         Command_1D_ATTACK_OBJECT damage=0A
L33B0               fcb       $FD                 ;                     Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FD
L33B1               fcb       $20                 ;                     IF_NOT_JUMP address=33D2
L33B2               fcb       $0D,$1E             ;                       Command_0D_EXECUTE_LIST_WHILE_PASS size=30
L33B4               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L33B5               fcb       $1A,$C7,$DE,$63,$16,$C9,$97,$43,$5E,$84,$15,$73 ;                           YOU MANAGE A GRAZING BLOW TO THE CHEST!
L33C1               fcb       $4A,$AB,$98,$89,$4E,$D6,$CE,$D6,$9C,$DB,$72,$1F ;                           .
L33CD               fcb       $54,$F1,$B9         ;                           .
L33D0               fcb       $1D,$14             ;                         Command_1D_ATTACK_OBJECT damage=14
L33D2               fcb       $FF                 ;                     Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FF
L33D3               fcb       $18                 ;                     IF_NOT_JUMP address=33EC
L33D4               fcb       $0D,$16             ;                       Command_0D_EXECUTE_LIST_WHILE_PASS size=22
L33D6               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L33D7               fcb       $12,$4E,$45,$DD,$C3,$44,$DB,$89,$8D,$89,$17,$82 ;                           A LUCKY BLOW TO THE HEART!
L33E3               fcb       $17,$4A,$5E,$94,$5F,$AB,$BB ;                           .
L33EA               fcb       $1D,$FF             ;                         Command_1D_ATTACK_OBJECT damage=FF
L33EC               fcb       $17                 ;                 Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=17(Hands
L33ED               fcb       $34                 ;                 IF_NOT_JUMP address=3422
L33EE               fcb       $0B,$32             ;                   Command_0B_SWITCH size=32
L33F0               fcb       $05,$AF             ;                     Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=AF
L33F2               fcb       $14                 ;                     IF_NOT_JUMP address=3407
L33F3               fcb       $04                 ;                       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L33F4               fcb       $12,$59,$45,$3E,$7A,$EF,$16,$1A,$98,$90,$14,$1B ;                         A WILD PUNCH AND YOU MISS.
L3400               fcb       $58,$1B,$A1,$D5,$92,$5B,$BB ;                         .
L3407               fcb       $FF                 ;                     Command_05_IS_LAST_RANDOM_LESS_THAN_OR_EQUAL value=FF
L3408               fcb       $19                 ;                     IF_NOT_JUMP address=3422
L3409               fcb       $0D,$17             ;                       Command_0D_EXECUTE_LIST_WHILE_PASS size=23
L340B               fcb       $04                 ;                         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L340C               fcb       $13,$C7,$DE,$EF,$16,$1A,$98,$F3,$5F,$8F,$73,$D0 ;                           YOU PUNCHED HIM IN THE HEAD!
L3418               fcb       $15,$82,$17,$4A,$5E,$86,$5F,$21 ;                           .
L3420               fcb       $1D,$03             ;                         Command_1D_ATTACK_OBJECT damage=03
L3422               fcb       $0D,$0F             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=15
L3424               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3425               fcb       $02,$5F,$BE         ;                 THE
L3428               fcb       $11                 ;               Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3429               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L342A               fcb       $08,$4B,$7B,$92,$C5,$37,$49,$17,$60 ;                 IS UNHARMED.
L3433               fcb       $0A                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=0A phrase="0A: LOOK *      *          *       "
L3434               fcb       $01                 ;       IF_NOT_JUMP address=3436
L3435               fcb       $07                 ;         Command_07_PRINT_ROOM_DESCRIPTION
L3436               fcb       $15                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=15 phrase="15: EAT *       u.......   *       "
L3437               fcb       $29                 ;       IF_NOT_JUMP address=3461
L3438               fcb       $0E,$27             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=39
L343A               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L343B               fcb       $0D,$24             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=36
L343D               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L343E               fcb       $0D,$80,$5B,$F3,$23,$5B,$4D,$4E,$B8,$F9,$8E,$82 ;               DON'T BE SILLY! THE
L344A               fcb       $17,$45             ;               .
L344C               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L344D               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L344E               fcb       $12,$47,$D2,$C8,$8B,$F3,$23,$55,$BD,$DB,$BD,$41 ;               WOULDN'T TASTE GOOD ANYWAY.
L345A               fcb       $6E,$03,$58,$99,$9B,$5F,$4A ;               .
L3461               fcb       $17                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=17 phrase="17: CLIMB *     u.......   *       "
L3462               fcb       $51                 ;       IF_NOT_JUMP address=34B4
L3463               fcb       $0E,$4F             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=79
L3465               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3466               fcb       $0D,$25             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=37
L3468               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L3469               fcb       $15,$10             ;             Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L346B               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L346C               fcb       $0C,$46,$77,$05,$A0,$16,$BC,$90,$73,$D6,$83,$DB ;               I DON'T THINK THE
L3478               fcb       $72                 ;               .
L3479               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L347A               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L347B               fcb       $11,$4E,$D1,$15,$8A,$50,$BD,$15,$58,$8E,$BE,$08 ;               WILL STAND STILL FORTHAT.
L3487               fcb       $8A,$BE,$A0,$56,$72,$2E ;               .
L348D               fcb       $0D,$25             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=37
L348F               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3490               fcb       $12,$CF,$62,$8B,$96,$9B,$64,$1B,$A1,$47,$55,$B3 ;               EVEN IF YOU COULD CLIMB THE
L349C               fcb       $8B,$C3,$54,$A3,$91,$5F,$BE ;               .
L34A3               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L34A4               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L34A5               fcb       $0E,$73,$7B,$47,$D2,$C8,$8B,$F3,$23,$EE,$72,$1B ;               IT WOULDN'T HELP YOU.
L34B1               fcb       $A3,$3F,$A1         ;               .
L34B4               fcb       $16                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=16 phrase="16: DROP OUT    *          u...A..."
L34B5               fcb       $16                 ;       IF_NOT_JUMP address=34CC
L34B6               fcb       $0E,$14             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=20
L34B8               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L34B9               fcb       $0D,$11             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=17
L34BB               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L34BC               fcb       $02,$5F,$BE         ;               THE
L34BF               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L34C0               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L34C1               fcb       $0A,$4B,$7B,$06,$9A,$BF,$14,$D3,$B2,$CF,$98 ;               IS NOT BURNING.
L34CC               fcb       $18                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=18 phrase="18: RUB *       u.......   *       "
L34CD               fcb       $35                 ;       IF_NOT_JUMP address=3503
L34CE               fcb       $0E,$33             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=51
L34D0               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L34D1               fcb       $0D,$18             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=24
L34D3               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L34D4               fcb       $15,$10             ;             Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L34D6               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L34D7               fcb       $11,$5B,$BE,$65,$BC,$99,$16,$F3,$17,$56,$DB,$CA ;               THAT'S NO WAY TO HURT THE
L34E3               fcb       $9C,$3E,$C6,$82,$17,$45 ;               .
L34E9               fcb       $16                 ;             Command_16_PRINT_VAR_NOUN_SHORT_NAME
L34EA               fcb       $84                 ;             CommonCommand_84
L34EB               fcb       $0D,$16             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=22
L34ED               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L34EE               fcb       $02,$5F,$BE         ;               THE
L34F1               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L34F2               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L34F3               fcb       $0F,$81,$8D,$CB,$87,$A5,$94,$04,$71,$8E,$62,$23 ;               LOOKS MUCH BETTER NOW.
L34FF               fcb       $62,$09,$9A,$2E     ;               .
L3503               fcb       $0B                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=0B phrase="0B: LOOK AT     *          u......."
L3504               fcb       $3A                 ;       IF_NOT_JUMP address=353F
L3505               fcb       $0E,$38             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=56
L3507               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3508               fcb       $0D,$19             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=25
L350A               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L350B               fcb       $15,$04             ;             Command_15_CHECK_OBJECT_BITS bits=04 .....X..
L350D               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L350E               fcb       $12,$3F,$B9,$82,$62,$91,$7A,$D5,$15,$04,$18,$8E ;               SOMETHING IS WRITTEN ON THE
L351A               fcb       $7B,$83,$61,$03,$A0,$5F,$BE ;               .
L3521               fcb       $16                 ;             Command_16_PRINT_VAR_NOUN_SHORT_NAME
L3522               fcb       $84                 ;             CommonCommand_84
L3523               fcb       $0D,$1A             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=26
L3525               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3526               fcb       $16,$5F,$BE,$5D,$B1,$D0,$B5,$02,$A1,$91,$7A,$62 ;               THERE'S NOTHING SPECIAL ABOUT THE
L3532               fcb       $17,$DB,$5F,$33,$48,$B9,$46,$73,$C6,$5F,$BE ;               .
L353D               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L353E               fcb       $84                 ;             CommonCommand_84
L353F               fcb       $0C                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=0C phrase="0C: LOOK UNDER  *          u......."
L3540               fcb       $1A                 ;       IF_NOT_JUMP address=355B
L3541               fcb       $0E,$18             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=24
L3543               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3544               fcb       $0D,$15             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=21
L3546               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3547               fcb       $11,$5F,$BE,$5D,$B1,$D0,$B5,$02,$A1,$91,$7A,$B0 ;               THERE'S NOTHING UNDER THE
L3553               fcb       $17,$F4,$59,$82,$17,$45 ;               .
L3559               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L355A               fcb       $84                 ;             CommonCommand_84
L355B               fcb       $10                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=10 phrase="10: LOOK IN     *          u......."
L355C               fcb       $18                 ;       IF_NOT_JUMP address=3575
L355D               fcb       $0E,$16             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=22
L355F               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3560               fcb       $0D,$13             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=19
L3562               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3563               fcb       $0F,$5F,$BE,$5D,$B1,$D0,$B5,$02,$A1,$91,$7A,$D0 ;               THERE'S NOTHING IN THE
L356F               fcb       $15,$82,$17,$45     ;               .
L3573               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3574               fcb       $84                 ;             CommonCommand_84
L3575               fcb       $1B                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=1B phrase="1B: LOOK AROUND *          u......."
L3576               fcb       $20                 ;       IF_NOT_JUMP address=3597
L3577               fcb       $0E,$1E             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=30
L3579               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L357A               fcb       $0D,$03             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L357C               fcb       $08,$00             ;             Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=00(NONE
L357E               fcb       $07                 ;             Command_07_PRINT_ROOM_DESCRIPTION
L357F               fcb       $0D,$16             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=22
L3581               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3582               fcb       $12,$5F,$BE,$5B,$B1,$4B,$7B,$06,$9A,$90,$73,$C3 ;               THERE IS NOTHING AROUND THE
L358E               fcb       $6A,$07,$B3,$33,$98,$5F,$BE ;               .
L3595               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3596               fcb       $84                 ;             CommonCommand_84
L3597               fcb       $1C                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=1C phrase="1C: LOOK BEHIND *          u......."
L3598               fcb       $34                 ;       IF_NOT_JUMP address=35CD
L3599               fcb       $0E,$32             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=50
L359B               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L359C               fcb       $0D,$17             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=23
L359E               fcb       $08,$00             ;             Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=00(NONE
L35A0               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L35A1               fcb       $13,$5F,$BE,$5B,$B1,$4B,$7B,$06,$9A,$90,$73,$C4 ;               THERE IS NOTHING BEHIND YOU.
L35AD               fcb       $6A,$A3,$60,$33,$98,$C7,$DE,$2E ;               .
L35B5               fcb       $0D,$16             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=22
L35B7               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L35B8               fcb       $12,$5F,$BE,$5B,$B1,$4B,$7B,$06,$9A,$90,$73,$C4 ;               THERE IS NOTHING BEHIND THE
L35C4               fcb       $6A,$A3,$60,$33,$98,$5F,$BE ;               .
L35CB               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L35CC               fcb       $84                 ;             CommonCommand_84
L35CD               fcb       $21                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=21 phrase="21: PLUGH *     *          *       "
L35CE               fcb       $0A                 ;       IF_NOT_JUMP address=35D9
L35CF               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L35D0               fcb       $08,$B5,$6C,$8E,$C5,$EB,$72,$AB,$BB ;           GESUNDHEIT!
L35D9               fcb       $22                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=22 phrase="22: SCREAM *    *          *       "
L35DA               fcb       $12                 ;       IF_NOT_JUMP address=35ED
L35DB               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L35DC               fcb       $10,$5B,$E0,$27,$60,$31,$60,$41,$A0,$49,$A0,$89 ;           YYYEEEEEOOOOOOWWWWWWWW!!
L35E8               fcb       $D3,$89,$D3,$69,$CE ;           .
L35ED               fcb       $23                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=23 phrase="23: QUIT *      *          *       "
L35EE               fcb       $05                 ;       IF_NOT_JUMP address=35F4
L35EF               fcb       $0D,$03             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=3
L35F1               fcb       $92                 ;           CommonCommand_92
L35F2               fcb       $26                 ;           Command_26_PRINT_SCORE
L35F3               fcb       $24                 ;           Command_24_ENDLESS_LOOP
L35F4               fcb       $2C                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=2C phrase="2C: SCORE *     *          *       "
L35F5               fcb       $04                 ;       IF_NOT_JUMP address=35FA
L35F6               fcb       $0D,$02             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=2
L35F8               fcb       $92                 ;           CommonCommand_92
L35F9               fcb       $26                 ;           Command_26_PRINT_SCORE
L35FA               fcb       $3E                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=3E phrase="??"
L35FB               fcb       $01                 ;       IF_NOT_JUMP address=35FD
L35FC               fcb       $27                 ;         Command_27_??_UNKNOWN_COMMAND_??
L35FD               fcb       $3F                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=3F phrase="??"
L35FE               fcb       $01                 ;       IF_NOT_JUMP address=3600
L35FF               fcb       $28                 ;         Command_28_??_UNKNOWN_COMMAND_??
L3600               fcb       $25                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=25 phrase="25: LEAVE *     *          *       "
L3601               fcb       $0D                 ;       IF_NOT_JUMP address=360F
L3602               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3603               fcb       $0B,$03,$C0,$7B,$14,$94,$5A,$E6,$5F,$C0,$7A,$2E ;           TRY A DIRECTION.
L360F               fcb       $26                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=26 phrase="26: GO AROUND   *          u......."
L3610               fcb       $24                 ;       IF_NOT_JUMP address=3635
L3611               fcb       $0E,$22             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=34
L3613               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3614               fcb       $0D,$17             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=23
L3616               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L3617               fcb       $15,$10             ;             Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L3619               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L361A               fcb       $02,$5F,$BE         ;               THE
L361D               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L361E               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L361F               fcb       $0D,$40,$D2,$F3,$23,$F6,$8B,$51,$18,$52,$C2,$65 ;               WON'T LET YOU PASS!
L362B               fcb       $49,$21             ;               .
L362D               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L362E               fcb       $06,$09,$9A,$FA,$17,$70,$49 ;             NOW WHAT?
L3635               fcb       $3D                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=3D phrase="3D: GO TO       *          u......."
L3636               fcb       $01                 ;       IF_NOT_JUMP address=3638
L3637               fcb       $94                 ;         CommonCommand_94
L3638               fcb       $27                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=27 phrase="27: KICK *      u.......   *       "
L3639               fcb       $0E                 ;       IF_NOT_JUMP address=3648
L363A               fcb       $0E,$0C             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=12
L363C               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L363D               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L363E               fcb       $09,$25,$A1,$AB,$70,$3B,$95,$77,$BF,$21 ;             OUCH! MY TOE!
L3648               fcb       $28                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=28 phrase="28: FEED WITH   ...P....   u......."
L3649               fcb       $0A                 ;       IF_NOT_JUMP address=3654
L364A               fcb       $0E,$08             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=8
L364C               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L364D               fcb       $0D,$04             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L364F               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L3650               fcb       $15,$10             ;             Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L3652               fcb       $96                 ;             CommonCommand_96
L3653               fcb       $97                 ;           CommonCommand_97
L3654               fcb       $29                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=29 phrase="29: FEED TO     u.......   ...P...."
L3655               fcb       $0A                 ;       IF_NOT_JUMP address=3660
L3656               fcb       $0E,$08             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=8
L3658               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3659               fcb       $0D,$04             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=4
L365B               fcb       $1B                 ;             Command_1B_SET_VAR_OBJECT_TO_SECOND_NOUN
L365C               fcb       $15,$10             ;             Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L365E               fcb       $96                 ;             CommonCommand_96
L365F               fcb       $97                 ;           CommonCommand_97
L3660               fcb       $2F                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=2F phrase="2F: WAIT *      *          *       "
L3661               fcb       $07                 ;       IF_NOT_JUMP address=3669
L3662               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3663               fcb       $05,$9B,$29,$57,$C6,$3E ;           <PAUSE>
L3669               fcb       $2D                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=2D phrase="2D: PULL UP     *          u......."
L366A               fcb       $09                 ;       IF_NOT_JUMP address=3674
L366B               fcb       $0E,$07             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=7
L366D               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L366E               fcb       $0D,$02             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=2
L3670               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L3671               fcb       $83                 ;             CommonCommand_83
L3672               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3673               fcb       $0C                 ;             Command_0C_FAIL
L3674               fcb       $33                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=33 phrase="??"
L3675               fcb       $04                 ;       IF_NOT_JUMP address=367A
L3676               fcb       $0E,$02             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=2
L3678               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3679               fcb       $98                 ;           CommonCommand_98
L367A               fcb       $34                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=34 phrase="34: JUMP OVER   *          u......."
L367B               fcb       $04                 ;       IF_NOT_JUMP address=3680
L367C               fcb       $0E,$02             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=2
L367E               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L367F               fcb       $98                 ;           CommonCommand_98
L3680               fcb       $36                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L3681               fcb       $17                 ;       IF_NOT_JUMP address=3699
L3682               fcb       $0E,$15             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=21
L3684               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3685               fcb       $0D,$12             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=18
L3687               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3688               fcb       $0E,$C7,$DE,$D3,$14,$E6,$96,$77,$15,$0B,$BC,$96 ;               YOU CAN'T GET IN THE
L3694               fcb       $96,$DB,$72         ;               .
L3697               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3698               fcb       $84                 ;             CommonCommand_84
L3699               fcb       $37                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=37 phrase="37: CLIMB OUT   *          *       "
L369A               fcb       $15                 ;       IF_NOT_JUMP address=36B0
L369B               fcb       $0E,$13             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=19
L369D               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L369E               fcb       $0D,$10             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=16
L36A0               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L36A1               fcb       $0C,$C7,$DE,$94,$14,$85,$61,$0B,$BC,$96,$96,$DB ;               YOU AREN'T IN THE
L36AD               fcb       $72                 ;               .
L36AE               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L36AF               fcb       $84                 ;             CommonCommand_84
L36B0               fcb       $38                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=38 phrase="38: CLIMB UNDER *          u......."
L36B1               fcb       $20                 ;       IF_NOT_JUMP address=36D2
L36B2               fcb       $0E,$1E             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=30
L36B4               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L36B5               fcb       $0D,$1B             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=27
L36B7               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L36B8               fcb       $17,$5F,$BE,$5B,$B1,$4B,$7B,$06,$9A,$30,$15,$29 ;               THERE IS NOT ENOUGH ROOM UNDER THE
L36C4               fcb       $A1,$14,$71,$3F,$A0,$B0,$17,$F4,$59,$82,$17,$45 ;               .
L36D0               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L36D1               fcb       $84                 ;             CommonCommand_84
L36D2               fcb       $39                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=39 phrase="39: THROW IN    u.......   u......."
L36D3               fcb       $1D                 ;       IF_NOT_JUMP address=36F1
L36D4               fcb       $0E,$1B             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=27
L36D6               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L36D7               fcb       $0D,$18             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=24
L36D9               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L36DA               fcb       $16,$C7,$DE,$FB,$17,$F3,$8C,$58,$72,$56,$5E,$D2 ;               YOU WILL HAVE TO PUT IT IN THERE.
L36E6               fcb       $9C,$73,$C6,$73,$7B,$83,$7A,$5F,$BE,$7F,$B1 ;               .
L36F1               fcb       $3A                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=3A phrase="3A: OPEN WITH   u.......   u......."
L36F2               fcb       $1E                 ;       IF_NOT_JUMP address=3711
L36F3               fcb       $0E,$1C             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=28
L36F5               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L36F6               fcb       $0D,$19             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=25
L36F8               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L36F9               fcb       $0C,$C7,$DE,$D3,$14,$E6,$96,$C2,$16,$83,$61,$5F ;               YOU CAN'T OPEN THE
L3705               fcb       $BE                 ;               .
L3706               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L3707               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3708               fcb       $06,$56,$D1,$16,$71,$DB,$72 ;               WITH THE
L370F               fcb       $12                 ;             Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L3710               fcb       $84                 ;             CommonCommand_84
L3711               fcb       $0D                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=0D phrase="0D: THROW AT    .v......   ...P...."
L3712               fcb       $34                 ;       IF_NOT_JUMP address=3747
L3713               fcb       $0E,$32             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=50
L3715               fcb       $0D,$2E             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=46
L3717               fcb       $1A                 ;             Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L3718               fcb       $83                 ;             CommonCommand_83
L3719               fcb       $0E,$2A             ;             Command_0E_EXECUTE_LIST_WHILE_FAIL size=42
L371B               fcb       $0D,$27             ;               Command_0D_EXECUTE_LIST_WHILE_PASS size=39
L371D               fcb       $0E,$07             ;                 Command_0E_EXECUTE_LIST_WHILE_FAIL size=7
L371F               fcb       $14                 ;                   Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3720               fcb       $15,$10             ;                     Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L3722               fcb       $1B                 ;                   Command_1B_SET_VAR_OBJECT_TO_SECOND_NOUN
L3723               fcb       $14                 ;                   Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3724               fcb       $15,$40             ;                     Command_15_CHECK_OBJECT_BITS bits=40 .v......
L3726               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3727               fcb       $02,$5F,$BE         ;                   THE
L372A               fcb       $11                 ;                 Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L372B               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L372C               fcb       $14,$07,$4F,$17,$98,$CA,$B5,$37,$49,$F5,$8B,$D3 ;                   BOUNCES HARMLESSLY OFF OF THE
L3738               fcb       $B8,$B8,$16,$91,$64,$96,$64,$DB,$72 ;                   .
L3741               fcb       $12                 ;                 Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L3742               fcb       $84                 ;                 CommonCommand_84
L3743               fcb       $10                 ;                 Command_10_DROP_OBJECT
L3744               fcb       $13                 ;               Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3745               fcb       $14                 ;           Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L3746               fcb       $0C                 ;             Command_0C_FAIL
L3747               fcb       $0E                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=0E phrase="0E: THROW TO    u.......   ...P...."
L3748               fcb       $39                 ;       IF_NOT_JUMP address=3782
L3749               fcb       $0E,$37             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=55
L374B               fcb       $0D,$1B             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=27
L374D               fcb       $1B                 ;             Command_1B_SET_VAR_OBJECT_TO_SECOND_NOUN
L374E               fcb       $14                 ;             Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L374F               fcb       $15,$10             ;               Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L3751               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3752               fcb       $02,$5F,$BE         ;               THE
L3755               fcb       $12                 ;             Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L3756               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3757               fcb       $10,$4B,$7B,$06,$9A,$85,$14,$B2,$53,$90,$BE,$C9 ;               IS NOT ACCEPTING GIFTS.
L3763               fcb       $6A,$5E,$79,$5B,$BB ;               .
L3768               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3769               fcb       $0D,$17             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=23
L376B               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L376C               fcb       $02,$5F,$BE         ;               THE
L376F               fcb       $12                 ;             Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L3770               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3771               fcb       $10,$60,$7B,$F3,$23,$D5,$46,$EE,$61,$91,$7A,$BC ;               ISN'T ACCEPTING BRIBES.
L377D               fcb       $14,$AF,$78,$5B,$BB ;               .
L3782               fcb       $0F                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=0F phrase="0F: DROP IN     u.......   u......."
L3783               fcb       $19                 ;       IF_NOT_JUMP address=379D
L3784               fcb       $0E,$17             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=23
L3786               fcb       $13                 ;           Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L3787               fcb       $0D,$14             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=20
L3789               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L378A               fcb       $02,$5F,$BE         ;               THE
L378D               fcb       $11                 ;             Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L378E               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L378F               fcb       $0B,$40,$D2,$F3,$23,$16,$67,$D0,$15,$82,$17,$45 ;               WON'T FIT IN THE
L379B               fcb       $12                 ;             Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L379C               fcb       $84                 ;             CommonCommand_84
L379D               fcb       $14                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=14 phrase="14: LIGHT WITH  u...A...   u...A..."
L379E               fcb       $3B                 ;       IF_NOT_JUMP address=37DA
L379F               fcb       $0D,$39             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=57
L37A1               fcb       $1B                 ;           Command_1B_SET_VAR_OBJECT_TO_SECOND_NOUN
L37A2               fcb       $83                 ;           CommonCommand_83
L37A3               fcb       $0E,$35             ;           Command_0E_EXECUTE_LIST_WHILE_FAIL size=53
L37A5               fcb       $0D,$18             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=24
L37A7               fcb       $1A                 ;               Command_1A_SET_VAR_OBJECT_TO_FIRST_NOUN
L37A8               fcb       $15,$08             ;               Command_15_CHECK_OBJECT_BITS bits=08 ....A...
L37AA               fcb       $0E,$04             ;               Command_0E_EXECUTE_LIST_WHILE_FAIL size=4
L37AC               fcb       $09,$12             ;                 Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=12(LitCandle
L37AE               fcb       $09,$14             ;                 Command_09_COMPARE_OBJECT_TO_SECOND_NOUN object=14(LitLamp
L37B0               fcb       $0E,$0D             ;               Command_0E_EXECUTE_LIST_WHILE_FAIL size=13
L37B2               fcb       $13                 ;                 Command_13_PROCESS_PHRASE_BY_ROOM_OR_FIRST_OR_SECOND
L37B3               fcb       $04                 ;                 Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L37B4               fcb       $0A,$73,$7B,$40,$D2,$F3,$23,$F4,$4F,$1B,$9C ;                   IT WON'T BURN.
L37BF               fcb       $0D,$19             ;             Command_0D_EXECUTE_LIST_WHILE_PASS size=25
L37C1               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L37C2               fcb       $0C,$C7,$DE,$D3,$14,$E6,$96,$BF,$14,$C3,$B2,$5F ;                 YOU CAN'T BURN THE
L37CE               fcb       $BE                 ;                 .
L37CF               fcb       $11                 ;               Command_11_PRINT_FIRST_NOUN_SHORT_NAME
L37D0               fcb       $04                 ;               Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L37D1               fcb       $06,$56,$D1,$16,$71,$DB,$72 ;                 WITH THE
L37D8               fcb       $12                 ;               Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L37D9               fcb       $84                 ;               CommonCommand_84
L37DA               fcb       $07                 ;       Command_0A_COMPARE_TO_PHRASE_FORM val=07 phrase="07: INVENT *    *          *       "
L37DB               fcb       $1A                 ;       IF_NOT_JUMP address=37F6
L37DC               fcb       $0D,$18             ;         Command_0D_EXECUTE_LIST_WHILE_PASS size=24
L37DE               fcb       $04                 ;           Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L37DF               fcb       $15,$C7,$DE,$94,$14,$45,$5E,$3C,$49,$D0,$DD,$D6 ;             YOU ARE CARRYING THE FOLLOWING:
L37EB               fcb       $6A,$DB,$72,$FE,$67,$89,$8D,$91,$7A,$3A ;             .
L37F5               fcb       $06                 ;           Command_06_PRINT_INVENTORY
L37F6               fcb       $04                 ;     Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L37F7               fcb       $02,$00,$00         ;       ???
; ENDOF 323C

;##HelperCommands
L37FA               fcb       $00,$84,$2C         ; Script list size=042C
L37FD               fcb       $81,$63             ;   Script number=81 size=042C
L37FF               fcb       $0D,$61             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=97
L3801               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L3802               fcb       $10,$C7,$DE,$AF,$23,$FF,$14,$17,$47,$8C,$17,$43 ;           YOU'RE DEAD. TRY AGAIN.
L380E               fcb       $DB,$0B,$6C,$1B,$9C ;           .
L3813               fcb       $95                 ;         CommonCommand_95
L3814               fcb       $17,$01,$81         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=01(Object1) location=81
L3817               fcb       $17,$05,$84         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=05(Food) location=84
L381A               fcb       $17,$06,$88         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=06(StatueEast) location=88
L381D               fcb       $17,$07,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=07(StatueWest) location=00
L3820               fcb       $17,$08,$8C         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=08(GoldRing) location=8C
L3823               fcb       $17,$09,$A1         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=09(Sword) location=A1
L3826               fcb       $17,$0A,$8E         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=0A(StoneGargoyle) location=8E
L3829               fcb       $17,$0C,$95         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=0C(Idol) location=95
L382C               fcb       $17,$0E,$91         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=0E(UnpulledLever) location=91
L382F               fcb       $17,$0F,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=0F(PulledLever) location=00
L3832               fcb       $17,$11,$92         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=11(UnlitCandle) location=92
L3835               fcb       $17,$12,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=12(LitCandle) location=00
L3838               fcb       $17,$14,$A0         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=14(LitLamp) location=A0
L383B               fcb       $17,$15,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=15(LiveSerpent) location=00
L383E               fcb       $17,$16,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=16(DeadSerpent) location=00
L3841               fcb       $17,$18,$9C         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=18(Coin) location=9C
L3844               fcb       $17,$1E,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1E(LiveGargoyle) location=00
L3847               fcb       $17,$1F,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1F(DeadGargoyle) location=00
L384A               fcb       $17,$22,$8F         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=22(GoldenChopstick) location=8F
L384D               fcb       $17,$25,$9C         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=9C
L3850               fcb       $17,$26,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=26(GemB) location=00
L3853               fcb       $17,$28,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=28(UnlitLamp) location=00
L3856               fcb       $1C,$15             ;         Command_1C_SET_VAR_OBJECT object=15 (LiveSerpent)
L3858               fcb       $23,$3C             ;         Command_23_HEAL_VAR_OBJECT value=3C
L385A               fcb       $1C,$1D             ;         Command_1C_SET_VAR_OBJECT object=1D (USER)
L385C               fcb       $23,$46             ;         Command_23_HEAL_VAR_OBJECT value=46
L385E               fcb       $17,$1D,$96         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=1D(USER) location=96
L3861               fcb       $25                 ;         Command_25_RESTART_GAME
L3862               fcb       $82,$2C             ;   Script number=82 size=042C
L3864               fcb       $0D,$2A             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=42
L3866               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L3867               fcb       $27,$5F,$BE,$66,$17,$8F,$49,$54,$5E,$3F,$61,$57 ;           THE STATUE RELEASES THE ARROW WHICH
L3873               fcb       $49,$D6,$B5,$DB,$72,$3C,$49,$6B,$A1,$23,$D1,$13 ;           PENETRATES YOUR HEART.
L387F               fcb       $54,$F0,$A4,$8C,$62,$7F,$49,$DB,$B5,$34,$A1,$9F ;           .
L388B               fcb       $15,$3E,$49,$2E     ;           .
L388F               fcb       $81                 ;         CommonCommand_81
L3890               fcb       $83,$66             ;   Script number=83 size=042C
L3892               fcb       $0D,$64             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=100
L3894               fcb       $0E,$61             ;         Command_0E_EXECUTE_LIST_WHILE_FAIL size=97
L3896               fcb       $0D,$08             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=8
L3898               fcb       $08,$0E             ;             Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=0E(UnpulledLever
L389A               fcb       $17,$0E,$00         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=0E(UnpulledLever) location=00
L389D               fcb       $1C,$0F             ;             Command_1C_SET_VAR_OBJECT object=0F (PulledLever)
L389F               fcb       $0C                 ;             Command_0C_FAIL
L38A0               fcb       $0D,$08             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=8
L38A2               fcb       $08,$25             ;             Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=25(GemA
L38A4               fcb       $17,$25,$00         ;             Command_17_MOVE_OBJECT_TO_LOCATION object=25(GemA) location=00
L38A7               fcb       $1C,$26             ;             Command_1C_SET_VAR_OBJECT object=26 (GemB)
L38A9               fcb       $0C                 ;             Command_0C_FAIL
L38AA               fcb       $0D,$1D             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=29
L38AC               fcb       $15,$10             ;             Command_15_CHECK_OBJECT_BITS bits=10 ...P....
L38AE               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L38AF               fcb       $0C,$46,$77,$05,$A0,$16,$BC,$90,$73,$D6,$83,$DB ;               I DON'T THINK THE
L38BB               fcb       $72                 ;               .
L38BC               fcb       $16                 ;             Command_16_PRINT_VAR_NOUN_SHORT_NAME
L38BD               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L38BE               fcb       $0A,$4E,$D1,$05,$8A,$42,$A0,$2B,$62,$FF,$BD ;               WILL COOPERATE.
L38C9               fcb       $0D,$21             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=33
L38CB               fcb       $14                 ;             Command_14_EXECUTE_COMMAND_REVERSE_STATUS
L38CC               fcb       $15,$20             ;               Command_15_CHECK_OBJECT_BITS bits=20 ..C.....
L38CE               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L38CF               fcb       $1A,$C7,$DE,$94,$14,$53,$5E,$D6,$C4,$4B,$5E,$13 ;               YOU ARE QUITE INCAPABLE OF REMOVING THE
L38DB               fcb       $98,$44,$A4,$DB,$8B,$C3,$9E,$6F,$B1,$53,$A1,$AB ;               .
L38E7               fcb       $98,$5F,$BE         ;               .
L38EA               fcb       $16                 ;             Command_16_PRINT_VAR_NOUN_SHORT_NAME
L38EB               fcb       $84                 ;             CommonCommand_84
L38EC               fcb       $18                 ;           Command_18_CHECK_VAR_OBJECT_OWNED_BY_ACTIVE_OBJECT
L38ED               fcb       $0D,$08             ;           Command_0D_EXECUTE_LIST_WHILE_PASS size=8
L38EF               fcb       $0F                 ;             Command_0F_PICK_UP_OBJECT
L38F0               fcb       $16                 ;             Command_16_PRINT_VAR_NOUN_SHORT_NAME
L38F1               fcb       $04                 ;             Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L38F2               fcb       $04,$4D,$BD,$A7,$61 ;               TAKEN.
L38F7               fcb       $18                 ;         Command_18_CHECK_VAR_OBJECT_OWNED_BY_ACTIVE_OBJECT
L38F8               fcb       $84,$04             ;   Script number=84 size=042C
L38FA               fcb       $04                 ;       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L38FB               fcb       $02,$3B,$F4         ;         .
L38FE               fcb       $85,$29             ;   Script number=85 size=042C
L3900               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L3901               fcb       $27,$49,$45,$07,$B3,$11,$A3,$89,$64,$94,$C3,$0B ;         A GROUP OF GUARDS MARCHES AROUND THE CORNER
L390D               fcb       $5C,$94,$91,$1F,$54,$C3,$B5,$07,$B3,$33,$98,$5F ;         TO YOUR RIGHT.
L3919               fcb       $BE,$E1,$14,$CF,$B2,$96,$AF,$DB,$9C,$34,$A1,$33 ;         .
L3925               fcb       $17,$2E,$6D,$2E     ;         .
L3929               fcb       $87,$2A             ;   Script number=87 size=042C
L392B               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L392C               fcb       $28,$49,$45,$07,$B3,$11,$A3,$89,$64,$94,$C3,$0B ;         A GROUP OF GUARDS DISAPPEARS AROUND THE
L3938               fcb       $5C,$95,$5A,$EA,$48,$94,$5F,$C3,$B5,$07,$B3,$33 ;         CORNER TO YOUR LEFT.
L3944               fcb       $98,$5F,$BE,$E1,$14,$CF,$B2,$96,$AF,$DB,$9C,$34 ;         .
L3950               fcb       $A1,$3F,$16,$D7,$68 ;         .
L3955               fcb       $86,$1E             ;   Script number=86 size=042C
L3957               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L3958               fcb       $1C,$49,$45,$07,$B3,$11,$A3,$89,$64,$94,$C3,$0B ;         A GROUP OF GUARDS COMES AROUND THE CORNER.
L3964               fcb       $5C,$3F,$55,$4B,$62,$39,$49,$8E,$C5,$82,$17,$45 ;         .
L3970               fcb       $5E,$B8,$A0,$47,$62 ;         .
L3975               fcb       $88,$13             ;   Script number=88 size=042C
L3977               fcb       $0D,$11             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=17
L3979               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L397A               fcb       $02,$5F,$BE         ;           THE
L397D               fcb       $12                 ;         Command_12_PRINT_SECOND_NOUN_SHORT_NAME
L397E               fcb       $04                 ;         Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L397F               fcb       $0A,$4B,$7B,$06,$9A,$BF,$14,$10,$B2,$5B,$70 ;           IS NOT BURING.
L398A               fcb       $92,$1C             ;   Script number=92 size=042C
L398C               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L398D               fcb       $1A,$36,$A1,$B8,$16,$7B,$14,$85,$A6,$44,$B8,$DB ;         OUT OF A POSSIBLE FIFTY, YOUR SCORE IS
L3999               fcb       $8B,$08,$67,$1E,$C1,$51,$18,$23,$C6,$61,$B7,$5B ;         .
L39A5               fcb       $B1,$4B,$7B         ;         .
L39A8               fcb       $89,$12             ;   Script number=89 size=042C
L39AA               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L39AB               fcb       $10,$C7,$DE,$D3,$14,$E6,$96,$FF,$15,$D3,$93,$5B ;         YOU CAN'T JUMP THAT FAR!
L39B7               fcb       $BE,$08,$BC,$21,$49 ;         .
L39BC               fcb       $8A,$32             ;   Script number=8A size=042C
L39BE               fcb       $0D,$30             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=48
L39C0               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L39C1               fcb       $2D,$C7,$DE,$3B,$16,$33,$98,$03,$A0,$55,$45,$8D ;           YOU LAND ON A SPIKE AT THE BOTTOM OF THE PIT
L39CD               fcb       $A5,$43,$5E,$16,$BC,$DB,$72,$06,$4F,$7F,$BF,$B8 ;           WHICH THE RUG COVERED.
L39D9               fcb       $16,$82,$17,$52,$5E,$73,$7B,$23,$D1,$13,$54,$5F ;           .
L39E5               fcb       $BE,$3F,$17,$C5,$6A,$4F,$A1,$66,$B1,$2E ;           .
L39EF               fcb       $81                 ;         CommonCommand_81
L39F0               fcb       $8B,$79             ;   Script number=8B size=042C
L39F2               fcb       $0D,$77             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=119
L39F4               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L39F5               fcb       $74,$C7,$DE,$2F,$17,$43,$48,$5B,$E3,$23,$D1,$DB ;           YOU REALIZE WHILE YOU'RE FALLING THAT THE
L3A01               fcb       $8B,$C7,$DE,$AF,$23,$4B,$15,$03,$8D,$AB,$98,$5B ;           RUG COVERED A PIT. THE BOTTOM OF THE PIT IS
L3A0D               fcb       $BE,$16,$BC,$DB,$72,$E9,$B3,$E1,$14,$74,$CA,$F3 ;           COVERED WITH SPIKES ABOUT FOUR FEET TALL -
L3A19               fcb       $5F,$52,$45,$97,$7B,$82,$17,$44,$5E,$0E,$A1,$DB ;           YOU DON'T HAVE TIME TO MEASURE THEM EXACTLY.
L3A25               fcb       $9F,$C3,$9E,$5F,$BE,$E3,$16,$0B,$BC,$C5,$B5,$4F ;
L3A31               fcb       $A1,$66,$B1,$FB,$17,$53,$BE,$63,$B9,$B5,$85,$84 ;           .
L3A3D               fcb       $14,$36,$A1,$59,$15,$23,$C6,$67,$66,$16,$BC,$46 ;           .
L3A49               fcb       $48,$8B,$18,$C7,$DE,$09,$15,$E6,$96,$9B,$15,$5B ;           .
L3A55               fcb       $CA,$8F,$BE,$56,$5E,$CF,$9C,$95,$5F,$2F,$C6,$82 ;           .
L3A61               fcb       $17,$5B,$61,$1B,$63,$06,$56,$DB,$E0 ;           .
L3A6A               fcb       $81                 ;         CommonCommand_81
L3A6B               fcb       $8C,$49             ;   Script number=8C size=042C
L3A6D               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L3A6E               fcb       $47,$C7,$DE,$03,$15,$61,$B7,$74,$CA,$7B,$14,$E7 ;         YOU DISCOVER A DEEP DARK PIT WHICH EXTENDS
L3A7A               fcb       $59,$06,$A3,$35,$49,$E3,$16,$19,$BC,$85,$73,$07 ;         FROM THE NORTH TO THE SOUTH WALL. THE PIT IS
L3A86               fcb       $71,$3F,$D9,$4D,$98,$5C,$15,$DB,$9F,$5F,$BE,$99 ;         TOO BROAD TO JUMP.
L3A92               fcb       $16,$C2,$B3,$89,$17,$82,$17,$55,$5E,$36,$A1,$19 ;         .
L3A9E               fcb       $71,$46,$48,$56,$F4,$DB,$72,$96,$A5,$D5,$15,$89 ;         .
L3AAA               fcb       $17,$C4,$9C,$F3,$B2,$16,$58,$CC,$9C,$72,$C5,$2E ;         .
L3AB6               fcb       $8D,$20             ;   Script number=8D size=042C
L3AB8               fcb       $04                 ;       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3AB9               fcb       $1E,$5F,$BE,$66,$17,$8F,$49,$4B,$5E,$CF,$B5,$DA ;         THE STATUE IS MUCH TOO HEAVY FOR YOU TO
L3AC5               fcb       $C3,$89,$17,$CA,$9C,$98,$5F,$48,$DB,$A3,$A0,$C7 ;         MOVE.
L3AD1               fcb       $DE,$89,$17,$71,$16,$7F,$CA ;         .
L3AD8               fcb       $8E,$3E             ;   Script number=8E size=042C
L3ADA               fcb       $04                 ;       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3ADB               fcb       $3C,$7A,$C4,$D9,$06,$82,$7B,$84,$15,$96,$5F,$03 ;         UGH! WITH GREAT DIFFICULTY YOU MANAGE TO
L3AE7               fcb       $15,$93,$66,$2E,$56,$FB,$C0,$C7,$DE,$63,$16,$C9 ;         MOVE THE ALTAR AND YOU DISCOVER A SECRET
L3AF3               fcb       $97,$56,$5E,$CF,$9C,$4F,$A1,$82,$17,$43,$5E,$3B ;         PASSAGE.
L3AFF               fcb       $8E,$83,$AF,$33,$98,$C7,$DE,$03,$15,$61,$B7,$74 ;         .
L3B0B               fcb       $CA,$7B,$14,$A5,$B7,$76,$B1,$DB,$16,$D3,$B9,$BF ;         .
L3B17               fcb       $6C                 ;         .
L3B18               fcb       $8F,$07             ;   Script number=8F size=042C
L3B1A               fcb       $0D,$05             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=5
L3B1C               fcb       $08,$2B             ;         Command_08_COMPARE_OBJECT_TO_FIRST_NOUN object=2B(Passage
L3B1E               fcb       $00,$A5             ;         Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=A5
L3B20               fcb       $90                 ;         CommonCommand_90
L3B21               fcb       $90,$22             ;   Script number=90 size=042C
L3B23               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L3B24               fcb       $20,$5F,$BE,$8E,$14,$54,$BD,$71,$16,$75,$CA,$AB ;         THE ALTAR MOVES BACK TO SEAL THE HOLE ABOVE
L3B30               fcb       $14,$8B,$54,$6B,$BF,$A3,$B7,$16,$8A,$DB,$72,$7E ;         YOU.
L3B3C               fcb       $74,$43,$5E,$08,$4F,$5B,$5E,$3F,$A1 ;         .
L3B45               fcb       $91,$37             ;   Script number=91 size=042C
L3B47               fcb       $0D,$35             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=53
L3B49               fcb       $1F                 ;         Command_1F_PRINT_MESSAGE
L3B4A               fcb       $30,$4B,$49,$C7,$DE,$DE,$14,$64,$7A,$C7,$16,$11 ;           AS YOU CLIMB OUT OF THE HOLE, IT SEEMS TO
L3B56               fcb       $BC,$96,$64,$DB,$72,$7E,$74,$B3,$63,$73,$7B,$A7 ;           MAGICALLY SEAL UP BEHIND YOU.
L3B62               fcb       $B7,$4B,$94,$6B,$BF,$89,$91,$D3,$78,$13,$8D,$57 ;           .
L3B6E               fcb       $17,$33,$48,$D3,$C5,$6A,$4D,$8E,$7A,$51,$18,$DB ;           .
L3B7A               fcb       $C7                 ;           .
L3B7B               fcb       $00,$9F             ;         Command_00_MOVE_ACTIVE_OBJECT_TO_ROOM_AND_LOOK room=9F
L3B7D               fcb       $95                 ;         CommonCommand_95
L3B7E               fcb       $93,$09             ;   Script number=93 size=042C
L3B80               fcb       $0B,$07             ;       Command_0B_SWITCH size=07
L3B82               fcb       $0A,$36             ;         Command_0A_COMPARE_TO_PHRASE_FORM val=36 phrase="36: CLIMB IN    *          *       "
L3B84               fcb       $01                 ;         IF_NOT_JUMP address=3B86
L3B85               fcb       $94                 ;           CommonCommand_94
L3B86               fcb       $37                 ;         Command_0A_COMPARE_TO_PHRASE_FORM val=37 phrase="37: CLIMB OUT   *          *       "
L3B87               fcb       $01                 ;         IF_NOT_JUMP address=3B89
L3B88               fcb       $94                 ;           CommonCommand_94
L3B89               fcb       $94,$19             ;   Script number=94 size=042C
L3B8B               fcb       $1F                 ;       Command_1F_PRINT_MESSAGE
L3B8C               fcb       $17,$FF,$A5,$57,$49,$B5,$17,$46,$5E,$2F,$7B,$03 ;         PLEASE USE DIRECTIONS N,S,E, OR W.
L3B98               fcb       $56,$1D,$A0,$A6,$16,$3F,$BB,$11,$EE,$99,$AF,$2E ;         .
L3BA4               fcb       $95,$26             ;   Script number=95 size=042C
L3BA6               fcb       $0D,$24             ;       Command_0D_EXECUTE_LIST_WHILE_PASS size=36
L3BA8               fcb       $17,$36,$FF         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=36(Jungle) location=FF
L3BAB               fcb       $17,$29,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=29(Floor) location=00
L3BAE               fcb       $17,$2A,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=2A(Exit) location=00
L3BB1               fcb       $17,$2B,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=2B(Passage) location=00
L3BB4               fcb       $17,$2C,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=2C(Hole) location=00
L3BB7               fcb       $17,$2D,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=2D(Corridor) location=00
L3BBA               fcb       $17,$2E,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=2E(Corner) location=00
L3BBD               fcb       $17,$31,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=31(Hallway) location=00
L3BC0               fcb       $17,$34,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=34(Entrance) location=00
L3BC3               fcb       $17,$35,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=35(Tunnel) location=00
L3BC6               fcb       $17,$3A,$00         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=3A(Ceiling) location=00
L3BC9               fcb       $17,$3C,$1D         ;         Command_17_MOVE_OBJECT_TO_LOCATION object=3C(Object3C) location=1D
L3BCC               fcb       $96,$1A             ;   Script number=96 size=042C
L3BCE               fcb       $04                 ;       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3BCF               fcb       $18,$5B,$BE,$65,$BC,$7B,$14,$41,$6E,$19,$58,$3B ;         THAT'S A GOOD WAY TO LOSE YOUR HAND!
L3BDB               fcb       $4A,$6B,$BF,$85,$8D,$5B,$5E,$34,$A1,$9B,$15,$31 ;         .
L3BE7               fcb       $98                 ;         .
L3BE8               fcb       $97,$19             ;   Script number=97 size=042C
L3BEA               fcb       $04                 ;       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3BEB               fcb       $17,$43,$79,$C7,$DE,$D3,$14,$88,$96,$8E,$7A,$7B ;         IF YOU CAN FIND A MOUTH, I'M GAME!
L3BF7               fcb       $14,$C7,$93,$76,$BE,$BD,$15,$49,$90,$67,$48,$21 ;         .
L3C03               fcb       $98,$24             ;   Script number=98 size=042C
L3C05               fcb       $04                 ;       Command_04_PRINT_SYSTEM_OR_PLAYER_MESSAGE
L3C06               fcb       $22,$0F,$A0,$5F,$17,$46,$48,$66,$17,$D3,$61,$04 ;         ONE SMALL STEP FOR MANKIND, ONE GIANT LEAP
L3C12               fcb       $68,$63,$16,$5B,$99,$56,$98,$C0,$16,$49,$5E,$90 ;         FOR YOU!
L3C1E               fcb       $78,$0E,$BC,$92,$5F,$59,$15,$9B,$AF,$19,$A1 ;         .
; ENDOF 37FA

;##InputWordTables

; --- IGNORES --- Maybe for curse words. No words in this list and thus never used.
L3C29               fcb       $00
;
; --- VERBS ---
L3C2A               fcb       $04,$52,$45,$41,$44,$01 ; READ     1
L3C30               fcb       $03,$47,$45,$54,$09 ; GET      9
L3C35               fcb       $05,$54,$48,$52,$4F,$57,$03 ; THROW    3
L3C3C               fcb       $06,$41,$54,$54,$41,$43,$4B,$04 ; ATTACK   4
L3C44               fcb       $04,$4B,$49,$4C,$4C,$04 ; KILL     4
L3C4A               fcb       $03,$48,$49,$54,$04 ; HIT      4
L3C4F               fcb       $05,$4E,$4F,$52,$54,$48,$05 ; NORTH    5
L3C56               fcb       $01,$4E,$05         ; N        5
L3C59               fcb       $05,$53,$4F,$55,$54,$48,$06 ; SOUTH    6
L3C60               fcb       $01,$53,$06         ; S        6
L3C63               fcb       $04,$45,$41,$53,$54,$07 ; EAST     7
L3C69               fcb       $01,$45,$07         ; E        7
L3C6C               fcb       $04,$57,$45,$53,$54,$08 ; WEST     8
L3C72               fcb       $01,$57,$08         ; W        8
L3C75               fcb       $04,$54,$41,$4B,$45,$09 ; TAKE     9
L3C7B               fcb       $04,$44,$52,$4F,$50,$0A ; DROP     10
L3C81               fcb       $03,$50,$55,$54,$0A ; PUT      10
L3C86               fcb       $06,$49,$4E,$56,$45,$4E,$54,$0B ; INVENT   11
L3C8E               fcb       $04,$4C,$4F,$4F,$4B,$0C ; LOOK     12
L3C94               fcb       $04,$47,$49,$56,$45,$0D ; GIVE     13
L3C9A               fcb       $05,$4F,$46,$46,$45,$52,$0D ; OFFER    13
L3CA1               fcb       $06,$45,$58,$41,$4D,$49,$4E,$0E ; EXAMIN   14
L3CA9               fcb       $06,$53,$45,$41,$52,$43,$48,$0E ; SEARCH   14
L3CB1               fcb       $04,$4F,$50,$45,$4E,$0F ; OPEN     15
L3CB7               fcb       $04,$50,$55,$4C,$4C,$10 ; PULL     16
L3CBD               fcb       $05,$4C,$49,$47,$48,$54,$11 ; LIGHT    17
L3CC4               fcb       $04,$42,$55,$52,$4E,$11 ; BURN     17
L3CCA               fcb       $03,$45,$41,$54,$12 ; EAT      18
L3CCF               fcb       $05,$54,$41,$53,$54,$45,$12 ; TASTE    18
L3CD6               fcb       $04,$42,$4C,$4F,$57,$13 ; BLOW     19
L3CDC               fcb       $06,$45,$58,$54,$49,$4E,$47,$14 ; EXTING   20
L3CE4               fcb       $05,$43,$4C,$49,$4D,$42,$15 ; CLIMB    21
L3CEB               fcb       $03,$52,$55,$42,$16 ; RUB      22
L3CF0               fcb       $04,$57,$49,$50,$45,$16 ; WIPE     22
L3CF6               fcb       $06,$50,$4F,$4C,$49,$53,$48,$16 ; POLISH   22
L3CFE               fcb       $04,$4C,$49,$46,$54,$1C ; LIFT     28
L3D04               fcb       $04,$57,$41,$49,$54,$1F ; WAIT     31
L3D0A               fcb       $04,$53,$54,$41,$59,$1F ; STAY     31
L3D10               fcb       $04,$4A,$55,$4D,$50,$20 ; JUMP     32
L3D16               fcb       $02,$47,$4F,$21     ; GO       33
L3D1A               fcb       $03,$52,$55,$4E,$21 ; RUN      33
L3D1F               fcb       $05,$45,$4E,$54,$45,$52,$21 ; ENTER    33
L3D26               fcb       $04,$50,$55,$53,$48,$10 ; PUSH     16
L3D2C               fcb       $04,$4D,$4F,$56,$45,$10 ; MOVE     16
L3D32               fcb       $04,$4B,$49,$43,$4B,$23 ; KICK     35
L3D38               fcb       $04,$46,$45,$45,$44,$24 ; FEED     36
L3D3E               fcb       $05,$53,$43,$4F,$52,$45,$28 ; SCORE    40
L3D45               fcb       $06,$53,$43,$52,$45,$41,$4D,$2B ; SCREAM   43
L3D4D               fcb       $04,$59,$45,$4C,$4C,$2B ; YELL     43
L3D53               fcb       $04,$51,$55,$49,$54,$2D ; QUIT     45
L3D59               fcb       $04,$53,$54,$4F,$50,$2D ; STOP     45
L3D5F               fcb       $05,$50,$4C,$55,$47,$48,$32 ; PLUGH    50
L3D66               fcb       $05,$4C,$45,$41,$56,$45,$2C ; LEAVE    44
L3D6D               fcb       $04,$50,$49,$43,$4B,$34 ; PICK     52
L3D73               fcb       $00
;
; --- NOUNS ---
L3D74               fcb       $06,$50,$4F,$54,$49,$4F,$4E,$03 ; POTION   3
L3D7C               fcb       $03,$52,$55,$47,$06 ; RUG      6
L3D81               fcb       $04,$44,$4F,$4F,$52,$09 ; DOOR     9
L3D87               fcb       $04,$46,$4F,$4F,$44,$0C ; FOOD     12
L3D8D               fcb       $06,$53,$54,$41,$54,$55,$45,$0D ; STATUE   13
L3D95               fcb       $05,$53,$57,$4F,$52,$44,$0E ; SWORD    14
L3D9C               fcb       $06,$47,$41,$52,$47,$4F,$59,$0F ; GARGOY   15
L3DA4               fcb       $04,$52,$49,$4E,$47,$12 ; RING     18
L3DAA               fcb       $03,$47,$45,$4D,$13 ; GEM      19
L3DAF               fcb       $05,$4C,$45,$56,$45,$52,$16 ; LEVER    22
L3DB6               fcb       $06,$50,$4C,$41,$51,$55,$45,$18 ; PLAQUE   24
L3DBE               fcb       $05,$52,$55,$4E,$45,$53,$18 ; RUNES    24
L3DC5               fcb       $04,$53,$49,$47,$4E,$18 ; SIGN     24
L3DCB               fcb       $06,$4D,$45,$53,$53,$41,$47,$18 ; MESSAG   24
L3DD3               fcb       $06,$43,$41,$4E,$44,$4C,$45,$19 ; CANDLE   25
L3DDB               fcb       $04,$4C,$41,$4D,$50,$1B ; LAMP     27
L3DE1               fcb       $06,$43,$48,$4F,$50,$53,$54,$1E ; CHOPST   30
L3DE9               fcb       $04,$48,$41,$4E,$44,$1F ; HAND     31
L3DEF               fcb       $05,$48,$41,$4E,$44,$53,$1F ; HANDS    31
L3DF6               fcb       $04,$43,$4F,$49,$4E,$20 ; COIN     32
L3DFC               fcb       $04,$53,$4C,$4F,$54,$21 ; SLOT     33
L3E02               fcb       $05,$41,$4C,$54,$41,$52,$22 ; ALTAR    34
L3E09               fcb       $04,$49,$44,$4F,$4C,$23 ; IDOL     35
L3E0F               fcb       $06,$53,$45,$52,$50,$45,$4E,$24 ; SERPEN   36
L3E17               fcb       $05,$53,$4E,$41,$4B,$45,$24 ; SNAKE    36
L3E1E               fcb       $04,$57,$41,$4C,$4C,$25 ; WALL     37
L3E24               fcb       $05,$57,$41,$4C,$4C,$53,$25 ; WALLS    37
L3E2B               fcb       $04,$56,$49,$4E,$45,$26 ; VINE     38
L3E31               fcb       $05,$56,$49,$4E,$45,$53,$26 ; VINES    38
L3E38               fcb       $04,$47,$41,$54,$45,$27 ; GATE     39
L3E3E               fcb       $05,$47,$41,$54,$45,$53,$27 ; GATES    39
L3E45               fcb       $05,$47,$55,$41,$52,$44,$28 ; GUARD    40
L3E4C               fcb       $06,$47,$55,$41,$52,$44,$53,$28 ; GUARDS   40
L3E54               fcb       $04,$52,$4F,$4F,$4D,$2A ; ROOM     42
L3E5A               fcb       $05,$46,$4C,$4F,$4F,$52,$2B ; FLOOR    43
L3E61               fcb       $04,$45,$58,$49,$54,$2C ; EXIT     44
L3E67               fcb       $06,$50,$41,$53,$53,$41,$47,$2D ; PASSAG   45
L3E6F               fcb       $04,$48,$4F,$4C,$45,$2E ; HOLE     46
L3E75               fcb       $06,$43,$4F,$52,$52,$49,$44,$2F ; CORRID   47
L3E7D               fcb       $03,$42,$4F,$57,$31 ; BOW      49
L3E82               fcb       $05,$41,$52,$52,$4F,$57,$32 ; ARROW    50
L3E89               fcb       $06,$48,$41,$4C,$4C,$57,$41,$33 ; HALLWA   51
L3E91               fcb       $06,$43,$48,$41,$4D,$42,$45,$34 ; CHAMBE   52
L3E99               fcb       $05,$56,$41,$55,$4C,$54,$35 ; VAULT    53
L3EA0               fcb       $06,$45,$4E,$54,$52,$41,$4E,$36 ; ENTRAN   54
L3EA8               fcb       $06,$54,$55,$4E,$4E,$45,$4C,$37 ; TUNNEL   55
L3EB0               fcb       $06,$4A,$55,$4E,$47,$4C,$45,$38 ; JUNGLE   56
L3EB8               fcb       $06,$54,$45,$4D,$50,$4C,$45,$39 ; TEMPLE   57
L3EC0               fcb       $03,$50,$49,$54,$3A ; PIT      58
L3EC5               fcb       $06,$43,$45,$49,$4C,$49,$4E,$3B ; CEILIN   59
L3ECD               fcb       $00
;
; --- ADJECTIVES ---
L3ECE               fcb       $00
;
; --- PREPOSITIONS ---
L3ECF               fcb       $02,$54,$4F,$01     ; TO       1
L3ED3               fcb       $04,$57,$49,$54,$48,$02 ; WITH     2
L3ED9               fcb       $02,$41,$54,$03     ; AT       3
L3EDD               fcb       $05,$55,$4E,$44,$45,$52,$04 ; UNDER    4
L3EE4               fcb       $02,$49,$4E,$05     ; IN       5
L3EE8               fcb       $04,$49,$4E,$54,$4F,$05 ; INTO     5
L3EEE               fcb       $03,$4F,$55,$54,$06 ; OUT      6
L3EF3               fcb       $02,$55,$50,$07     ; UP       7
L3EF7               fcb       $04,$44,$4F,$57,$4E,$08 ; DOWN     8
L3EFD               fcb       $04,$4F,$56,$45,$52,$09 ; OVER     9
L3F03               fcb       $06,$42,$45,$48,$49,$4E,$44,$0A ; BEHIND   10
L3F0B               fcb       $06,$41,$52,$4F,$55,$4E,$44,$0B ; AROUND   11
L3F13               fcb       $02,$4F,$4E,$0C     ; ON       12
L3F17               fcb       $00


os9read             pshs      y,x,d
                    clra
                    leax      ,s
                    ldy       #$0001
                    os9       I$Read
ok                  puls      d,x,y,pc

os9write            pshs      y,x,d
                    cmpa      #$0D
                    beq       WriteCR
                    lda       #$01
                    leax      ,s
                    ldy       #$0001
                    os9       I$Write
                    bra       DoCHROUT
WriteCR
                    lda       #$01
                    leax      ,s
                    ldy       #$0001
                    os9       I$WritLn
DoCHROUT
                    puls      d,x,y
                    rts
                    pshs      x,b,a
                    ldx       $88                 get cursor position
                    cmpa      #$08                backspace character?
                    bne       LA31D               branch if not...
                    cmpx      #$400               else is current screen pointer at top?
                    beq       LA35D               branch if so...
                    lda       #$60                else put SPACE to erase character and move X back
                    sta       ,-x
                    bra       LA344
LA31D               cmpa      #$0D
                    bne       LA32F
                    ldx       $88
LA323               lda       #$60
                    sta       ,x+
                    tfr       x,d
                    bitb      #$1F
                    bne       LA323
                    bra       LA344
LA32F               cmpa      #$20
                    bcs       LA35D
                    tsta
                    bmi       LA342
                    cmpa      #$40
                    bcs       LA340
                    cmpa      #$60
                    bcs       LA342
                    anda      #$DF
LA340               eora      #$40
LA342               sta       ,x+
LA344               stx       $88
                    cmpx      #$400+511
                    bls       LA35D
                    ldx       #$400

* SCROLL SCREEN
LA34E               ldd       32,x
                    std       ,x++
                    cmpx      #$400+$1E0
                    bcs       LA34E
                    ldb       #$60
LA92D               stx       $88
LA92F               stb       ,x+
                    cmpx      #$400+511
                    bls       LA92F
LA35D               puls      d,x,pc

os9exit             os9       F$Exit

                    emod
eom                 equ       *
                    end
