****************************************************************************
*
* instrument.a - acquires all needed data values from various instruments
*
*

                    section   bss
speed               rmb       2
mileage             rmb       4
engtemp             rmb       2
fuelamt             rmb       2
                    endsect

                    section   code

* initialize hardware
*
* Entry: None
*
* Exit:  D = speed value in miles per hour
insinit
                    ldd       #55
                    std       speed,u

                    ldd       #(171556/65536)
                    std       mileage,u
                    ldd       #40439
                    std       mileage+2,u

                    ldd       #200
                    std       engtemp,u

                    ldd       #9
                    std       fuelamt,u

                    rts

* Get the current speed
*
* Entry: None
*
* Exit:  D = speed value in miles per hour
getspeed
                    ldd       speed,u             55 mph
                    rts

speedplus
                    ldd       speed,u
                    addd      #$0001
                    std       speed,u
                    rts

* Get the odometer value
*
* Entry: None
*
* Exit:  D = bits 23-16 of odometer
*        X = bits 15-0  of odometer
getmileage
                    ldd       mileage,u
                    ldx       mileage+2,u
                    rts


* Get the current engine temperature
*
* Entry: None
*
* Exit:  D = engine temperature value in Farenheit
getengtemp
                    ldd       engtemp,u
                    rts


* Get the current fuel amount
*
* Entry: None
*
* Exit:  D = fuel amount in 16ths
getfuel
                    ldd       fuelamt,u
                    rts


                    endsect
