// Basic offline-first SW for Rails apps
const CACHE_VERSION = 'v1';
const RUNTIME_CACHE = `runtime-${CACHE_VERSION}`;
const CORE_ASSETS = [
  '/',
  '/offline.html',
  '/icons/pwa-192.png',
  '/icons/pwa-512.png'
];


self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(RUNTIME_CACHE).then((cache) => cache.addAll(CORE_ASSETS))
  );
  self.skipWaiting();
});


self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.map((key) => (key !== RUNTIME_CACHE ? caches.delete(key) : null)))
    )
  );
  self.clients.claim();
});


self.addEventListener('fetch', (event) => {
  const req = event.request;


  if (req.method !== 'GET') return;


  if (req.mode === 'navigate') {
    event.respondWith(
      fetch(req)
        .then((res) => {

          const copy = res.clone();
          caches.open(RUNTIME_CACHE).then((cache) => cache.put(req, copy));
          return res;
        })
        .catch(async () => {

          const cached = await caches.match(req);
          return cached || caches.match('/offline.html');
        })
    );
    return;
  }


  event.respondWith(
    caches.match(req).then((cached) => {
      if (cached) return cached;
      return fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(RUNTIME_CACHE).then((cache) => cache.put(req, copy));
          return res;
        })
        .catch(() => cached);
    })
  );
});
