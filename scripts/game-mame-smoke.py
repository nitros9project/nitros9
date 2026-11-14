#!/usr/bin/env python3
"""Boot a game image and require its process to remain present for two seconds."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('disk', 'rompath', 'output'):
        parser.add_argument('--' + name, required=True, type=Path)
    parser.add_argument('--disk2', type=Path)
    parser.add_argument('--hard1', type=Path)
    parser.add_argument('--mame', default='mame')
    parser.add_argument('--cpu', choices=['6809', '6309'], required=True)
    parser.add_argument('--game', required=True)
    parser.add_argument('--program', required=True, type=Path)
    parser.add_argument('--scan-mapped-modules', action='store_true',
                        help='also locate a relocated engine module in the process DAT image')
    parser.add_argument('--command', default='')
    parser.add_argument('--error-byte', type=lambda value: int(value, 0),
                        help='game error byte in private process memory; must be zero at the checkpoint')
    parser.add_argument('--ram', default='512K')
    parser.add_argument('--replay', type=Path)
    parser.add_argument('--min-frames', type=int, default=3600)
    parser.add_argument('--seconds', type=int, default=90)
    parser.add_argument('--min-screen-change', type=float, default=0.0)
    parser.add_argument('--min-screen-colors', type=int, default=0)
    parser.add_argument('--require-animation', action='store_true')
    args = parser.parse_args()
    if not 0 <= args.min_screen_change <= 1:
        parser.error('--min-screen-change must be between zero and one')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    for name in ('passed.txt', 'screen-change.txt', 'animation.txt', 'error-byte.txt', 'screen-colors.txt',
                 'snap/before.png', 'snap/game.png', 'snap/screen.png'):
        (output / name).unlink(missing_ok=True)
    # Use the actual module header name, which can differ from its host filename.
    module = args.program.read_bytes()
    if module[:2] != b'\x87\xcd':
        raise SystemExit(f'Not an OS-9 module: {args.program}')
    offset = int.from_bytes(module[4:6], 'big')
    name = ''
    for byte in module[offset:]:
        name += chr(byte & 127)
        if byte & 128:
            break
    name = name.lower()
    machine = 'coco3h' if args.cpu == '6309' else 'coco3'
    subprocess.run(['python3', str(Path(__file__).with_name('mame-rgb.py')), '--machine', machine,
                    '--config', str(output / 'cfg')], check=True)
    disk = output / 'test.dsk'
    shutil.copyfile(args.disk, disk)
    command = [args.mame, machine, '-rompath', str(args.rompath.resolve())]
    with (output / 'rom-audit.log').open('w') as log:
        subprocess.run(command + ['-verifyroms'], stdout=log, stderr=subprocess.STDOUT, check=True)
        subprocess.run([args.mame, 'coco_fdc', '-rompath', str(args.rompath.resolve()), '-verifyroms'],
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    # These are the Level 2 OS-9 D.PrcDBT, P$PModul, P$DATImg and M$Name
    # layouts from defs/os9.d. Read system memory through task 0's GIME map,
    # then read each primary module through that process's saved DAT image.
    lua = '''local monitor = manager.machine.ioport.ports[":screen_config"]:read() & 1
local monitorlog = assert(io.open("monitor.txt","w")); monitorlog:write(monitor); monitorlog:close()
assert(monitor == 1, "MAME must start in RGB mode")
emu.keypost("DOS\\n")
local ram = emu.item(manager.machine.devices[":ram"].items["0/m_pointer"])
local mmu = emu.item(manager.machine.devices[":gime"].items["0/m_mmu"])
local blockmask = (ram.count // 8192) - 1
local function sysbyte(a)
  return ram:read((mmu:read((a >> 13) & 7) & blockmask)*8192 + (a & 8191))
end
local function sysword(a) return sysbyte(a)*256 + sysbyte(a+1) end
local function userbyte(p,a)
  local block = sysword(p+0x40+((a >> 13) & 7)*2) & blockmask
  return ram:read(block*8192 + (a & 8191))
end
local function username(p,m)
  m = m or sysword(p+0x11)
  if userbyte(p,m) ~= 0x87 or userbyte(p,m+1) ~= 0xcd then return "" end
  local n = m + userbyte(p,m+4)*256 + userbyte(p,m+5)
  local name = ""
  for i=0,31 do
    local c = userbyte(p,(n+i) & 65535)
    name = name .. string.char(c & 127)
    if c & 128 ~= 0 then return string.lower(name) end
  end
  return ""
end
-- A private engine can switch its own pages out between callbacks.
-- Retain a verified identity only for the lifetime of this process/module pair.
local identities = {}
local frames, stable = 0, 0
local before
local previous_frame, animated = nil, false
emu.register_frame_done(function()
  frames = frames + 1
  if frames == 1740 and MIN_SCREEN_CHANGE > 0 then
    before = manager.machine.screens[":screen"]:pixels()
    manager.machine.screens[":screen"]:snapshot("before.png")
  end
  if frames == 1800 and INPUT ~= "" then emu.keypost(INPUT .. "\\n") end
  local found = false
  local error = 0
  local table = sysword(0x48)
  if table > 0 and table < 0xff00 then
    for id=1,63 do
      local p = sysbyte(table+id)*256
      if p > 0 and sysbyte(p) == id and (sysbyte(p+12) & 1) == 0 then
        if username(p) == TARGET then
          found = true
          if ERROR_BYTE >= 0 then error = error | userbyte(p,ERROR_BYTE) end
        end
        if SCAN_MAPPED_MODULES then
          local module = sysword(p+0x11)
          local identity = identities[id]
          if not identity or identity.p ~= p or identity.module ~= module then
            identity = {p=p, module=module, matched=false}
            identities[id] = identity
          end
          -- Sierra copies its engine modules into private pages and remaps
          -- the loader's primary header out of the process address space.
          for slot=0,7 do
            if username(p,slot*8192) == TARGET then identity.matched = true end
          end
          if identity.matched then
            found = true
            if ERROR_BYTE >= 0 then error = error | userbyte(p,ERROR_BYTE) end
          end
        end
      else
        identities[id] = nil
      end
    end
  end
  if found then stable = stable + 1 else stable = 0 end
  if REQUIRE_ANIMATION and found and frames >= 2400 and frames % 60 == 0 then
    local pixels = manager.machine.screens[":screen"]:pixels()
    if previous_frame and pixels ~= previous_frame then animated = true end
    previous_frame = pixels
  end
  if frames % 300 == 0 then manager.machine.screens[":screen"]:snapshot("screen.png") end
  if stable >= 120 and frames >= MIN_FRAMES then
    manager.machine.screens[":screen"]:snapshot("game.png")
    if MIN_SCREEN_COLORS > 0 then
      local pixels = manager.machine.screens[":screen"]:pixels()
      local colors, count = {}, 0
      for i=1,#pixels,4 do
        local pixel = pixels:sub(i,i+3)
        if not colors[pixel] then colors[pixel] = true; count = count + 1 end
      end
      local f = assert(io.open("screen-colors.txt","w")); f:write(count); f:close()
      if count < MIN_SCREEN_COLORS then manager.machine:exit(); return end
    end
    if ERROR_BYTE >= 0 then
      local f = assert(io.open("error-byte.txt","w")); f:write(error); f:close()
      if error ~= 0 then manager.machine:exit(); return end
    end
    if MIN_SCREEN_CHANGE > 0 then
      local pixels = manager.machine.screens[":screen"]:pixels()
      local ratio = 0
      if before and #before ~= #pixels then
        ratio = 1
      elseif before then
        local changed = 0
        for i=1,#pixels,4 do
          if pixels:sub(i,i+3) ~= before:sub(i,i+3) then changed = changed + 1 end
        end
        ratio = changed / (#pixels / 4)
      end
      local f = assert(io.open("screen-change.txt","w")); f:write(ratio); f:close()
      if ratio < MIN_SCREEN_CHANGE then manager.machine:exit(); return end
    end
    if REQUIRE_ANIMATION then
      local f = assert(io.open("animation.txt","w")); f:write(tostring(animated)); f:close()
      if not animated then manager.machine:exit(); return end
    end
    local f = assert(io.open("passed.txt","w")); f:write(TARGET); f:close()
    manager.machine:exit()
  end
end)
'''.replace('MIN_SCREEN_COLORS', str(args.min_screen_colors)).replace('ERROR_BYTE', str(args.error_byte if args.error_byte is not None else -1)).replace('SCAN_MAPPED_MODULES', str(args.scan_mapped_modules).lower()).replace('TARGET', json.dumps(name)).replace('INPUT', json.dumps(args.command)).replace('MIN_FRAMES', str(args.min_frames)).replace('MIN_SCREEN_CHANGE', str(args.min_screen_change)).replace('REQUIRE_ANIMATION', str(args.require_animation).lower())
    if args.replay:
        lua += '\n' + args.replay.read_text()
    (output / 'boot.lua').write_text(lua)
    (output / 'passed.txt').unlink(missing_ok=True)
    command += ['-cfg_directory', 'cfg', '-nvram_directory', 'nvram', '-snapshot_directory', 'snap',
                '-skip_gameinfo', '-sound', 'none', '-video', 'soft', '-window', '-nothrottle',
                '-ram', args.ram, '-ext', 'fdc,bios=v11', '-ext:fdc:wd17xx:0', '525qd',
                '-flop1', str(disk), '-autoboot_delay', '3', '-autoboot_script', 'boot.lua',
                '-seconds_to_run', str(args.seconds)]
    if args.disk2:
        shutil.copyfile(args.disk2, output / 'data.dsk')
        command += ['-flop2', str(output / 'data.dsk')]
    if args.hard1:
        shutil.copyfile(args.hard1, output / 'library.vhd')
        command += ['-hard1', str(output / 'library.vhd')]
    with (output / 'mame.log').open('w') as log:
        subprocess.run(command, cwd=output, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=180)
    if not (output / 'passed.txt').exists() or (output / 'passed.txt').read_text() != name:
        raise SystemExit(f'FAIL: {args.game} did not satisfy its process/display checks; see {output}')
    print(f'PASS: {args.game} booted on {machine}; {name} module remained in a live process for 120 frames')


if __name__ == '__main__':
    main()
