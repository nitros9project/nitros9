"""Execute assembled s9o; OS-9 I/O is mocked, C ABI and score callbacks checked."""
import inspect, sys
from test_midi_import import *
import test_midi_import as midi
exec(inspect.getsource(midi.run).replace("s9i", "s9o").replace(
    "clefs=[", "patches=[mem.read_word(0x75f+2*i) for i in range(64)], names=[bytes(mem.read_byte(0x7eb+16*i+j) for j in range(8)) for i in range(8)], clefs=["))

SAMPLE = b"K1#\rNQ=80\rV1YA V2YB V3YC V4YD\rP01\rM01 *Q$B$B\r    V2Q$6$6\r    V3Q$4$4\r    V4Q-3$1$\rR01\r"

def midi_notes(r):
    return [(e[1]*256+e[2], e[3], e[4]) for e in r['rawnotes']]

def test():
    r = run(SAMPLE, native=True)
    assert r['result'] == 1, r
    ons = [(t, s & 15, p) for (t, s, p) in midi_notes(r) if s & 0xf0 == 0x90]
    # measure 1: V1 B (=+B: G5 79) on beats 2 and 4; V2 6 (B4 71); V3 4 (G4 67); V4 -3 (G3 55) beat 1, 1 (D4 62) beat 3;
    # then the same measure again from R01 (key of G: F# only - none of these are F)
    assert ons[:5] == [(0, 3, 55), (48, 0, 79), (48, 1, 71), (48, 2, 67), (96, 3, 62)], ons[:8]
    assert len(ons) == 16, len(ons)
    assert ons[8][0] == 192, ons[8]
    keys = [e for e in r['records'] if e[0] == 0 and e[5] == 0x0B]
    assert keys and keys[0][6] == 1, keys
    tempos = [e[3] + 256*e[4] for e in r['records'] if e[5] == 0x19]
    assert tempos == [120], tempos
    meters = [(e[6], e[7]) for e in r['records'] if e[0] == 0 and e[5] == 0x0A]
    assert meters == [(4, 4)], meters
    assert r['nbars'] == 3 and len(r['bars']) == 3, (r['nbars'], r['bars'])
    assert r['parts'] == 4 and r['channels'][:4] == bytes([0, 1, 2, 3]), r
    assert [p & 0x7f for p in r['patches'][:5]] == [56, 68, 71, 19, 40], r['patches'][:5]
    assert r['names'][0].startswith(b'Trumpet'), r['names'][0]
    rests = [e for e in r['notes'] if e[5] == 32]
    assert len(rests) == 16, len(rests)
    # a custom register: the piano definition of appendix D matches the piano, a random wave is a drum
    r = run(b"JASA8642202F\rJBR000300058\rV1YA V2YB\rM *Q0 V2Q0\r", native=True)
    assert r['result'] == 1, r
    assert (r['patches'][0] & 0x7f, r['patches'][1] & 0x7f) == (0, 118), r['patches'][:2]
    assert r['names'][0].startswith(b'Piano'), r['names'][0]
    # accidentals: explicit sharp holds for the measure, the bar resets it; flats from the key
    r = run(b"K1&\rM *Q0#00 M *Q0 3 -3\r", native=True)
    ons = [p for (t, s, p) in midi_notes(r) if s & 0xf0 == 0x90]
    assert ons == [61, 61, 61, 60, 65, 55], ons
    # durations, dots, triplets, rests and articulation gates
    r = run(b"M *W0H.0Q:0I$S0'\r", native=True)
    ns = midi_notes(r)
    starts = [t for (t, s, p) in ns if s & 0xf0 == 0x90]
    assert starts == [0, 192, 336, 392], starts
    offs = [t for (t, s, p) in ns if s & 0xf0 == 0x80]
    assert offs == [192, 336, 368, 403], offs
    # transposition: > semitones and U steps; the one-note clef override; the bass clef
    r = run(b">2 M @0 +0 V2U-7 *0\r", native=True)
    ons = [p for (t, s, p) in midi_notes(r) if s & 0xf0 == 0x90]
    assert ons == [62, 50, 62], ons  # V2's note at tick 0 sorts before V1's second note
    # ( )n repeats and parts: (0 1)1 plays twice, P02 R01 replays part 1 after part 2
    r = run(b"P01 M *Q(01)1 P02 M *Q2 R01\r", native=True)
    ons = [(t, p) for (t, s, p) in midi_notes(r) if s & 0xf0 == 0x90]
    assert ons == [(0, 60), (48, 62), (96, 60), (144, 62), (192, 64), (240, 60), (288, 62), (336, 60), (384, 62)], ons
    # the percussion clef: channel 10, drum keys, staff 4
    r = run(b"M *Q0 V2 \x5fQ0'1'\r", native=True)
    ons = [(s & 15, p) for (t, s, p) in midi_notes(r) if s & 0xf0 == 0x90]
    assert ons == [(0, 60), (9, 35), (9, 36)], ons
    assert r['staffof'][1] == 4, r['staffof']
    # bad input leaves the score alone
    for data in (b"", b"V9", b"YZ"):
        r = run(data)
        assert r['result'] == 0 and not r['init'], (data, r)
    print('PASS Orchestra-90: sample, registers, accidentals, durations, transposition, repeats, percussion, errors')
if __name__ == '__main__': test()
