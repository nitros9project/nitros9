********************************************************************
* httpd - HTTP daemon
*
* $Id$
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment
* ------------------------------------------------------------------
*   1      2013/05/22  Boisy G. Pitre
* Started.

                    nam       httpd
                    ttl       HTTP daemon

                    section   __os9
type                equ       Prgrm
lang                equ       Objct
attr                equ       ReEnt
rev                 equ       $00
edition             equ       1
stack               equ       200
                    endsect

                    section   bss
gbufferl            equ       128
gbuffer             rmb       gbufferl
dentbuf             rmb       32
filepath            rmb       1
fileptr             rmb       2
lbufferl            equ       128
lbuffer             rmb       lbufferl
                    endsect

                    section   code

DEBUG               equ       1

**** Entry Point ****
__start
* Turn off pause in standard out
                    lda       #1
                    lbsr      SetEchoOff
                    lbsr      SetAutoLFOn

* change to www root dir
                    lda       #READ.
                    leax      wwwroot,pcr
                    os9       I$ChgDir
                    bcs       errexit

* main loop: read line on stdin
mainloop
                    leax      gbuffer,u
                    ldy       #gbufferl
                    clra
                    os9       I$ReadLn
                    bcs       checkeof
* quickly nul terminate the line we just read
                    pshs      x
                    tfr       y,d
                    leax      d,x
                    clr       -1,x
                    puls      x
                    bsr       process
                    bra       errexit

checkeof            cmpb      #E$EOF
                    bcs       errexit
                    clrb
errexit
                    pshs      cc,b
                    lda       #1
                    lbsr      SetEchoOn
                    puls      cc,b
                    os9       F$Exit

* input: X = line read (nul terminated)
process
* check for GET
                    leay      get,pcr
                    ldd       #getl
                    lbsr      STRNCMP
                    beq       GETOK
                    clrb
                    rts

* we know it is a GET... get the text following it
GETOK               leax      4,x
                    ldd       ,x
                    cmpd      #'/*256+C$SPAC
                    beq       doindex
                    leax      1,x

NulTerminate        pshs      x
loop@               lda       ,x+
                    beq       terminate@
                    cmpa      #C$CR
                    beq       terminate@
                    cmpa      #C$SPAC
                    beq       terminate@
                    bra       loop@
terminate@          clr       -1,x
                    puls      x
                    bra       readfile

* point to index.html
doindex             leax      index,pcr
readfile
                    stx       fileptr,u
                    lda       #READ.
                    os9       I$Open
                    bcs       isitdir

                    lbsr      print200OK

readloop            leax      lbuffer,u
                    ldy       #lbufferl
                    os9       I$Read
                    bcs       eofcheck
                    pshs      a
                    lda       #1
                    os9       I$Write
                    puls      a
                    bra       readloop

eofcheck            cmpb      #E$EOF
                    bne       ret
                    clrb
                    os9       I$Close
ret                 rts

isitdir             cmpb      #E$FNA
                    lbne      notfound
* open as directory
                    lda       #READ.+DIR.
                    ldx       fileptr,u
                    os9       I$Open
                    lbcs      notfound
* process dir here
                    sta       filepath,u
                    lbsr      print200OK
                    lbsr      _htmltag
                    lbsr      _headtag
                    lbsr      _titletag
                    lbsr      PRINTS
                    fcc       "Directory of "
                    fcb       $00
                    ldx       fileptr,u
                    lbsr      PUTS
                    lbsr      _ntitletag
                    lbsr      _nheadtag
                    lbsr      _bodytag
                    lbsr      PRINTS
                    fcc       "<H3>"
                    fcc       "Directory of "
                    fcb       $00
                    ldx       fileptr,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       "</H3>"
                    fcb       $00
                    lda       filepath,u
* skip over .. and .
                    ldy       #DIR.SZ
                    leax      dentbuf,u
                    os9       I$Read
                    leax      dentbuf,u
                    os9       I$Read

nextdirent          lda       filepath,u
                    leax      dentbuf,u
                    ldy       #DIR.SZ
                    os9       I$Read
                    bcs       endoffile
                    tst       ,x
                    beq       nextdirent

