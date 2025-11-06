const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const seedItems = require('./scripts/seed_items');
const seedAvatars = require('./scripts/seed_avatars');
const seedInventory = require('./scripts/seed_inventory');
const seedAll = require('./scripts/seed_all');
const createSchema = require('./scripts/schema');

const DB_PATH = path.join(__dirname, 'data.db'); 

const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('Failed to open DB', err);
    process.exit(1);
  }
});

// Create tables via central schema script. We call this immediately after DB open.
createSchema(db).then(() => {
  // After schema is created, ensure any new columns exist (safe to call on every start)
  (async () => {
    await addColumnIfNotExistsTable('users', 'email', 'TEXT');
    await addColumnIfNotExistsTable('users', 'profile_picture', 'TEXT');
    await addColumnIfNotExistsTable('users', 'gender', 'TEXT');
    await addColumnIfNotExistsTable('users', 'birthday', 'TEXT');
    await addColumnIfNotExistsTable('users', 'avatar_id', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'head', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'body', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'hand', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'accessory', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'accessory', 'INTEGER');
    // created_at: add as TEXT and set existing rows' values to now (can't use non-constant default in ALTER)
    await addColumnIfNotExistsTable('users', 'created_at', 'TEXT');
    try { await run("UPDATE users SET created_at = datetime('now') WHERE created_at IS NULL") } catch (e) { /* ignore */ }
    // ensure goals new columns exist for reward system
    // For goals ensure important columns exist; use PRAGMA to avoid errors if table exists without columns
    try {
      const cols = await all("PRAGMA table_info('goals')");
      const names = (cols || []).map(c => c.name);
      if (!names.includes('goal_picture')) await run("ALTER TABLE goals ADD COLUMN goal_picture TEXT");
      if (!names.includes('duration_days')) await run("ALTER TABLE goals ADD COLUMN duration_days INTEGER");
      if (!names.includes('reward_item_id')) await run("ALTER TABLE goals ADD COLUMN reward_item_id INTEGER");
      if (!names.includes('completed_at')) await run("ALTER TABLE goals ADD COLUMN completed_at TEXT");
    } catch (e) { console.error('ensure goals columns error', e && e.message ? e.message : e); }
      // Ensure goal_participants columns for per-participant completion exist
      try {
        const pcols = await all("PRAGMA table_info('goal_participants')");
        const pnames = (pcols || []).map(c => c.name);
        if (!pnames.includes('completed')) await run("ALTER TABLE goal_participants ADD COLUMN completed INTEGER DEFAULT 0");
        if (!pnames.includes('reward_item_id')) await run("ALTER TABLE goal_participants ADD COLUMN reward_item_id INTEGER");
        if (!pnames.includes('completed_at')) await run("ALTER TABLE goal_participants ADD COLUMN completed_at TEXT");
      } catch (e) { console.error('ensure goal_participants columns error', e && e.message ? e.message : e); }
  })();
}).catch((err) => {
  console.error('Failed to create schema', err && err.message ? err.message : err);
});

// Promisified helpers
function run(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) return reject(err);
      resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
}

function get(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) return reject(err);
      resolve(row);
    });
  });
}

function all(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) return reject(err);
      resolve(rows);
    });
  });
}

// Higher-level helpers
// Add a column to a specific table if missing
const addColumnIfNotExistsTable = async (table, colName, colDef) => {
  try {
    await get(`SELECT ${colName} FROM ${table} LIMIT 1`);
  } catch (e) {
    try {
      await run(`ALTER TABLE ${table} ADD COLUMN ${colName} ${colDef}`);
      console.log(`Added column ${colName} to ${table} table`);
    } catch (err) {
      if (!(err && err.message && err.message.includes('duplicate column'))) console.error(err);
    }
  }
};

// (migrations run after schema creation above)

// Seed example data if not present
(async () => {
  try {
    // Run all seed scripts in order (users -> items -> avatars -> inventory -> notes)
    await seedAll(run, get, all, addColumnIfNotExistsTable);
  } catch (e) {
    // non-fatal
    console.error('seed error', e.message || e);
  }
  try {
    await ensureDefaultAvatars();
  } catch (e) {
    console.error('ensureDefaultAvatars error', e.message || e);
  }
})();

