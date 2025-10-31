// inventory seeding moved out of db.js
module.exports = async function seedInventory(run, get) {
  try {
    // Give inventory items to users (idempotent via INSERT OR IGNORE)
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (1, 1, 1, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (2, 1, 2, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (3, 1, 3, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (4, 1, 4, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (5, 1, 5, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (6, 1, 6, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (7, 1, 7, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (8, 1, 8, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (9, 1, 9, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (10, 1, 10, 1)");
    // Keep a couple items for user 2 as well
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (11, 2, 4, 1)");
    await run("INSERT OR IGNORE INTO inventory (id, user_id, item_id, qty) VALUES (12, 2, 5, 1)");

    // Ensure idempotently that user 1 owns items 1..10 (use SELECT then INSERT to avoid id conflicts)
    for (let iid = 1; iid <= 10; iid++) {
      try {
        const exists = await get('SELECT id FROM inventory WHERE user_id = ? AND item_id = ? LIMIT 1', [1, iid]);
        if (!exists) {
          await run('INSERT INTO inventory (user_id, item_id, qty) VALUES (?, ?, ?)', [1, iid, 1]);
        }
      } catch (e) {
        // ignore non-fatal per-item failures
        console.error('seed_inventory: ensure inventory for user1 item', iid, e && e.message ? e.message : e);
      }
    }
  } catch (e) {
    console.error('seed_inventory error', e && e.message ? e.message : e);
  }
};
