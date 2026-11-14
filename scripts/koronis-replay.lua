-- Select RGB and dismiss the title with the joystick button.
local buttons=manager.machine.ioport.ports[":joystick_buttons"].fields
emu.register_frame_done(function()
  if frames == 4200 then emu.keypost('r') end
  if frames == 5400 then
    buttons["Left Button 1"]:set_value(1)
    buttons["Right Button 1"]:set_value(1)
  elseif frames == 5460 then
    buttons["Left Button 1"]:clear_value()
    buttons["Right Button 1"]:clear_value()
  end
end)
