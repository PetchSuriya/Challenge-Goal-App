// seeds for items moved out of db.js
module.exports = async function seedItems(run, get, all, addColumnIfNotExistsTable) {
  try {
    // Ensure items table has picture/type columns before seeding
    await addColumnIfNotExistsTable('items', 'picture', 'TEXT');
    await addColumnIfNotExistsTable('items', 'type', 'TEXT');

    // Insert items (idempotent)
    const items = [
      { id: 1, name: 'Wooden Sword', slot: 'hand', picture: 'sword.png', type: 'weapon' },
      { id: 2, name: 'Iron Helmet', slot: 'head', picture: 'helmet.png', type: 'armor' },
      { id: 3, name: 'Leather Armor', slot: 'body', picture: 'armor.png', type: 'armor' },
      { id: 4, name: 'Wooden Shield', slot: 'hand', picture: 'shield.png', type: 'shield' },
      { id: 5, name: 'Magic Ring', slot: 'accessory', picture: 'ring.png', type: 'accessory' },
      { id: 6, name: 'Steel Dagger', slot: 'hand', picture: 'dagger.png', type: 'weapon' },
      { id: 7, name: 'Cloth Hat', slot: 'head', picture: 'clothhat.png', type: 'armor' },
      { id: 8, name: 'Chainmail', slot: 'body', picture: 'chainmail.png', type: 'armor' },
      { id: 9, name: 'Tower Shield', slot: 'hand', picture: 'towershield.png', type: 'shield' },
      { id: 10, name: 'Amulet of Health', slot: 'accessory', picture: 'amulet.png', type: 'accessory' },
      { id: 11, name: 'White Hat', slot: 'head', picture: 'White_hat.png', type: 'hat' },
      { id: 12, name: 'Green Hat', slot: 'head', picture: 'Green_hat.png', type: 'hat' },
      { id: 13, name: 'Red Hat', slot: 'head', picture: 'Red_hat.png', type: 'hat' },
      { id: 14, name: 'Black Suit', slot: 'body', picture: 'Black_suit.png', type: 'suit' },
      { id: 15, name: 'Blue Suit', slot: 'body', picture: 'Blue_suit.png', type: 'suit' },
      { id: 16, name: 'Brown Suit', slot: 'body', picture: 'Brown_suit.png', type: 'suit' },
      { id: 17, name: 'Grey Shoes', slot: 'foot', picture: 'Grey_shoes.png', type: 'shoes' },
      { id: 18, name: 'Blue Shoes', slot: 'foot', picture: 'Blue_shoes.png', type: 'shoes' },
      { id: 19, name: 'Brown Shoes', slot: 'foot', picture: 'Brown_shoes.png', type: 'shoes' },
    ];

    for (const it of items) {
      try {
        await run(
          "INSERT OR IGNORE INTO items (id, name, slot, picture, type) VALUES (?, ?, ?, ?, ?)",
          [it.id, it.name, it.slot, it.picture, it.type]
        );
      } catch (e) {
        // non-fatal per-item
        console.error('seed_items: failed to insert', it, e && e.message ? e.message : e);
      }
    }
  } catch (e) {
    console.error('seed_items error', e && e.message ? e.message : e);
  }
};
