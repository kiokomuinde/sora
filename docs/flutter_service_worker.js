'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "ed9d29281bcc753c06d71033da38af1b",
"version.json": "b75bad869b2040f1993e54d13f3df6c6",
"index.html": "5520c1c85f07c5aff3d5dc9b96144476",
"/": "5520c1c85f07c5aff3d5dc9b96144476",
"CNAME": "e1387523602c19a789f63aef496c64ed",
"main.dart.js": "9844c65b2db4c337be55e0957746a7e1",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "179141e6b08366d58e8d8f1ee22e08cc",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "e7548a83d90a4f970cab79cc132923ce",
"assets/AssetManifest.json": "970e79bcdedea9347978b9de4c37e788",
"assets/NOTICES": "3629d08374cdbe6547530906e4b003cc",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "6cbd6cfd0a05ec398027165b873437ac",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "115ad795ede5569d8a18487dfc85b472",
"assets/fonts/MaterialIcons-Regular.otf": "45d27412976d70b307b1d0b564946ef1",
"assets/assets/images/image27.webp": "df9b48a277e511b8eb004e93bedb96b1",
"assets/assets/images/image31.webp": "40beceb60d30ccdce77ccb7890aa9a73",
"assets/assets/images/image5.webp": "c541a6b14b1056d857c561bc88ed8438",
"assets/assets/images/image5_3.webp": "310a5903f189674adff304558899ea7d",
"assets/assets/images/image15_3.webp": "0d753b4d07834da6e351cbebb885df63",
"assets/assets/images/image11_4.webp": "93e6a67d13882442b3490e3ca051822b",
"assets/assets/images/image1_4.webp": "baab9da4bfdd1ee45dc0a2ad5bb15f29",
"assets/assets/images/image24_1.webp": "78feee1d4ebbd9e8150b89488e9941b2",
"assets/assets/images/image37_5.webp": "dedc053c4616b646bb04782f5741832f",
"assets/assets/images/image21_2.webp": "93671801b049ec3a0035cbc9a84541e1",
"assets/assets/images/image19_3.webp": "8504345ef3d2453fd5cd9c7f5dd77a4a",
"assets/assets/images/image9_3.webp": "52dc36fc67ddb96f7fee383912cfaaff",
"assets/assets/images/image42_2.webp": "7378eae4f551e3c01557884ff571bf0e",
"assets/assets/images/image11.webp": "b3cb2eee46bb131dbcd4cc556060fb5f",
"assets/assets/images/image7_2.webp": "cf08715ac3e27b9a439d92e663e0e6b8",
"assets/assets/images/image17_2.webp": "da780312abcce12f87898e5df423c03b",
"assets/assets/images/image13_5.webp": "f49987383174bd20f49643ceb06b6ed2",
"assets/assets/images/image3_5.webp": "5832bedda79f3386213634f7040f58a3",
"assets/assets/images/image23_3.webp": "22771e4b08af029d2ee7d7c3d6ea2d23",
"assets/assets/images/image39_4.webp": "af67c5d2dc292b243ff92ba44a72e6ca",
"assets/assets/images/image9.webp": "627bf31a29e695b1d41b05a9f2ddc3f4",
"assets/assets/images/image2_1.webp": "91c851f2814f4358f80493042db4ab4b",
"assets/assets/images/image40_3.webp": "ab7157f7b3a2f16eb1c2dc4b5e26809b",
"assets/assets/images/image12_1.webp": "800a033e9018a90a985ddb8c34f25828",
"assets/assets/images/image40_2.webp": "7386d89bc2281d28605344e6b7ba1279",
"assets/assets/images/image8.webp": "48f02a668319bf548a12bb2dc3047b0f",
"assets/assets/images/image23_2.webp": "4be297aec517504ee730ec42210e8940",
"assets/assets/images/image39_5.webp": "6b838d414290a2988f0ebae7cf1c600b",
"assets/assets/images/image13_4.webp": "f24884cd48f4aedcccbc37c1a0f69b1f",
"assets/assets/images/image3_4.webp": "62ab4812255687d6e0da9e96e1c2b68e",
"assets/assets/images/image7_3.webp": "8b9159b682513857ee3213dabfe7a639",
"assets/assets/images/image17_3.webp": "1b8b7a2db6ec7ca3c7004378fada6b1b",
"assets/assets/images/image38_1.webp": "4466f23a54b35af0d03e53e714adcdc6",
"assets/assets/images/image10.webp": "6f539d71b8d1dd7b7a7cc51459998baf",
"assets/assets/images/image19_2.webp": "93e6a67d13882442b3490e3ca051822b",
"assets/assets/images/image9_2.webp": "2952dc755d67a3d79278706c0d1034d4",
"assets/assets/images/image42_3.webp": "3fa1090ce94f4875af50aa59df5585c1",
"assets/assets/images/image10_1.webp": "81c3fe30209bc2e7a23ea003f5aecb30",
"assets/assets/images/image21_3.webp": "5bfde6ddd8ececdd358eb39b194ed91b",
"assets/assets/images/image37_4.webp": "905faf653ce945b386b18d7f5c8ac546",
"assets/assets/images/image11_5.webp": "5b57f5d35b87cd17335f0c2cea44679f",
"assets/assets/images/image1_5.webp": "fd5166c21e12f0f3c8f0aeb36841572d",
"assets/assets/images/image5_2.webp": "438f9de91765a20e0ed06dda1a808788",
"assets/assets/images/image15_2.webp": "ee12c61f4c87be9c1ec12365e153c3e0",
"assets/assets/images/image4.webp": "7e16cd4e882d3984cad519da8b8d3700",
"assets/assets/images/image1.jpeg": "4b64508127f2f4a0c6037a0f2f7ff6ba",
"assets/assets/images/image30.webp": "1d9040cc1877cc49f328b22b90e1aec3",
"assets/assets/images/image26.webp": "d3379981642ea05d1e82d9444fbf0249",
"assets/assets/images/image15_5.webp": "341b0868d566636b8a77f01b6d8a5450",
"assets/assets/images/image5_5.webp": "d1a0e55aae039f0ec67436343aa84789",
"assets/assets/images/image1_2.webp": "c765456a072611a8aa7f4359acf60484",
"assets/assets/images/image18_1.webp": "d16d9fd12a450275199c6a8b9e497fa2",
"assets/assets/images/image8_1.webp": "63032c117241e393dde0ed403037f46c",
"assets/assets/images/image11_2.webp": "e5aa7bb5c9267286c44372cfb0801662",
"assets/assets/images/image37_3.webp": "01de418a9869a8c67a81165f5935f23c",
"assets/assets/images/image4_1.webp": "6901f1cc7ad0036d336fb70a83fce3e0",
"assets/assets/images/image14_1.webp": "381a11115e8a67971287834a7f0ddd73",
"assets/assets/images/image8_4.jpeg": "b6a81255af4cbc42fcf095f9da163b17",
"assets/assets/images/image21_4.webp": "db5f5c49883510cdf51ffc066a979b72",
"assets/assets/images/image9_5.webp": "358555c8d62f505fff0c709240dcfa69",
"assets/assets/images/image42_4.webp": "6702308cf668f7264a98deaa500b2dfa",
"assets/assets/images/image19_5.webp": "5b57f5d35b87cd17335f0c2cea44679f",
"assets/assets/images/image17.webp": "3cb42ebf86357e61955b8a90d0abde78",
"assets/assets/images/image17_4.webp": "22e74693261e211865213b52bc39a25e",
"assets/assets/images/image7_4.webp": "bdc4fc043638fe9c05c7416ec6950cbf",
"assets/assets/images/image40.webp": "b0450d43eacd6fc76c146a8e62093cb3",
"assets/assets/images/image3_3.webp": "9cf6a6b469baa33429b9bd7527f789e8",
"assets/assets/images/image41_1.webp": "b67e056c3d3e58368434dd10c0db1ce9",
"assets/assets/images/image13_3.webp": "e670a57637575b976c34b903580284f8",
"assets/assets/images/image23_5.webp": "eed0112c9ddd64dd42aafa03939cb7c8",
"assets/assets/images/image39_2.webp": "d8839a9e38fb8aa599a90f1782cda2ef",
"assets/assets/images/image40_5.webp": "3ceb2a06eb483203fe5329ee2251855a",
"assets/assets/images/image21.webp": "ef6c77ff44601bce044713ccac3e8b84",
"assets/assets/images/image37.webp": "482d77a173d6ebc39c97dc4cebd88619",
"assets/assets/images/image3.webp": "9b8dee6b3a5fd2fcbbb3311ab42754cc",
"assets/assets/images/image2.webp": "b778bec6fc021ad1c0501a4840d22be8",
"assets/assets/images/image36.webp": "1f9ee18e274931522dc20152c1bdd53f",
"assets/assets/images/image20.webp": "047ff6530536497ca1ae683f7d2236ee",
"assets/assets/images/image40_4.webp": "2bcec5a875a080b6d14eafde2b4648a6",
"assets/assets/images/image6_1.webp": "c79b4154b71f257b7b7e1cf65f787c1b",
"assets/assets/images/image16_1.webp": "d7ce0f64969a5ee5cda515168123e151",
"assets/assets/images/image23_4.webp": "38b7dd148792673b76871262e228627a",
"assets/assets/images/image39_3.webp": "420821f1311fda21b2a25ec40e503d8b",
"assets/assets/images/image3_2.webp": "365b26f0e6ae61635f52ee5811394ebb",
"assets/assets/images/image13_2.webp": "d4f82966a76e8c3eefa1fb7b2e4b1094",
"assets/assets/images/image41.webp": "1a1c5a19a45ad308f4c4f1d42f40bffc",
"assets/assets/images/image17_5.webp": "3c02ea8cb0fe8d6a844136780675f8b8",
"assets/assets/images/image7_5.webp": "c75aa90e30b70bdbc5d956c36a5d5aad",
"assets/assets/images/image16.webp": "2392ba2eefdf9f9147e056ddc2717513",
"assets/assets/images/image9_4.webp": "ab2cab038dcda9a446d94573d4c2b739",
"assets/assets/images/image42_5.webp": "03013136588400863f259b64ed61b55c",
"assets/assets/images/image19_4.webp": "f9c54b557a782047870013be245c75a4",
"assets/assets/images/image21_5.webp": "998b913c6deeafc3eb493200821d7070",
"assets/assets/images/image37_2.webp": "f7755cf8de04b0abb980cca24b2016aa",
"assets/assets/images/image1_3.webp": "a8c63117e1dfdc2580f515dff10f56ca",
"assets/assets/images/image11_3.webp": "5dc1a8e555a42dfe0c6da67e3984d704",
"assets/assets/images/image20_1.webp": "560f73a07a48b0c578043e13f145dfaf",
"assets/assets/images/image15_4.webp": "38604d67bcc76005bfe05d2d0ff32fbf",
"assets/assets/images/image5_4.webp": "b916d220abf95671fa6dfb362d2c0568",
"assets/assets/images/image2_5.webp": "c2cbc9abc94bde9a7d124781885f008e",
"assets/assets/images/image12_5.webp": "9ea508a9b02383560616d60cd2d70cda",
"assets/assets/images/image16_2.webp": "da9805321a04d8936b939a7c1c4d1235",
"assets/assets/images/image6_2.webp": "17d791821c58aa9b953880f3c1e451a5",
"assets/assets/images/image41_3.webp": "748199ca8573ca318767b69d8c567616",
"assets/assets/images/image13_1.webp": "3036187366b25e2af4a0e20da460745b",
"assets/assets/images/image3_1.webp": "7a8289062deeead08915c7a45c05ec63",
"assets/assets/images/image42.webp": "bf861ba5c607869a08b43cb766c80c24",
"assets/assets/images/image15.webp": "6a4b2ae2a2996f925fe8680c78552877",
"assets/assets/images/image38_4.webp": "0597e1cdea4a6df673869b308afb477a",
"assets/assets/images/image10_4.webp": "ece3a2490240ad5c72aba69ecf576188",
"assets/assets/images/image39.webp": "1350afcb8f159a1da1f1c65a59fa1a83",
"assets/assets/images/image14_3.webp": "eb4894bd063dc139e6b20d557a91e5b6",
"assets/assets/images/image4_3.webp": "cf79f5c09fd823650fe15f034f467deb",
"assets/assets/images/image37_1.webp": "0cad367eae61ceffc459a06c6feff3b8",
"assets/assets/images/image24_5.webp": "1bd95aca361d911f98dd62f2082c3a0e",
"assets/assets/images/image8_3.webp": "074f671f0ab09104632dddd0e26b1230",
"assets/assets/images/image18_3.webp": "7062eb87fc1d231e73d07db549c6651f",
"assets/assets/images/image20_2.webp": "8922a5aa1c3f2696ee010eee26c408c1",
"assets/assets/images/image19.webp": "1fd53af108027f7cc57047d67ea15a9a",
"assets/assets/images/image8_2.jpg": "80df6df83af8f03052e386b56ed8f44e",
"assets/assets/images/image35.webp": "9e72367fb5e4efa2126fa5b74a08ff2d",
"assets/assets/images/image23.webp": "aaefb2e68b4174b416f5782a887272ba",
"assets/assets/images/image22.webp": "083fe31b3eb410ff244c1561c019c74e",
"assets/assets/images/image34.webp": "aad8b867a306ee255de500b7f4936351",
"assets/assets/images/image18.webp": "7886ac1a096dd5464eb5212858a0d50b",
"assets/assets/images/image20_3.webp": "b47f26bf9caa5767831b522d7a8bc9bb",
"assets/assets/images/image8_2.webp": "5541aa89f3ddd811e190ac01f76c3bc4",
"assets/assets/images/image11_1.webp": "353efe5585c3b6ecc250a9e16dc0fda7",
"assets/assets/images/image1_1.webp": "bf0713ef0af0889f6442986b64fe2f4e",
"assets/assets/images/image18_2.webp": "9de89fb34c1d04c28dfc1a3c74ca3343",
"assets/assets/images/image24_4.webp": "4994bf2ca23b9191a6656df8c186c3f6",
"assets/assets/images/image38.webp": "7c13ca3583120bb8ad37a09e0fa1ab45",
"assets/assets/images/image14_2.webp": "3ab646c22214c9a1bc8f87bd99bbd75f",
"assets/assets/images/image4_2.webp": "823975e151bc7fd107605954dd2a3184",
"assets/assets/images/image10_5.webp": "64caaf6269d1433d3f0fd32647013efe",
"assets/assets/images/image14.webp": "7b8b8f589ca6fbbae18c036e02a96b13",
"assets/assets/images/image38_5.webp": "9460f5a4835bbc238bde40858812450b",
"assets/assets/images/image41_2.webp": "b1e543f17d75b216fbca4be5ad663d99",
"assets/assets/images/image39_1.webp": "8fbcef1487b95d79e617a1f0156a5cad",
"assets/assets/images/image16_3.webp": "140357529761e5e6811ce28388f4aa8a",
"assets/assets/images/image6_3.webp": "b29282cbb7c4c30165321c572e48a271",
"assets/assets/images/image2_4.webp": "0c6a8763d7b0ca927346a084f216fe54",
"assets/assets/images/image12_4.webp": "4c52749e5f66b6d0f143631fd5f7f8c0",
"assets/assets/images/image7.webp": "9b8dee6b3a5fd2fcbbb3311ab42754cc",
"assets/assets/images/image33.webp": "1cfd789ce48924d4ba85e063fb6ab74e",
"assets/assets/images/image25.webp": "39b518be3cc9af63df67278cccd8444d",
"assets/assets/images/image40_1.webp": "445bc65e252a9f18da8745635e5fe65b",
"assets/assets/images/image12_3.webp": "84b1de36540fa709485953ab8e88e0cf",
"assets/assets/images/image2_3.webp": "251e9e3afce603ea8a3aba4a520fc886",
"assets/assets/images/image6_4.webp": "80a4d3f0eeb9902040235c5d7d8adc2d",
"assets/assets/images/image16_4.webp": "279e13684b0d54f47badd68535f3439b",
"assets/assets/images/image23_1.webp": "7f003db8c35223fda38cbf94771f8b3c",
"assets/assets/images/image41_5.webp": "df4cad278b8a64f585446de2ec950f2f",
"assets/assets/images/image13.webp": "b0ec4650082082f9bbb4f99f4f3f440c",
"assets/assets/images/image38_2.webp": "343d3b3086edab2b3085230ca72b41e8",
"assets/assets/images/image9_1.webp": "e7b0aa818b1d6b50e0d6ed3475bc4184",
"assets/assets/images/image10_2.webp": "ff58b0b23558657219996ec8da21c8a7",
"assets/assets/images/image19_1.webp": "929d0bfdb8fdd678a79221cc54cacbb8",
"assets/assets/images/image4_5.webp": "6f6f7b52953774774ecfbb16b9881004",
"assets/assets/images/image14_5.webp": "c546f1f8e2f434bf30ba33960670f28a",
"assets/assets/images/image24_3.webp": "85723d716ae3b06caf97f91d3966e789",
"assets/assets/images/image18_5.webp": "7a077890e2dbf4ac0bcbe1a027197741",
"assets/assets/images/image8_5.webp": "135d4e8115898481588f7ed4c040a768",
"assets/assets/images/image29.webp": "3e705394369a4ca81d865aa649026fbe",
"assets/assets/images/image20_4.webp": "80b58805455e334527a7f05fa834d362",
"assets/assets/images/image15_1.webp": "5f64e389b70d3208a47cb873659fd76a",
"assets/assets/images/image5_1.webp": "e9fb69bc322240d2c3178a707307ce06",
"assets/assets/images/image20_5.webp": "c704cd2ae264d838c70a6fa6b1ef2c85",
"assets/assets/images/image18_4.webp": "4cff15b2c05e1cfe6654a937ac1f500c",
"assets/assets/images/image8_4.webp": "53aa852776d094133ae77853ba4eb4cf",
"assets/assets/images/image28.webp": "3e53308cea54776e1d7c66a4c0add52a",
"assets/assets/images/image24_2.webp": "d9f3c9bfd4dee302ca9d067951ba019e",
"assets/assets/images/image4_4.webp": "8656536b2ca0de4df5613bde3f7966eb",
"assets/assets/images/image14_4.webp": "a6d052469ee6a29e62a497a004434ff5",
"assets/assets/images/image21_1.webp": "197ae23d9860a27e83488cb553f2c203",
"assets/assets/images/sora_logo.png": "27b423bf1a28fe69f4ecb2d8f136d8d1",
"assets/assets/images/image42_1.webp": "793257e65b123a369eb13e3cf966f469",
"assets/assets/images/image10_3.webp": "b01eb6b20ba6b1073788ecbf3a7b2fbd",
"assets/assets/images/image12.webp": "b587e924216285ff08a5f70a14a8d18f",
"assets/assets/images/image38_3.webp": "bcdc6b2934b7e3358c9fb655791aeb73",
"assets/assets/images/image17_1.webp": "fa6d18af5f970388143eb167f7484c20",
"assets/assets/images/image7_1.webp": "135d4e8115898481588f7ed4c040a768",
"assets/assets/images/image41_4.webp": "401f320123c07c00a9e0ca53ef46f222",
"assets/assets/images/image6_5.webp": "67ca86d954b222dfcf363606fead59b1",
"assets/assets/images/image16_5.webp": "757d99ed3b648a9b0a026adb814e8d15",
"assets/assets/images/image12_2.webp": "e6f84d5aa9c6933beb92c964de1c637b",
"assets/assets/images/image2_2.webp": "97d1a3128a1b46bb5bde19afba35d18e",
"assets/assets/images/image24.webp": "b1fe8da34a48a68914b3dc0a1e8af96b",
"assets/assets/images/image32.webp": "1a60f071c5558c298c5d47a12e09a9ff",
"assets/assets/images/image6.webp": "3fa56226a43092bb27468f539ca47fef",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
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
