(async () => {
  try {
    const db = require('../db');
    // Insert items 6..10
    await db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (6,'Steel Dagger','hand','dagger.png','weapon')");
    await db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (7,'Cloth Hat','head','clothhat.png','armor')");
    await db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (8,'Chainmail','body','chainmail.png','armor')");
    await db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (9,'Tower Shield','hand','towershield.png','shield')");
    await db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (10,'Amulet of Health','accessory','amulet.png','accessory')");

    for (let iid = 1; iid <= 10; iid++) {
      const exists = await db.get('SELECT id FROM inventory WHERE user_id = ? AND item_id = ? LIMIT 1', [1, iid]);
      if (!exists) await db.run('INSERT INTO inventory (user_id, item_id, qty) VALUES (?, ?, ?)', [1, iid, 1]);
    }

    const items = await db.getItems();
    console.log('items count', items.length);
    const inv = await db.getInventoryByUser(1);
    console.log('user1 inventory count', inv.length);
    console.log(JSON.stringify(inv, null, 2));
  } catch (e) {
    console.error('manual seed error', e && e.message ? e.message : e);
  } finally {
    process.exit(0);
  }
})();
