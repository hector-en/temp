
from pathlib import Path
import zipfile, json, shutil

def zip_dir(src, dest):
    src=Path(src); dest=Path(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(dest,'w',zipfile.ZIP_DEFLATED) as z:
        for p in sorted(src.rglob('*')):
            if p.is_file(): z.write(p, p.relative_to(src.parent))
    return dest

def require_files(input_dir, names):
    root=Path(input_dir)
    missing=[n for n in names if not (root/n).exists()]
    if missing:
        raise SystemExit('Missing pack files:\n'+'\n'.join('- '+m for m in missing))
    return [root/n for n in names]

def package(input_dir, out_dir, kind):
    if kind == 'create':
        req=['CODEX_PROMPT.txt','PROJECT_CACHE.md','SPEC.md','RUN_INSTRUCTIONS.md','POSTCHECK_TEMPLATE.md']
        name='codex_create_pack.zip'
    else:
        req=['CODEX_UPDATE_PROMPT.txt','PROJECT_UPDATE_CACHE.md','UPDATE_SPEC.md','UPDATE_RUN_INSTRUCTIONS.md','UPDATE_POSTCHECK_TEMPLATE.md']
        name='codex_update_pack.zip'
    files=require_files(input_dir, req)
    out=Path(out_dir); out.mkdir(parents=True, exist_ok=True)
    zp=out/name
    with zipfile.ZipFile(zp,'w',zipfile.ZIP_DEFLATED) as z:
        for f in files: z.write(f, f.name)
        z.writestr('manifest.json', json.dumps({'kind':kind,'files':req}, indent=2))
    return zp
