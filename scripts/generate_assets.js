const fs = require('fs');
const zlib = require('zlib');

const targets = [
  {
    name: 'base',
    width: 320,
    height: 360,
    iconSize: 40,
    outputDir: 'resources/drawables',
  },
  {
    name: 'venux1',
    width: 448,
    height: 486,
    iconSize: 65,
    outputDir: 'resources-venux1/drawables',
  },
];

function crc32(buf) {
  let c = ~0;
  for (let i = 0; i < buf.length; i += 1) {
    c ^= buf[i];
    for (let k = 0; k < 8; k += 1) {
      c = (c >>> 1) ^ (0xedb88320 & -(c & 1));
    }
  }
  return ~c >>> 0;
}

function chunk(type, data) {
  const out = Buffer.alloc(12 + data.length);
  out.writeUInt32BE(data.length, 0);
  out.write(type, 4, 4, 'ascii');
  data.copy(out, 8);
  out.writeUInt32BE(crc32(out.subarray(4, 8 + data.length)), 8 + data.length);
  return out;
}

function png(w, h, rgba) {
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y += 1) {
    const row = y * (w * 4 + 1);
    raw[row] = 0;
    rgba.copy(raw, row + 1, y * w * 4, (y + 1) * w * 4);
  }

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;

  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw)),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

function blend(base, over, alpha) {
  return [
    Math.round(base[0] * (1 - alpha) + over[0] * alpha),
    Math.round(base[1] * (1 - alpha) + over[1] * alpha),
    Math.round(base[2] * (1 - alpha) + over[2] * alpha),
    255,
  ];
}

const progress = [
  [0x00, 0x00, 0x00],
  [0x78, 0x4f, 0x17],
  [0x6d, 0x23, 0x88],
  [0x00, 0x51, 0x9f],
  [0x55, 0xcd, 0xe8],
  [0xf7, 0xa8, 0xb8],
  [0xff, 0xff, 0xff],
  [0xe4, 0x03, 0x03],
  [0xff, 0x8c, 0x00],
  [0xff, 0xed, 0x00],
  [0x00, 0x80, 0x26],
  [0x24, 0x40, 0x8e],
  [0x73, 0x29, 0x82],
];

function makeBackground(width, height, mode) {
  const data = Buffer.alloc(width * height * 4);
  const dim = mode === 'aod' ? 0.30 : 0.68;

  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const index = (y * width + x) * 4;
      const diagonal = x + y * 0.66;
      const wave = Math.sin((y / height) * Math.PI * 2.1) * (height / 20);
      const bandWidth = Math.max(31, Math.round(width / 10.3));
      const band = Math.floor(((diagonal + wave + (width / 8.9)) / bandWidth) % progress.length);
      const stripe = progress[(band + progress.length) % progress.length];
      const shade = 0.78 + Math.sin((x / width) * Math.PI) * 0.12;
      const color = [
        Math.round(stripe[0] * dim * shade),
        Math.round(stripe[1] * dim * shade),
        Math.round(stripe[2] * dim * shade),
        255,
      ];

      data[index] = color[0];
      data[index + 1] = color[1];
      data[index + 2] = color[2];
      data[index + 3] = 255;

      if (mode !== 'active') {
        data[index] = Math.round(data[index] * 0.48);
        data[index + 1] = Math.round(data[index + 1] * 0.48);
        data[index + 2] = Math.round(data[index + 2] * 0.48);
      }
    }
  }

  return png(width, height, data);
}

function makeIcon(size) {
  const data = Buffer.alloc(size * size * 4);
  const center = size / 2;
  const radius = size * 0.45;
  for (let y = 0; y < size; y += 1) {
    for (let x = 0; x < size; x += 1) {
      const index = (y * size + x) * 4;
      const ring = Math.hypot(x - center, y - center);
      const color = progress[Math.floor((x + y) / Math.max(7, size / 5.7)) % progress.length];
      data[index] = ring < radius ? color[0] : 0;
      data[index + 1] = ring < radius ? color[1] : 0;
      data[index + 2] = ring < radius ? color[2] : 0;
      data[index + 3] = ring < radius + 1 ? 255 : 0;
    }
  }
  return png(size, size, data);
}

const drawablesXml = `<?xml version="1.0"?>
<drawables>
    <bitmap id="LauncherIcon" filename="launcher_icon.png" />
    <bitmap id="PrideBackgroundActive" filename="pride_bg_active.png" />
    <bitmap id="PrideBackgroundAod" filename="pride_bg_aod.png" />
</drawables>
`;

for (const target of targets) {
  fs.mkdirSync(target.outputDir, { recursive: true });
  fs.writeFileSync(`${target.outputDir}/drawables.xml`, drawablesXml);
  fs.writeFileSync(
    `${target.outputDir}/pride_bg_active.png`,
    makeBackground(target.width, target.height, 'active')
  );
  fs.writeFileSync(
    `${target.outputDir}/pride_bg_aod.png`,
    makeBackground(target.width, target.height, 'aod')
  );
  fs.writeFileSync(`${target.outputDir}/launcher_icon.png`, makeIcon(target.iconSize));
}
