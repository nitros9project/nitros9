"""Independent allocation checks, allowing only the pristine boot-track reservations."""
import re
import subprocess

def check(pristine, disk, output):
    reports=[]
    for name,image in [('baseline-dcheck.log',pristine),('dcheck.log',disk)]:
        result=subprocess.run(['os9','dcheck',str(image)],check=True,capture_output=True)
        (output/name).write_bytes(result.stdout+result.stderr)
        reports.append(result.stdout)
    for expected in (b'0 bad file decriptor sector',b'0 clusters in file structure but not in allocation map',b'0 previously allocated cluster found'):
        assert expected in reports[1].splitlines(), ('disk allocation failure',expected)
    pattern=rb'^Logical sector (\d+) .* in allocation map but not in file structure$'
    assert set(re.findall(pattern,reports[0],re.M))==set(re.findall(pattern,reports[1],re.M)), 'changed orphan allocations'
