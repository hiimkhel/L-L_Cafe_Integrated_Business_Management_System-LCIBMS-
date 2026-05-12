const pool = require('../config/dbConnection');

const seedMenu = async () => {
  try {
    console.log('Starting menu seeding...');

    // 1. Clear existing data (DEV ONLY)
    await pool.query('DELETE FROM order_items');
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
      // FOODS
      ['L&L Cafe Burger', 'Foods', 'Signature house burger.', 95.00, 'lnl-cafe-burger.jpg'],
      ['Cheese Burger', 'Foods', 'Double patty, double cheese.', 110.00, 'double-cheese-burger.jpg'],
      ['Lechon Sauce Chicken Wings', 'Foods', 'Rich tomato pesto pasta.', 160.00, 'lechon-chicken-wings.jpg'],  
      ['Red Pesto Pasta', 'Foods', 'Rich tomato pesto pasta.', 120.00, 'red-pesto.jpg'],
      ['Creamy Carbonara', 'Foods', 'Creamy white sauce pasta.', 100.00, 'creamy-carbonara.jpg'],
      ['Cheese Stick', 'Foods', 'Fried mozzarella sticks.', 130.00, 'mozarella-sticks.jpg'],
      ['Loaded Fries', 'Foods', 'Fries with chicken toppings.', 150.00, 'loaded-fries.jpg'],

      // PARTY TRAY
      ['Creamy Carbonara (Half Tray)', 'Party Tray', 'Good for small group.', 550.00, 'creamy-carbonara-tray.jpg'],
      ['Creamy Carbonara (Full Tray)', 'Party Tray', 'Good for large group.', 1000.00, 'creamy-carbonara-tray.jpg'],
      ['Chicken Wings (30 pcs)', 'Party Tray', 'Party wings set.', 820.00, 'chicken-wings-tray.jpg'],
      ['Chicken Wings (40 pcs)', 'Party Tray', 'Party wings set.', 1090.00, 'chicken-wings-tray.jpg'],
      ['Chicken Wings (50 pcs)', 'Party Tray', 'Party wings set.', 1350.00, 'chicken-wings-tray.jpg'],

      // WAFFLES
      ['Chocolate Waffle', 'Waffles', 'Chocolate marshmallow waffle.', 80.00, 'chocolate-waffle.jpg'],
      ['Bubble Waffle Caramel Cookie', 'Waffles', 'Hong Kong style waffle.', 85.00, 'caramel-cookie-waffle.jpg'],
      ['Bubble Waffle Biscoff', 'Waffles', 'With Oreo toppings.', 100.00, 'biscoff-waffle.jpg'],
      ['Bubble Waffle KitKat Oreo', 'Waffles', 'Loaded waffle combo.', 120.00, 'kitkat-oreo-waffle.jpg'],

      // COFFEE
      ['Iced Coffee', 'Coffee', 'Refreshing iced coffee.', 60.00, 'iced-latte.jpg'],
      ['Spanish Latte', 'Coffee', 'Sweet caramel espresso.', 75.00, 'spanish-latte.jpg'],

      // NON-COFFEE
      ['Strawberry Milk', 'Non-Coffee', 'Sweet strawberry drink.', 95.00, 'strawberry-milk.jpg'],
      ['Biscoff Drink', 'Non-Coffee', 'Fresh mango milk.', 95.00, 'biscoff-drink.jpg'],
      ['Oreo Milk', 'Non-Coffee', 'Cookies and cream drink.', 95.00, 'oreo-milk.jpg'],
      ['Mango Milk', 'Non-Coffee', 'Japanese matcha drink.', 100.00, 'mango-milk.jpg'],

      // FRAPPE
      ['Choco Chips Frappe', 'Frappe', 'Sweet peach blend.', 120.00, 'choco-chips-frappe.jpg'],
      ['Nutella Frappe', 'Frappe', 'Tropical mango drink.', 120.00, 'nutella-frappe.jpg'],
      ['Red Velvet Frappe', 'Frappe', 'Cookies blended frappe.', 130.00, 'red-velvet.jpg'],
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