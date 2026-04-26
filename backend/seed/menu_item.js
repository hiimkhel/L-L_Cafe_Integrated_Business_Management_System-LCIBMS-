const pool = require('../config/dbConnection');

const seedMenu = async () => {
  try {
    console.log('Starting menu seeding...');

    // 1. Clear existing data (DEV ONLY)
    await pool.query('DELETE FROM menu_items');
    await pool.query('DELETE FROM menu_categories');

    console.log('Old data cleared');

    // 2. Seed Categories
    const categories = [
      'Foods',
      'Party Tray',
      'Waffles',
      'Coffee',
      'Non-Coffee',
      'Frappe'
    ];

    const categoryInsertQuery = `INSERT INTO menu_categories (name) VALUES (?)`;

    for (const name of categories) {
      await pool.query(categoryInsertQuery, [name]);
    }

    console.log('Categories seeded');

    // 3. Fetch category IDs
    const [rows] = await pool.query('SELECT * FROM menu_categories');

    const categoryMap = {};
    rows.forEach(cat => {
      categoryMap[cat.name] = cat.id;
    });

    // 4. Seed Menu Items
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

    const itemInsertQuery = `
      INSERT INTO menu_items (name, category_id, description, price, image_url)
      VALUES (?, ?, ?, ?, ?)
    `;

    for (const item of items) {
      const [name, categoryName, description, price, imageUrl] = item;

      const categoryId = categoryMap[categoryName];

      if (!categoryId) {
        console.warn(`Category not found: ${categoryName}`);
        continue;
      }

      await pool.query(itemInsertQuery, [
        name,
        categoryId,
        description,
        price,
        imageUrl
      ]);
    }

    console.log('Menu items seeded successfully!');
    console.log('Seeding completed!');

    process.exit(0);

  } catch (error) {
    console.error('Seeding failed:', error.message);
    process.exit(1);
  }
};

seedMenu();