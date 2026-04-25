const pool = require('../config/dbConnection');

const seedMenuItems = async () => {
  try {
    console.log('Seeding menu items...');

    // Optional: clear existing data (use carefully in dev only)
    await pool.query('DELETE FROM menu_items');

    const items = [
      ['Chicken Burger', 'Foods', 'This is a description.', 199.00, 'temp.png'],
      ['Cheese Burger', 'Foods', 'This is a description.', 199.00, 'temp.png'],
      ['Hawaiian Burger', 'Foods', 'This is a description.', 199.00, 'temp.png'],

      ['Barkada Platter', 'Party Tray', 'Good for 5–6 persons.', 599.00, 'temp.png'],

      ['Classic Waffle', 'Waffles', 'Crispy golden waffle.', 149.00, 'temp.png'],
      ['Choco Waffle', 'Waffles', 'With rich chocolate drizzle.', 169.00, 'temp.png'],

      ['Americano', 'Coffee', 'Bold and smooth espresso.', 99.00, 'temp.png'],
      ['Cappuccino', 'Coffee', 'Espresso with steamed milk.', 119.00, 'temp.png'],

      ['Matcha Latte', 'Non-Coffee', 'Premium Japanese matcha.', 129.00, 'temp.png'],

      ['Mocha Frappe', 'Frappe', 'Chilled mocha bliss.', 139.00, 'temp.png'],
      ['Caramel Frappe', 'Frappe', 'Sweet caramel swirls.', 139.00, 'temp.png'],
    ];

    const query = `
      INSERT INTO menu_items (name, category, description, price, imageUrl)
      VALUES (?, ?, ?, ?, ?)
    `;

    for (const item of items) {
      await pool.query(query, item);
    }

    console.log('✅ Menu items seeded successfully!');
    process.exit(0);

  } catch (error) {
    console.error('❌ Seeding failed:', error.message);
    process.exit(1);
  }
};

seedMenuItems();