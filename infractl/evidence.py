
from pathlib import Path

def evidence_dir(project, batch):
    root = Path(project['root']) / project['project'].get('paths',{}).get('evidence_snapshots_root','evidence_snapshots')
    return root / batch.get('track','skeleton') / batch.get('slug')

def check_evidence(project, batch):
    d=evidence_dir(project,batch)
    expected=batch.get('evidence_contract',['POSTCHECK.md','INTEGRATION_REQUEST.md','SMOKE_REPORT.md'])
    return [(name, d/name, (d/name).exists()) for name in expected]
