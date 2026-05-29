'use strict';
const fs = require('fs');
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, AlignmentType, HeadingLevel, BorderStyle, WidthType, ShadingType,
  PageNumber, PageBreak, LevelFormat, TabStopType, TabStopPosition,
} = require('docx');

// ── Constants ──────────────────────────────────────────────────
const TNR  = 'Times New Roman';
const MONO = 'Courier New';
const SZ   = 24;   // 12pt  (half-points)
const SZ_H1 = 32;  // 16pt
const SZ_H2 = 28;  // 14pt
const SZ_SMALL = 18; // 9pt  (used in header + code)
const SP = { line: 360, lineRule: 'auto' };  // 1.5 line spacing

// A4 dimensions (DXA: 1440 = 1 inch)
const A4W = 11906;
const A4H = 16838;
const MAR = 1440;           // 1-inch margin
const CW  = A4W - 2 * MAR; // 9026 DXA content width

// Black border helper
const B = { style: BorderStyle.SINGLE, size: 6, color: '000000' };
const BORDERS = { top: B, bottom: B, left: B, right: B };

// ── Helper: plain paragraph ────────────────────────────────────
function p(text, opts = {}) {
  return new Paragraph({
    spacing: SP,
    alignment: opts.center ? AlignmentType.CENTER : AlignmentType.LEFT,
    children: [new TextRun({
      text,
      font: opts.font || TNR,
      size: opts.size || SZ,
      bold: opts.bold || false,
    })],
  });
}

// ── Helper: blank line ─────────────────────────────────────────
function blank() {
  return new Paragraph({
    spacing: { line: 260 },
    children: [new TextRun({ text: '', font: TNR, size: SZ })],
  });
}

// ── Helper: page break ─────────────────────────────────────────
function pageBreak() {
  return new Paragraph({ children: [new PageBreak()] });
}

// ── Helper: heading 1 ──────────────────────────────────────────
function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 280, after: 140, line: 360, lineRule: 'auto' },
    children: [new TextRun({ text, font: TNR, size: SZ_H1, bold: true })],
  });
}

// ── Helper: heading 2 ──────────────────────────────────────────
function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 200, after: 80, line: 360, lineRule: 'auto' },
    children: [new TextRun({ text, font: TNR, size: SZ_H2, bold: true })],
  });
}

// ── Helper: bullet point ───────────────────────────────────────
function bullet(text) {
  return new Paragraph({
    spacing: SP,
    numbering: { reference: 'bullets', level: 0 },
    children: [new TextRun({ text, font: TNR, size: SZ })],
  });
}

// ── Helper: monospace line (for folder tree) ───────────────────
function code(text) {
  return new Paragraph({
    spacing: { line: 240 },
    children: [new TextRun({ text, font: MONO, size: SZ_SMALL })],
  });
}

// ── Helper: table ──────────────────────────────────────────────
function makeTable(headers, rows, colWidths) {
  const totalW = colWidths.reduce((a, b) => a + b, 0);

  const headerRow = new TableRow({
    tableHeader: true,
    children: headers.map((h, i) =>
      new TableCell({
        borders: BORDERS,
        width: { size: colWidths[i], type: WidthType.DXA },
        shading: { fill: 'FFFFFF', type: ShadingType.CLEAR },
        margins: { top: 80, bottom: 80, left: 130, right: 130 },
        children: [new Paragraph({
          spacing: { line: 260 },
          children: [new TextRun({ text: h, font: TNR, size: SZ, bold: true })],
        })],
      })
    ),
  });

  const dataRows = rows.map(row =>
    new TableRow({
      children: row.map((cell, i) =>
        new TableCell({
          borders: BORDERS,
          width: { size: colWidths[i], type: WidthType.DXA },
          shading: { fill: 'FFFFFF', type: ShadingType.CLEAR },
          margins: { top: 80, bottom: 80, left: 130, right: 130 },
          children: [new Paragraph({
            spacing: { line: 260 },
            children: [new TextRun({ text: String(cell), font: TNR, size: SZ })],
          })],
        })
      ),
    })
  );

  return new Table({
    width: { size: totalW, type: WidthType.DXA },
    columnWidths: colWidths,
    rows: [headerRow, ...dataRows],
  });
}

