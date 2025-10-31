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

  // Register Alice
  let opts = { method: 'POST', hostname: host, port, path: '/api/register', headers: { 'Content-Type': 'application/json' } };
  let r = await request(opts, JSON.stringify({ username: 'alice_f', password: 'secret', email: 'a@x.com', gender: 'other', birthday: '1990-01-01' }));
  console.log('/api/register alice', r.res.statusCode, r.body);

  // Register Bob
  r = await request(opts, JSON.stringify({ username: 'bob_f', password: 'secret', email: 'b@x.com', gender: 'other', birthday: '1990-01-02' }));
  console.log('/api/register bob', r.res.statusCode, r.body);

  // Login as Alice
  opts = { method: 'POST', hostname: host, port, path: '/api/login', headers: { 'Content-Type': 'application/json' } };
  let aliceLogin = await request(opts, JSON.stringify({ username: 'alice_f', password: 'secret' }));
  console.log('/api/login alice', aliceLogin.res.statusCode, aliceLogin.body);
  const setCookieA = aliceLogin.res.headers['set-cookie'];
  const cookieA = Array.isArray(setCookieA) ? setCookieA.map(c=>c.split(';')[0]).join('; ') : (setCookieA && setCookieA.split(';')[0]);

  // Alice searches for Bob
  opts = { method: 'GET', hostname: host, port, path: '/api/friends/search?username=bob', headers: { Cookie: cookieA } };
  let search = await request(opts);
  console.log('/api/friends/search', search.res.statusCode, search.body);
  const hits = JSON.parse(search.body || '[]');
  const bob = hits.find(h=>h.username && h.username.includes('bob'));
  if (!bob) { console.error('bob not found'); return; }

  // Alice sends friend request
  opts = { method: 'POST', hostname: host, port, path: '/api/friends/request', headers: { 'Content-Type': 'application/json', Cookie: cookieA } };
  let reqRes = await request(opts, JSON.stringify({ friend_id: bob.id }));
  console.log('/api/friends/request', reqRes.res.statusCode, reqRes.body);

  // Login as Bob
  opts = { method: 'POST', hostname: host, port, path: '/api/login', headers: { 'Content-Type': 'application/json' } };
  let bobLogin = await request(opts, JSON.stringify({ username: 'bob_f', password: 'secret' }));
  console.log('/api/login bob', bobLogin.res.statusCode, bobLogin.body);
  const setCookieB = bobLogin.res.headers['set-cookie'];
  const cookieB = Array.isArray(setCookieB) ? setCookieB.map(c=>c.split(';')[0]).join('; ') : (setCookieB && setCookieB.split(';')[0]);

  // Bob lists friends/pending
  opts = { method: 'GET', hostname: host, port, path: '/api/friends', headers: { Cookie: cookieB } };
  let bobList = await request(opts);
  console.log('/api/friends for bob', bobList.res.statusCode, bobList.body);
  // accept the request
  opts = { method: 'POST', hostname: host, port, path: '/api/friends/accept', headers: { 'Content-Type': 'application/json', Cookie: cookieB } };
  let acceptRes = await request(opts, JSON.stringify({ friend_id: (JSON.parse(bobList.body).pending[0] && JSON.parse(bobList.body).pending[0].requester_id) }));
  console.log('/api/friends/accept', acceptRes.res.statusCode, acceptRes.body);

  // Alice lists friends
  opts = { method: 'GET', hostname: host, port, path: '/api/friends', headers: { Cookie: cookieA } };
  let aliceList = await request(opts);
  console.log('/api/friends for alice', aliceList.res.statusCode, aliceList.body);
}

run().catch(e=>console.error(e));
