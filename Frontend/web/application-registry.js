const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1', '::1']);

export function isLocalHost(hostname) {
  return LOCAL_HOSTS.has(hostname);
}

export function getApplicationIds(registry) {
  if (!registry || typeof registry !== 'object' || !registry.applications || typeof registry.applications !== 'object') {
    return [];
  }

  return Object.keys(registry.applications).filter((appId) => appId !== 'portal');
}

export function validateApplicationRegistry(registry) {
  const errors = [];

  if (!registry || typeof registry !== 'object') {
    return { valid: false, errors: ['Registry must be an object.'] };
  }

  if (!Number.isInteger(registry.schemaVersion) || registry.schemaVersion < 1) {
    errors.push('schemaVersion must be a positive integer.');
  }

  if (!registry.applications || typeof registry.applications !== 'object') {
    errors.push('applications must be an object.');
    return { valid: false, errors };
  }

  for (const [appId, app] of Object.entries(registry.applications)) {
    if (!app || typeof app !== 'object') {
      errors.push(`${appId}: application definition must be an object.`);
      continue;
    }

    if (typeof app.name !== 'string' || !app.name.trim()) {
      errors.push(`${appId}: name is required.`);
    }

    if (!Number.isInteger(app.port) || app.port < 1 || app.port > 65535) {
      errors.push(`${appId}: port must be between 1 and 65535.`);
    }

    if (typeof app.localUrl !== 'string' || !app.localUrl.trim()) {
      errors.push(`${appId}: localUrl is required.`);
    }

    if (typeof app.productionUrl !== 'string') {
      errors.push(`${appId}: productionUrl must be a string.`);
    }

    if (typeof app.rootPath !== 'string' || !app.rootPath.trim()) {
      errors.push(`${appId}: rootPath is required.`);
    }

    if (typeof app.webPath !== 'string' || !app.webPath.trim()) {
      errors.push(`${appId}: webPath is required.`);
    }
  }

  return { valid: errors.length === 0, errors };
}

export function resolveApplicationUrl(app, hostname) {
  if (!app || typeof app !== 'object') return '';
  return isLocalHost(hostname) ? (app.localUrl || '') : (app.productionUrl || '');
}
