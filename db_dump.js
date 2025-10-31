const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const db = new sqlite3.Database(path.join(__dirname, 'data.db'));

db.serialize(() => {
  console.log('Users:');
  db.each('SELECT id, username FROM users', (err, row) => {
    if (err) return console.error(err);
    console.log(row);
  }, () => {
    console.log('Notes:');
    db.each('SELECT id, user_id, content FROM notes', (err, row) => {
      if (err) return console.error(err);
      console.log(row);
    }, () => db.close());
  });
});
