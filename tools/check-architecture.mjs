import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();

const requiredPaths = [
  'lib/core',
  'lib/features',
  'lib/shared',
  'backend/src',
];

const missing = [];

const exists = (relativePath) => fs.existsSync(path.join(root, relativePath));

for (const p of requiredPaths) {
  if (!exists(p)) {
    missing.push(p);
  }
}

if (missing.length > 0) {
  console.error('Architecture check failed. Missing required paths:');
  for (const p of missing) {
    console.error(` - ${p}`);
  }
  process.exit(1);
}

console.log('Architecture check passed. Required structure is present.');
