#!/usr/bin/env python3
"""Execute Level 1 F$SRqMem and its bitmap allocator on an external usim CPU.

Requires LWASM, a C++20 compiler, and a usim checkout (--usim-dir). The CPU
dependency is not downloaded or vendored. --baseline REF tests archived sources.
Generated programs and the minimal RAM test board stay in a temporary directory.
"""
import argparse
from pathlib import Path
import subprocess
import sys
import tempfile

BOARD = r'''
#include "mc6809.h"
#include <array>
#include <fstream>
#include <iostream>
#include <stdexcept>
class Board : public mc6809 {
public:
    std::array<Byte,65536> mem{};
    bool done = false;
    int result = 255;
    Board() { abort = [] { throw std::runtime_error("invalid instruction"); }; }
    Byte read(Word addr) override { ++cycles; return mem[addr]; }
    void write(Word addr, Byte value) override {
        ++cycles;
        if (mem[0x100] && addr >= 0x620 && addr < 0x640) {
            std::cerr << "write beyond allocation bitmap at $" << std::hex << addr << '\n';
            result = 99; done = true;
        }
        if (addr == 0xFE08) { result = value; done = true; }
        mem[addr] = value;
    }
};
int main(int argc, char **argv) {
    try {
        if (argc != 2) return 2;
        Board board;
        std::ifstream rom(argv[1], std::ios::binary);
        rom.read(reinterpret_cast<char *>(board.mem.data()+0xC000), 0x4000);
        if (rom.gcount() != 0x4000) throw std::runtime_error("invalid ROM size");
        board.reset();
        for (unsigned n=0; n<1000000 && !board.done; ++n) board.tick();
        if (!board.done) throw std::runtime_error("instruction limit");
        return board.result;
    } catch (const std::exception& e) { std::cerr << e.what() << '\n'; return 98; }
}
'''


def program(size, full, release_at=None):
    bitmap = bytearray(b'\xff'*4 + b'\x00'*12 + b'\xff'*16)
    if full:
        bitmap[:] = b'\xff'*32
    expected = bitmap[:]
    rounded = (size+255) & ~255
    succeeds = 0 < rounded <= 0x6000 and not full
    if succeeds:
        base = 0x8000-rounded
        for page in range(base//256, 0x80):
            expected[page//8] |= 0x80 >> (page % 8)
        check = f'''
        lbcs Fail
        ldd R$D,u
        cmpd #{rounded}
        lbne Fail
        ldd R$U,u
        cmpd #{base}
        lbne Fail
'''
    else:
        check = '''
        lbcc Fail
        cmpb #207
        lbne Fail
        ldd R$U,u
        cmpd #$4567
        lbne Fail
'''
    operation = 'FSRqMem'
    argument = 0x4567
    if release_at is not None:
        operation = 'FSRtMem'
        argument = release_at
        bitmap[:] = b'\xff'*32
        expected = bitmap[:]
        noop = size == 0 or release_at == 0
        succeeds = noop or (rounded <= 0xFF00 and release_at % 256 == 0
                            and release_at+rounded <= 0x10000)
        if succeeds and not noop:
            for page in range(release_at//256, (release_at+rounded)//256):
                expected[page//8] &= ~(0x80 >> (page % 8))
        check = f'''
        {'lbcs' if succeeds else 'lbcc'} Fail
'''
        if not succeeds:
            check += '''
        cmpb #210
        lbne Fail
'''
        check += f'''
        ldd R$U,u
        cmpd #{release_at}
        lbne Fail
'''
    return f'''
Level   equ 1
        use os9.d
        org $C000
Start   orcc #$50
        lds #$1000
        clra
        tfr a,dp
        ldd #$0600
        std <D.FMBM
        ldd #$0620
        std <D.FMBM+2
        leax Initial,pcr
        ldy #$0600
        ldb #32
Copy    lda ,x+
        sta ,y+
        decb
        bne Copy
        ldu #$1800
        ldd #{size}
        std R$D,u
        ldd #{argument}
        std R$U,u
        lda #1
        sta >$0100
        jsr {operation}
{check}
        ldx #$0600
        leay Expected,pcr
        ldb #32
Check   lda ,x+
        cmpa ,y+
        lbne Fail
        decb
        bne Check
        clrb
        bra Done
Fail    ldb #1
Done    stb >$FE08
        bra Done
Initial fcb {','.join(str(b) for b in bitmap)}
Expected fcb {','.join(str(b) for b in expected)}
        use fsrqmem.asm
        use fallbit.asm
        fill $FF,$FFFE-*
        fdb Start
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assembler', default='lwasm')
    parser.add_argument('--cxx', default='c++')
    parser.add_argument('--usim-dir', required=True, type=Path)
    parser.add_argument('--baseline', help='Git revision to test instead of working sources')
    parser.add_argument('--return-memory', action='store_true', help='Exercise F$SRtMem instead')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    cpu = args.usim_dir.resolve()
    with tempfile.TemporaryDirectory(prefix='nitros9-srqmem-') as temp:
        work = Path(temp)
        source_root = root
        if args.baseline:
            source_root = work/'baseline'
            source_root.mkdir()
            archive = subprocess.check_output(['git','archive',args.baseline,'defs','level1'],cwd=root)
            subprocess.run(['tar','-xf','-','-C',str(source_root)],input=archive,check=True)
        (work/'board.cpp').write_text(BOARD)
        subprocess.run([args.cxx,'-std=c++20','-O2',f'-I{cpu}',str(work/'board.cpp'),
                        *(str(cpu/f) for f in ('usim.cpp','memory.cpp','mc6809.cpp','mc6809in.cpp')),
                        '-o',str(work/'board')],check=True)
        failures = 0
        cases = [(size,False) for size in (0,1,255,256,257,4097,0x6000,0x6001,0xFF00,0xFF01,0xFFFF)]
        cases += [(1,True)]
        if args.return_memory:
            cases = [(0,page*256) for page in range(0x20,0x28)]
            cases += [(0xFF01,0x2100),(0xFFFF,0x2100),(1,0x2100),
                      (257,0x2100),(0xFF00,0x100),(256,0xFF00),
                      (257,0xFF00),(256,0x2001),(0,0),(0xFFFF,0)]
        for size,setting in cases:
            source = program(size,False,setting) if args.return_memory else program(size,setting)
            (work/'test.asm').write_text(source)
            subprocess.run([args.assembler,'--6809','--format=raw','--no-warn=ifp1',
                            '--pragma=nosymbolcase,condundefzero,undefextern,dollarnotlocal,noforwardrefmax',
                            '-DH6309=0',f'-I{source_root / "defs"}',
                            f'-I{source_root / "level1/modules/kernel"}',
                            str(work/'test.asm'),'-o'+str(work/'test.rom')],check=True,capture_output=True)
            result = subprocess.run([str(work/'board'),str(work/'test.rom')],capture_output=True,text=True)
            label = (f'size=${size:04X}, address=${setting:04X}' if args.return_memory
                     else f'size=${size:04X}, bitmap={"full" if setting else "96 free pages"}')
            print(f'{"FAIL" if result.returncode else "PASS"}: {label} {result.stderr.strip()}')
            failures += bool(result.returncode)
        print(f'{len(cases)-failures}/{len(cases)} cases passed')
        return bool(failures)


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        if error.stderr:
            print(error.stderr.decode() if isinstance(error.stderr, bytes) else error.stderr,
                  file=sys.stderr)
        raise SystemExit(error.returncode)
