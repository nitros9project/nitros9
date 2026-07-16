                    nam       boot_config
                    ttl       Boot manager configuration

                    section   code

boot_config

* autoboot (1 = yes, 0 = no, use menu)
cfg_auto            fcb       0

* list of booters to be tried (in order, $0000 terminates list)
* entry format:  booter entry point, address, device ID
cfg_boot            fdb       llbt_1773,$FF40,0
                    fdb       llbt_1773,$FF40,1
*          fdb    llbt_tc3,$FF70,0
*          fdb    llbt_ide,$FF50,0
                    fdb       $0000

                    endsect
