"""OS-9 shell scripts used by the MAME integration recipes."""


def script(lines):
    # Expected rejection cases must not abort the shell. Show progress without
    # echoing redirection operators or completion markers as commands.
    result=['-x','-p']
    for step,line in enumerate(lines,1):
        if not line.strip():continue
        result.extend([f'echo RUN {step} {line.split()[0]}',line])
    return ('\r'.join(result)+'\r').encode()


def answers(stage):
    (stage/'CANCEL.IN').write_bytes(b'l\ry\rq\r')
    (stage/'DELETE.IN').write_bytes(b'd\rd\rd\rd\r')
