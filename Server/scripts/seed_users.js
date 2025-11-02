// users seeding moved out of db.js
module.exports = async function seedUsers(run) {
  try {
    // Insert two users (use IGNORE to not duplicate)
    await run("INSERT OR IGNORE INTO users (id, username, password, email) VALUES (1, 'player1', 'changeme', 'p1@example.com')");
    await run("INSERT OR IGNORE INTO users (id, username, password, email) VALUES (2, 'player2', 'changeme', 'p2@example.com')");
  } catch (e) {
    console.error('seed_users error', e && e.message ? e.message : e);
  }
};