async function createUser(username, passwordHash, email = null, profile_picture = null, gender = null, birthday = null) {
  const res = await run('INSERT INTO users (username, password, email, profile_picture, gender, birthday) VALUES (?, ?, ?, ?, ?, ?)', [username, passwordHash, email, profile_picture, gender, birthday]);
  return { id: res.lastID, username, email, profile_picture, gender, birthday };
}

async function getUserByUsername(username) {
  return get('SELECT id, username, password FROM users WHERE username = ?', [username]);
}

async function getUserByEmail(email) {
  return get('SELECT id, username, password FROM users WHERE email = ?', [email]);
}

async function getUserById(id) {
  return get('SELECT id, username, email, profile_picture, gender, birthday, avatar_id, created_at FROM users WHERE id = ?', [id]);
}

async function createNote(userId, content) {
  const res = await run('INSERT INTO notes (user_id, content) VALUES (?, ?)', [userId, content]);
  return { id: res.lastID, content };
}

async function getNotesByUser(userId) {
  return all('SELECT id, content FROM notes WHERE user_id = ?', [userId]);
}

// --- Goals / Goal logs helpers ---
async function createGoal(userId, title, description = null, duration = null, durationDays = null, category = null, type = 'single', friendId = null, startDate = null, goalPicture = null) {
  // If this is a group goal with a single friend selected, create separate goal rows for each collaborator
  // so each user has their own goal record and progress. This avoids blocking other collaborators when one completes.
  try {
    // create the goal for the requesting user
    const res = await run(
      `INSERT INTO goals (user_id, title, description, duration, category, type, friend_id, status, start_date, goal_picture, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))`,
      [userId, title, description, duration, category, type, friendId, 'ongoing', startDate, goalPicture]
    );
    const goalId = res.lastID;
    if (durationDays) {
      const displayDuration = duration || (durationDays ? (durationDays + ' days') : null);
      try { await run('UPDATE goals SET duration_days = ? WHERE goal_id = ?', [durationDays, goalId]); } catch (e) { /* ignore */ }
      try { if (displayDuration) await run('UPDATE goals SET duration = ? WHERE goal_id = ?', [displayDuration, goalId]); } catch (e) { /* ignore */ }
    }
    // ensure owner is a participant for their own goal
    try {
      await run('INSERT OR IGNORE INTO goal_participants (goal_id, user_id, progress_days, last_completed_at) VALUES (?, ?, 0, NULL)', [goalId, userId]);
    } catch (e) { console.error('createGoal participant insert error', e && e.message ? e.message : e); }

    // if group and a friend is specified, create a separate goal row for the friend (their own copy)
    if (type === 'group' && friendId && friendId !== userId) {
      try {
        const res2 = await run(
          `INSERT INTO goals (user_id, title, description, duration, category, type, friend_id, status, start_date, goal_picture, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, datetime('now'))`,
          [friendId, title, description, duration, category, type, userId, 'ongoing', startDate, goalPicture]
        );
        const friendGoalId = res2.lastID;
        if (durationDays) {
          try { await run('UPDATE goals SET duration_days = ? WHERE goal_id = ?', [durationDays, friendGoalId]); } catch (e) { /* ignore */ }
          try { if (duration) await run('UPDATE goals SET duration = ? WHERE goal_id = ?', [duration, friendGoalId]); } catch (e) { /* ignore */ }
        }
        // ensure friend is participant of their own goal
        try { await run('INSERT OR IGNORE INTO goal_participants (goal_id, user_id, progress_days, last_completed_at) VALUES (?, ?, 0, NULL)', [friendGoalId, friendId]); } catch (e) { console.error('createGoal friend participant insert error', e && e.message ? e.message : e); }
      } catch (e) {
        console.error('failed to create friend copy of group goal', e && e.message ? e.message : e);
      }
    }
  return { goal_id: goalId, user_id: userId, title, description, duration, category, type, friend_id: friendId, status: 'ongoing', start_date: startDate, goal_picture: goalPicture };
  } catch (e) {
    console.error('createGoal error', e && e.message ? e.message : e);
    throw e;
  }
}

