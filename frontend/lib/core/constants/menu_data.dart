class MenuData {
  static const List<String> categories = [
    'Foods',
    'Party Tray',
    'Waffles',
    'Coffee',
    'Non-Coffee',
    'Frappe',
  ];

  static final Map<String, List<Map<String, String>>> itemsByCategory = {
    'Foods': [
      {
        'name': 'Chicken Burger',
        'price': '₱199.00',
        'desc': 'This is a description.',
      },
      {
        'name': 'Cheese Burger',
        'price': '₱199.00',
        'desc': 'This is a description.',
      },
      {
        'name': 'Hawaiian Burger',
        'price': '₱199.00',
        'desc': 'This is a description.',
      },
    ],
    'Party Tray': [
      {
        'name': 'Barkada Platter',
        'price': '₱599.00',
        'desc': 'Good for 5–6 persons.',
      },
    ],
    'Waffles': [
      {
        'name': 'Classic Waffle',
        'price': '₱149.00',
        'desc': 'Crispy golden waffle.',
      },
      {
        'name': 'Choco Waffle',
        'price': '₱169.00',
        'desc': 'With rich chocolate drizzle.',
      },
    ],
    'Coffee': [
      {
        'name': 'Americano',
        'price': '₱99.00',
        'desc': 'Bold and smooth espresso.',
      },
      {
        'name': 'Cappuccino',
        'price': '₱119.00',
        'desc': 'Espresso with steamed milk.',
      },
    ],
    'Non-Coffee': [
      {
        'name': 'Matcha Latte',
        'price': '₱129.00',
        'desc': 'Premium Japanese matcha.',
      },
    ],
    'Frappe': [
      {
        'name': 'Mocha Frappe',
        'price': '₱139.00',
        'desc': 'Chilled mocha bliss.',
      },
      {
        'name': 'Caramel Frappe',
        'price': '₱139.00',
        'desc': 'Sweet caramel swirls.',
      },
    ],
  };
}
