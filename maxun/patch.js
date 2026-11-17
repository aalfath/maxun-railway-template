// Build-time patches for the Railway template. Fails the build if upstream code changed shape.
const fs = require('fs');
const path = require('path');

function replaceInFile(file, from, to, what) {
  const src = fs.readFileSync(file, 'utf8');
  if (!src.includes(from)) {
    console.error(`patch.js: could not find ${what} in ${file}; upstream changed, update the patch`);
    process.exit(1);
  }
  fs.writeFileSync(file, src.split(from).join(to));
  console.log(`patch.js: ${what} patched in ${file}`);
}

// 1. Same-origin API: the upstream image swaps __VITE_BACKEND_URL__ at start-up; we bake an
//    empty base so every call is relative (`/auth/...`, socket.io on the same host).
const assets = '/srv/maxun/assets';
let hits = 0;
for (const f of fs.readdirSync(assets)) {
  if (!f.endsWith('.js')) continue;
  const p = path.join(assets, f);
  const src = fs.readFileSync(p, 'utf8');
  if (src.includes('__VITE_BACKEND_URL__')) {
    fs.writeFileSync(p, src.split('__VITE_BACKEND_URL__').join(''));
    hits++;
  }
}
if (!hits) { console.error('patch.js: __VITE_BACKEND_URL__ placeholder not found in the UI bundle'); process.exit(1); }
console.log(`patch.js: UI API base set to same-origin in ${hits} file(s)`);

// 2. Close self-registration once an account exists, unless MAXUN_OPEN_SIGNUP=true.
replaceInFile(
  '/app/server/dist/server/src/routes/auth.js',
  'exports.router.post("/register", async (req, res) => {\n    try {\n',
  'exports.router.post("/register", async (req, res) => {\n    try {\n' +
  '        if (process.env.MAXUN_OPEN_SIGNUP !== "true" && (await User_1.default.count()) > 0) {\n' +
  '            return res.status(403).json({ error: "REGISTRATION_CLOSED", code: "register.error.generic" });\n' +
  '        }\n',
  'sign-up guard'
);
