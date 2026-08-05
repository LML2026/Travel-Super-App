import fs from 'node:fs';
import path from 'node:path';

const resolveRepoRoot = () => {
  const cwd = process.cwd();
  if (fs.existsSync(path.join(cwd, '.github', 'workflows', 'ci.yml'))) {
    return cwd;
  }

  const parent = path.resolve(cwd, '..');
  if (fs.existsSync(path.join(parent, '.github', 'workflows', 'ci.yml'))) {
    return parent;
  }

  return cwd;
};

const root = resolveRepoRoot();
const workflowPath = path.join(root, '.github', 'workflows', 'ci.yml');
const workflowSource = fs.readFileSync(workflowPath, 'utf8');

const requiredCommands = [
  'node tools/check-architecture.mjs',
  'node tools/check-openapi-contracts.mjs',
  'node tools/check-api-spec-coverage.mjs',
  'node tools/check-automation-workflow-parity.mjs',
  'npm run test:contracts',
];

const missingCommands = requiredCommands.filter((command) => !workflowSource.includes(command));

if (missingCommands.length > 0) {
  console.error('Automation workflow parity check failed. Missing CI commands:');
  for (const command of missingCommands) {
    console.error(` - ${command}`);
  }
  process.exit(1);
}

console.log('Automation workflow parity check passed. Required CI commands are present.');
