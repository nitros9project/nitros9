# gdb scripts for NitrOS-9 (or OS-9)
# Copyright 2014  Tormod Volden


define hook-stop
	printf "S=%04x X=%04x Y=%04x U=%04x A=%02x B=%02x CC=%02x PC=%04x ", $s, $x, $y, $u, $a, $b, $cc , $pc
	os9_mwhere
end

document hook-stop
 Pretty-print of registers on every halt,
 and updates external source code window.
end

define os9_mname
	set $mname = (char*)$arg0 + *((int*)$arg0 + 2)
	while 1
		if (*$mname < 0x20)
			loop_break
		end
		if (*$mname < 0x80)
			printf "%c", *$mname
		else
			printf "%c", *$mname-0x80
			loop_break
		end
		set $mname += 1
	end
end

document os9_mname
 Print name of module at given address
end

define os9_mident
	set $m = (int*)$arg0
	set $msize = *($m + 1)
	set $mend = (char*) $m + $msize
	set $mtype = *((char*) $m + 6)
	set $mexec = *(int*)((char*) $m + 9)
	printf "%04x %4x %2X ", $m, $msize, $mtype
	printf "%02X%02X%02X ", *((char*)$mend-3), *((char*)$mend-2), *((char*)$mend-1)
	os9_mname $m
	if ($mtype & 0xf)
		printf "\t\t[exec %04x] ", (char*)$m + $mexec
	end
	printf "\n"
end

document os9_mident
 Print details of module at given address.
end

define os9_mdir
	printf "addr size ty crc    name\n"
	set $mt = *0x44
	set $mte = *0x46
	while ($mt < $mte)
		if ((int*)*$mt)
			os9_mident (int*)*$mt
		end
		set $mt += 4
	end
end

document os9_mdir
 List all modules registered in module directory.
end

define os9_mwhich
	set $pc_reg = $arg0
	set $mt = *0x44
	set $mte = *0x46
	while ($mt < $mte)
		if ((int*)*$mt)
			set $mstart = (int*)*$mt
			set $mend = (char*)$mstart + *($mstart + 1)
			if ($pc_reg >= $mstart && $pc_reg < $mend)
				loop_break
			end
		end
		set $mt += 4
	end
	if ($mt == $mte)
		set $mstart = 0
	end
end

document os9_mwhich
 (internal) Finds module at given address, sets $mstart quietly.
end

define os9_mwhere
	if ($argc == 1)
		set $pc_reg = $arg0
	else
		set $pc_reg = $pc
	end
	os9_mwhich $pc_reg
	if ($mstart)
		printf "inside "
		os9_mname $mstart
		printf "\n"
		eval "!gvim --remote %02X%02X%02X.crc && gvim --remote-send \":set cursorline<CR>\" && gvim --remote-send \"/^%04X<CR>\"", *((char*)$mend-3), *((char*)$mend-2), *((char*)$mend-1), (char*)$pc_reg - (char*)$mstart
	else
		printf "no module\n"
	end
end

document os9_mwhere
 Look up source code line for given address.
 Requires assembly list files named by CRC in current directory
 and "gvim" to display listing and highlight line.
end

define b9
	os9_mwhich $pc
	eval "hbreak *0x%x", (int)$mstart + $arg0
end

document b9
 Set breakpoint in current module, at given offset.
end

define ss
	set $steps = 0
	if (*$pc == 0x103f)
		set $steps = 3
	end
	if (*(char*)$pc == 0x8d)
		set $steps = 2
	end
	if (*(char*)$pc == 0x17)
		set $steps = 3
	end
	if ($steps != 0)
		thbreak *($pc + $steps)
		cont
        else
		stepi
	end
end

document ss
 Single step, but skips OS-9 SWI, bsr and lbsr.
end
