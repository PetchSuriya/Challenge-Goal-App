// Creates the DB schema (CREATE TABLE IF NOT EXISTS...) in a single place
// This module exports an async function that accepts a sqlite3 Database `db` and
// runs the statements sequentially. It uses the raw db.run API internally so
// it can be invoked before the promisified helpers are defined.
module.exports = async function createSchema(db) {
  const runAsync = (sql) => new Promise((resolve, reject) => {
    db.run(sql, (err) => err ? reject(err) : resolve());
  });

  // Run statements sequentially
  try {
    await runAsync(`CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT,
      email TEXT,
      profile_picture TEXT,
      gender TEXT,
      birthday TEXT
    )`);

    await runAsync(`CREATE TABLE IF NOT EXISTS notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      content TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id)
    )`);

    await runAsync(`CREATE TABLE IF NOT EXISTS avatars (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      name TEXT,
      appearance TEXT,
      equipment INTEGER,
      head INTEGER,
      body INTEGER,
      hand INTEGER,
      accessory INTEGER,
      FOREIGN KEY(user_id) REFERENCES users(id)
    )`);

    await runAsync(`CREATE TABLE IF NOT EXISTS items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      slot TEXT,
      picture TEXT,
      type TEXT
    )`);

    await runAsync(`CREATE TABLE IF NOT EXISTS inventory (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      item_id INTEGER,
      qty INTEGER DEFAULT 1,
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(item_id) REFERENCES items(id)
    )`);

    // Goals table: stores user goals and their current progress/status
    await runAsync(`CREATE TABLE IF NOT EXISTS goals (
      goal_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      duration TEXT,
      category TEXT,
      type TEXT,
      friend_id INTEGER,
      status TEXT DEFAULT 'ongoing',
      start_date TEXT,
      progress_days INTEGER DEFAULT 0,
      last_completed_at TEXT,
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(friend_id) REFERENCES users(id)
    )`);

    // Goal_logs table: record of daily/periodic progress for goals
    await runAsync(`CREATE TABLE IF NOT EXISTS goal_logs (
      goal_log_id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      description TEXT,
      date TEXT DEFAULT (date('now')),
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY(goal_id) REFERENCES goals(goal_id),
      FOREIGN KEY(user_id) REFERENCES users(id)
    )`);

    // Goal participants: per-user progress for collaborative goals (and owner)
    await runAsync(`CREATE TABLE IF NOT EXISTS goal_participants (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      user_id INTEGER NOT NULL,
      progress_days INTEGER DEFAULT 0,
      last_completed_at TEXT,
      UNIQUE(goal_id, user_id),
      FOREIGN KEY(goal_id) REFERENCES goals(goal_id),
      FOREIGN KEY(user_id) REFERENCES users(id)
    )`);

    await runAsync(`CREATE TABLE IF NOT EXISTS avatar_items (
      avatar_id INTEGER,
      item_id INTEGER,
      PRIMARY KEY (avatar_id, item_id),
      FOREIGN KEY(avatar_id) REFERENCES avatars(id),
      FOREIGN KEY(item_id) REFERENCES items(id)
    )`);

    await runAsync(`CREATE TABLE IF NOT EXISTS friends (
      user_id INTEGER,
      friend_id INTEGER,
      status TEXT DEFAULT 'pending',
      PRIMARY KEY (user_id, friend_id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(friend_id) REFERENCES users(id)
    )`);
  } catch (err) {
    console.error('createSchema error', err && err.message ? err.message : err);
    throw err;
  }
};