* find char with hi bit set
                    tfr       x,y
lo@                 lda       ,y+
                    bpl       lo@
                    anda      #$7F
                    sta       -1,y
                    clr       ,y
                    pshs      x
                    lbsr      PRINTS
                    fcc       '<A HREF="'
                    fcb       $00
                    ldx       fileptr,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       "/"
                    fcb       $00
                    ldx       ,s
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       '">'
                    fcb       $00
                    puls      x
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       "</A>"
                    fcc       "<BR>"
                    fcb       $00
                    bra       nextdirent
endoffile
                    lda       filepath,u
                    os9       I$Close
                    lbsr      _nbodytag
                    lbsr      _nhtmltag
                    rts

notfound            lbsr      print404
                    rts

_http11
                    lbsr      PRINTS
                    fcc       "HTTP/1.1 "
                    fcb       $00
                    rts

_server
                    lbsr      PRINTS
                    fcc       "Server: "
                    fcb       $00
                    lbsr      _serverinf
                    lbsr      _newline
                    rts

_connclose
                    lbsr      PRINTS
                    fcc       "Connection: close"
                    fcb       C$CR,$00
                    rts

_newline
                    lbsr      PRINTS
                    fcb       C$CR,$00
                    rts

_serverinf
                    lbsr      PRINTS
                    fcc       /httpd ed. /
                    fcb       edition+$30
                    fcc       / (NitrOS-9)/
                    fcb       $00
                    rts

_htmltag
                    lbsr      PRINTS
                    fcc       "<HTML>"
                    fcb       $00
                    rts

_nhtmltag
                    lbsr      PRINTS
                    fcc       "</HTML>"
                    fcb       $00
                    rts

_headtag
                    lbsr      PRINTS
                    fcc       "<HEAD>"
                    fcb       $00
                    rts

_nheadtag
                    lbsr      PRINTS
                    fcc       "</HEAD>"
                    fcb       $00
                    rts

_titletag
                    lbsr      PRINTS
                    fcc       "<TITLE>"
                    fcb       $00
                    rts

_ntitletag
                    lbsr      PRINTS
                    fcc       "</TITLE>"
                    fcb       $00
                    rts

_bodytag
                    lbsr      PRINTS
                    fcc       "<BODY>"
                    fcb       $00
                    rts

_nbodytag
                    lbsr      PRINTS
                    fcc       "</BODY>"
                    fcb       $00
                    rts

print200OK
                    lbsr      _http11
                    lbsr      PRINTS
                    fcc       "200 OK"
                    fcb       C$CR,$00
                    lbsr      _server
                    lbsr      _connclose
                    lbsr      _newline
                    rts

print404
                    lbsr      _http11
                    lbsr      PRINTS
                    fcc       "404 Not Found"
                    fcb       C$CR,$00
                    lbsr      _server
                    lbsr      _connclose
                    lbsr      _newline
                    lbsr      PRINTS
                    fcc       '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">'
                    fcb       $00
                    lbsr      _htmltag
                    lbsr      _headtag
                    lbsr      PRINTS
                    fcc       '<title>404 Not Found</title>'
                    fcb       $00
                    lbsr      _nheadtag
                    lbsr      _bodytag
                    lbsr      PRINTS
                    fcc       '<h1>Not Found</h1>'
                    fcc       '<p>The requested URL '
                    fcb       $00
                    ldx       fileptr,u
                    lbsr      PUTS
                    lbsr      PRINTS
                    fcc       ' was not found on this server.</p>'
                    fcc       '<hr>'
                    fcc       '<address>'
                    fcb       $00
                    lbsr      _serverinf
                    lbsr      PRINTS
                    fcc       '</address>'
                    fcb       $00
                    lbsr      _nbodytag
                    lbsr      _nhtmltag
                    rts

wwwroot             fcs       "....../WWWROOT"
get                 fcc       "GET "
getl                equ       *-get
                    fcb       $00
index               fcs       "index.html"

                    endsect
