-- Continue through the introductory screens and skip the instructions.
emu.register_frame_done(function()
  if frames == 3000 or frames == 3600 or frames == 4200 or frames == 6000 or frames == 6600 then emu.keypost('\n') end
  if frames == 4800 then emu.keypost('n') end
end)
