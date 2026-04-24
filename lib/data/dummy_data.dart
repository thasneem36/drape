// ─────────────────────────────────────────────────────────────
// Dummy data — mirrors drape-data.jsx 1:1.
// ─────────────────────────────────────────────────────────────

import 'models.dart';

class DummyData {
  DummyData._();

  static const user = (
    name: 'Mohammed Thasneem',
    firstName: 'Thasneem',
    email: 'thasneem@email.com',
    phone: '+94 077 123 4567',
    address: '142 thaika, Sammanthurai, 03',
    initials: 'mt',
  );

  static const categories = <({String id, String name})>[
    (id: 'all', name: 'All'),
    (id: 'women', name: 'Women'),
    (id: 'men', name: 'Men'),
    (id: 'kids', name: 'Kids'),
    (id: 'access', name: 'Accessories'),
    (id: 'sale', name: 'Sale'),
  ];

  static const products = <Product>[
    Product(
      id: 'p_001',
      name: 'Silk Wrap Dress',
      brand: 'Drape Studio',
      price: 189,
      cat: 'Women',
      desc:
          'A fluid silk wrap dress with a flattering silhouette, perfect for any occasion. Made from 100% pure silk with a lightweight feel.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: ['Black', 'Beige', 'Dusty Rose'],
      rating: 4.8,
      reviews: 128,
      isNew: true,
      tint: [0xFF1C1A18, 0xFF3A322C],
      art: 'silk dress',
    ),
    Product(
      id: 'p_002',
      name: 'Linen Blazer',
      brand: 'Drape Studio',
      price: 245,
      cat: 'Women',
      desc:
          'A tailored linen blazer with clean lines and a modern fit. Versatile enough for office or casual wear.',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['White', 'Camel', 'Navy'],
      rating: 4.6,
      reviews: 94,
      tint: [0xFFE8DFD0, 0xFFC8B89C],
      art: 'linen blazer',
    ),
    Product(
      id: 'p_003',
      name: 'Slim Fit Chinos',
      brand: 'Drape Men',
      price: 120,
      cat: 'Men',
      desc:
          'Classic slim fit chinos crafted from stretch cotton for all-day comfort.',
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      colors: ['Khaki', 'Olive', 'Navy'],
      rating: 4.5,
      reviews: 76,
      tint: [0xFF9C8E6E, 0xFF6E6142],
      art: 'chinos',
    ),
    Product(
      id: 'p_004',
      name: 'Cotton Oxford Shirt',
      brand: 'Drape Men',
      price: 95,
      cat: 'Men',
      desc: 'A classic oxford shirt in premium cotton with a relaxed fit.',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['White', 'Light Blue', 'Pink'],
      rating: 4.7,
      reviews: 112,
      isNew: true,
      tint: [0xFFDCE6EE, 0xFFA9BBCD],
      art: 'oxford shirt',
    ),
    Product(
      id: 'p_005',
      name: 'Floral Sundress',
      brand: 'Drape Kids',
      price: 65,
      cat: 'Kids',
      desc:
          'A bright floral sundress for little ones, made from soft breathable cotton.',
      sizes: ['3-4Y', '5-6Y', '7-8Y', '9-10Y'],
      colors: ['Pink', 'Yellow', 'Blue'],
      rating: 4.9,
      reviews: 58,
      tint: [0xFFF3CAC5, 0xFFD88A87],
      art: 'sundress',
    ),
    Product(
      id: 'p_006',
      name: 'Leather Tote Bag',
      brand: 'Drape Accessories',
      price: 310,
      cat: 'Accessories',
      desc:
          'A structured leather tote bag with gold hardware and a spacious interior.',
      sizes: ['One Size'],
      colors: ['Black', 'Tan', 'Burgundy'],
      rating: 4.8,
      reviews: 203,
      isSale: true,
      tint: [0xFF8C5A3E, 0xFF5E3A26],
      art: 'leather tote',
    ),
    Product(
      id: 'p_007',
      name: 'Cashmere Knit Sweater',
      brand: 'Drape Studio',
      price: 275,
      cat: 'Women',
      desc: 'Ultra-soft cashmere knit sweater with a relaxed oversized fit.',
      sizes: ['XS', 'S', 'M', 'L'],
      colors: ['Cream', 'Camel', 'Grey'],
      rating: 4.9,
      reviews: 167,
      tint: [0xFFE9DCC4, 0xFFBFA57C],
      art: 'cashmere knit',
    ),
    Product(
      id: 'p_008',
      name: 'Leather Belt',
      brand: 'Drape Accessories',
      price: 78,
      cat: 'Accessories',
      desc: 'A genuine leather belt with a polished silver buckle.',
      sizes: ['S', 'M', 'L', 'XL'],
      colors: ['Black', 'Brown'],
      rating: 4.4,
      reviews: 89,
      isSale: true,
      tint: [0xFF5A3A28, 0xFF2E1E14],
      art: 'leather belt',
    ),
  ];

  static const addresses = <Address>[
    Address('Home', '248 Silk Road', 'New York, 10012', isDefault: true),
    Address('Work', '88 Regent Street', 'London, W1B 5TT'),
  ];

  static const payments = <Payment>[
    Payment('Visa', '•••• 4821', 'visa'),
    Payment('Apple Pay', 'Touch ID', 'apple'),
  ];

  static const orders = <Order>[
    Order('DRP-2024-001', 'March 15, 2024', 'Delivered', 342.00, [
      'p_001',
      'p_002',
    ], '248 Silk Road, New York'),
    Order('DRP-2024-002', 'April 02, 2024', 'Shipped', 189.00, [
      'p_001',
    ], '248 Silk Road, New York'),
    Order('DRP-2024-003', 'April 10, 2024', 'Processing', 555.00, [
      'p_006',
      'p_007',
      'p_008',
    ], '248 Silk Road, New York'),
  ];

  static Product byId(String id) => products.firstWhere((p) => p.id == id);
  static List<Product> featured() =>
      products.where((p) => p.isNew || p.isSale).toList();
}
