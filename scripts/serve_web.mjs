import { createReadStream, existsSync, statSync } from 'node:fs';
import { createServer } from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const webRoot = path.join(repositoryRoot, 'build', 'web');
const port = Number(process.env.E2E_WEB_PORT ?? 5181);
const mimeTypes = {
  '.bin': 'application/octet-stream',
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.ico': 'image/x-icon',
  '.jpeg': 'image/jpeg',
  '.jpg': 'image/jpeg',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.ttf': 'font/ttf',
  '.wasm': 'application/wasm',
  '.webp': 'image/webp',
};

if (!existsSync(path.join(webRoot, 'index.html'))) {
  throw new Error('Flutter web build is missing. Run `npm run build:web` first.');
}

const server = createServer((request, response) => {
  const pathname = decodeURIComponent(new URL(request.url ?? '/', 'http://localhost').pathname);
  const requestedFile = path.resolve(webRoot, `.${pathname}`);
  if (requestedFile !== webRoot && !requestedFile.startsWith(`${webRoot}${path.sep}`)) {
    response.writeHead(403).end('Forbidden');
    return;
  }

  let filePath = requestedFile;
  if (!existsSync(filePath) || !statSync(filePath).isFile()) {
    if (path.extname(pathname)) {
      response.writeHead(404).end('Not found');
      return;
    }
    filePath = path.join(webRoot, 'index.html');
  }

  response.writeHead(200, {
    'Cache-Control': 'no-store',
    'Content-Type': mimeTypes[path.extname(filePath).toLowerCase()] ?? 'application/octet-stream',
    'X-Content-Type-Options': 'nosniff',
  });
  if (request.method === 'HEAD') {
    response.end();
    return;
  }
  createReadStream(filePath).pipe(response);
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Serving Flutter web build at http://127.0.0.1:${port}`);
});

for (const signal of ['SIGINT', 'SIGTERM']) {
  process.on(signal, () => server.close(() => process.exit(0)));
}
