const http = require('http');

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve({ res, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function run() {
  const host = 'localhost';
  const port = 3000;

  // Register
  let opts = { method: 'POST', hostname: host, port, path: '/api/register', headers: { 'Content-Type': 'application/json' } };
  try {
    let r = await request(opts, JSON.stringify({ username: 'alice', password: 'secret' }));
    console.log('/api/register', r.res.statusCode, r.body);
  } catch (e) {
    console.error('Register error', e);
  }

  // Login
  opts = { method: 'POST', hostname: host, port, path: '/api/login', headers: { 'Content-Type': 'application/json' } };
  const login = await request(opts, JSON.stringify({ username: 'alice', password: 'secret' }));
  console.log('/api/login', login.res.statusCode, login.body);
  const setCookie = login.res.headers['set-cookie'];
  console.log('set-cookie:', setCookie);
  const cookieHeader = Array.isArray(setCookie) ? setCookie.map(c => c.split(';')[0]).join('; ') : (setCookie && setCookie.split(';')[0]);

  // Create note
  opts = { method: 'POST', hostname: host, port, path: '/api/notes', headers: { 'Content-Type': 'application/json', Cookie: cookieHeader } };
  const note = await request(opts, JSON.stringify({ content: 'My first note' }));
  console.log('/api/notes POST', note.res.statusCode, note.body);

  // Get notes
  opts = { method: 'GET', hostname: host, port, path: '/api/notes', headers: { Cookie: cookieHeader } };
  const notes = await request(opts);
  console.log('/api/notes GET', notes.res.statusCode, notes.body);
}

run().catch(e => console.error(e));