async function getGoalsByUser(userId) {
  // return goals where the user is a participant, with participant-specific progress fields
  return all(`SELECT g.*, COALESCE(p.progress_days, 0) as progress_days, p.last_completed_at
    FROM goals g JOIN goal_participants p ON p.goal_id = g.goal_id AND p.user_id = ?
    ORDER BY g.created_at DESC`, [userId]);
}

async function getGoalById(goalId, userId = null) {
  if (userId) {
    return get(`SELECT g.*, COALESCE(p.progress_days, 0) as progress_days, p.last_completed_at, COALESCE(p.completed,0) as completed, p.reward_item_id as participant_reward_item_id, p.completed_at as participant_completed_at
      FROM goals g LEFT JOIN goal_participants p ON p.goal_id = g.goal_id AND p.user_id = ?
      WHERE g.goal_id = ? LIMIT 1`, [userId, goalId]);
  }
  return get('SELECT * FROM goals WHERE goal_id = ?', [goalId]);
}

async function logGoalProgress(goalId, userId, description = null, date = null) {
  // Determine the log date (YYYY-MM-DD)
  const logDate = date || new Date().toISOString().slice(0, 10);

  // Ensure this participant hasn't already completed the goal
  try {
    const partCheck = await get('SELECT completed FROM goal_participants WHERE goal_id = ? AND user_id = ? LIMIT 1', [goalId, userId]);
    if (partCheck && partCheck.completed) {
      const err = new Error('Participant already completed');
      err.code = 'PARTICIPANT_COMPLETED';
      throw err;
    }
  } catch (e) {
    if (e && e.code === 'PARTICIPANT_COMPLETED') throw e;
    // otherwise continue; if table/row missing we'll insert later
  }
  // Check if a log for this goal/user/date already exists BEFORE inserting
  const existing = await get('SELECT 1 FROM goal_logs WHERE goal_id = ? AND user_id = ? AND date = ? LIMIT 1', [goalId, userId, logDate]);
  // Insert the log (we keep all logs)
  const res = await run('INSERT INTO goal_logs (goal_id, user_id, description, date, created_at) VALUES (?, ?, ?, ?, datetime(\'now\'))', [goalId, userId, description, logDate]);
  let awardedItem = null;
  try {
    // ensure participant row exists
    await run('INSERT OR IGNORE INTO goal_participants (goal_id, user_id, progress_days, last_completed_at) VALUES (?, ?, 0, NULL)', [goalId, userId]);
    if (!existing) {
      // increment this user's participant progress
      await run('UPDATE goal_participants SET progress_days = COALESCE(progress_days, 0) + 1, last_completed_at = datetime(\'now\') WHERE goal_id = ? AND user_id = ?', [goalId, userId]);
    } else {
      // update last_completed_at even if duplicate log
      await run('UPDATE goal_participants SET last_completed_at = datetime(\'now\') WHERE goal_id = ? AND user_id = ?', [goalId, userId]);
    }
    // After updating participant progress, check for completion against goals.duration_days
    try {
      // Inspect table columns first to avoid selecting missing columns
      const cols = await all("PRAGMA table_info('goals')");
      const colNames = (cols || []).map(c => c.name);
      let durationNeeded = null;
      let goalStatus = null;
      let alreadyRewarded = null;
      if (colNames.includes('duration_days')) {
        const goalRow = await get('SELECT duration_days as duration_needed, status, reward_item_id FROM goals WHERE goal_id = ? LIMIT 1', [goalId]);
        if (goalRow) {
          durationNeeded = goalRow.duration_needed || null;
          goalStatus = goalRow.status;
          alreadyRewarded = goalRow.reward_item_id || null;
        }
      } else {
        // fallback parse from duration text
        if (colNames.includes('reward_item_id')) {
          const txt = await get('SELECT duration, status, reward_item_id FROM goals WHERE goal_id = ? LIMIT 1', [goalId]);
          if (txt) {
            goalStatus = txt.status;
            alreadyRewarded = txt.reward_item_id || null;
            if (txt.duration) {
              const m = String(txt.duration).match(/(\d+)/);
              if (m) durationNeeded = parseInt(m[1], 10);
            }
          }
        } else {
          const txt = await get('SELECT duration, status FROM goals WHERE goal_id = ? LIMIT 1', [goalId]);
          if (txt) {
            goalStatus = txt.status;
            if (txt.duration) {
              const m = String(txt.duration).match(/(\d+)/);
              if (m) durationNeeded = parseInt(m[1], 10);
            }
          }
        }
      }

      if (goalStatus !== 'completed' && durationNeeded && durationNeeded > 0) {
        const part = await get('SELECT progress_days FROM goal_participants WHERE goal_id = ? AND user_id = ? LIMIT 1', [goalId, userId]);
        if (part && part.progress_days >= durationNeeded) {
          // award reward (only once per goal)
          if (!alreadyRewarded) {
            const item = await get('SELECT id, name, picture, type FROM items ORDER BY RANDOM() LIMIT 1');
              if (item) {
              // add to user's inventory (increment qty if exists)
              const inv = await get('SELECT id, qty FROM inventory WHERE user_id = ? AND item_id = ? LIMIT 1', [userId, item.id]);
              if (inv) {
                await run('UPDATE inventory SET qty = qty + 1 WHERE id = ?', [inv.id]);
              } else {
                await run('INSERT INTO inventory (user_id, item_id, qty) VALUES (?, ?, ?)', [userId, item.id, 1]);
              }
              // mark this participant as completed and set participant reward info
              try {
                await run("UPDATE goal_participants SET completed = 1, reward_item_id = ?, completed_at = datetime('now') WHERE goal_id = ? AND user_id = ?", [item.id, goalId, userId]);
              } catch (e) {
                // fallback: try to set individual fields if composite update fails
                try { if (colNames.includes('reward_item_id')) await run("UPDATE goal_participants SET reward_item_id = ? WHERE goal_id = ? AND user_id = ?", [item.id, goalId, userId]); } catch (er) {}
                try { await run("UPDATE goal_participants SET completed = 1 WHERE goal_id = ? AND user_id = ?", [goalId, userId]); } catch (er) {}
                try { if (colNames.includes('completed_at')) await run("UPDATE goal_participants SET completed_at = datetime('now') WHERE goal_id = ? AND user_id = ?", [goalId, userId]); } catch (er) {}
              }
              awardedItem = item;
            }
          }
        }
      }
    } catch (e) {
      console.error('completion check error', e && e.message ? e.message : e);
    }
  } catch (e) {
    console.error('logGoalProgress participant update error', e && e.message ? e.message : e);
  }
  // Determine if we awarded a reward by re-checking goals.reward_item_id
  try {
    if (awardedItem) return { goal_log_id: res.lastID, reward: awardedItem, completed: true };
    // otherwise try to read reward_item_id column if present
    const cols = await all("PRAGMA table_info('goals')");
    const names = (cols || []).map(c => c.name);
    if (names.includes('reward_item_id')) {
      const g = await get('SELECT reward_item_id FROM goals WHERE goal_id = ? LIMIT 1', [goalId]);
      if (g && g.reward_item_id) {
        const item = await get('SELECT id, name, picture, type FROM items WHERE id = ? LIMIT 1', [g.reward_item_id]);
        return { goal_log_id: res.lastID, reward: item, completed: true };
      }
    }
  } catch (e) { /* ignore */ }
  return { goal_log_id: res.lastID };
}

