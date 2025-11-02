const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('data.db');

db.serialize(() => {
  db.all("PRAGMA table_info('avatars')", (err, rows) => {
    if (err) { console.error(err); process.exit(1); }
    const names = rows.map(r => r.name);
    if (!names.includes('accessory')) {
      db.run("ALTER TABLE avatars ADD COLUMN accessory INTEGER", (err) => {
        if (err) { console.error('alter failed', err); process.exit(1); }
        console.log('added accessory column to avatars');
        db.close(() => process.exit(0));
      });
    } else {
      console.log('accessory column already present');
      db.close(() => process.exit(0));
    }
  });
});
