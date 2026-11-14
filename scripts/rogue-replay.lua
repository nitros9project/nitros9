-- Dismiss the title, enter a player name, then take a dungeon turn.
emu.register_frame_done(function()
  if frames == 3000 then emu.keypost(' ') end
  if frames == 3600 then emu.keypost('Tester\n') end
  if frames == 5400 then emu.keypost('.') end
end)