async function getLogsForGoal(goalId, limit = 100) {
  return all('SELECT * FROM goal_logs WHERE goal_id = ? ORDER BY date DESC LIMIT ?', [goalId, limit]);
}

async function setGoalStatus(goalId, status) {
  await run('UPDATE goals SET status = ? WHERE goal_id = ?', [status, goalId]);
  return { ok: true };
}


async function createAvatar(userId, name = 'Hero') {
  const res = await run('INSERT INTO avatars (user_id, name, appearance) VALUES (?, ?, ?)', [userId, name, '']);
  return { id: res.lastID, user_id: userId, name };
}

// Ensure each user has at least one avatar and avatar_id set
async function ensureDefaultAvatars() {
  const users = await all('SELECT id FROM users');
  for (const u of users) {
    const av = await get('SELECT id FROM avatars WHERE user_id = ? LIMIT 1', [u.id]);
    if (!av) {
      const newAv = await createAvatar(u.id, 'Hero' + u.id);
      await run('UPDATE users SET avatar_id = ? WHERE id = ?', [newAv.id, u.id]);
    } else {
      // if user has avatars but avatar_id null, set to first
      const me = await get('SELECT avatar_id FROM users WHERE id = ?', [u.id]);
      if (!me || !me.avatar_id) {
        await run('UPDATE users SET avatar_id = ? WHERE id = ?', [av.id, u.id]);
      }
    }
  }
}

