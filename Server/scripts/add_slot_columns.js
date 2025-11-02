const sqlite3 = require('sqlite3').verbose();
const db = new sqlite3.Database('data.db');

db.serialize(() => {
  db.all("PRAGMA table_info('avatars')", (err, rows) => {
    if (err) { console.error(err); process.exit(1); }
    const names = rows.map(r => r.name);
    const tasks = [];
    if (!names.includes('head')) tasks.push(cb => db.run("ALTER TABLE avatars ADD COLUMN head INTEGER", cb));
    if (!names.includes('body')) tasks.push(cb => db.run("ALTER TABLE avatars ADD COLUMN body INTEGER", cb));
    if (!names.includes('hand')) tasks.push(cb => db.run("ALTER TABLE avatars ADD COLUMN hand INTEGER", cb));
    if (!names.includes('accessory')) tasks.push(cb => db.run("ALTER TABLE avatars ADD COLUMN accessory INTEGER", cb));
    if (tasks.length === 0) { console.log('slot columns already present'); db.close(()=>process.exit(0)); return; }
    let i = 0;
    const next = (err) => {
      if (err) { console.error('alter failed', err); db.close(()=>process.exit(1)); return; }
      i += 1;
      if (i >= tasks.length) { console.log('added slot columns'); db.close(()=>process.exit(0)); return; }
      tasks[i](next);
    };
    // run first
    tasks[0](next);
  });
});
