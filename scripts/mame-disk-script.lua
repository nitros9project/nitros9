-- Only boot is typed. OS-9 startup executes all test commands from disk.
emu.keypost('DOS\n')
local frames, finished = 0, nil
emu.register_frame_done(function()
    frames = frames + 1
    if frames % 300 == 0 then manager.machine.screens[':screen']:snapshot(snapshot_path) end
    if script_finished and not finished then finished = frames end
    -- Allow the final write/close and startup shell to finish before stopping.
    if finished and frames >= finished + 120 then
        manager.machine.screens[':screen']:snapshot(snapshot_path)
        manager.machine:exit()
    end
end)
