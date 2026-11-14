-- Optional input replay, loaded after the shared boot observer.
local f=0
emu.register_frame_done(function()
 f=f+1
 if f==3600 then manager.machine.screens[":screen"]:snapshot('title.png') end
 if f==3600 then manager.machine.natkeyboard:post('2\n') end
 if f==3780 then manager.machine.natkeyboard:post('n\n') end
 if f==3960 then manager.machine.natkeyboard:post('y\n') end
 if f==4140 then manager.machine.natkeyboard:post('y\n') end
 if f==4440 then manager.machine.natkeyboard:post('\n') end
 if f==5400 then manager.machine.screens[":screen"]:snapshot('board.png');manager.machine.natkeyboard:post('\n') end
 if f==6000 then manager.machine.natkeyboard:post(' ') end
 if f==6300 then manager.machine.natkeyboard:post('c') end
 if f==8400 then manager.machine.screens[":screen"]:snapshot('move.png') end
end)
