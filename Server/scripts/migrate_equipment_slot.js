const db = require('../db');

(async () => {
  try {
    const rows = await db.all('SELECT id, equipment FROM avatars WHERE equipment IS NOT NULL');
    for (const r of rows) {
      try {
        const item = await db.get('SELECT id, slot FROM items WHERE id = ?', [r.equipment]);
        if (!item) continue;
        const slot = item.slot || 'hand';
        if (slot === 'head') await db.run('UPDATE avatars SET head = ? WHERE id = ?', [item.id, r.id]);
        else if (slot === 'body') await db.run('UPDATE avatars SET body = ? WHERE id = ?', [item.id, r.id]);
        else if (slot === 'hand') await db.run('UPDATE avatars SET hand = ? WHERE id = ?', [item.id, r.id]);
        else if (slot === 'accessory') await db.run('UPDATE avatars SET accessory = ? WHERE id = ?', [item.id, r.id]);
        // clear the old equipment column
        await db.run('UPDATE avatars SET equipment = NULL WHERE id = ?', [r.id]);
        console.log('migrated avatar', r.id, 'equipment', item.id, 'to', slot);
      } catch (e) { console.error('row migration error', r.id, e && e.message ? e.message : e); }
    }
    console.log('migration complete');
  } catch (e) { console.error('migration failed', e && e.message ? e.message : e); }
  process.exit(0);
})();
