"""Execute assembled s9f against Musica II records and native score callbacks."""
import inspect
import math
import struct
from pathlib import Path
import test_midi_import as midi
from test_midi_import import *

class Memory(Memory):
    """Foenix combinational unsigned 16x16 multiplier, not a SID emulator."""
    def read_byte(self, address):
        if 0xfef0 <= address <= 0xfef3:
            self.cpu.cycles += 1
            a = (super().read_byte(0xfee0) << 8) | super().read_byte(0xfee1)
            b = (super().read_byte(0xfee2) << 8) | super().read_byte(0xfee3)
            return (a * b >> (8 * (0xfef3-address))) & 255
        return super().read_byte(address)

exec(inspect.getsource(midi.run).replace("s9i", "s9f").replace(
    "reads=reads[0])", "reads=reads[0], patches=bytes(mem.read_byte(0x75f+i) for i in range(128)), instruments_enabled=mem.read_byte(0x40))"))

ROOTS = [Path(r"D:\CoCo")]

def rec(length, *freqs):
    assert len(freqs) == 4
    return bytes([length]) + struct.pack(">4H", *freqs)

def musica(*records, tempo=64, header=True):
    waves = bytes([1]) + bytes(1023)
    defaults = bytes([tempo, 0x41, 0x42, 0x43, 0x40])
    body = defaults + b"".join(records) + b"\0\x39\x83"
    payload = waves + body
    return (b"\0" + len(payload).to_bytes(2, "big") + b"\x40\0" if header else b"") + payload

def time(e):
    return int.from_bytes(e[1:3], "big")

def validate_corpus():
    paths = {}
    for root in ROOTS:
        for p in root.rglob("*"):
            if p.is_file() and p.suffix.lower() == ".mus":
                paths[str(p).lower()] = p
    assert paths, "no Musica II corpus found"
    layouts = {"header": 0, "headerless": 0}
    bars = pitches = 0
    phase_min, phase_max = 0xffff, 0
    midi_min, midi_max = 127, 0
    for p in paths.values():
        data = p.read_bytes()
        base = 5 if data and data[0] == 0 else 0
        layouts["header" if base else "headerless"] += 1
        pos = base + 1024
        assert len(data) >= pos + 8, (p, len(data))
        pos += 5
        found = False
        while pos < len(data):
            code = data[pos]
            if code == 0:
                assert pos + 3 <= len(data), (p, "short end")
                found = True
                break
            assert pos + 9 <= len(data), (p, hex(pos), hex(code))
            if code == 0xff:
                bars += 1
            elif code < 0x80:
                for phase in struct.unpack_from(">4H", data, pos + 1):
                    if phase:
                        pitches += 1
                        phase_min, phase_max = min(phase_min, phase), max(phase_max, phase)
                        hz = phase * 440 / 0x123f
                        note = round(69 + 12 * math.log2(hz / 440))
                        midi_min, midi_max = min(midi_min, note), max(midi_max, note)
            pos += 9
        assert found, (p, "no end record")
    assert bars and pitches and midi_min < 36, (bars, pitches, midi_min, midi_max)
    return len(paths), layouts, bars, pitches, phase_min, phase_max, midi_min, midi_max

