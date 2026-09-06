import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { test } from 'node:test';

import {
  isHttpUrl,
  isLocalHostname,
  resolveApplicationUrl,
  validateApplicationRegistry,
} from '../Frontend/web/lib/app-registry.js';

const registryUrl = new URL('../Frontend/web/public/config/applications.json', import.meta.url);

async function loadRegistry() {
  return JSON.parse(await readFile(registryUrl, 'utf8'));
}

test('the committed application registry is valid', async () => {
  const registry = validateApplicationRegistry(await loadRegistry());
  assert.ok(registry.applications.portal);
  assert.ok(registry.applications.quiz);
  assert.ok(registry.applications.study);
});

test('local hostnames are detected explicitly', () => {
  assert.equal(isLocalHostname('localhost'), true);
  assert.equal(isLocalHostname('127.0.0.1'), true);
  assert.equal(isLocalHostname('::1'), true);
  assert.equal(isLocalHostname('bibleopen.example'), false);
});

test('only HTTP and HTTPS URLs are accepted', () => {
  assert.equal(isHttpUrl('https://bibleopen.example/app'), true);
  assert.equal(isHttpUrl('http://localhost:5173/'), true);
  assert.equal(isHttpUrl('javascript:alert(1)'), false);
  assert.equal(isHttpUrl('file:///tmp/app'), false);
  assert.equal(isHttpUrl(''), false);
});

test('production URL is optional but local URL is required', async () => {
  const registry = await loadRegistry();
  assert.doesNotThrow(() => validateApplicationRegistry(registry));

  const invalid = structuredClone(registry);
  invalid.applications.quiz.localUrl = 'not-a-url';
  assert.throws(() => validateApplicationRegistry(invalid), /localUrl/);
});

test('application URL resolution follows the environment', () => {
  const app = {
    localUrl: 'http://localhost:5173/',
    productionUrl: 'https://quiz.bibleopen.example/',
  };

  assert.equal(resolveApplicationUrl(app, { local: true }), 'http://localhost:5173/');
  assert.equal(resolveApplicationUrl(app, { local: false }), 'https://quiz.bibleopen.example/');
  assert.equal(resolveApplicationUrl({ ...app, productionUrl: '' }, { local: false }), null);
});
