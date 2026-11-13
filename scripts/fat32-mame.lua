-- commands is supplied by fat32-mame.py. Keep reliable CoWin key timing.
-- The recording can accelerate typing while retaining normal-speed results.
emu.keypost('DOS\n')
local keys = {}
local shiftkey
for _, port in pairs(manager.machine.ioport.ports) do
    for _, field in pairs(port.fields) do
        if field.type_class == 'keyboard' then
            if field.name == 'SHIFT' then shiftkey = field end
            for shift = 0, 1 do
                for _, character in ipairs(field:keyboard_codes(shift)) do
                    keys[character] = {field=field, shift=shift == 1}
                end
            end
        end
    end
end
assert(shiftkey, 'CoCo SHIFT key not found')
local frames, index, character = 0, 1, 1
local ready, held = 2700, nil
emu.register_frame_done(function()
    frames = frames + 1
    if frames % 300 == 0 then manager.machine.screens[':screen']:snapshot(snapshot_path) end
    if frames < ready then return end
    if held then
        held.field:clear_value()
        shiftkey:clear_value()
        held = nil
        ready = frames + 12
        return
    end
    if index > #commands then
        manager.machine.screens[':screen']:snapshot(snapshot_path)
        manager.machine:exit()
        return
    end
    local line = commands[index]
    if character > #line then
        index, character = index + 1, 1
        ready = frames + (command_pause or 100)
        return
    end
    if character == 1 then
        print(string.format('command %d at frame %d: %s',index,frames,line))
        manager.machine.screens[':screen']:snapshot(snapshot_path:gsub('screen.png',string.format('command-%02d.png',index)))
    end
    local ch = line:sub(character,character)
    if ch == '\n' then ch = '\r' end
    held = assert(keys[ch], 'No keyboard mapping for '..ch)
    if held.shift then shiftkey:set_value(1) end
    held.field:set_value(1)
    character = character + 1
    ready = frames + 12
end)
