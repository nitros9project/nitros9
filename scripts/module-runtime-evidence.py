"""Decode guest snapshots and require balanced per-process and kernel resources."""

def records(data):
    size = 878
    assert data and len(data) % size == 0, ('incomplete runtime evidence', len(data))
    result = []
    for offset in range(0, len(data), size):
        raw = data[offset:offset + size]
        word = lambda pos: int.from_bytes(raw[pos:pos + 2], 'big')
        assert raw[10:12] == b'GR', 'invalid runtime record'
        result.append(dict(role=chr(raw[0]), phase=raw[1], pid=raw[2], peer=raw[3],
            held=word(4), extra=word(6), sequence=word(8),
            dat=[word(12 + 0x40 + i * 2) for i in range(8)],
            links=[word(12 + 0x80 + i * 2) for i in range(8)],
            paths=list(raw[12 + 0x30:12 + 0x40]), flags=list(raw[524:588]),
            processes=list(raw[588:844]), tasks=list(raw[844:876]), active_paths=word(876)))
    return result


def group(state):
    slot = state['held'] // 8192
    while slot and not state['links'][slot]:
        slot -= 1
    return slot


def multiprocess(parent_data, child_data):
    parents = records(parent_data)
    assert len(parents) == 10
    cases = []
    for case, data in enumerate(child_data, 1):
        parent = parents[(case - 1) * 5:case * 5]
        child = records(data)
        assert len(child) == 5
        for role, states in [('P', parent), ('C', child)]:
            assert [s['phase'] for s in states] == list(range(5))
            assert all(s['role'] == role and s['sequence'] == case for s in states)
            assert len({s['pid'] for s in states}) == 1
        assert parent[1]['pid'] != child[0]['pid']
        assert all(s['peer'] == parent[1]['pid'] for s in child)
        assert all(s['peer'] == child[0]['pid'] for s in parent[1:])
        ps, cs = group(parent[1]), group(child[0])
        blocks = parent[1]['dat'][ps:ps + 2]
        assert blocks == child[0]['dat'][cs:cs + 2]
        assert parent[1]['links'][ps] == 1
        assert [s['links'][cs] for s in child] == [1, 1, 2, 1, 0]
        assert all(s['dat'][cs:cs + 2] == blocks for s in child[:4])
        assert child[4]['dat'][cs:cs + 2] == [0x333e] * 2
        assert all(s['dat'][ps:ps + 2] == [0x333e] * 2 for s in parent[2:])
        assert all(s['flags'][b] & 2 for s in child[:4] for b in blocks)
        assert all(child[4]['flags'][b] & 3 == 0 for b in blocks)
        for key in ('dat', 'links', 'paths'):
            assert parent[0][key] == parent[4][key], (case, 'parent resources changed', key)
        assert parent[4]['processes'][child[0]['pid']] == 0
        cases.append(dict(case=case, blocks=blocks, parent=parent, child=child))
    return cases


def resources(data, cycles):
    states = records(data)
    assert states[0]['phase'] == 0 and states[0]['sequence'] == 0
    assert states[-1]['phase'] == 2 and states[-1]['sequence'] == cycles
    assert [s['sequence'] for s in states] == [0] + list(range(100, cycles, 100)) + [cycles]
    baseline = None
    for state in states:
        assert state['role'] == 'L'
        metrics = dict(free_blocks=sum(v == 0 for v in state['flags']),
            processes=sum(v != 0 for v in state['processes'][1:]),
            tasks=sum(v != 0 for v in state['tasks']), paths=state['active_paths'])
        state['metrics'] = metrics
        if baseline is None:
            baseline = state
        for key in ('metrics', 'dat', 'links', 'paths'):
            assert state[key] == baseline[key], ('resource leak', state['sequence'], key, baseline[key], state[key])
    return dict(cycles=cycles, checkpoints=states, baseline=baseline['metrics'])
