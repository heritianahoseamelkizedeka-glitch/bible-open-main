import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  getApplicationIds,
  resolveApplicationUrl,
  validateApplicationRegistry,
} from '../Frontend/web/application-registry.js';

const registryPath = new URL('../Frontend/web/public/config/applications.json', import.meta.url);
const registry = JSON.parse(await readFile(registryPath, 'utf8'));

const expectedApplicationIds = [
  'quiz',
  'study',
  'community',
  'core',
  'communication',
  'stewardship',
  'pastoral',
  'worship',
];

test('application registry is structurally valid', () => {
  const result = validateApplicationRegistry(registry);
  assert.equal(result.valid, true, result.errors.join('\n'));
});

test('application registry exposes the complete platform', () => {
  assert.deepEqual(getApplicationIds(registry), expectedApplicationIds);
});

test('all local ports are unique', () => {
  const ports = Object.values(registry.applications).map((app) => app.port);
  assert.equal(new Set(ports).size, ports.length);
});

test('local hosts resolve local URLs', () => {
  assert.equal(
    resolveApplicationUrl(registry.applications.worship, 'localhost'),
    'http://localhost:5184/',
  );
  assert.equal(
    resolveApplicationUrl(registry.applications.core, '127.0.0.1'),
    'http://localhost:5181/',
  );
});

test('public hosts never fall back to localhost', () => {
  for (const appId of expectedApplicationIds) {
    assert.equal(resolveApplicationUrl(registry.applications[appId], 'bible-open.example'), '');
  }
});

test('linked repositories have portable root metadata', () => {
  for (const appId of expectedApplicationIds) {
    const app = registry.applications[appId];
    assert.equal(typeof app.rootPath, 'string');
    assert.ok(app.rootPath.length > 0);
    assert.equal(typeof app.webPath, 'string');
    assert.ok(app.webPath.length > 0);
    assert.equal(typeof app.rootEnv, 'string');
    assert.ok(app.rootEnv.startsWith('BIBLE_OPEN_'));
  }
});
