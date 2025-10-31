const seedUsers = require('./seed_users');
const seedItems = require('./seed_items');
const seedAvatars = require('./seed_avatars');
const seedInventory = require('./seed_inventory');
const seedNotes = require('./seed_notes');

module.exports = async function seedAll(run, get, all, addColumnIfNotExistsTable) {
  // Run in a safe, sequential order: users -> items -> avatars -> inventory -> notes
  try {
    await seedUsers(run, get, all, addColumnIfNotExistsTable);
    await seedItems(run, get, all, addColumnIfNotExistsTable);
    await seedAvatars(run, get, all, addColumnIfNotExistsTable);
    await seedInventory(run, get, all, addColumnIfNotExistsTable);
    await seedNotes(run, get, all, addColumnIfNotExistsTable);
  } catch (e) {
    console.error('seed_all error', e && e.message ? e.message : e);
  }
};