// --- Friends helper functions ---
async function searchUsersByUsername(q) {
  if (!q) return [];
  const like = `%${q}%`;
  return all('SELECT id, username, profile_picture, avatar_id FROM users WHERE username LIKE ? LIMIT 50', [like]);
}

async function sendFriendRequest(fromUserId, toUserId) {
  if (!fromUserId || !toUserId) throw new Error('Missing user ids');
  if (fromUserId === toUserId) throw new Error('Cannot friend yourself');
  // check existing relation
  const existing = await get('SELECT status FROM friends WHERE user_id = ? AND friend_id = ?', [fromUserId, toUserId]);
  if (existing) {
    return { exists: true, status: existing.status };
  }
  await run('INSERT INTO friends (user_id, friend_id, status) VALUES (?, ?, ?)', [fromUserId, toUserId, 'pending']);
  return { created: true };
}

async function acceptFriendRequest(userId, friendId) {
  // userId is the accepter (recipient), friendId is the requester
  const reqRow = await get('SELECT status FROM friends WHERE user_id = ? AND friend_id = ? LIMIT 1', [friendId, userId]);
  if (!reqRow || reqRow.status !== 'pending') return { ok: false, reason: 'no_pending' };
  // mark the original request accepted
  await run('UPDATE friends SET status = ? WHERE user_id = ? AND friend_id = ?', ['accepted', friendId, userId]);
  // ensure reciprocal accepted row exists
  await run('INSERT OR REPLACE INTO friends (user_id, friend_id, status) VALUES (?, ?, ?)', [userId, friendId, 'accepted']);
  return { ok: true };
}

async function getFriendsList(userId) {
  return all(`SELECT u.id, u.username, u.profile_picture, u.avatar_id
    FROM users u JOIN friends f ON f.friend_id = u.id
    WHERE f.user_id = ? AND f.status = ?`, [userId, 'accepted']);
}

async function getPendingRequests(userId) {
  return all(`SELECT u.id, u.username, u.profile_picture, u.avatar_id, f.user_id as requester_id
    FROM users u JOIN friends f ON f.user_id = u.id
    WHERE f.friend_id = ? AND f.status = ?`, [userId, 'pending']);
}

async function unfriend(userId, friendId) {
  if (!userId || !friendId) throw new Error('Missing ids');
  // remove both directions if present
  await run('DELETE FROM friends WHERE user_id = ? AND friend_id = ?', [userId, friendId]);
  await run('DELETE FROM friends WHERE user_id = ? AND friend_id = ?', [friendId, userId]);
  return { ok: true };
}


