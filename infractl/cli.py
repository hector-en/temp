
from pathlib import Path
import argparse, json, sys
from .project import load_project, batches, hooks, find_batch, source_status, public_tool_status
from .profiles import PROFILES, validate_profile
from .render import write_request
from .pack import package
from .evidence import check_evidence

def print_json(x): print(json.dumps(x, indent=2, default=str))

def main(argv=None):
    p=argparse.ArgumentParser(prog='infractl')
    sub=p.add_subparsers(dest='cmd', required=True)
    sub.add_parser('profiles')
    for c in ['list-batches','list-hooks','status','check-required-files']:
        sp=sub.add_parser(c); sp.add_argument('--project', required=True); sp.add_argument('--track'); sp.add_argument('--repo-root'); sp.add_argument('--allow-bundle-fallback', action='store_true')
    sp=sub.add_parser('validate-real-layout')
    sp.add_argument('--project', required=True)
    sp.add_argument('--public-tool-root')
    sp.add_argument('--repo-root', help='Deprecated compatibility alias for --public-tool-root in the v0 two-root contract.')
    sp.add_argument('--allow-bundle-fallback', action='store_true')
    sp=sub.add_parser('explain-batch'); sp.add_argument('--project', required=True); sp.add_argument('--track'); sp.add_argument('--batch', required=True)
    for c in ['request-create','request-update']:
        sp=sub.add_parser(c); sp.add_argument('--project', required=True); sp.add_argument('--track', required=True); sp.add_argument('--batch', required=True); sp.add_argument('--topic', default='manual'); sp.add_argument('--profile', default='webchat-sandbox'); sp.add_argument('--out', required=True); sp.add_argument('--extra-source', action='append', default=[]); sp.add_argument('--repo-root')
    sp=sub.add_parser('package-codex-create'); sp.add_argument('--input', required=True); sp.add_argument('--out', required=True)
    sp=sub.add_parser('package-codex-update'); sp.add_argument('--input', required=True); sp.add_argument('--out', required=True)
    sp=sub.add_parser('check-evidence'); sp.add_argument('--project', required=True); sp.add_argument('--track', required=True); sp.add_argument('--batch', required=True)
    args=p.parse_args(argv)
    if args.cmd=='profiles': print_json(PROFILES); return
    if args.cmd.startswith('package-codex'):
        kind='create' if args.cmd.endswith('create') else 'update'; print(package(args.input,args.out,kind)); return
    data=load_project(args.project)
    if args.cmd=='list-batches':
        for b in batches(data,args.track): print(f"{b.get('track')} {b.get('id')} {b.get('slug')} | {b.get('scope')}")
    elif args.cmd=='list-hooks':
        for h in hooks(data): print(f"{h.get('id')} {h.get('anx')} applies={','.join(h.get('applies_to',[]))} | {h.get('purpose')}")
    elif args.cmd=='explain-batch': print_json(find_batch(data,args.batch,args.track))
    elif args.cmd in ['check-required-files','validate-real-layout']:
        keys=set()
        if args.cmd=='check-required-files':
            for b in batches(data,args.track):
                for k in b.get('required_sources',[]): keys.add(k)
        else:
            keys=set(data.get('files',{}).get('source_keys',{}).keys())
            public_tool_root = Path(args.public_tool_root or args.repo_root or Path.cwd()).resolve()
            public_failures=[]
            private_failures=[]
            print_json({
                'kind': 'contract_roots',
                'public_tool_root': str(public_tool_root),
                'private_project_root': str(data['root']),
                'mode': 'two-root-v0'
            })
            for st in public_tool_status(public_tool_root):
                print_json(st)
                if st.get('required') and not st.get('exists'):
                    public_failures.append(st['name'])
            for name in ['project.yaml', 'layers.yaml', 'batches.yaml', 'hooks.yaml', 'files.yaml', 'sources/']:
                path = data['root'] / name.rstrip('/')
                exists = path.exists()
                st = {
                    'kind': 'private_project_check',
                    'name': name,
                    'path': str(path),
                    'exists': exists,
                    'required': True,
                }
                print_json(st)
                if not exists:
                    private_failures.append(name)
        bad=False
        missing_required=[]
        for k in sorted(keys):
            st=source_status(data,k,args.repo_root); print_json(st)
            if args.cmd=='check-required-files':
                if st.get('required') and not st.get('bundle_exists'):
                    bad=True; missing_required.append(k)
            else:
                if st.get('required') and not st.get('bundle_exists'):
                    bad=True; missing_required.append(k)
        if bad:
            kind = 'MISSING_REQUIRED_BUNDLE_FILES' if args.cmd=='check-required-files' else 'INVALID_PUBLIC_PRIVATE_CONTRACT'
            payload = {'error': kind, 'missing_required_keys': missing_required, 'repo_root': getattr(args,'repo_root',None), 'allow_bundle_fallback': getattr(args,'allow_bundle_fallback',False)}
            if args.cmd == 'validate-real-layout':
                payload.update({
                    'public_tool_root': str(public_tool_root),
                    'private_project_root': str(data['root']),
                    'missing_public_paths': public_failures,
                    'missing_private_paths': private_failures,
                })
            print_json(payload)
            raise SystemExit(2)
        if args.cmd == 'validate-real-layout' and (public_failures or private_failures):
            print_json({
                'error': 'INVALID_PUBLIC_PRIVATE_CONTRACT',
                'missing_required_keys': missing_required,
                'public_tool_root': str(public_tool_root),
                'private_project_root': str(data['root']),
                'missing_public_paths': public_failures,
                'missing_private_paths': private_failures,
            })
            raise SystemExit(2)
    elif args.cmd in ['request-create','request-update']:
        validate_profile(args.profile); b=find_batch(data,args.batch,args.track); root,z=write_request(data,b,'create' if args.cmd=='request-create' else 'update',args.topic,args.profile,args.out,args.extra_source,args.repo_root); print(root); print(z)
    elif args.cmd=='check-evidence':
        b=find_batch(data,args.batch,args.track)
        for name,path,exists in check_evidence(data,b): print(f"{name}: {'OK' if exists else 'MISSING'} {path}")
    elif args.cmd=='status':
        print(f"Project: {data['project'].get('name')} ({data['project'].get('version')})")
        for b in batches(data,args.track): print(f"{b.get('track')} {b.get('id')} {b.get('slug')} status={b.get('status')} profile-ready={','.join(data['project'].get('supported_profiles',[]))}")
if __name__ == '__main__': main()