def test():
    c3, c4, e4, a4 = 0x056c, 0x0ad9, 0x0dab, 0x123f
    data = musica(rec(0x20, c4, e4 + 3, c3, a4), b"\xff" + bytes(8))
    r = run(data, native=True)
    assert r["result"] == 1, r
    assert len(r["notes"]) == 4, r
    assert [time(e) for e in r["notes"]] == [0] * 4, r["notes"]
    assert [e[0] for e in r["notes"]] == [1, 2, 3, 4], r["notes"]
    assert all(e[7] == 2 for e in r["notes"]), r["notes"]
    assert not r["rawnotes"], r["rawnotes"]
    assert r["channels"][:4] == bytes(range(4)), r
    assert r["staffof"][:4] == [1, 1, 3, 0], r["staffof"]
    assert r["notes"][0][5:7] == bytes([3, 1]), r["notes"][0]  # author's $0AD9 = C4
    tempos = [e[3] + 256*e[4] for e in r["records"] if e[0] == 0 and e[5] == 0x19]
    assert tempos == [191], tempos
    assert [time(e) for e in r["bars"]] == [0, 48], r["bars"]
    meters = [e[5:] for e in r["records"] if e[0] == 0 and e[5] == 0x0a]
    assert meters == [bytes([0x0a, 4, 4])], meters
    assert all((e[3], e[4]) == (3, 0) for e in r["notes"]), r["notes"]

    # Headerless scores and Play-compatible bar repeats are accepted. The FD
    # record repeats everything from the first music record once.
    data = musica(rec(0x20, c4, 0, 0, 0), b"\xfd" + bytes(8), rec(0x10, e4, 0, 0, 0), header=False)
    r = run(data, native=True)
    assert r["result"] == 1, r
    assert [time(e) for e in r["notes"]] == [0, 96], r["notes"]
    assert [(e[3], e[4]) for e in r["notes"]] == [(2, 0), (4, 0)], r["notes"]
    assert all(e[7] == 2 for e in r["notes"]), r["notes"]
    assert not r["rawnotes"], r["rawnotes"]

    # Rounding cumulative source time avoids adding half-tick error to every
    # odd record: three one-tick records begin at native ticks 0, 2 and 3.
    r = run(musica(rec(1, c4, 0, 0, 0), rec(1, c4, 0, 0, 0),
                   rec(1, c4, 0, 0, 0), b"\xff" + bytes(8)), native=True)
    assert [time(e) for e in r["notes"]] == [0] and duration(r["notes"][0]) == 5, r["notes"]
    assert [time(e) for e in r["bars"]] == [0, 5], r["bars"]

    # Four Musica quarter notes span 192 native ticks, producing a visible 4/4
    # meter record and source-authoritative closing bar.
    quarter = rec(0x20, c4, 0, 0, 0)
    r = run(musica(quarter, quarter, quarter, quarter,
                   b"\xff" + bytes(8)), native=True)
    assert [time(e) for e in r["notes"]] == [0], r["notes"]
    assert [time(e) for e in r["bars"]] == [0, 192], r["bars"]
    assert [e[5:] for e in r["records"] if e[0] == 0 and e[5] == 0x0a] == [bytes([0x0a, 4, 4])], r["records"]

    # The real player scale reaches an octave below the old importer table.
    r = run(musica(rec(0x20, 0x015b, 0, 0, 0)), native=True)
    assert r["result"] == 1 and len(r["notes"]) == 1 and r["staffof"][0] == 3, r

    # A /4 tempo block follows the real 137-cycle player, not tempo/240.
    tempo = bytes([0xfe, 0x41, 0x42, 0x43, 0x40, 100, 0, 0, 0])
    r = run(musica(tempo, rec(0x20, c4, 0, 0, 0)), native=True)
    assert [e[3] + 256*e[4] for e in r["records"] if e[0] == 0 and e[5] == 0x19] == [191, 122], r["records"]

    # Import owns all four melodic channels and patches, without Tutti.
    r = run(musica(rec(0x20, c4, e4, c3, a4)), native=True)
    assert r['instruments_enabled'] == 1
    assert r['patches'][:8] == bytes([0,128])*4, r['patches'][:8]
    assert [e[6:8] for e in r['records'] if not e[0] and e[5] == 0x16] == [bytes([i+1,i]) for i in range(4)]
    assert [e[6:8] for e in r['records'] if not e[0] and e[5] == 0x17] == [bytes([1,1]),bytes([2,2]),bytes([3,3]),bytes([4,0])]
    # Distinct periodic waves select pitched defaults; FE changes retain the
    # same editable native slots. The wave shape is only an approximation.
    waves=b''.join(bytes(round(32+28*math.sin(2*math.pi*h*i/256)) for i in range(256)) for h in (1,2,4,1))
    change=bytes([0xfe,0x43,0x42,0x41,0x40,80,0,0,0])
    data=musica(rec(32,c4,e4,c3,a4),change,rec(32,c4,e4,c3,a4))
    data=data[:5]+waves+data[1029:]
    r=run(data,native=True)
    assert r['patches'][:8]==bytes([0,128,0,184,0,176,0,128]),r['patches'][:8]
    assert [e[6:8] for e in r['records'] if not e[0] and e[5]==0x17][-4:]==[bytes([i+1,3-i]) for i in range(4)]

    # Zero tempo is 256 counts; wide tempo retains fast settings; meter changes
    # must not alter elapsed note time. Four quarters infer 4/4.
    for t, want in [(0,48),(1,12248),(64,191),(80,153),(100,122),(255,48)]:
        r = run(musica(quarter,quarter,quarter,quarter,b"\xff"+bytes(8),tempo=t),native=True)
        assert [e[3]+256*e[4] for e in r['records'] if not e[0] and e[5]==0x19] == [want], (t,r['records'])
    # Direct step-rate calculation, including chorus detuning.
    for phase,acc in [(c4,1),(e4+3,1),(a4,1),(0x0b7e,2)]:
        r=run(musica(rec(0x20,phase,0,0,0)),native=True)
        assert r['notes'][0][6] == acc,(hex(phase),r['notes'])

    good = musica(rec(0x20, c4, 0, 0, 0))
    for end in (0, 4, 1028, len(good) - 4):
        r = run(good[:end])
        assert r["result"] == 0 and r["errors"] and not r["init"], (end, r)
    r = run(good, fail_add=True)
    assert r["result"] == 0 and "memory" in r["errors"][0].lower(), r

    test_continuity()
    count, layouts, bars, pitches, pmin, pmax, nmin, nmax = validate_corpus()
    print(f"PASS Musica II: direct calculated pitch, 137-cycle/0.895 Mhz tempo, cumulative timing, native meter/bars, staff placement, four voices, headerless files, repeat bar, malformed/memory errors; {count} collection files valid ({layouts}), {bars} bars, {pitches} pitches, phase ${pmin:04X}-${pmax:04X}, MIDI {nmin}-{nmax}")

