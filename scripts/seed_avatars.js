// seeds and migrations related to avatars moved out of db.js
module.exports = async function seedAvatars(run, get, all, addColumnIfNotExistsTable) {
  try {
    // Ensure per-slot columns exist
    await addColumnIfNotExistsTable('avatars', 'equipment', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'head', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'body', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'hand', 'INTEGER');
    await addColumnIfNotExistsTable('avatars', 'accessory', 'INTEGER');

    // Insert avatars (idempotent)
    await run("INSERT OR IGNORE INTO avatars (id, user_id, name, appearance) VALUES (1, 1, 'Hero1', '')");
    await run("INSERT OR IGNORE INTO avatars (id, user_id, name, appearance) VALUES (2, 1, 'Hero2', '')");
    await run("INSERT OR IGNORE INTO avatars (id, user_id, name, appearance) VALUES (3, 2, 'Hero3', '')");

    // Migrate old single 'equipment' value into head if head is null (idempotent)
    try {
      const rows = await all('SELECT id, equipment, head, body, hand FROM avatars');
      for (const r of rows) {
        if ((r.equipment || r.equipment === 0) && !r.head && !r.body && !r.hand) {
          await run('UPDATE avatars SET head = ? WHERE id = ?', [r.equipment, r.id]);
          // clear equipment for compatibility
          await run('UPDATE avatars SET equipment = NULL WHERE id = ?', [r.id]);
        }
      }
    } catch (e) {
      // ignore migration errors
      console.error('seed_avatars: migration warning', e && e.message ? e.message : e);
    }

    // seed some example slot equips: give avatar 1 head = 1, avatar 2 head = 2 (if not set)
    await run("UPDATE avatars SET head = 1 WHERE id = 1 AND (head IS NULL OR head = 0)");
    await run("UPDATE avatars SET head = 2 WHERE id = 2 AND (head IS NULL OR head = 0)");
    // give avatar 1 an accessory (magic ring item id 5) for testing if not set
    await run("UPDATE avatars SET accessory = 5 WHERE id = 1 AND (accessory IS NULL OR accessory = 0)");

    // Ensure every user has an active avatar (set to their first avatar if null)
    await run("UPDATE users SET avatar_id = (SELECT id FROM avatars WHERE avatars.user_id = users.id LIMIT 1) WHERE avatar_id IS NULL");
  } catch (e) {
    console.error('seed_avatars error', e && e.message ? e.message : e);
  }
};
