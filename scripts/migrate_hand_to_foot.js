const db = require('../db');

(async () => {
  try {
    console.log('Migrating shoe items stored in avatars.hand to avatars.foot (if item.slot = "foot")');
    // show rows that will be affected
    const rows = await db.all(`SELECT a.id as avatar_id, a.hand as hand_item_id, i.slot as item_slot, i.name as item_name
      FROM avatars a JOIN items i ON a.hand = i.id WHERE i.slot = 'foot'`);
    if (!rows || rows.length === 0) {
      console.log('No avatars with hand referencing foot items found. Nothing to do.');
      process.exit(0);
    }
    console.log('About to migrate the following avatar rows:');
    for (const r of rows) console.log(` avatar ${r.avatar_id} hand_item=${r.hand_item_id} (${r.item_name})`);

    // Run migration
    await db.run("UPDATE avatars SET foot = hand WHERE hand IS NOT NULL AND EXISTS (SELECT 1 FROM items WHERE items.id = avatars.hand AND items.slot = 'foot')");
    await db.run("UPDATE avatars SET hand = NULL WHERE foot IS NOT NULL AND EXISTS (SELECT 1 FROM items WHERE items.id = avatars.foot AND items.slot = 'foot')");
    console.log('Migration applied. You may want to inspect avatars table to verify.');
  } catch (e) {
    console.error('Migration failed', e && e.message ? e.message : e);
    process.exit(1);
  }
  process.exit(0);
})();
