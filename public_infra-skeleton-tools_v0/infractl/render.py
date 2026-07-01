
from pathlib import Path
import json, shutil
from .project import source_path, source_status
from .pack import zip_dir
from .evidence import check_evidence

def safe_name(s):
    return ''.join(c if c.isalnum() or c in '-_.' else '-' for c in str(s)).strip('-')

def collect_source_keys(data, batch):
    keys=list(batch.get('required_sources',[]))
    for hid in batch.get('required_hooks',[]):
        for h in data.get('hooks',{}).get('hooks',[]):
            if h.get('id')==hid:
                keys.extend(h.get('source_keys',[]))
    # keep order unique
    seen=[]
    for k in keys:
        if k not in seen: seen.append(k)
    return seen

def write_request(data, batch, mode, topic, profile, out_dir, extra_sources=None, repo_root=None):
    extra_sources=extra_sources or []
    slug=batch['slug']; track=batch.get('track','skeleton'); bid=batch['id']; topic=safe_name(topic or 'manual')
    name=f"request_{mode}_{track}_{bid}_{slug}_{topic}"
    root=Path(out_dir)/name; root.mkdir(parents=True, exist_ok=True)
    source_root=root/'source_bundle'; source_root.mkdir(exist_ok=True)
    keys=collect_source_keys(data,batch)
    statuses=[]
    copied=[]
    for k in keys:
        st=source_status(data,k,repo_root); statuses.append(st)
        p=source_path(data,k, prefer_real=False)
        if p and p.exists():
            dest=source_root/'sources'/p.name
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p,dest); copied.append(str(dest.relative_to(root)))
    extra_dir=source_root/'extra_sources'; extra_dir.mkdir(parents=True, exist_ok=True)
    extra_copied=[]
    for x in extra_sources:
        xp=Path(x)
        if xp.exists():
            if xp.is_dir():
                dest=extra_dir/xp.name
                if dest.exists(): shutil.rmtree(dest)
                shutil.copytree(xp,dest)
                extra_copied.append(str(dest.relative_to(root)))
            else:
                dest=extra_dir/xp.name
                shutil.copy2(xp,dest)
                extra_copied.append(str(dest.relative_to(root)))
        else:
            extra_copied.append(f"MISSING:{x}")
    manifest={"mode":mode,"profile":profile,"track":track,"batch":bid,"slug":slug,"topic":topic,"source_keys":keys,"copied_sources":copied,"extra_sources":extra_copied,"safety":"deterministic request only; extra sources candidate only; no real workspace mutation"}
    (root/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
    missing_required=[s for s in statuses if s.get('required') and not s.get('bundle_exists')]
    req_lines=[f"# Required inputs for {mode} {track} {bid} {slug}\n"]
    for s in statuses:
        req_lines.append(f"- {s['key']}: bundle={'OK' if s.get('bundle_exists') else 'MISSING'} | real={s.get('real_path')} | required={s.get('required')}")
    if missing_required:
        req_lines.append('\n## BLOCKING MISSING BUNDLE SOURCES')
        for s in missing_required: req_lines.append(f"- {s['key']} -> {s.get('bundle_path')}")
    (root/'REQUIRED_INPUTS.md').write_text('\n'.join(req_lines)+'\n',encoding='utf-8')
    ctx=[f"# Selected context manifest\n", f"Mode: `{mode}`", f"Profile: `{profile}`", f"Track: `{track}`", f"Batch: `{bid}` `{slug}`", f"Topic: `{topic}`", "", "## Batch scope", batch.get('scope',''), "", "## Smoke domains", '\n'.join('- '+x for x in batch.get('smoke_domains',[])), "", "## Must not", '\n'.join('- '+x for x in batch.get('must_not',[])), "", "## Copied source bundle files", '\n'.join('- '+x for x in copied) or '- none']
    (root/'SELECTED_CONTEXT_MANIFEST.md').write_text('\n'.join(ctx)+'\n',encoding='utf-8')
    extra_txt=f"# Extra source routing\n\nExtra sources are candidate knowledge only. ChatGPT must classify them before any update is proposed.\n\nProvided extra sources:\n" + ('\n'.join('- '+x for x in extra_copied) if extra_copied else '- none') + "\n\nClassification options:\n- affects this already-run batch\n- creates/updates a SPEC annex\n- creates/updates a creation/update hook\n- affects future batch creation\n- affects already-run batches through update lane\n- irrelevant/outdated\n- missing required supporting files\n"
    (root/'EXTRA_SOURCE_ROUTING.md').write_text(extra_txt,encoding='utf-8')
    if mode=='update':
        ev=check_evidence(data,batch)
        ev_lines=[f"# Existing evidence check for {track} {bid} {slug}\n"]
        for name,path,exists in ev: ev_lines.append(f"- {name}: {'OK' if exists else 'MISSING'} at `{path}`")
        ev_lines.append("\nUpdate rule: never overwrite original evidence. Use updates/<update-id>/ for update evidence in the real workspace.")
        (root/'EXISTING_EVIDENCE_CHECK.md').write_text('\n'.join(ev_lines)+'\n',encoding='utf-8')
    prompt=f"""# CHATGPT_REQUEST\n\nUse this request pack to create a {mode} response for Infra-Skeleton.\n\nTrack: `{track}`\nBatch: `{bid}` `{slug}`\nTopic: `{topic}`\nProfile: `{profile}`\n\nRead these files in this request folder first:\n1. REQUIRED_INPUTS.md\n2. SELECTED_CONTEXT_MANIFEST.md\n3. EXTRA_SOURCE_ROUTING.md\n4. EXISTING_EVIDENCE_CHECK.md if present\n5. source_bundle/ contents\n\nRequired behavior:\n- Stop if REQUIRED_INPUTS.md reports a blocking missing required source.\n- Use only the selected batch scope.\n- Treat extra sources as candidate context only.\n- Preserve public/private separation: infractl is public; this private bundle is project data.\n- No API calls, no smoke execution, no Codex execution, and no workspace mutation in webchat-sandbox.\n- At the end, update `CLI_EXTRACTION_NOTES.md` with only reusable patterns from this {mode} run that should inform future infractl v1.\n\nExpected ChatGPT output:\n- For creation: CODEX_PROMPT.txt, PROJECT_CACHE.md, SPEC.md, RUN_INSTRUCTIONS.md, POSTCHECK_TEMPLATE.md.\n- For update: CODEX_UPDATE_PROMPT.txt, PROJECT_UPDATE_CACHE.md, UPDATE_SPEC.md, UPDATE_RUN_INSTRUCTIONS.md, UPDATE_POSTCHECK_TEMPLATE.md.\n"""
    (root/'CHATGPT_REQUEST.md').write_text(prompt,encoding='utf-8')
    (root/'CLI_EXTRACTION_REMINDER.md').write_text("# CLI extraction reminder\n\nAt the end, update `CLI_EXTRACTION_NOTES.md` with only the reusable patterns from this batch/update run that should inform a future `infractl` CLI.\n",encoding='utf-8')
    z=zip_dir(root, root.with_suffix('.zip'))
    return root,z
