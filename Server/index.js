const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const cors = require('cors');

const DB_PATH = path.join(__dirname, 'data.db');
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
// Allow Flutter Web dev server (localhost ports) and 127.0.0.1 with credentials
app.use(cors({
  origin: function(origin, callback) {
    if (!origin) return callback(null, true); // non-CORS or same-origin
    const ok = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);
    return callback(ok ? null : new Error('Not allowed by CORS'), ok);
  },
  credentials: true,
}));

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(session({
  secret: 'dev-secret-change-me',
  resave: false,
  saveUninitialized: false,
  // For local dev: allow cookies to be sent on same-site requests from localhost dev ports
  cookie: { secure: false, sameSite: 'lax' }
}));

// Serve public files
app.use(express.static(path.join(__dirname, 'public')));

// Database (initialized in separate module)
const dbModule = require('./db');
const db = dbModule.db;

// Helpers
function requireAuth(req, res, next) {
  if (req.session && req.session.user) return next();
  res.status(401).json({ error: 'Unauthorized' });
}

// Routes
app.post('/api/register', async (req, res) => {
  try {
    console.log('[/api/register] body:', req.body);
  const { username, password, email, gender, birthday } = req.body;
  if (!username) return res.status(400).json({ error: 'Missing username' });
  if (!password) return res.status(400).json({ error: 'Missing password' });
  if (!email) return res.status(400).json({ error: 'Missing email' });
  if (!gender) return res.status(400).json({ error: 'Missing gender' });
  if (!birthday) return res.status(400).json({ error: 'Missing birthday' });
    const hash = await bcrypt.hash(password, 10);
    try {
      const user = await dbModule.createUser(username, hash, email, null, gender, birthday);
      // create default avatar for this user and set as active — failures here shouldn't break registration
      try {
        const avatar = await dbModule.createAvatar(user.id, 'Hero' + user.id);
        await dbModule.run('UPDATE users SET avatar_id = ? WHERE id = ?', [avatar.id, user.id]);
        user.avatar_id = avatar.id;
      } catch (e) {
        console.error('Failed to create default avatar for user', user.id, e.message || e);
        // let ensureDefaultAvatars pick this up on next startup or call it now
        try { await dbModule.ensureDefaultAvatars(); } catch (er) { console.error('ensureDefaultAvatars runtime fix failed', er.message || er); }
      }
      return res.json(user);
    } catch (e) {
      if (e && e.message && e.message.includes('UNIQUE')) return res.status(409).json({ error: 'User exists' });
      console.error(e);
      return res.status(500).json({ error: 'DB error' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/api/login', async (req, res) => {
  try {
    const { username, password, email } = req.body;
    if ((!username && !email) || !password) return res.status(400).json({ error: 'Missing username/email or password' });
    let row = null;
    try {
      if (email || (username && String(username).includes('@'))) {
        row = await dbModule.getUserByEmail(email || username);
      } else {
        row = await dbModule.getUserByUsername(username);
      }
    } catch (e) { row = null; }
    if (!row) return res.status(401).json({ error: 'Invalid credentials' });
    const ok = await bcrypt.compare(password, row.password);
    if (!ok) return res.status(401).json({ error: 'Invalid credentials' });
    req.session.user = { id: row.id, username: row.username };
    res.json({ message: 'Logged in' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

app.post('/api/logout', (req, res) => {
  req.session.destroy(() => res.json({ message: 'Logged out' }));
});

// CRUD for notes
app.post('/api/notes', requireAuth, async (req, res) => {
  try {
    const { content } = req.body;
    if (!content) return res.status(400).json({ error: 'Missing content' });
    const note = await dbModule.createNote(req.session.user.id, content);
    res.json(note);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

app.get('/api/notes', requireAuth, async (req, res) => {
  try {
    const rows = await dbModule.getNotesByUser(req.session.user.id);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB error' });
  }
});

// Avatars and items APIs
app.get('/api/avatars', requireAuth, async (req, res) => {
  try {
    const avatars = await dbModule.getAvatarsByUser(req.session.user.id);
    res.json(avatars);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

// current user
app.get('/api/me', requireAuth, async (req, res) => {
  try {
    const u = await dbModule.getUserById(req.session.user.id);
    res.json(u);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.post('/api/me/avatar', requireAuth, async (req, res) => {
  try {
    const { avatar_id } = req.body;
    // ensure avatar belongs to user
    const avatar = await dbModule.getAvatarById(avatar_id);
    if (!avatar || avatar.user_id !== req.session.user.id) return res.status(403).json({ error: 'Forbidden' });
    await dbModule.run('UPDATE users SET avatar_id = ? WHERE id = ?', [avatar_id, req.session.user.id]);
    res.json({ avatar_id });
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.get('/api/items', requireAuth, async (req, res) => {
  try {
    const items = await dbModule.getItems();
    res.json(items);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.get('/api/inventory', requireAuth, async (req, res) => {
  try {
    const inv = await dbModule.getInventoryByUser(req.session.user.id);
    res.json(inv);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.post('/api/avatar/:id/equip', requireAuth, async (req, res) => {
  try {
    const avatarId = Number(req.params.id);
    const { item_id } = req.body;
    // ensure avatar belongs to current user
    const avatar = await dbModule.getAvatarById(avatarId);
    if (!avatar || avatar.user_id !== req.session.user.id) return res.status(403).json({ error: 'Forbidden' });
    await dbModule.equipItem(avatarId, item_id);
    const equipped = await dbModule.getEquippedByAvatar(avatarId);
    const accessory = await dbModule.getAccessoryByAvatar(avatarId);
    // return equipped item (backwards-compatible) and include accessory in a separate field
    res.json({ equipped, accessory });
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.post('/api/avatar/:id/unequip', requireAuth, async (req, res) => {
  try {
    const avatarId = Number(req.params.id);
    const avatar = await dbModule.getAvatarById(avatarId);
    if (!avatar || avatar.user_id !== req.session.user.id) return res.status(403).json({ error: 'Forbidden' });
    // allow specifying slot in body: 'equipment' (legacy), a specific slot name, or 'all' to clear every slot
    const slot = (req.body && req.body.slot) ? req.body.slot : 'equipment';
    if (slot === 'all') {
      await dbModule.unequipAll(avatarId);
    } else {
      await dbModule.unequipItem(avatarId, slot);
    }
    const equipped = await dbModule.getEquippedByAvatar(avatarId);
    const accessory = await dbModule.getAccessoryByAvatar(avatarId);
    res.json({ equipped, accessory });
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.get('/api/avatar/:id/equipped', requireAuth, async (req, res) => {
  try {
    const avatarId = Number(req.params.id);
    const avatar = await dbModule.getAvatarById(avatarId);
    if (!avatar || avatar.user_id !== req.session.user.id) return res.status(403).json({ error: 'Forbidden' });
    const equipped = await dbModule.getEquippedByAvatar(avatarId);
    const accessory = await dbModule.getAccessoryByAvatar(avatarId);
    // return main equipped item (backwards compatible) but also include accessory
    res.json({ equipped, accessory });
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.get('/api/avatar/:id', requireAuth, async (req, res) => {
  try {
    const avatarId = Number(req.params.id);
    const avatar = await dbModule.getAvatarById(avatarId);
    if (!avatar || avatar.user_id !== req.session.user.id) return res.status(403).json({ error: 'Forbidden' });
    // also include equipped item
    const equipped = await dbModule.getEquippedByAvatar(avatarId);
    const accessory = await dbModule.getAccessoryByAvatar(avatarId);
    avatar.equipped = equipped || null;
    avatar.accessory = accessory || null;
    res.json(avatar);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

// Public user info (for showing friend avatar/profile)
app.get('/api/user/:id', requireAuth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const u = await dbModule.getUserById(id);
    if (!u) return res.status(404).json({ error: 'Not found' });
    // include active avatar details (if any)
    if (u.avatar_id) {
      try {
        const av = await dbModule.getAvatarById(u.avatar_id);
        const equipped = await dbModule.getEquippedByAvatar(u.avatar_id);
        const accessory = await dbModule.getAccessoryByAvatar(u.avatar_id);
        u.avatar = av || null;
        if (u.avatar) { u.avatar.equipped = equipped || null; u.avatar.accessory = accessory || null; }
      } catch (e) { /* ignore avatar errors */ }
    }
    res.json(u);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

// Friends: search users, send request, accept, list
app.get('/api/friends/search', requireAuth, async (req, res) => {
  try {
    const q = (req.query.username || '').trim();
    if (!q) return res.json([]);
    const rows = await dbModule.searchUsersByUsername(q);
    // annotate relationship relative to current user
    const annotated = [];
    for (const r of rows) {
      if (r.id === req.session.user.id) continue; // skip self
      const rel = await dbModule.get('SELECT status FROM friends WHERE user_id = ? AND friend_id = ? LIMIT 1', [req.session.user.id, r.id]).catch(()=>null);
      const relBack = await dbModule.get('SELECT status FROM friends WHERE user_id = ? AND friend_id = ? LIMIT 1', [r.id, req.session.user.id]).catch(()=>null);
      annotated.push({ id: r.id, username: r.username, profile_picture: r.profile_picture, avatar_id: r.avatar_id, status: rel ? rel.status : (relBack ? 'requested_by_them' : null) });
    }
    res.json(annotated);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.post('/api/friends/request', requireAuth, async (req, res) => {
  try {
    const { friend_id } = req.body;
    const fid = Number(friend_id);
    if (!fid) return res.status(400).json({ error: 'Missing friend_id' });
    const result = await dbModule.sendFriendRequest(req.session.user.id, fid);
    res.json(result);
  } catch (e) { console.error(e); res.status(500).json({ error: e.message || 'DB error' }); }
});

app.post('/api/friends/accept', requireAuth, async (req, res) => {
  try {
    const { friend_id } = req.body;
    const fid = Number(friend_id);
    if (!fid) return res.status(400).json({ error: 'Missing friend_id' });
    const result = await dbModule.acceptFriendRequest(req.session.user.id, fid);
    res.json(result);
  } catch (e) { console.error(e); res.status(500).json({ error: e.message || 'DB error' }); }
});

app.get('/api/friends', requireAuth, async (req, res) => {
  try {
    const friends = await dbModule.getFriendsList(req.session.user.id);
    const pending = await dbModule.getPendingRequests(req.session.user.id);
    res.json({ friends, pending });
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

// Goals APIs
app.get('/api/goals', requireAuth, async (req, res) => {
  try {
    const goals = await dbModule.getGoalsByUser(req.session.user.id);
    res.json(goals);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.post('/api/goals', requireAuth, async (req, res) => {
  try {
    const { title, description, duration, duration_days, category, type, friend_id, start_date, goal_picture, picture } = req.body;
    if (!title) return res.status(400).json({ error: 'Missing title' });
    const friendId = friend_id ? Number(friend_id) : null;
    const durDays = duration_days ? Number(duration_days) : null;
    const goalPic = goal_picture || picture || null;
    const goal = await dbModule.createGoal(
      req.session.user.id,
      title,
      description,
      duration,
      durDays,
      category,
      type || 'single',
      friendId,
      start_date,
      goalPic
    );
    res.json(goal);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.get('/api/goals/:id', requireAuth, async (req, res) => {
  try {
    const id = Number(req.params.id);
  const goal = await dbModule.getGoalById(id, req.session.user.id);
    if (!goal) return res.status(404).json({ error: 'Not found' });
    // ensure the requester is a participant of the goal (owner or invited/added participant)
    const participant = await dbModule.get('SELECT 1 FROM goal_participants WHERE goal_id = ? AND user_id = ? LIMIT 1', [id, req.session.user.id]);
    if (!participant) return res.status(403).json({ error: 'Forbidden' });
    res.json(goal);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.get('/api/goals/:id/logs', requireAuth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const logs = await dbModule.getLogsForGoal(id, 1000);
    res.json(logs);
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

app.post('/api/goals/:id/logs', requireAuth, async (req, res) => {
  try {
    const id = Number(req.params.id);
    const { description, date } = req.body;
    // ensure user is allowed to log for this goal
    const goal = await dbModule.getGoalById(id, req.session.user.id);
    if (!goal) return res.status(404).json({ error: 'Not found' });
  // if the requesting participant already completed, block them from logging
  if (goal.completed) return res.status(400).json({ error: 'You have already completed this goal' });
    const participant = await dbModule.get('SELECT 1 FROM goal_participants WHERE goal_id = ? AND user_id = ? LIMIT 1', [id, req.session.user.id]);
    if (!participant) return res.status(403).json({ error: 'Forbidden' });
    try {
      const log = await dbModule.logGoalProgress(id, req.session.user.id, description, date);
      res.json(log);
    } catch (e) {
      if (e && e.code === 'PARTICIPANT_COMPLETED') return res.status(400).json({ error: 'You have already completed this goal' });
      throw e;
    }
  } catch (e) { console.error(e); res.status(500).json({ error: 'DB error' }); }
});

// Serve goals pages (protected)
app.get('/goals', (req, res) => {
  if (req.session && req.session.user) return res.sendFile(path.join(__dirname, 'public', 'goals.html'));
  res.redirect('/login.html');
});

app.get('/goals/:id/logs', (req, res) => {
  if (req.session && req.session.user) return res.sendFile(path.join(__dirname, 'public', 'goal_logs.html'));
  res.redirect('/login.html');
});

app.post('/api/friends/unfriend', requireAuth, async (req, res) => {
  try {
    const { friend_id } = req.body;
    const fid = Number(friend_id);
    if (!fid) return res.status(400).json({ error: 'Missing friend_id' });
    const result = await dbModule.unfriend(req.session.user.id, fid);
    res.json(result);
  } catch (e) { console.error(e); res.status(500).json({ error: e.message || 'DB error' }); }
});

// serve customize page
app.get('/customize', (req, res) => {
  if (req.session && req.session.user) return res.sendFile(path.join(__dirname, 'public', 'customize.html'));
  res.redirect('/login.html');
});

// Serve a protected hello page
app.get('/hello', (req, res) => {
  if (req.session && req.session.user) return res.sendFile(path.join(__dirname, 'public', 'hello.html'));
  res.redirect('/login.html');
});

<<<<<<< Updated upstream:Server/index.js
// Default homepage route: redirect to a sensible page instead of 404
app.get('/', (req, res) => {
  if (req.session && req.session.user) return res.redirect('/hello');
  return res.redirect('/login.html');
});

// Optional: pretty route for friends page (protected)
app.get('/friends', (req, res) => {
  if (req.session && req.session.user) return res.sendFile(path.join(__dirname, 'public', 'friends.html'));
  res.redirect('/login.html');
});

=======
// Root and /index: redirect to an appropriate page
app.get(['/', '/index'], (req, res) => {
  // If user is logged in, send them to the protected hello (or app landing)
  if (req.session && req.session.user) return res.redirect('/hello');
  // Otherwise send to login page
  return res.redirect('/login.html');
});

>>>>>>> Stashed changes:index.js
// Fallback
app.use((req, res) => res.status(404).send('Not found'));

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
