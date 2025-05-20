'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "b75bad869b2040f1993e54d13f3df6c6",
"manifest.json": "e7548a83d90a4f970cab79cc132923ce",
"main.dart.js": "eca1cf3923be472a9d89c74ea16a22d9",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"assets/NOTICES": "f22d1d553bc0426b3801e341c9906081",
"assets/AssetManifest.json": "2d78cee1e04f41cc888d10d6e46250c6",
"assets/assets/images/apartment4.webp": "7e47d064f98697c6cf6cc7d775c89012",
"assets/assets/images/office2_3.webp": "5ee809f549bebf9803bf105b2d47607d",
"assets/assets/images/mansion5.webp": "a75e656fc45fa1e4d628df43b4ac0f1f",
"assets/assets/images/apartment5.webp": "bc5bd98d427f787315e9c47d241641fa",
"assets/assets/images/home2.jpg": "d8fda8b036217e28733cbcbba9535658",
"assets/assets/images/bungalow4.webp": "16d3c0eb797a4afd5da096a876c02e24",
"assets/assets/images/home5.jpg": "24ab7d22481311c3d721ff5c2671ea0e",
"assets/assets/images/mansion3.webp": "0fd06c0a491289fd4bd069d33c5c64cf",
"assets/assets/images/office2_1.webp": "c3621ec13ff896639b05770f5f7a26f7",
"assets/assets/images/house1.jpg": "47b75a1286816a3edbf5ec53d7b3caed",
"assets/assets/images/mansion2.webp": "7f9c385476bd672cfd7cb676c8f94553",
"assets/assets/images/bungalow1.webp": "cff32a866a4b9ccb8db839579bd2c110",
"assets/assets/images/apartment1_2.webp": "bf0713ef0af0889f6442986b64fe2f4e",
"assets/assets/images/inside_mansion1_3.webp": "4637b5953419c3fd05cf60f1660264d8",
"assets/assets/images/home6.jpg": "52b2b86c6e06272c2b5460b80b28f548",
"assets/assets/images/house2.jpg": "f2f92ea05f0f35e0673dc74637893040",
"assets/assets/images/mansion6.webp": "7d279a7162d5f48eac11a23e666b9d80",
"assets/assets/images/villa7.webp": "7bc039f24b60c6c269169f452cf6ead1",
"assets/assets/images/apartment1_3.webp": "c765456a072611a8aa7f4359acf60484",
"assets/assets/images/bungalow6.webp": "bc6bab493c2387811d4412006f6784c6",
"assets/assets/images/mansion1.webp": "154056af58798782f9b79c46b5f10642",
"assets/assets/images/bungalow3.webp": "324d1bd5e58685831a8bee05254c6c36",
"assets/assets/images/bungalow5.webp": "cf6be121b1bd5e6aa906a6d9a724f21d",
"assets/assets/images/apartment1.webp": "1870747d5b90c1d54ea0b87379329d27",
"assets/assets/images/villa1_1.webp": "7a0679be0929c3613fcc8dddd377d519",
"assets/assets/images/villa3.webp": "9e51d9680703a42ea0f42efedab3f94e",
"assets/assets/images/office1_1.webp": "00c43d652833c9b768cac9c10babbf99",
"assets/assets/images/vila1_2.webp": "2d74546a41fcb18d70a9f054be5c143c",
"assets/assets/images/apartment2.webp": "ebdf80e5132ddfdf2cfc84e57837d280",
"assets/assets/images/mansion4.webp": "0fd06c0a491289fd4bd069d33c5c64cf",
"assets/assets/images/villa5.webp": "822564d844b8a1b8bd0fc505dbb5f171",
"assets/assets/images/apartment1_1.webp": "a8c63117e1dfdc2580f515dff10f56ca",
"assets/assets/images/villa1.webp": "6a380af3b78483d737b626aea6a7b9b7",
"assets/assets/images/villa2.webp": "432e726d5c2b76769f7deb3e6ac52e51",
"assets/assets/images/apartment6.webp": "f9f1933f063960492ea9589809af1c00",
"assets/assets/images/office2_2.webp": "568eedf7f31aabb3804623cd00fef95e",
"assets/assets/images/office2.webp": "a9df9225351df53ec768b96998d8c1ee",
"assets/assets/images/home4.jpg": "08f85c08263568c7fdf31cfa0e3f9fec",
"assets/assets/images/villa1_3.webp": "e4f4efdc0dbcfbbc16283c3be43817f7",
"assets/assets/images/inside_mansion1_2.webp": "63ce1a68b5260946af44e15e0c6362a2",
"assets/assets/images/home4.png": "c9a68c5b7d1e695e6dca87b302167fad",
"assets/assets/images/inside_mansion1_1.webp": "e4b1b363b5e6b1a9dac372a73350de57",
"assets/assets/images/home3.jpg": "d667548efde744978b6a5228b1576c68",
"assets/assets/images/office1.webp": "ef6e963d1fb0948ca06b3254316beb70",
"assets/assets/images/villa4.webp": "60284ef7c07140d75756d000b179ba1a",
"assets/assets/images/office1_2.webp": "2a13e8487896bce5a8c88dc16af82b9c",
"assets/assets/images/apartment3.webp": "ab9d0643699022cdae7beab388a8054f",
"assets/assets/images/office1_3.webp": "f5d661fe9ee534f329d87fa766e66109",
"assets/assets/images/villa6.webp": "08a2dd9ec82f84bb5dce9771bf6e1481",
"assets/assets/images/bungalow2.webp": "cf21fe0dae235ad1114ca1031f0c88be",
"assets/AssetManifest.bin": "b2d663c38693636b36c9ad5dacebd189",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "a371500274df7675e166ba819f5dab71",
"assets/fonts/MaterialIcons-Regular.otf": "4640c009dd261c1c94deb38abaecf777",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"index.html": "5520c1c85f07c5aff3d5dc9b96144476",
"/": "5520c1c85f07c5aff3d5dc9b96144476",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"flutter_bootstrap.js": "6e0735290bfadd060db3aeb44265ffaa",
"flutter.js": "76f08d47ff9f5715220992f993002504"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