module.exports = {
  db,
  run,
  get,
  all,
  createUser,
  getUserByUsername,
  createAvatar,
  ensureDefaultAvatars,
  getUserById,
  createNote,
  getNotesByUser,
  getUserByEmail,
  // goals
  createGoal,
  getGoalsByUser,
  getGoalById,
  logGoalProgress,
  getLogsForGoal,
  setGoalStatus,
  // avatars/items helpers
  // returns avatars for a user
  async getAvatarsByUser(userId) {
    // include equipped item (if any) - still return equipment for compatibility
    return all(`SELECT avatars.id, avatars.name, avatars.appearance, avatars.equipment, avatars.head, avatars.body, avatars.hand, avatars.accessory, items.id as item_id, items.name as item_name, items.slot as item_slot, items.picture as item_picture
      FROM avatars LEFT JOIN items ON avatars.equipment = items.id WHERE avatars.user_id = ?`, [userId]);
  },
  async getAvatarById(id) {
    return get('SELECT id, user_id, name, appearance, equipment, head, body, hand, accessory FROM avatars WHERE id = ?', [id]);
  },
  async getItems() {
    return all('SELECT id, name, slot, picture, type FROM items');
  },
  async getInventoryByUser(userId) {
    return all('SELECT inventory.id as inventory_id, items.id as item_id, items.name, items.slot, inventory.qty FROM inventory JOIN items ON inventory.item_id = items.id WHERE inventory.user_id = ?', [userId]);
  },
  // return per-slot equipped items as an object
  async getEquippedByAvatar(avatarId) {
    const row = await get(`SELECT 
      a.id, a.head, a.body, a.hand, a.accessory,
      h.id as head_id, h.name as head_name, h.slot as head_slot, h.picture as head_picture, h.type as head_type,
      b.id as body_id, b.name as body_name, b.slot as body_slot, b.picture as body_picture, b.type as body_type,
      ha.id as hand_id, ha.name as hand_name, ha.slot as hand_slot, ha.picture as hand_picture, ha.type as hand_type,
      ac.id as acc_id, ac.name as acc_name, ac.slot as acc_slot, ac.picture as acc_picture, ac.type as acc_type
      FROM avatars a
      LEFT JOIN items h ON a.head = h.id
      LEFT JOIN items b ON a.body = b.id
      LEFT JOIN items ha ON a.hand = ha.id
      LEFT JOIN items ac ON a.accessory = ac.id
      WHERE a.id = ?`, [avatarId]);
    if (!row) return null;
    const make = (prefix) => {
      if (!row[`${prefix}_id`]) return null;
      return { id: row[`${prefix}_id`], name: row[`${prefix}_name`], slot: row[`${prefix}_slot`], picture: row[`${prefix}_picture`], type: row[`${prefix}_type`] };
    };
    return {
      head: make('head'),
      body: make('body'),
      hand: make('hand'),
      accessory: make('acc')
    };
  },
  async getAccessoryByAvatar(avatarId) {
    return get('SELECT items.id, items.name, items.slot, items.picture, items.type FROM avatars LEFT JOIN items ON avatars.accessory = items.id WHERE avatars.id = ?', [avatarId]);
  },
  // equip item into appropriate avatar column based on item's slot (head/body/hand/accessory)
  async equipItem(avatarId, itemId) {
    const item = await get('SELECT slot FROM items WHERE id = ?', [itemId]);
    if (!item) throw new Error('Item not found');
    const slot = item.slot || 'hand';
    if (slot === 'head') return run('UPDATE avatars SET head = ? WHERE id = ?', [itemId, avatarId]);
    if (slot === 'body') return run('UPDATE avatars SET body = ? WHERE id = ?', [itemId, avatarId]);
    if (slot === 'hand') return run('UPDATE avatars SET hand = ? WHERE id = ?', [itemId, avatarId]);
    if (slot === 'accessory') return run('UPDATE avatars SET accessory = ? WHERE id = ?', [itemId, avatarId]);
    // fallback: set hand
    return run('UPDATE avatars SET hand = ? WHERE id = ?', [itemId, avatarId]);
  },
  // unequip by slot name
  async unequipItem(avatarId, slot = 'hand') {
    if (slot === 'head') return run('UPDATE avatars SET head = NULL WHERE id = ?', [avatarId]);
    if (slot === 'body') return run('UPDATE avatars SET body = NULL WHERE id = ?', [avatarId]);
    if (slot === 'hand') return run('UPDATE avatars SET hand = NULL WHERE id = ?', [avatarId]);
    if (slot === 'accessory') return run('UPDATE avatars SET accessory = NULL WHERE id = ?', [avatarId]);
    if (slot === 'equipment') return run('UPDATE avatars SET equipment = NULL WHERE id = ?', [avatarId]);
    return run('UPDATE avatars SET head = NULL, body = NULL, hand = NULL, accessory = NULL WHERE id = ?', [avatarId]);
  }
  ,
  // unequip all slots (head/body/hand/accessory/equipment)
  async unequipAll(avatarId) {
    return run('UPDATE avatars SET head = NULL, body = NULL, hand = NULL, accessory = NULL, equipment = NULL WHERE id = ?', [avatarId]);
  }
  ,
  // friends
  searchUsersByUsername,
  sendFriendRequest,
  acceptFriendRequest,
  getFriendsList,
  getPendingRequests
  ,
  unfriend
};
