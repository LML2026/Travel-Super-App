import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();

const requiredCoreDirs = [
  'lib/core/api',
  'lib/core/config',
  'lib/core/constants',
  'lib/core/errors',
  'lib/core/extensions',
  'lib/core/services',
  'lib/core/storage',
  'lib/core/theme',
  'lib/core/utils',
  'lib/core/widgets',
];

const requiredFeatures = [
  'auth',
  'home',
  'flights',
  'hotels',
  'weather',
  'trips',
  'wallet',
  'translator',
  'payments',
  'ai',
  'profile',
  'settings',
];

const requiredFeaturePaths = [
  'data/models',
  'data/repositories',
  'data/services',
  'domain/entities',
  'domain/repositories',
  'domain/usecases',
  'presentation/providers',
  'presentation/screens',
  'presentation/widgets',
  'routes.dart',
];

const requiredBackendDirs = [
  'backend/src/config',
  'backend/src/middleware',
  'backend/src/validators',
  'backend/src/models',
  'backend/src/routes',
  'backend/src/controllers',
  'backend/src/services',
  'backend/src/repositories',
  'backend/src/utils',
  'backend/src/app.js',
];

const missing = [];

const exists = (relativePath) => fs.existsSync(path.join(root, relativePath));

for (const p of requiredCoreDirs) {
  if (!exists(p)) {
    missing.push(p);
  }
}

for (const feature of requiredFeatures) {
  for (const p of requiredFeaturePaths) {
    const target = `lib/features/${feature}/${p}`;
    if (!exists(target)) {
      missing.push(target);
    }
  }
}

for (const p of requiredBackendDirs) {
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
