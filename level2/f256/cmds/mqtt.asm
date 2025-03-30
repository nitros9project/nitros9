********************************************************************
* MQTT - Message Queuing Telemetry Transport
* Command to publish and subscribe to MQTT topics using the F256K's
* WizFi360 WIFI module.
*
* Place your MQTT Broker's login information in /dd/sys/mqttbroker.sys
* com: wizfi
* brokerurl: 192.168.1.85 (example)
* username: brokeruser
* password: brokerpassword
*
* Edt/Rev  YYYY/MM/DD  Modified by
* Comment

*   1      2025/03/30  Roger Taylor     
* ------------------------------------------------------------------

                    nam       MQTT
                    ttl       Message Queuing Telemetry Transport

                    ifp1
                    use       defsfile
                    endc

DOHELP              set       0

tylg                set       Prgrm+Objct
atrv                set       ReEnt+rev
rev                 set       $00
edition             set       3

                    mod       eom,name,tylg,atrv,start,size

u0000               rmb       2
u0002               rmb       1
u0003               rmb       7
newtype             rmb       1
winpath             rmb       1
u000C               rmb       1
zflag               rmb       1
u000E               rmb       480
size                equ       .

name                fcs       /MQTT/
                    fcb       edition

HelpMsg             fcb       C$CR
                    fcb       C$LF
                    fcc       "Publishing to topics:"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       " Adds a device:"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "  mqtt </comdevice> -p {topic} {payload}"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "  mqtt /t2 -p homeassistant/os9health/config </dd/sys/mqtt/os9health.config"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       " Publish states, stats, etc:"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "  mqtt /t2 -p stat/os9health/freeram 1452"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       "  mqtt /t2 -p stat/os9health/processes 8"
                    fcb       C$CR
                    fcb       C$LF
                    fcc       " Removes a device:"
                    fcb       C$CR
                    fcb       C$LF
		    fcc       "  mqtt -p homeassistant/os9health/config {empty payload}"
                    fcb       C$CR
                    fcb       C$LF
                    fcb       0


start
ExitOk              clrb
Exit                os9       F$Exit


                    emod
eom                 equ       *
                    end