// ──────────────────────────────────────────────────────────────
// COVER PAGE
// ──────────────────────────────────────────────────────────────
const coverChildren = [
  blank(), blank(), blank(), blank(),
  p('[University Name]',            { center: true, bold: true, size: 34 }),
  blank(),
  p('[Faculty of Computing / Information Technology]', { center: true, size: 24 }),
  blank(), blank(), blank(),
  p('CIT211 – Mobile Software Development',          { center: true, bold: true, size: 28 }),
  blank(),
  p('Design and Development of a Fashion Store Mobile Application',
    { center: true, bold: true, size: 26 }),
  blank(), blank(), blank(),
  p('App Name: Drape',                { center: true, size: SZ }),
  blank(), blank(),
  p('Student Full Name: [Student Full Name]', { center: true, size: SZ }),
  p('Student ID: [Student ID]',              { center: true, size: SZ }),
  p('Lecturer: [Lecturer Name]',             { center: true, size: SZ }),
  p('Submission Date: [Submission Date]',    { center: true, size: SZ }),
  blank(),
  p('GitHub Repository: [Paste your GitHub link here]',    { center: true, size: SZ }),
  p('Video Demonstration: [Paste your YouTube link here]', { center: true, size: SZ }),
];

// ──────────────────────────────────────────────────────────────
// PAGE HEADER (appears on every content page)
// ──────────────────────────────────────────────────────────────
const pageHeader = new Header({
  children: [
    new Paragraph({
      tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }],
      border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: '000000', space: 4 } },
      spacing: { after: 80 },
      children: [
        new TextRun({
          text: 'Drape | CIT211 – Mobile Software Development',
          font: TNR, size: SZ_SMALL,
        }),
        new TextRun({ text: '\t', font: TNR, size: SZ_SMALL }),
        new TextRun({ children: [PageNumber.CURRENT], font: TNR, size: SZ_SMALL }),
      ],
    }),
  ],
});

