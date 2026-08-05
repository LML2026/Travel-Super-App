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
const routesDir = path.join(root, 'backend', 'src', 'routes');

const openApiSource = fs.readFileSync(openApiPath, 'utf8');

const expectedRoutes = [
  { method: 'post', route: '/api/flights/search' },
  { method: 'get', route: '/api/weather' },
  { method: 'get', route: '/api/hotels/search' },
  { method: 'get', route: '/api/places/nearby' },
  { method: 'get', route: '/api/currency/rate' },
  { method: 'post', route: '/api/ai/travel-plan' },
];

const routeFiles = fs
  .readdirSync(routesDir)
  .filter((file) => file.endsWith('.js'))
  .map((file) => fs.readFileSync(path.join(routesDir, file), 'utf8'));

const missingFromSpec = [];
const missingFromRoutes = [];

for (const { method, route } of expectedRoutes) {
  if (!openApiSource.includes(`${route}:`) || !openApiSource.includes(`  ${method}:`)) {
    missingFromSpec.push(`${method.toUpperCase()} ${route}`);
  }

  const implemented = routeFiles.some((source) => source.includes(`router.${method}('${route}'`) || source.includes(`router.${method}(\n    '${route}'`));

  if (!implemented) {
    missingFromRoutes.push(`${method.toUpperCase()} ${route}`);
  }
}

if (missingFromSpec.length > 0 || missingFromRoutes.length > 0) {
  console.error('API spec coverage check failed.');
  if (missingFromSpec.length > 0) {
    console.error('Missing from OpenAPI spec:');
    for (const entry of missingFromSpec) {
      console.error(` - ${entry}`);
    }
  }
  if (missingFromRoutes.length > 0) {
    console.error('Missing from backend routes:');
    for (const entry of missingFromRoutes) {
      console.error(` - ${entry}`);
    }
  }
  process.exit(1);
}

console.log('API spec coverage check passed. Documented contracts map to backend routes.');
