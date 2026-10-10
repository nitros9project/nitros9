"""Execute assembled s9y; OS-9 I/O is mocked, C ABI and score callbacks checked."""
import inspect
from test_midi_import import *
import test_midi_import as midi
exec(inspect.getsource(midi.run).replace("s9i", "s9y").replace(
    "clefs=[", "patches=[mem.read_word(0x75f+2*i) for i in range(64)], clefs=["))

def lyr(*voices, start=0x151):
    h=bytearray(start); h[:8]=b'2Z0S44\x00\x20'
    h[0x121:0x129]=bytes(range(8))
    data=bytearray()
    for i,v in enumerate(voices):
        h[0x10+i*2:0x12+i*2]=(start+len(data)).to_bytes(2,'big')
        data+=v+b'\0\0'
    h[0x22:0x24]=(start+len(data)).to_bytes(2,'big')
    return bytes(h+data)

def test():
    for start in (0x151,0x160,0x181):
        r=run(lyr(bytes([3,15]),start=start))
        assert r['result']==1,r
    r=run(lyr(bytes([3,15])))
    assert r['result']==1,r
    assert len(r['notes'])==1,r
    assert r['notes'][0][3:5]==bytes([3,0]),r
    assert times(r['notes'])==[0] and r['notes'][0][5]==5,r   # one staff step higher since 2026-10-01 (C1 = 1)
    # A select pair returning to the instrument already given cancels the pending one (BluBayou $9C,$94).
    r=run(lyr(bytes([3,15,0x9c,12,0x90,12,3,15])))
    assert r['result']==1,r
    assert [e[6:8] for e in r['records'] if e[0]==0 and e[5]==0x17]==[bytes([1,0])],r
    r=run(lyr(bytes([3,15,4,16]),bytes([2,29])),native=True)
    assert r['result']==1 and len(r['notes'])==3,r
    assert times(r['notes'])==[0,0,48],r
    assert r['parts']==2 and r['channels'][:2]==bytes([0,1]),r
    r=run(lyr(bytes([0x43,15,0x13,15,0x0b,0])))
    assert r['result']==1 and times(r['notes'])==[0,72,104],r
    assert r['notes'][-1][5]==32,r
    r=run(lyr(bytes([3,15,0x23,15])))
    assert r['result']==1 and len(r['rawnotes'])==2,r
    assert times(r['rawnotes'])==[0,96],r
    r=run(lyr(bytes([3,15,0x0b,0,3,15])))
    assert r['result']==1 and times(r['rawnotes'])==[0,48,96,144],r
    # Lyra flags encode sounding pitch; the key header is for notation only.
    data=bytearray(lyr(bytes([3,0x4c,3,12,3,0xcc,3,12])));data[2:4]=b'1S'
    r=run(bytes(data))
    assert [e[4] for e in r['rawnotes'] if e[3]&0xf0==0x90]==[78,77,77,77],r
    assert [e[6] for e in r['notes']]==[0,4,0,0],r
    data=bytearray(lyr(bytes([0x90,0,0xe3,0,3,15,0xa0,80,3,15])))
    data[0x26:0x29]=b'010';data[0x12c]=80
    r=run(bytes(data))
    assert r['result']==1,r
    assert [e[3] for e in r['records'] if e[0]==0 and e[5]==0x19]==[102,51],r
    assert any(e[5]==0x17 and e[6:8]==bytes([1,0]) for e in r['records']),r
    assert r['patches'][0]==138,r
    assert r['rawnotes'][0][7]==208,r
    r=run(lyr(bytes([0xb0,0xc0,0xb0,10,0xb0,0xf8,3,15])))
    assert r['result']==1 and any(e[5]==0x17 and e[6:8]==bytes([1,16]) for e in r['records']),r
    assert r['patches'][16]==138,r
    assert any(e[5]==0x1f and e[3]==0x88 for e in r['records']),r
    r=run(lyr(bytes([0xb0,0x90,3,15])))
    assert r['result']==1,r
    r=run(lyr(bytes([0xb0,0x90,0xb0,60,3,15])))
    assert r['result']==0 and not r['init'],r
    # Multiple refills on two voices, with real score callbacks.
    r=run(lyr(bytes([7,15])*80,bytes([7,29])*80),native=True)
    assert r['result']==1 and len(r['notes'])==160 and r['reads']<20,r
    for data in [b'',lyr(bytes([3,15]))[:-1],lyr(bytes([0x80,0]))]:
        r=run(data)
        assert r['result']==0 and not r['init'],r
    r=run(lyr(bytes([3,15])),fail_add=True)
    assert r['result']==0 and r['errors'],r
    # Real archive patterns: orphan/cross-pitch ties, zero-duration placeholders, low G.
    for voice in (bytes([0x23,15]),bytes([3,15,0x23,16]),bytes([0,3,3,15]),bytes([0x43,167])):
        r=run(lyr(voice)); assert r['result']==1,r
    r=run(lyr(bytes([0xa0,15,3,15,0xa0,1,3,16])))
    tempos=[e[3]+256*e[4] for e in r['records'] if e[5]==0x19]
    assert r['result']==1 and tempos==[102,259,1983],r
    data=bytearray(lyr(bytes([3,15,0x93,27,3,16])))
    data[0x104:0x104+13]=b'CASIO CZ-230S'
    data[0x26:0x29]=b'007'
    r=run(bytes(data))
    programs=[(e[6],e[7]) for e in r['records'] if e[5]==0x17]
    assert r['result']==1 and programs==[(1,0),(1,3)],programs
    assert r['patches'][0]&127==48,r
    # A patch change from fixed percussion back to melody must release the
    # previous note on its original channel, even after routing has changed.
    data=bytearray(lyr(bytes([3,15,0x91,27,3,16])))
    data[0x104:0x104+13]=b'CASIO CZ-230S'
    data[0x26:0x29]=b'085'
    data[0x34:0x37]=b'000'
    r=run(bytes(data))
    assert r['result']==1,r
    assert [(e[3],e[4]) for e in r['rawnotes']]==[(0x99,54),(0x89,54),(0x90,71),(0x80,71)],r
    # Russia's named CT-460 bank: the old zero-based table turned Bass029
    # into Bird Tweet123, and also selected the wrong vibes/harp/guitar.
    data=bytearray(lyr(bytes([0x90,0,3,15,0x91,0,3,16,0x92,0,3,17,0x93,0,3,18])))
    data[0x104:0x110]=b'CASIO CT-460'
    for i,program in enumerate((3,29,24,9)):
        data[0x26+14*i:0x29+14*i]=f'{program:03d}'.encode()
    r=run(bytes(data),native=True)
    assert r['result']==1 and [v&127 for v in r['patches'][:4]]==[11,32,46,26],r
    assert [(e[6],e[7]) for e in r['records'] if not e[0] and e[5]==0x17]==[(1,i) for i in range(4)],r
    assert all(e[3]&15==0 for e in r['rawnotes']),r
    # Accidentals cancel within a bar and the printed key resets at each bar.
    data=bytearray(lyr(bytes([3,0x4c,3,12,3,0x8c,3,12,3,12])))
    data[2:4]=b'1S'
    r=run(bytes(data),native=True)
    assert [e[4] for e in r['rawnotes'] if e[3]&0xf0==0x90]==[78,77,76,77,77],r
    assert [e[6] for e in r['notes']]==[0,4,7,4,4],r
    # Eight source voices remain eight native parts. Match MIDI's placement
    # for the same notes/channels, including all four pitched clefs and drums.
    indices=[12,19,26,33,15,22,29,29]
    pitches=[77,65,53,41,72,60,48,48]
    channels=[0,1,2,3,4,5,6,9]
    data=bytearray(lyr(*(bytes([3,p,3,p]) for p in indices)))
    data[0x121:0x129]=bytes(channels)
    r=run(bytes(data),native=True)
    tracks=[bytes([0,0x90+c,p,100,48,0x80+c,p,0,
                   0,0x90+c,p,100,48,0x80+c,p,0])+END
            for c,p in zip(channels,pitches)]
    mr=midi.run(smf(*tracks,ppqn=48),native=True)
    assert r['result']==mr['result']==1,(r,mr)
    assert r['parts']==mr['parts']==8,(r,mr)
    assert [sum(e[0]==v for e in r['notes']) for v in range(1,9)]==[2]*8,r
    assert r['channels'][:8]==mr['channels'][:8]==bytes(channels),(r,mr)
    assert r['staffof'][:8]==mr['staffof'][:8]==[0,1,2,3,0,1,3,4],(r,mr)
    # A single low note no longer forces a predominantly high voice to bass.
    r=run(lyr(bytes([3,12,3,12,3,29])),native=True)
    assert r['result']==1 and r['staffof'][0]==1,r
    # Every ordinary/dotted/triplet duration matches Lyra 2.85's tables.
    for modifier,base in [(0,384),(0x40,576),(0x10,256),(0x50,384)]:
        data=lyr(bytes(v for length in range(1,8) for v in (modifier|length,15)))
        r=run(data)
        expected=[]; tick=0
        for length in range(1,8):
            expected.append(tick);tick+=base>>length
        assert times(r['notes'])==expected and r['final'][0][0]==tick,r
    # Gate length changes sound duration, never onset spacing or other voices.
    for fraction in range(0,9):
        data=bytearray(lyr(bytes([3,15,3,16]),bytes([3,19,3,20])))
        data[0x131]=ord('0')+fraction
        r=run(bytes(data),native=True)
        gate=48*(fraction or 8)//8
        assert times([e for e in r['notes'] if e[0]==1])==[0,48],r
        assert times([e for e in r['notes'] if e[0]==2])==[0,48],r
        assert times([e for e in r['rawnotes'] if e[3]==0x80])==[gate,48+gate],r
        assert times([e for e in r['rawnotes'] if e[3]==0x81])==[48,96],r
        assert times(r['records'])==sorted(times(r['records'])),r
    data=bytearray(lyr(bytes([3,15,0x23,15,3,16])))
    data[0x131]=ord('6')
    r=run(bytes(data))
    assert times(r['rawnotes'])==[0,84,96,132],r
    # Short notes follow Lyra's gate rounding: floor(duration/8) first.
    data=bytearray(lyr(bytes([7,15,7,16])))
    data[0x131]=ord('1')
    r=run(bytes(data));assert times(r['rawnotes'])==[0,3,3,6],r
    # Meter changes beat labels, not the duration of a quarter note.
    for meter,tempo in [(b'44',102),(b'22',51),(b'38',203),(b'68',68),(b'98',68)]:
        data=bytearray(lyr(bytes([3,15])));data[4:6]=meter
        r=run(bytes(data));t=[e[3]+256*e[4] for e in r['records'] if e[5]==0x19]
        assert r['result']==1 and t==[tempo],(meter,t)
    # Independent master and in-stream inverse tempo factors, including high byte.
    for master,expected in [(16,190),(32,102),(64,53),(256,14)]:
        data=bytearray(lyr(bytes([3,15])));data[6:8]=master.to_bytes(2,'big')
        r=run(bytes(data));t=[e[3]+256*e[4] for e in r['records'] if e[5]==0x19]
        assert t==[expected],(master,t)
    print('PASS Lyra: merged notes/rests, durations, channel routing, native callbacks, malformed/unsupported input and memory failure; S/Y/U restored on every return')
if __name__=='__main__': test()
