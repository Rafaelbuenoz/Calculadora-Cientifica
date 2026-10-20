#!/usr/bin/env python3
"""Local publication guard. Pattern scanning is not a complete secrets/SAST audit."""
import argparse
import json
import re
import subprocess
from pathlib import Path

RULES = {
    "github-token": re.compile(rb"(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,})"),
    "stripe-key": re.compile(rb"(?:sk|rk)_(?:live|test)_[A-Za-z0-9]{20,}|whsec_[A-Za-z0-9]{20,}"),
    "aws-key": re.compile(rb"(?:AKIA|ASIA)[A-Z0-9]{16}"),
    "google-key": re.compile(rb"AIza[A-Za-z0-9_-]{35}"),
    "private-key": re.compile(rb"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
    "database-password": re.compile(rb"(?:postgres(?:ql)?|mysql|mongodb(?:\+srv)?)://[^\s/:]+:[^\s/@]{3,}@"),
}
DENIED = {'.sites-runtime', '.review-runtime', '.openai', '.codex', '.agents', 'node_modules', '.dart_tool', '.m2', 'target', 'dist', 'connector-preview', 'artifacts', '__pycache__'}
PREFIXES = ('lib/connector', 'components/connector-error', 'app/chatgpt-auth', 'build/')

def scan_bytes(data):
    return [rule for rule, pattern in RULES.items() if pattern.search(data)]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--history', action='store_true')
    args = parser.parse_args()
    paths = subprocess.check_output(['git', 'ls-files', '-co', '--exclude-standard', '-z']).decode().split('\0')[:-1]
    paths = sorted(set(paths))
    findings = []
    for name in paths:
        p = Path(name)
        if not p.exists(): continue
        if (set(p.parts) & DENIED or name.startswith(PREFIXES) or p.is_symlink()
            or (p.name.startswith(('.env', '.dev.vars')) and not p.name.endswith('.example'))
            or p.suffix in ('.key', '.p12', '.pfx', '.pyc')):
            findings.append({'path': name, 'rule': 'publication-path'})
            continue
        data = p.read_bytes()
        if b'\0' not in data:
            findings += [{'path': name, 'rule': rule} for rule in scan_bytes(data)]
        if name.startswith('.github/workflows/'):
            text = data.decode()
            if 'pull_request_target' in text or 'write-all' in text:
                findings.append({'path': name, 'rule': 'workflow-permissions'})
            for action in re.findall(r'uses:\s*([^\s#]+)', text):
                if not action.startswith('./') and not re.fullmatch(r'[^@]+@[0-9a-f]{40}', action):
                    findings.append({'path': name, 'rule': 'action-not-pinned'})
    historical_blobs = 0
    if args.history:
        objects = subprocess.check_output(['git', 'rev-list', '--objects', '--all'], text=True).splitlines()
        for line in objects:
            oid, _, name = line.partition(' ')
            if subprocess.check_output(['git', 'cat-file', '-t', oid]).strip() != b'blob': continue
            historical_blobs += 1
            data = subprocess.check_output(['git', 'cat-file', 'blob', oid])
            if b'\0' not in data:
                findings += [{'path': name, 'object': oid, 'rule': rule} for rule in scan_bytes(data)]
    print(json.dumps({'files': len(paths), 'history_blobs': historical_blobs, 'findings': findings, 'limitations': 'Pattern/config scan; not complete SAST or proof of absence of secrets.'}, ensure_ascii=False))
    raise SystemExit(bool(findings))

if __name__ == '__main__': main()