def duration(e):
    return [384,576,672,256][e[4]] >> e[3]

def coverage(r):
    assert r['result']==1 and not r['errors'], r
    bars=[time(e) for e in r['bars']]
    assert bars==sorted(set(bars)),bars
    assert [time(e) for e in r['records']]==sorted(time(e) for e in r['records'])
    for part in range(1,r['parts']+1):
        notes=[e for e in r['notes'] if e[0]==part]
        if not notes: continue
        end=0
        for e in notes:
            assert time(e)==end,(part,end,e)
            end=time(e)+duration(e)
            assert not any(time(e)<b<end for b in bars),(part,e,bars)
        assert end==bars[-1],(part,end,bars[-1])
    return r

def test_continuity():
    c,e,g=0xad9,0xdab,0x1042
    bar=b"\xff"+bytes(8)
    r=coverage(run(musica(*[rec(32,c,0,0,0)]*4,bar),native=True))
    assert len(r['notes'])==1 and duration(r['notes'][0])==192
    r=coverage(run(musica(rec(32,c,e,0,0),rec(32,c,g,0,0),rec(32,c,0,0,0),rec(32,c,e,0,0),bar),native=True))
    assert len([e for e in r['notes'] if e[0]==1])==1
    assert [e[5] for e in r['notes'] if e[0]==2][2]==32
    r=coverage(run(musica(*[rec(32,c,0,0,0)]*8),native=True))
    assert [(time(e),duration(e),e[7]) for e in r['notes']]==[(0,192,0),(192,192,2)]
    # Changing exactly at the bar must end the first note, not tie to the next.
    r=coverage(run(musica(*[rec(32,c,0,0,0)]*4,bar,*[rec(32,e,0,0,0)]*4,bar),native=True))
    assert [e[7] for e in r['notes']]==[2,2]
    # 30+2 is one quarter, not a rounded quarter plus a 64th.
    r=coverage(run(musica(*[rec(n,c,0,0,0) for n in [30,2]*4],bar),native=True))
    assert len(r['notes'])==1 and duration(r['notes'][0])==192
    # Exact documented tuplets: sixteenth triplets total24, eighth triplets48.
    for length,total in [(5,24),(11,48)]:
        r=coverage(run(musica(*[rec(length,c,0,0,0)]*3,bar),native=True))
        assert r['bars'][-1][1:3]==total.to_bytes(2,'big')
    # Same pitch, distinct silence: must remain two sounding notes.
    r=coverage(run(musica(rec(16,c,0,0,0),rec(16,0,0,0,0),rec(32,c,0,0,0)),native=True))
    assert [e[5]==32 for e in r['notes']]==[False,True,False]
    # Long records crossing a bar and a pickup; every voice accounts for every tick.
    r=coverage(run(musica(rec(16,c,e,0,0),bar,rec(127,c,e,0,0),rec(64,c,g,0,0),bar),native=True))
    print('PASS independent voice holds, rests, exact durations, tuplets, bar ties, pickups and generated measures')

if __name__ == "__main__":
    test()
