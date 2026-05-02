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
      ['L&L Cafe Burger', 'Foods', 'Signature house burger.', 100.00, 'temp.png'],
      ['Cheese Burger', 'Foods', 'Classic cheeseburger.', 115.00, 'temp.png'],
      ['Double Cheese Burger', 'Foods', 'Double patty, double cheese.', 140.00, 'temp.png'],
      ['Red Pesto Pasta', 'Foods', 'Rich tomato pesto pasta.', 120.00, 'temp.png'],
      ['Creamy Carbonara', 'Foods', 'Creamy white sauce pasta.', 100.00, 'temp.png'],
      ['Plain Fries', 'Foods', 'Crispy fries.', 70.00, 'temp.png'],
      ['Cheese Stick', 'Foods', 'Fried mozzarella sticks.', 130.00, 'temp.png'],
      ['Loaded Beef Fries', 'Foods', 'Fries with beef toppings.', 160.00, 'temp.png'],

      // PARTY TRAY
      ['Red Pesto Pasta (Half Tray)', 'Party Tray', 'Good for small group.', 700.00, 'temp.png'],
      ['Red Pesto Pasta (Full Tray)', 'Party Tray', 'Good for large group.', 1200.00, 'temp.png'],
      ['Creamy Carbonara (Half Tray)', 'Party Tray', 'Good for small group.', 550.00, 'temp.png'],
      ['Creamy Carbonara (Full Tray)', 'Party Tray', 'Good for large group.', 1000.00, 'temp.png'],
      ['Chicken Wings (30 pcs)', 'Party Tray', 'Party wings set.', 820.00, 'temp.png'],
      ['Chicken Wings (40 pcs)', 'Party Tray', 'Party wings set.', 1090.00, 'temp.png'],
      ['Chicken Wings (50 pcs)', 'Party Tray', 'Party wings set.', 1350.00, 'temp.png'],

      // WAFFLES
      ['Plain Belgian Waffle', 'Waffles', 'Classic waffle.', 60.00, 'temp.png'],
      ['Nutella Waffle', 'Waffles', 'Waffle with Nutella.', 80.00, 'temp.png'],
      ['S’mores Waffle', 'Waffles', 'Chocolate marshmallow waffle.', 80.00, 'temp.png'],
      ['Bubble Waffle Classic', 'Waffles', 'Hong Kong style waffle.', 85.00, 'temp.png'],
      ['Bubble Waffle Oreo', 'Waffles', 'With Oreo toppings.', 100.00, 'temp.png'],
      ['Bubble Waffle KitKat Oreo', 'Waffles', 'Loaded waffle combo.', 120.00, 'temp.png'],

      // COFFEE
      ['Iced Coffee', 'Coffee', 'Refreshing iced coffee.', 70.00, 'temp.png'],
      ['Caramel Latte', 'Coffee', 'Sweet caramel espresso.', 80.00, 'temp.png'],
      ['Iced Mocha', 'Coffee', 'Chocolate coffee blend.', 80.00, 'temp.png'],

      // NON-COFFEE
      ['Strawberry Milk', 'Non-Coffee', 'Sweet strawberry drink.', 95.00, 'temp.png'],
      ['Mango Milk', 'Non-Coffee', 'Fresh mango milk.', 95.00, 'temp.png'],
      ['Oreo Milk', 'Non-Coffee', 'Cookies and cream drink.', 95.00, 'temp.png'],
      ['Matcha Milk', 'Non-Coffee', 'Japanese matcha drink.', 100.00, 'temp.png'],

      // FRAPPE
      ['Banana Frappe', 'Frappe', 'Blended banana drink.', 110.00, 'temp.png'],
      ['Peach Frappe', 'Frappe', 'Sweet peach blend.', 120.00, 'temp.png'],
      ['Mango Frappe', 'Frappe', 'Tropical mango drink.', 120.00, 'temp.png'],
      ['Oreo Frappe', 'Frappe', 'Cookies blended frappe.', 130.00, 'temp.png'],
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