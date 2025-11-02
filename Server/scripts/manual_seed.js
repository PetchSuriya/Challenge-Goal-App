const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('data.db');

db.serialize(() => {
  db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (6,'Steel Dagger','hand','dagger.png','weapon')");
  db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (7,'Cloth Hat','head','clothhat.png','armor')");
  db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (8,'Chainmail','body','chainmail.png','armor')");
  db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (9,'Tower Shield','hand','towershield.png','shield')");
  db.run("INSERT OR IGNORE INTO items (id,name,slot,picture,type) VALUES (10,'Amulet of Health','accessory','amulet.png','accessory')");
  // ensure inventory ownership for user 1
  for (let iid = 1; iid <= 10; iid++) {
    db.get('SELECT id FROM inventory WHERE user_id = ? AND item_id = ? LIMIT 1', [1, iid], (err, row) => {
      if (err) return console.error('check inventory err', err);
      if (!row) db.run('INSERT INTO inventory (user_id, item_id, qty) VALUES (?, ?, ?)', [1, iid, 1]);
    });
  }
});

db.close(() => console.log('manual_seed done'));