// ──────────────────────────────────────────────────────────────
// SECTION 1 — Introduction
// ──────────────────────────────────────────────────────────────
const sec1 = [
  h1('1. Introduction'),
  p('Drape is a cross-platform fashion e-commerce mobile application built using the Flutter framework and Firebase backend services. The application targets Android and iOS platforms and delivers a complete online shopping experience — from browsing a curated product catalogue to placing orders and tracking their status in real time.'),
  blank(),
  p('The primary goal of the project was to design and implement a production-quality Flutter application that demonstrates core mobile development competencies: declarative UI construction, reactive state management, cloud authentication, real-time database integration, and a polished UI/UX designed for a fashion retail context.'),
  blank(),
  p('The design language of Drape is minimalist and editorial, using a warm charcoal-and-mocha colour palette, generous white space, and clean typography to evoke the aesthetic of a high-fashion online store. All 20 screens follow a consistent visual language defined in a central constants layer (app_colors.dart, app_text_styles.dart, app_spacing.dart).'),
  blank(),
  p('GitHub Repository: [Paste your GitHub link here]'),
  p('Video Demonstration: [Paste your YouTube link here]'),
  blank(),
  p('This report is structured as follows: Section 2 presents the technology stack; Section 3 describes the UI/UX design including all screens and the colour palette; Section 4 explains the system architecture and folder structure; Section 5 details the Firebase database design; Section 6 discusses the six most significant implementation features; Section 7 presents manual test results; Section 8 reflects on development challenges and the solutions applied; and Sections 9 and 10 provide the conclusion and references.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 2 — System Overview
// ──────────────────────────────────────────────────────────────
const sec2 = [
  pageBreak(),
  h1('2. System Overview'),
  p('Drape is built on the Flutter 3.x framework using the Dart programming language. Firebase provides the cloud backend, covering authentication, the NoSQL database, and file storage. All package dependencies are declared in pubspec.yaml. The table below lists the complete technology stack extracted from that file.'),
  blank(),
  makeTable(
    ['Package / Technology', 'Version', 'Purpose'],
    [
      ['Flutter SDK (Dart)',      'SDK ^3.11.0',  'Cross-platform declarative UI framework'],
      ['firebase_core',          '^3.6.0',  'Firebase app initialisation for all platforms'],
      ['firebase_auth',          '^5.3.1',  'Email/password and Google OAuth authentication'],
      ['cloud_firestore',        '^5.4.4',  'Real-time NoSQL cloud database'],
      ['firebase_storage',       '^12.3.2', 'Cloud file and asset storage'],
      ['google_sign_in',         '^6.2.2',  'Google OAuth sign-in flow (Android & iOS)'],
      ['provider',               '^6.1.2',  'Reactive state management (ChangeNotifier pattern)'],
      ['google_fonts',           '^6.1.0',  'Custom typography from Google Fonts CDN'],
      ['cached_network_image',   '^3.3.1',  'Network image loading with disk/memory cache'],
      ['flutter_native_splash',  '^2.4.3',  'Native splash screen generation (Android & iOS)'],
      ['flutter_launcher_icons', '^0.14.3', 'Adaptive app icon generation (dev dependency)'],
      ['flutter_lints',          '^6.0.0',  'Static analysis and lint rules (dev dependency)'],
    ],
    [3000, 1800, 4226]
  ),
  blank(),
  p('The application is configured for Android (minimum SDK 21), iOS, and Flutter Web. Firebase platform configuration is managed through platform-specific files (google-services.json for Android, GoogleService-Info.plist for iOS, and a JavaScript configuration snippet for web) generated by the Firebase CLI and referenced in lib/firebase_options.dart. Firestore long polling is enabled for Flutter Web to avoid QUIC protocol instability.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 3 — UI/UX Design
// ──────────────────────────────────────────────────────────────
const sec3 = [
  pageBreak(),
  h1('3. UI/UX Design'),
  h2('3.1 Design Philosophy'),
  p('Drape follows a minimalist editorial aesthetic. The palette is limited to warm neutrals and a single mocha accent. There are no decorative gradients or illustrations; layout proportions, typography scale, and whitespace carry the visual weight. All colour tokens are centralised in lib/core/constants/app_colors.dart so that any colour change propagates consistently across the entire application.'),
  blank(),
  h2('3.2 Colour Palette'),
  p('The following colour tokens are defined in AppColors and used throughout every screen.'),
  blank(),
  makeTable(
    ['Token', 'Hex Value', 'Usage in the Application'],
    [
      ['ink',        '#1A1816', 'Primary text, navigation icons, button fills, dark headings'],
      ['inkSoft',    '#3A332D', 'Secondary text, border tones'],
      ['accent',     '#9B6B4A', 'Call-to-action buttons, sale tags, active indicator'],
      ['accentSoft', '#E8D7C4', 'Chip and tag backgrounds, hover tones'],
      ['bg',         '#F4EFE7', 'App-wide background (warm parchment off-white)'],
      ['surface',    '#FBF8F2', 'Card and bottom-sheet surfaces'],
      ['surface2',   '#EEE7DB', 'Input field backgrounds, secondary panels'],
      ['textMuted',  '#7A7269', 'Placeholders, captions, disabled labels'],
      ['success',    '#5B7A5B', 'Order confirmation, wishlist filled state'],
      ['error',      '#B04D3C', 'Form validation messages, destructive actions'],
      ['info',       '#4A6FA5', 'Informational banners'],
      ['warning',    '#C98A3D', 'Stock or delivery warnings'],
    ],
    [2000, 1800, 5226]
  ),
  blank(),
  h2('3.3 Screen Inventory'),
  p('The application contains 20 distinct screens, each implemented as a dedicated Dart file in lib/screens/. They cover the complete customer journey from brand introduction to post-purchase tracking.'),
  blank(),
  makeTable(
    ['Screen', 'Route', 'Purpose'],
    [
      ['OnboardingScreen',          '/',                   'Brand splash; single "Get Started" entry point'],
      ['LoginScreen',               '/login',              'Email/password login and Google Sign-In button'],
      ['SignupScreen',              '/signup',             'New account creation with name, email, password'],
      ['HomeScreen',                '/home',               'Hero banner, category chips, new arrivals product grid'],
      ['ProductListScreen',         '/products',           'Full product catalogue with category tab filter'],
      ['ProductDetailScreen',       '/pdp',                'Product image, description, size/colour selectors, Add to Cart'],
      ['SearchScreen',              '/search',             'Live keyword search with instant Firestore results'],
      ['CartScreen',                '/cart',               'Cart items list, quantity +/- controls, order total'],
      ['WishlistScreen',            '/wishlist',           'Grid of hearted/saved products'],
      ['CheckoutScreen',            '/checkout',           'Inline address + payment forms; order placement'],
      ['OrderConfirmationScreen',   '/order-confirmation', 'Animated success badge, short order ref, delivery estimate'],
      ['OrderHistoryScreen',        '/orders',             'Chronological list of all past orders'],
      ['OrderDetailScreen',         '/order-detail',       'Full detail for one order: items, total, status, address'],
      ['ProfileScreen',             '/profile',            'User avatar, display name, quick-link settings menu'],
      ['AddressesScreen',           '/addresses',          'Add, view, and remove saved delivery addresses'],
      ['PaymentsScreen',            '/payments',           'Add, view, and remove saved payment methods'],
      ['NotificationInboxScreen',   '/notification-inbox', 'Activity feed derived from order history events'],
      ['NotificationsScreen',       '/notifications',      'Toggle preferences: order updates, sales, new arrivals'],
      ['PrivacyScreen',             '/privacy',            'Static privacy policy content'],
      ['HelpScreen',                '/help',               'FAQ and customer support information'],
    ],
    [3200, 2400, 3426]
  ),
  blank(),
  p('[SCREENSHOT: HomeScreen showing the hero banner, category chip row, and product grid]'),
  blank(),
  p('[SCREENSHOT: ProductDetailScreen showing product image, size selector, colour dots, and Add to Cart button]'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 4 — System Architecture
// ──────────────────────────────────────────────────────────────
const folderTree = [
  'lib/',
  '  core/',
  '    constants/',
  '      app_colors.dart        -- Colour token definitions',
  '      app_text_styles.dart   -- Typography scale (AppText.*)',
  '      app_spacing.dart       -- Spacing and border-radius constants',
  '      app_images.dart        -- Asset path constants',
  '    routes/',
  '      app_routes.dart        -- Centralised named-route table (onGenerate)',
  '  data/',
  '    models/',
  '      product_model.dart     -- Product data class',
  '      cart_item_model.dart   -- CartItem data class',
  '      order_model.dart       -- Order and OrderItem data classes',
  '      user_model.dart        -- Address and Payment data classes',
  '      category_model.dart    -- Category data class',
  '    models.dart              -- Barrel export file',
  '    cart_manager.dart        -- CartManager (ChangeNotifier)',
  '    wishlist_manager.dart    -- WishlistManager (ChangeNotifier)',
  '    order_manager.dart       -- OrderManager (ChangeNotifier)',
  '    user_profile_manager.dart -- UserProfileManager (ChangeNotifier)',
  '  screens/                   -- 20 screen files (see Section 3)',
  '  services/',
  '    auth_service.dart        -- AuthService (ChangeNotifier)',
  '    firestore_service.dart   -- Single Firestore access point',
  '    seed_service.dart        -- Idempotent product seeder from JSON',
  '  shared/',
  '    widgets/',
  '      product_card.dart      -- Reusable product card with wishlist heart',
  '      bottom_nav_bar.dart    -- Persistent bottom navigation',
  '      drape_scaffold.dart    -- Shared scaffold wrapper',
  '      primary_button.dart    -- Filled call-to-action button',
  '      outlined_button_widget.dart  -- Outlined secondary button',
  '      category_chip.dart     -- Tappable category filter chip',
  '      custom_input_field.dart -- Styled text input field',
  '      app_local_image.dart   -- Product art renderer (network + fallback)',
  '  app.dart                   -- MultiProvider root + MaterialApp',
  '  main.dart                  -- Entry: Firebase init, splash, seeding, runApp',
  '  firebase_options.dart      -- Auto-generated platform Firebase config',
];

const sec4 = [
  pageBreak(),
  h1('4. System Architecture'),
  h2('4.1 Project Folder Structure'),
  p('The project uses a feature-grouped folder structure inside lib/. Concerns are separated into core (design tokens and routing), data (models and ChangeNotifier managers), screens (UI layer), services (Firebase calls), and shared (reusable widgets).'),
  blank(),
  ...folderTree.map(line => code(line)),
  blank(),
  h2('4.2 State Management'),
  p('The application uses the Provider package (ChangeNotifier pattern) for reactive state management. Six ChangeNotifier instances are registered in a MultiProvider at the root of the widget tree inside app.dart. Each manager subscribes to Firebase auth state changes and sets up or tears down its Firestore stream listener automatically on sign-in and sign-out.'),
  blank(),
  makeTable(
    ['Provider Class', 'Responsibility'],
    [
      ['AuthService',               'Firebase Authentication: email/password login, signup, Google Sign-In, sign-out, error message mapping'],
      ['CartManager',               'Cart item CRUD and quantity updates; real-time sync with users/{uid}/cart subcollection'],
      ['WishlistManager',           'Wishlist toggle (add/remove); persisted to users/{uid}/wishlist subcollection'],
      ['OrderManager',              'Order history; real-time stream from orders collection; placeOrder() returns new doc ID'],
      ['UserProfileManager',        'Profile data (name, email, phone), addresses list, payments list; synced from users/{uid}'],
      ['NotificationPrefsManager',  'Notification preference toggles; persisted to users/{uid}.notifPrefs; exposes anyEnabled getter'],
    ],
    [3200, 5826]
  ),
  blank(),
  h2('4.3 Navigation'),
  p('Navigation is centralised in AppRoutes (lib/core/routes/app_routes.dart). The app uses Flutter\'s named route system with a custom onGenerate callback that switches on the route name and casts RouteSettings.arguments to the correct typed argument. All transitions use a 220 ms FadeTransition, giving the application a calm editorial feel. Complex argument types such as Product and Order are passed directly as typed objects rather than serialised strings.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 5 — Database Design
// ──────────────────────────────────────────────────────────────
const sec5 = [
  pageBreak(),
  h1('5. Database Design'),
  p('Drape uses Cloud Firestore as its cloud database. Firestore is a NoSQL document-store organised into collections and sub-collections. All reads in the application use real-time snapshot streams so the UI reacts instantly to any data change. Writes use batch operations and SetOptions(merge: true) to avoid overwriting unrelated fields.'),
  blank(),
  h2('5.1 Collection Structure'),
  blank(),
  makeTable(
    ['Collection Path', 'Key Document Fields', 'Notes'],
    [
      [
        'products',
        'name, brand, price, cat, desc, sizes[], colors[], rating, reviews, tint[], art, imageUrl, isNew, isSale',
        'Seeded from assets/seed_data.json on app start by SeedService; 20 products across Women, Men, Kids, Accessories',
      ],
      [
        'users/{uid}',
        'name, email, phone, addresses[], payments[], notifPrefs{}, createdAt, updatedAt',
        'Created on signup or first Google Sign-In via SetOptions(merge: true)',
      ],
      [
        'users/{uid}/cart',
        'productId, name, brand, price, imageUrl, size, color, qty, addedAt',
        'Subcollection; qty incremented if same productId + size + color combination already exists',
      ],
      [
        'users/{uid}/wishlist',
        'savedAt (document ID = productId)',
        'Toggle: exists => delete; not exists => set with server timestamp; O(1) lookup by document ID',
      ],
      [
        'orders',
        'userId, dateStr, status, totalPrice, address, items[], createdAt',
        'Queried with where(userId).orderBy(createdAt, descending: true); all items denormalised into array',
      ],
    ],
    [2600, 4000, 2426]
  ),
  blank(),
  h2('5.2 Data Models'),
  p('Five Dart model classes defined in lib/data/models/ provide typed access to Firestore documents. Each includes a factory constructor for deserialisation (fromMap / fromFirestore) and, where written back to Firestore, a toMap() serialisation method.'),
  blank(),
  makeTable(
    ['Model Class', 'Key Fields', 'Serialisation Notes'],
    [
      ['Product',    'id, name, brand, cat, price, sizes[], colors[], rating, reviews, tint[], isNew, isSale', 'Factory _docToProduct() in FirestoreService; tint[] stored as int list'],
      ['CartItem',   'productId, name, brand, price, imageUrl, size, color, qty',       'fromMap() for stream reads; fields written individually in addToCart()'],
      ['Order',      'id, date, status, total, address, itemIds[], orderItems[]',        'fromFirestore() converts Firestore Timestamp to human-readable date string'],
      ['OrderItem',  'productId, name, brand, size, color, imageUrl, price, qty',        'Nested inside Order; fromMap() used during order stream parsing'],
      ['Address',    'label, line1, line2, isDefault',                                   'toMap() for writing to addresses[] array field on users/{uid}'],
      ['Payment',    'label, detail, brand',                                             'toMap() for writing to payments[] array field on users/{uid}'],
    ],
    [1800, 4000, 3226]
  ),
  blank(),
  h2('5.3 Seeding Strategy'),
  p('SeedService (lib/services/seed_service.dart) runs once at app startup after Firebase initialisation. It reads assets/seed_data.json (20 product definitions), fetches all existing documents from the products collection in a single round-trip, and performs batch writes in chunks of 500 (the Firestore hard limit). The logic is fully idempotent: new products are created, existing products with a changed imageUrl have only that field patched, and documents that are already up to date are left untouched.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 6 — Implementation
// ──────────────────────────────────────────────────────────────
const sec6 = [
  pageBreak(),
  h1('6. Implementation'),
  h2('6.1 Firebase Authentication'),
  p('Authentication is implemented in AuthService (lib/services/auth_service.dart), a ChangeNotifier wrapping FirebaseAuth. Users can create accounts with email and password (createUserWithEmailAndPassword) or sign in with Google OAuth using the google_sign_in package. On account creation, a Firestore user document is written with the user\'s name, email, and empty arrays for addresses and payments. On first Google Sign-In, the service checks whether the user document already exists and creates it only if missing, supporting repeated sign-ins without data loss. A static errorMessage() method maps every relevant FirebaseAuthException code to a user-friendly string displayed in the UI.'),
  blank(),
  h2('6.2 Product Catalogue and Seeding'),
  p('Products are stored in the Firestore products collection and streamed in real time via FirestoreService.getProducts(). SeedService provides automatic data seeding: it reads a bundled JSON file (assets/seed_data.json) containing 20 product definitions and performs idempotent batch writes on every app start. This means new products in the JSON are created, changed image URLs are patched on existing documents, and unchanged documents are skipped entirely. The tint colour array is stored as a list of integers in Firestore (not as hex strings) to match the Product model\'s type declaration.'),
  blank(),
  p('[SCREENSHOT: ProductListScreen showing the filtered product grid with NEW and SALE tags]'),
  blank(),
  h2('6.3 Cart Management'),
  p('CartManager (lib/data/cart_manager.dart) subscribes to the users/{uid}/cart Firestore subcollection stream. When a user taps Add to Cart on the ProductDetailScreen, FirestoreService.addToCart() queries for an existing document matching the same productId, size, and colour before writing. If a match exists, it increments the qty field; otherwise it creates a new document. The cart item count and subtotal are computed as ChangeNotifier getters and consumed using context.watch<CartManager>() in the bottom navigation badge and cart screen header, so they update in real time without explicit refresh calls.'),
  blank(),
  h2('6.4 Wishlist'),
  p('WishlistManager (lib/data/wishlist_manager.dart) uses the users/{uid}/wishlist subcollection, where each document\'s ID equals the productId of the saved item. Toggling a product calls toggleWishlist(), which checks document existence with a single get() call and either deletes or creates the document. This O(1) lookup pattern avoids iterating any list. ProductCard reads WishlistManager with context.watch and switches between a filled and outlined heart icon without rebuilding the rest of the card widget tree.'),
  blank(),
  h2('6.5 Checkout with Inline Forms'),
  p('CheckoutScreen (lib/screens/checkout_screen.dart) eliminates the need for a first-time user to navigate away to a separate screen to add an address or payment method. The screen\'s state tracks _showAddrForm and _showPayForm boolean flags alongside the selected address and payment indices. When the addresses list is empty, the AddressForm widget is rendered inline immediately. Once at least one address is saved, a dashed-border Add New button appears below the address cards; tapping it sets _showAddrForm to true and expands the form in place. After submission, the new item is auto-selected by capturing list.length before the asynchronous save call and using it as the new index once the Future resolves. The Confirm Order button is only enabled when the cart is non-empty and both an address and a payment method are selected.'),
  blank(),
  p('[SCREENSHOT: CheckoutScreen showing inline address form and payment card tiles]'),
  blank(),
  h2('6.6 Order Placement and Notification System'),
  p('OrderManager.placeOrder() writes a full order document to the Firestore orders collection, including a denormalised items array with complete product snapshots (name, brand, price, image, size, colour, quantity). The method returns the new document ID. After a successful write, CartManager clears the cart and the user is navigated to OrderConfirmationScreen, which displays an animated elastic-out check badge, a short order reference derived from the last six characters of the Firestore document ID, and a delivery window calculated as five to seven days from today.'),
  blank(),
  p('The notification system has two separate components. NotificationPrefsManager persists per-user preference toggles to the users/{uid}.notifPrefs map field in Firestore. The home screen bell icon uses Consumer<NotificationPrefsManager> to switch between notifications_none and notifications_off_outlined based on the allDisabled getter. The notification inbox screen derives its activity feed directly from OrderManager.orders, generating one or two tiles per order without requiring a separate Firestore collection for notification events.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 7 — Testing and Results
// ──────────────────────────────────────────────────────────────
const sec7 = [
  pageBreak(),
  h1('7. Testing and Results'),
  p('The application was tested manually on an Android device and via Flutter Web. The table below documents the key test cases with their input actions, expected outcomes, and actual results observed during testing sessions.'),
  blank(),
  makeTable(
    ['Test Case', 'Action Performed', 'Expected', 'Result'],
    [
      ['User Registration',        'Enter name, email, password; tap Sign Up',         'Account created; Home shown',               'Pass'],
      ['Email Login',              'Enter valid credentials; tap Log In',              'Authenticated; Home shown',                 'Pass'],
      ['Google Sign-In',           'Tap Continue with Google; select account',         'OAuth completes; Home shown',               'Pass'],
      ['Invalid Login',            'Enter wrong password; tap Log In',                 'Error message displayed',                   'Pass'],
      ['Browse Products',          'Open Home; scroll product grid',                   'Products load from Firestore in real time',  'Pass'],
      ['Category Filter',          'Tap Women / Men / Kids chip',                      'Grid filters to selected category',         'Pass'],
      ['Product Search',           'Type keyword in search bar',                       'Matching products shown instantly',          'Pass'],
      ['Add to Cart',              'Select size and colour; tap Add to Cart',          'Cart badge count increments',               'Pass'],
      ['Duplicate Cart Item',      'Add same product/size/colour twice',               'Quantity incremented, not duplicated',       'Pass'],
      ['Wishlist Toggle',          'Tap heart on product card',                        'Heart fills; product in Wishlist screen',    'Pass'],
      ['Checkout First-Time',      'Open Checkout with empty profile',                 'Inline address form shown immediately',      'Pass'],
      ['Add Address Inline',       'Fill address form; tap Save',                      'Card appears; auto-selected',               'Pass'],
      ['Place Order',              'Select address and payment; tap Confirm',          'Order in Firestore; confirmation shown',     'Pass'],
      ['Order History',            'Open Orders from Profile',                         'All orders listed newest first',            'Pass'],
      ['Notification Bell',        'Disable all notifications; return to Home',        'Bell changes to notifications_off icon',    'Pass'],
      ['Sign Out',                 'Tap Sign Out in Profile',                          'Auth cleared; Onboarding shown',            'Pass'],
    ],
    [2600, 2800, 2400, 1226]
  ),
  blank(),
  p('All 16 manual test cases passed. Two notable observations: (1) on slow network connections the product images show a grey placeholder until the cached_network_image package completes loading; (2) on Flutter Web, Firestore streams function correctly with the long polling override applied in main.dart, avoiding the QUIC protocol crash that occurs without the override.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 8 — Challenges and Solutions
// ──────────────────────────────────────────────────────────────
const sec8 = [
  pageBreak(),
  h1('8. Challenges and Solutions'),
  p('Several non-trivial technical challenges were encountered during development. The table below describes each challenge, its root cause, and the solution implemented.'),
  blank(),
  makeTable(
    ['Challenge', 'Solution Applied'],
    [
      [
        'Shared notification state between two unrelated screens',
        'A dedicated NotificationPrefsManager ChangeNotifier was registered at the root MultiProvider. Both the home screen bell icon (via Consumer<NotificationPrefsManager>) and the NotificationsScreen settings page consume the same instance, so a toggle change in either location is immediately reflected in the other without any explicit messaging.',
      ],
      [
        'First-time checkout experience: user had no saved addresses',
        'The CheckoutScreen was redesigned to render an inline AddressForm immediately when the addresses list is empty, eliminating the need to navigate to AddressesScreen and back. The auto-select pattern (capture list.length before the async save; use it as the new index after the Future resolves) avoids any race condition between the Firestore write and the UI state update.',
      ],
      [
        'Dead Unsplash product image URLs returning HTTP 404',
        'Three imageUrl values in seed_data.json became invalid as Unsplash changed its URL structure. Fixed in two parts: the URLs were updated in the JSON file, and SeedService\'s patch logic was changed from "patch if liveUrl is empty" to "patch if seedUrl differs from liveUrl", so existing documents are updated without a full re-seed.',
      ],
      [
        'Firestore QUIC protocol crash on Flutter Web',
        'Set FirebaseFirestore.instance.settings with webExperimentalForceLongPolling: true immediately after Firebase.initializeApp() in main.dart, before any Firestore read is issued. This forces HTTP long polling as the transport layer and completely eliminates the crash on web builds.',
      ],
      [
        'RenderFlex overflow on hero card (web)',
        'The hero card Column used crossAxisAlignment.start alongside fixed-width SizedBox children. Under certain viewport widths, this left the parent Row with fewer than 40 logical pixels of space, triggering a 139 px overflow. The fix was to switch the Column to crossAxisAlignment.stretch and replace SizedBox text wrappers with maxLines + TextOverflow.ellipsis on the Text widgets themselves.',
      ],
      [
        'Duplicate cart items when Add to Cart is tapped quickly',
        'FirestoreService.addToCart() was changed to first query for a document matching the same productId, size, and colour combination before writing. If a matching document exists, it updates the qty field using a Firestore update call rather than creating a new document, making the operation idempotent regardless of tap frequency.',
      ],
    ],
    [3200, 5826]
  ),
];

// ──────────────────────────────────────────────────────────────
// SECTION 9 — Conclusion
// ──────────────────────────────────────────────────────────────
const sec9 = [
  pageBreak(),
  h1('9. Conclusion and Future Improvements'),
  h2('9.1 Conclusion'),
  p('Drape demonstrates the practical application of Flutter and Firebase to build a production-quality mobile e-commerce application. Over the course of this assignment, 20 screens were implemented covering the complete customer journey: brand onboarding, authentication (email/password and Google), product discovery, search, cart management, wishlist, multi-step checkout with inline data entry, order placement, order tracking, and a notification system.'),
  blank(),
  p('The Provider pattern proved well-suited to this project\'s scale. Six ChangeNotifier classes each own a well-defined slice of application state and expose it through reactive getters consumed by descendant widgets. The result is a codebase where adding a new screen typically requires only declaring a new route and reading from an existing provider, rather than wiring up new streams or rebuilding the state layer.'),
  blank(),
  p('The Firebase integration demonstrated the practical trade-offs of a NoSQL backend: denormalising the items array inside each order document eliminates extra reads at the cost of slightly larger documents; the idempotent seeding strategy allows the product catalogue to evolve without a migration script; and subcollections for cart and wishlist keep per-user data isolated and easy to query.'),
  blank(),
  h2('9.2 Future Improvements'),
  p('The following enhancements are identified for future development iterations:'),
  blank(),
  bullet('Push Notifications: Integrate Firebase Cloud Messaging (FCM) to deliver real device-level push notifications for order status updates and promotional alerts, replacing the current order-derived inbox.'),
  bullet('Product Reviews: Allow authenticated users to submit star ratings and text reviews, stored in a reviews subcollection under each product document and averaged into the product\'s rating field.'),
  bullet('Advanced Filtering: Add price range sliders, multi-select colour and size filters, and sort options (price ascending/descending, newest, highest-rated) to the ProductListScreen.'),
  bullet('Promotional Vouchers: Implement a vouchers Firestore collection and a discount code entry field in CheckoutScreen, with server-side validation via a Firebase Cloud Function.'),
  bullet('Automated Testing: Write Flutter widget tests for the cart, wishlist, and checkout flows, and integration tests using the integration_test package to verify end-to-end user journeys on a real device.'),
  bullet('Accessibility: Audit all screens with TalkBack / VoiceOver, add Semantics labels to interactive widgets, and verify WCAG AA contrast ratios across the colour palette.'),
];

// ──────────────────────────────────────────────────────────────
// SECTION 10 — References
// ──────────────────────────────────────────────────────────────
const sec10 = [
  pageBreak(),
  h1('10. References'),
  blank(),
  p('Flutter Team. (2024). Flutter documentation. Google LLC. Retrieved from https://flutter.dev/docs'),
  blank(),
  p('Firebase Team. (2024). Firebase documentation: Authentication, Cloud Firestore, Cloud Storage. Google LLC. Retrieved from https://firebase.google.com/docs'),
  blank(),
  p('Rousselet, R., & Flutter Community. (2024). provider (v6.1.2) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/provider'),
  blank(),
  p('Google & Flutter Team. (2024). cloud_firestore (v5.4.4) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/cloud_firestore'),
  blank(),
  p('Google & Flutter Team. (2024). firebase_auth (v5.3.1) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/firebase_auth'),
  blank(),
  p('Google. (2024). google_sign_in (v6.2.2) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/google_sign_in'),
  blank(),
  p('Baseflow. (2024). cached_network_image (v3.3.1) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/cached_network_image'),
  blank(),
  p('Jonasbroens. (2024). flutter_native_splash (v2.4.3) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/flutter_native_splash'),
  blank(),
  p('Google Fonts Team. (2024). google_fonts (v6.1.0) [Flutter package]. Pub.dev. Retrieved from https://pub.dev/packages/google_fonts'),
  blank(),
  p('Dart Team. (2024). Dart programming language. Google LLC. Retrieved from https://dart.dev'),
  blank(),
  p('Google. (2024). Android developer documentation: minSdkVersion. Android Open Source Project. Retrieved from https://developer.android.com/reference/android/os/Build.VERSION_CODES'),
];

// ──────────────────────────────────────────────────────────────
// ASSEMBLE DOCUMENT
// ──────────────────────────────────────────────────────────────
const doc = new Document({
  numbering: {
    config: [
      {
        reference: 'bullets',
        levels: [{
          level: 0,
          format: LevelFormat.BULLET,
          text: '•',
          alignment: AlignmentType.LEFT,
          style: {
            paragraph: { indent: { left: 720, hanging: 360 } },
          },
        }],
      },
    ],
  },
  styles: {
    default: {
      document: { run: { font: TNR, size: SZ } },
    },
    paragraphStyles: [
      {
        id: 'Heading1', name: 'Heading 1',
        basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: SZ_H1, bold: true, font: TNR, color: '000000' },
        paragraph: {
          spacing: { before: 280, after: 140, line: 360, lineRule: 'auto' },
          outlineLevel: 0,
        },
      },
      {
        id: 'Heading2', name: 'Heading 2',
        basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: SZ_H2, bold: true, font: TNR, color: '000000' },
        paragraph: {
          spacing: { before: 200, after: 80, line: 360, lineRule: 'auto' },
          outlineLevel: 1,
        },
      },
    ],
  },
  sections: [
    // ── Cover page: no header ──────────────────────────────────
    {
      properties: {
        page: {
          size: { width: A4W, height: A4H },
          margin: { top: MAR, right: MAR, bottom: MAR, left: MAR },
        },
      },
      children: coverChildren,
    },
    // ── Main content: header on every page ────────────────────
    {
      properties: {
        page: {
          size: { width: A4W, height: A4H },
          margin: { top: 1200, right: MAR, bottom: MAR, left: MAR },
        },
      },
      headers: { default: pageHeader },
      children: [
        ...sec1,
        ...sec2,
        ...sec3,
        ...sec4,
        ...sec5,
        ...sec6,
        ...sec7,
        ...sec8,
        ...sec9,
        ...sec10,
      ],
    },
  ],
});

Packer.toBuffer(doc)
  .then(buffer => {
    fs.writeFileSync('drape_report.docx', buffer);
    console.log('SUCCESS: drape_report.docx has been generated.');
  })
  .catch(err => {
    console.error('ERROR generating document:', err);
    process.exit(1);
  });
