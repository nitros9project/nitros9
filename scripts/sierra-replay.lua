-- Choose keyboard controls at Sierra's joystick prompt.
local control = assert(manager.machine.ioport.ports[":row6"].fields["CTRL"])
local breakkey = assert(manager.machine.ioport.ports[":row6"].fields["BREAK"])
emu.register_frame_done(function()
  if frames == 4200 then
    control:set_value(1)
    breakkey:set_value(1)
  elseif frames == 4260 then
    control:clear_value()
    breakkey:clear_value()
  end
end)
