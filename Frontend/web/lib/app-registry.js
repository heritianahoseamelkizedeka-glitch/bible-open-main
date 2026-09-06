const HTTP_PROTOCOLS = new Set(['http:', 'https:']);

export function isLocalHostname(hostname) {
  return ['localhost', '127.0.0.1', '::1'].includes(hostname);
}

export function isHttpUrl(value) {
  if (typeof value !== 'string' || value.trim() === '') return false;

  try {
    return HTTP_PROTOCOLS.has(new URL(value).protocol);
  } catch {
    return false;
  }
}

export function validateApplicationRegistry(registry) {
  if (!registry || typeof registry !== 'object') {
    throw new TypeError('Application registry must be an object.');
  }

  if (!registry.applications || typeof registry.applications !== 'object') {
    throw new TypeError('Application registry must contain an applications object.');
  }

  for (const [appId, app] of Object.entries(registry.applications)) {
    if (!app || typeof app !== 'object') {
      throw new TypeError(`Application ${appId} must be an object.`);
    }

    if (typeof app.name !== 'string' || app.name.trim() === '') {
      throw new TypeError(`Application ${appId} must have a name.`);
    }

    if (!Number.isInteger(app.port) || app.port < 1 || app.port > 65535) {
      throw new TypeError(`Application ${appId} has an invalid port.`);
    }

    if (!isHttpUrl(app.localUrl)) {
      throw new TypeError(`Application ${appId} has an invalid localUrl.`);
    }

    if (app.productionUrl && !isHttpUrl(app.productionUrl)) {
      throw new TypeError(`Application ${appId} has an invalid productionUrl.`);
    }

    if (typeof app.rootPath !== 'string' || app.rootPath.trim() === '') {
      throw new TypeError(`Application ${appId} must have a rootPath.`);
    }
  }

  return registry;
}

export function resolveApplicationUrl(app, { local = false } = {}) {
  if (!app || typeof app !== 'object') return null;

  const candidate = local ? app.localUrl : app.productionUrl;
  return isHttpUrl(candidate) ? candidate : null;
}
