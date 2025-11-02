(async () => {
  try {
    const bcrypt = require('bcrypt');
    const db = require('../db');
    const hash = await bcrypt.hash('changeme', 10);
    await db.run('UPDATE users SET password = ? WHERE id IN (1,2)', [hash]);
    console.log('updated passwords for users 1 and 2');
  } catch (e) {
    console.error('error updating passwords', e && e.message ? e.message : e);
  } finally { process.exit(0); }
})();
