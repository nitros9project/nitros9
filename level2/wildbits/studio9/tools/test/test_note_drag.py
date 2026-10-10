"""Run pitch-move/place/formatting with a controlled mouse and mocked event mapping.

This diagnostic has not reproduced Roger's K2 freeze and does not establish a fix.
"""
from test_ume_squawk import setup


def drag():
    c,sy=setup();m=c.memory;base=0x2000
    m.write_byte(sy['MIDI.Base'],sy['MIDI.RxEmpty'])
    records=bytes.fromhex('0100300300030102')*3
    m.load(0xe000,records)
    m.write_word(sy['nparts'],1);m.write_word(sy['nstaves'],1)
    m.write_word(sy['parts']+4,1);m.write_word(sy['parts']+6,0)
    m.write_word(sy['staves']+10,130);m.write_word(sy['staves']+12,0)
    m.write_word(sy['clefs']+2,0)
    m.write_word(sy['xyoff'],0);m.write_word(sy['curcurse'],19)
    m.write_byte(sy['grafxes']+1,30);m.write_byte(sy['grafyes']+1,136)
    m.write_word(0x1e00,0x1f80);m.write_word(0x1e02,1)
    c.system_stack_pointer.set(0x1e00);c.user_stack_pointer.set(0x1234)
    c.program_counter.set(base+sy['movenote']);out=[];heard=[];polls=0;calls=[]
    tracked={base+sy[k]:k for k in ('place','partstaff','drawnr','mouce','SendCmdAC','SendCmdAD','abortest','MoveNoteDone')}
    for _ in range(120000):
        pc=c.program_counter.value;sp=c.system_stack_pointer.value
        if pc==0x1f80:break
        if pc in tracked:calls.append((tracked[pc],hex(sp)))
        if pc==base+sy['i2p']:
            assert m.read_word(sp+2)==1
            c.accu_d.set(0xe008)
        elif pc==base+sy['AuditionPlacedNote']:
            heard.append(m.read_word(sp+2))
        elif pc==base+sy['FPutc']:
            out.append(m.read_word(sp+2)&255);c.accu_d.set(out[-1])
        elif pc==base+sy['FFlush']:c.accu_d.set(0)
        elif pc in [base+sy[n] for n in ('alert','yesno','fixmarx','addclone')]:
            raise AssertionError(('unexpected dialog/range',hex(pc),calls[-15:],bytes(out)))
        elif m.read_byte(pc)==0x10 and m.read_byte(pc+1)==0x3f:
            op=m.read_byte(pc+2);c.C=0
            if op==sy['I$GetStt'] and c.accu_b.value==sy['SS.Mouse']:
                polls+=1;c.accu_a.set(int(polls<4));c.index_x.set(240)
                c.index_y.set(110 if polls==1 else 94)
            else:raise AssertionError(('unexpected OS call',op,hex(pc)))
            c.program_counter.set(pc+3);continue
        else:c.get_and_call_next_op();continue
        c.program_counter.set(c.pull_word(c.system_stack_pointer))
    else:raise AssertionError(('drag stuck',hex(c.program_counter.value),hex(c.system_stack_pointer.value),calls[-20:],bytes(out)))
    assert c.system_stack_pointer.value==0x1e02 and c.user_stack_pointer.value==0x1234 and c.index_y.value==0
    result=bytes(m.read_byte(0xe000+i) for i in range(24))
    assert result[:8]==records[:8] and result[16:]==records[16:]
    assert result[8:13]==records[8:13] and result[15]==records[15]
    assert heard==[1] and polls>=4,(heard,polls)
    print('PASS real note drag: balanced stack, one note changed, one audition; mouse polls',polls)
    return bytes(out)


if __name__=='__main__':print(drag())
