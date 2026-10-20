import { execFileSync } from 'node:child_process';
import { cpSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const dart = process.env.DART_BIN || (process.platform === 'win32' ? 'dart.exe' : 'dart');
const run = args => execFileSync(dart, args, { cwd: root, stdio: 'inherit' });
run(['pub', 'get', '--enforce-lockfile', ...(process.argv.includes('--offline') ? ['--offline'] : [])]);
run(['analyze', '--fatal-infos']);
mkdirSync(path.join(root, 'artifacts'), { recursive: true });
for (const name of ['engine_test', 'security_test']) {
  run(['run', `test/${name}.dart`]);
  const out = path.join(root, 'artifacts', `${name}.js`);
  run(['compile', 'js', '-O2', '--no-source-maps', `test/${name}.dart`, '-o', out]);
  execFileSync(process.execPath, ['-e', 'globalThis.self=globalThis;require(process.argv[1]);', out], { cwd: root, stdio: 'inherit' });
}
const dist = path.join(root, 'dist');
rmSync(dist, { recursive: true, force: true });
cpSync(path.join(root, 'web'), dist, { recursive: true });
run(['compile', 'js', '-O2', '--no-source-maps', 'web/main.dart', '-o', path.join(dist, 'main.dart.js')]);
for (const file of readdirSync(dist)) if (file.endsWith('.deps') || file.endsWith('.map') || file.endsWith('.dart')) rmSync(path.join(dist, file));
const hashes = {};
function collect(dir) {
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const file = path.join(dir, entry.name);
    if (entry.isDirectory()) collect(file);
    else hashes[path.relative(dist, file).split(path.sep).join('/')] = createHash('sha256').update(readFileSync(file)).digest('hex');
  }
}
collect(dist);
writeFileSync(path.join(root, 'artifacts/assets.sha256.json'), JSON.stringify(hashes, null, 2) + '\n');
console.log('Independent Dart build and VM/JavaScript tests passed. Output: dist/');
