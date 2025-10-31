// notes seeding moved out of db.js (example notes)
module.exports = async function seedNotes(run) {
  try {
    // Example notes for testing; idempotent via INSERT OR IGNORE on a combination isn't available easily here,
    // so we insert a simple note for user 1 only if they don't already have any notes.
    const row = await new Promise((resolve) => {
      run('SELECT id FROM notes WHERE user_id = ? LIMIT 1', [1]).then((r) => resolve(r)).catch(() => resolve(null));
    });
    if (!row) {
      await run('INSERT INTO notes (user_id, content) VALUES (?, ?)', [1, 'Welcome to your notes!']);
    }
  } catch (e) {
    console.error('seed_notes error', e && e.message ? e.message : e);
  }
};
