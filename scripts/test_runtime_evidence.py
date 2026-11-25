import importlib.util
from pathlib import Path
import unittest

spec=importlib.util.spec_from_file_location('runtime',Path(__file__).with_name('module-runtime-evidence.py'))
runtime=importlib.util.module_from_spec(spec);spec.loader.exec_module(runtime)

def checkpoint(sequence,phase):
    raw=bytearray(878)
    raw[:3]=bytes([ord('L'),phase,3])
    raw[8:10]=sequence.to_bytes(2,'big');raw[10:12]=b'GR'
    raw[524:588]=bytes([1]*8+[0]*56)
    raw[589:592]=b'\x01\x02\x03'
    raw[844:848]=b'\x01'*4
    raw[876:878]=(5).to_bytes(2,'big')
    return raw

class ResourceEvidenceTests(unittest.TestCase):
    def test_balanced_checkpoints(self):
        result=runtime.resources(checkpoint(0,0)+checkpoint(100,1)+checkpoint(200,2),200)
        self.assertEqual(result['baseline'],dict(free_blocks=56,processes=3,tasks=4,paths=5))

    def test_each_resource_leak_is_rejected(self):
        for offset in (524+8,588+4,844+4,877):
            with self.subTest(offset=offset):
                last=checkpoint(100,2);last[offset]+=1
                with self.assertRaisesRegex(AssertionError,'resource leak'):
                    runtime.resources(checkpoint(0,0)+last,100)

    def test_process_mapping_and_path_leaks_are_rejected(self):
        for offset in (12+0x40,12+0x80,12+0x30):
            last=checkpoint(100,2);last[offset]=1
            with self.assertRaisesRegex(AssertionError,'resource leak'):
                runtime.resources(checkpoint(0,0)+last,100)

    def test_incomplete_or_shortened_run_is_rejected(self):
        for data in (b'',checkpoint(0,0)[:-1],checkpoint(0,0)+checkpoint(100,2)):
            with self.assertRaises(AssertionError):runtime.resources(data,1000)

    def test_missing_checkpoint_is_rejected(self):
        with self.assertRaises(AssertionError):
            runtime.resources(checkpoint(0,0)+checkpoint(200,2),200)



def ownership_fixture():
    parents=[];children=[]
    for case in (1,2):
        child=[]
        for role,pid,peer,slot,output in [('P',3,4,4,parents),('C',4,3,5,child)]:
            for phase in range(5):
                raw=bytearray(878);raw[:4]=bytes([ord(role),phase,pid,peer if phase or role=='C' else 0])
                raw[4:6]=(slot*8192).to_bytes(2,'big');raw[8:10]=case.to_bytes(2,'big');raw[10:12]=b'GR'
                dat=[0x333e]*8;links=[0]*8
                if (role=='P' and phase==1) or (role=='C' and phase<4):
                    dat[slot:slot+2]=[20,21];links[slot]=[1,1,2,1,0][phase] if role=='C' else 1
                    raw[524+20:524+22]=b'\x02\x02'
                for i,v in enumerate(dat):raw[12+0x40+i*2:12+0x42+i*2]=v.to_bytes(2,'big')
                for i,v in enumerate(links):raw[12+0x80+i*2:12+0x82+i*2]=v.to_bytes(2,'big')
                output.append(raw)
        children.append(b''.join(child))
    return b''.join(parents),children


class OwnershipEvidenceTests(unittest.TestCase):
    def test_two_processes_and_both_orders(self):
        parent,children=ownership_fixture()
        self.assertEqual(len(runtime.multiprocess(parent,children)),2)

    def test_stale_mapping_and_lost_child_reference_are_rejected(self):
        parent,children=ownership_fixture()
        broken=bytearray(parent);broken[2*878+12+0x40+8:2*878+12+0x42+8]=(20).to_bytes(2,'big')
        with self.assertRaises(AssertionError):runtime.multiprocess(broken,children)
        broken=bytearray(children[0]);broken[2*878+12+0x80+11]=1
        with self.assertRaises(AssertionError):runtime.multiprocess(parent,[broken,children[1]])


if __name__ == '__main__':
    unittest.main()
