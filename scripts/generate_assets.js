const fs = require('fs');
const zlib = require('zlib');

const width = 320;
const height = 360;

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

function makeBackground(mode) {
  const data = Buffer.alloc(width * height * 4);
  const dim = mode === 'aod' ? 0.30 : 0.68;

  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      const index = (y * width + x) * 4;
      const diagonal = x + y * 0.66;
      const wave = Math.sin((y / height) * Math.PI * 2.1) * 18;
      const band = Math.floor(((diagonal + wave + 36) / 31) % progress.length);
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

function makeIcon() {
  const size = 40;
  const data = Buffer.alloc(size * size * 4);
  for (let y = 0; y < size; y += 1) {
    for (let x = 0; x < size; x += 1) {
      const index = (y * size + x) * 4;
      const ring = Math.hypot(x - 20, y - 20);
      const color = progress[Math.floor((x + y) / 7) % progress.length];
      data[index] = ring < 18 ? color[0] : 0;
      data[index + 1] = ring < 18 ? color[1] : 0;
      data[index + 2] = ring < 18 ? color[2] : 0;
      data[index + 3] = ring < 19 ? 255 : 0;
    }
  }
  return png(size, size, data);
}

fs.writeFileSync('resources/drawables/pride_bg_active.png', makeBackground('active'));
fs.writeFileSync('resources/drawables/pride_bg_aod.png', makeBackground('aod'));
fs.writeFileSync('resources/drawables/launcher_icon.png', makeIcon());
