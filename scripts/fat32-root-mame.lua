-- Passive observation only: capture OS-9 console writes at the SWI2 vector,
-- before the kernel switches MMU tasks, and VHD record reads. No guest writes.
local cpu = manager.machine.devices[':maincpu']
local space = cpu.spaces['program']
local console = assert(io.open(console_path, 'wb'))
local reads = assert(io.open(reads_path, 'w'))
local writes = assert(io.open(writes_path, 'w'))
local guards = false
local errors = assert(io.open(errors_path, 'w'))
local busy = false
fatroot_swi_tap = space:install_read_tap(0xfff4, 0xfff4, 'fatroot-console', function()
    if busy then return end
    busy = true
    local s = cpu.state['S'].value
    local pc = space:read_u16(s + 10)
    local call = space:read_u8(pc)
    if call == 0x0f then
        errors:write(string.format('%d\n',space:read_u8(s+2)));errors:flush()
    end
    local path = space:read_u8(s + 1)
    if (call == 0x8a or call == 0x8c) and (path == 1 or path == 2) then
        local x, length = space:read_u16(s + 4), space:read_u16(s + 6)
        if length > 0 and length < 16384 then
            local text = space:read_range(x, x + length - 1, 8)
            if call == 0x8c then text = text:match('^[^\r]*\r') or text end
            if text:find('PCFGUARDSBEGIN',1,true) or text:find('PCFRMDENYBEGIN',1,true) or text:find('PCFDELDENYBEGIN',1,true) or text:find('PCFRENDENYBEGIN',1,true) then guards=true end
            if text:find('PCFGUARDSEND',1,true) or text:find('PCFRMDENYEND',1,true) or text:find('PCFDELDENYEND',1,true) or text:find('PCFRENDENYEND',1,true) then guards=false end
            if completion_marker and text:gsub('[\r\n]+$','') == completion_marker then script_finished = true end
            console:write(text);console:flush()
        end
    end
    busy = false
end)
local reg = {0, 0, 0}
fatroot_vhd_tap = space:install_write_tap(0xff80, 0xff83, 'fatroot-vhd', function(address, value)
    if address < 0xff83 then reg[address-0xff80+1] = value
    elseif value == 0 then
        fatroot_vhd_seen = true
        reads:write(string.format('%d\n',reg[1]*65536+reg[2]*256+reg[3]));reads:flush()
    elseif value == 1 then
        writes:write((guards and 'GUARD ' or '')..string.format('%d\n',reg[1]*65536+reg[2]*256+reg[3]));writes:flush()
    end
end)
fatroot_stop = emu.add_machine_stop_notifier(function() console:close();reads:close();errors:close();writes:close() end)
-- Eject after the booter starts reading VHD; the floppy kernel track is loaded.
local ejected = false
emu.register_frame_done(function()
    if eject_bootstrap and fatroot_vhd_seen and not ejected then
        ejected = true
        local found = false
        for _, image in pairs(manager.machine.images) do
            if image.filename and image.filename:match('bootstrap%.dsk$') then
                image:unload()
                assert(not image.exists, 'floppy remained mounted')
                found = true
            end
        end
        assert(found, 'bootstrap floppy not found')
        print('FLOPPY EJECTED: continuing entirely from FAT32')
    end
end)
