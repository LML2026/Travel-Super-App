import fs from 'node:fs';
import path from 'node:path';

const resolveRepoRoot = () => {
  const cwd = process.cwd();
  if (fs.existsSync(path.join(cwd, 'docs', 'openapi.yaml'))) {
    return cwd;
  }

  const parent = path.resolve(cwd, '..');
  if (fs.existsSync(path.join(parent, 'docs', 'openapi.yaml'))) {
    return parent;
  }

  return cwd;
};

const root = resolveRepoRoot();
const openApiPath = path.join(root, 'docs', 'openapi.yaml');

if (!fs.existsSync(openApiPath)) {
  console.error('OpenAPI contract check failed. Missing docs/openapi.yaml.');
  process.exit(1);
}

const openApiSource = fs.readFileSync(openApiPath, 'utf8');
const requiredSnippets = [
  'openapi: 3.1.0',
  '/api/flights/search:',
  '/api/weather:',
  '/api/hotels/search:',
  '/api/places/nearby:',
  '/api/currency/rate:',
  '/api/ai/travel-plan:',
];

const missingSnippets = requiredSnippets.filter((snippet) => !openApiSource.includes(snippet));

if (missingSnippets.length > 0) {
  console.error('OpenAPI contract check failed. Missing required entries:');
  for (const snippet of missingSnippets) {
    console.error(` - ${snippet}`);
  }
  process.exit(1);
}

console.log('OpenAPI contract check passed. Required API entries are documented.');
