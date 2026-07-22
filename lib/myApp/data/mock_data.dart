// PWT mock data — ported verbatim from proto/shared.jsx. Replace with API
// responses when wiring a backend; the screens only depend on these shapes.

import 'package:flutter/material.dart';
import '../models/models.dart';

class MockData {
  MockData._();

  static const List<Product> products = [
    Product(id: 'PW90', name: 'PW90', cat: 'Fill Station', img: 'assets/products/PW90.png', tint: Color(0xFF1D4ED8), price: 280, buyPrice: 3400, blurb: 'Floor-standing fill station for offices and clinics. 90L/day, hot · cold · ambient.'),
    Product(id: 'PW50', name: 'PW50', cat: 'Fill Station', img: 'assets/products/PW50.png', tint: Color(0xFF3B82F6), price: 150, buyPrice: 1800, blurb: 'Compact fill station for residences. 50L/day.'),
    Product(id: 'PW90CT', name: 'PW90 Countertop', cat: 'Countertop', img: 'assets/products/PW90CT.png', tint: Color(0xFF1D4ED8), price: 180, buyPrice: 2100, blurb: 'Countertop version of PW90 — same performance, smaller footprint.'),
    Product(id: 'S4', name: 'S4 Sparkling', cat: 'Sparkling', img: 'assets/products/S4.png', tint: Color(0xFF10B981), price: 220, buyPrice: 2600, blurb: 'Compact sparkling water dispenser for hospitality.'),
    Product(id: 'S18C', name: 'S18 Countertop', cat: 'Sparkling', img: 'assets/products/S18C.png', tint: Color(0xFF10B981), quoteOnly: true, blurb: 'High-volume sparkling for restaurants — quote on request.'),
  ];

  static Product? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  static const Map<String, ProductDetail> productDetails = {
    'PW90': ProductDetail(rating: 4.8, reviews: 128, badge: 'Best seller', sparkling: false, specs: [
      ['Daily output', '90 L/day'], ['Hot water', '90–95°C'], ['Cold water', '4–10°C'], ['Tank capacity', '5.0L hot / 2.0L cold'], ['Filtration', '5-stage RO + UV'], ['Power', '500W'], ['Dimensions', '310 × 330 × 1040 mm'], ['Weight', '18 kg'], ['Noise', '< 40 dB']
    ]),
    'PW50': ProductDetail(rating: 4.7, reviews: 86, badge: 'Popular', sparkling: false, specs: [
      ['Daily output', '50 L/day'], ['Hot water', '90–95°C'], ['Cold water', '4–10°C'], ['Tank capacity', '3.5L hot / 1.5L cold'], ['Filtration', '4-stage RO'], ['Power', '420W'], ['Dimensions', '290 × 310 × 980 mm'], ['Weight', '14 kg'], ['Noise', '< 42 dB']
    ]),
    'PW90CT': ProductDetail(rating: 4.6, reviews: 54, sparkling: false, specs: [
      ['Daily output', '90 L/day'], ['Hot water', '90–95°C'], ['Cold water', '4–10°C'], ['Tank capacity', '4.0L hot / 1.8L cold'], ['Filtration', '5-stage RO + UV'], ['Power', '480W'], ['Dimensions', '300 × 320 × 520 mm'], ['Weight', '12 kg'], ['Format', 'Countertop']
    ]),
    'S4': ProductDetail(rating: 4.9, reviews: 73, badge: 'New', sparkling: true, specs: [
      ['Modes', 'Sparkling · Chilled · Ambient'], ['Cold water', '4–8°C'], ['Carbonation', 'On-demand CO₂'], ['Tank capacity', '2.5L cold'], ['Filtration', 'Carbon + UV'], ['Power', '120W'], ['Dimensions', '260 × 300 × 450 mm'], ['Weight', '9 kg']
    ]),
    'S18C': ProductDetail(rating: 4.8, reviews: 41, badge: 'For business', sparkling: true, specs: [
      ['Modes', 'High-volume sparkling'], ['Cold water', '4–8°C'], ['Carbonation', 'Continuous CO₂'], ['Tank capacity', '6.0L'], ['Filtration', 'Carbon + UV'], ['Power', '160W'], ['Dimensions', '320 × 360 × 560 mm'], ['Weight', '15 kg']
    ]),
  };

  static const List<Review> reviews = [
    Review(initials: 'SJ', name: 'Sarah J.', date: '12 May 2026', stars: 5, text: 'Genuinely great water. Installation took 15 minutes and the touch panel feels premium. Happy customer.'),
    Review(initials: 'MK', name: 'Michael K.', date: '28 Apr 2026', stars: 4, text: 'Solid build quality. Hot is properly hot and cold is properly cold. Wish the cold tank were slightly larger.'),
    Review(initials: 'AR', name: 'Aisha R.', date: '03 Apr 2026', stars: 5, text: 'Beautiful design that fits right into the kitchen. The child-safety lock is much appreciated.'),
  ];

  static const List<String> boxContents = [
    'Water dispenser unit', 'Starter filter set', 'Power cable', 'Removable drip tray', 'Installation guide', 'Warranty card'
  ];

  static const List<Device> individualDevices = [
    Device(id: 'PW90-IN-021', product: 'PW90', name: 'PW90', img: 'assets/products/PW90.png', tint: Color(0xFF1D4ED8), plan: Plan.rent, rent: 280, since: '15 Jan 2026', location: 'Home · Kitchen', lastService: '14 Feb 2026', nextService: '14 Aug 2026'),
    Device(id: 'S4-IN-007', product: 'S4', name: 'S4 Sparkling', img: 'assets/products/S4.png', tint: Color(0xFF10B981), plan: Plan.buy, since: '02 Jan 2026', location: 'Home · Living Room', lastService: '02 Apr 2026', nextService: '02 Oct 2026', maintenanceScheduled: MaintenanceWindow(date: '21 May 2026', window: '10:00 – 13:00')),
    Device(id: 'PW50-IN-118', product: 'PW50', name: 'PW50', img: 'assets/products/PW50.png', tint: Color(0xFF3B82F6), plan: Plan.rent, rent: 150, location: 'Home · Study', status: 'ordered', orderId: 'PWT-1058', eta: '12 Jun 2026'),
  ];

  static const List<Device> businessDevices = [
    Device(id: 'PW90-BZ-104', product: 'PW90', name: 'PW90 · Pantry · Floor 14', img: 'assets/products/PW90.png', tint: Color(0xFF1D4ED8), plan: Plan.rent, rent: 280, since: '20 Mar 2025', lastService: '12 Apr 2026', nextService: '12 Jul 2026', location: 'HQ Tower · Floor 14'),
    Device(id: 'PW90-BZ-103', product: 'PW90', name: 'PW90 · Pantry · Floor 12', img: 'assets/products/PW90.png', tint: Color(0xFF1D4ED8), plan: Plan.rent, rent: 280, since: '20 Mar 2025', lastService: '12 Apr 2026', nextService: '12 Jul 2026', location: 'HQ Tower · Floor 12'),
    Device(id: 'PW50-BZ-088', product: 'PW50', name: 'PW50 · Reception', img: 'assets/products/PW50.png', tint: Color(0xFF3B82F6), plan: Plan.rent, rent: 150, since: '12 Sep 2025', lastService: '01 Mar 2026', nextService: '01 Jun 2026', location: 'HQ Tower · Lobby'),
    Device(id: 'S4-BZ-031', product: 'S4', name: 'S4 · Executive Lounge', img: 'assets/products/S4.png', tint: Color(0xFF10B981), plan: Plan.buy, since: '04 Nov 2025', lastService: '04 Feb 2026', nextService: '04 May 2026', location: 'HQ Tower · Floor 22'),
    Device(id: 'PW90CT-BZ-052', product: 'PW90CT', name: 'PW90 CT · Boardroom', img: 'assets/products/PW90CT.png', tint: Color(0xFF1D4ED8), plan: Plan.rent, rent: 180, since: '17 Jun 2025', lastService: '10 Mar 2026', nextService: '10 Jun 2026', location: 'HQ Tower · Floor 20'),
  ];

  static const List<Order> individualOrders = [
    Order(id: 'PWT-1042', date: '15 Jan 2026', items: 'PW90 · Monthly Rental', plan: Plan.rent, amount: 280, status: 'active', statusLabel: 'Active rental'),
    Order(id: 'PWT-0991', date: '02 Jan 2026', items: 'S4 Sparkling · Purchase', plan: Plan.buy, amount: 2600, status: 'delivered', statusLabel: 'Delivered'),
  ];

  static const List<Order> businessOrders = [
    Order(id: 'PWT-B-2240', date: '12 May 2026', items: '2× PW90 · Rental + install', plan: Plan.rent, status: 'quote_pending', statusLabel: 'Preparing quotation'),
    Order(id: 'PWT-B-2218', date: '04 May 2026', items: '1× S18 Countertop · Custom install', plan: Plan.rent, status: 'quote_sent', statusLabel: 'Quote sent'),
    Order(id: 'PWT-B-2102', date: '20 Mar 2025', items: '4× PW90 + 1× PW50 · Rental', plan: Plan.rent, amount: 1270, status: 'active', statusLabel: 'Active rental'),
    Order(id: 'PWT-B-1980', date: '04 Nov 2025', items: '1× S4 Sparkling · Purchase', plan: Plan.buy, amount: 2600, status: 'delivered', statusLabel: 'Delivered'),
  ];

  static const List<MaintenanceRequest> maintenanceRequests = [
    MaintenanceRequest(id: 'MR-308', deviceId: 'PW90-BZ-104', device: 'PW90 · Floor 14', issue: 'Cold tap not dispensing', raised: '14 May 2026', status: 'scheduled', statusLabel: 'Scheduled', schedule: '21 May 2026 · 10:00–13:00', tech: 'Tariq A.'),
    MaintenanceRequest(id: 'MR-305', deviceId: 'PW50-BZ-088', device: 'PW50 · Reception', issue: 'Filter replacement', raised: '11 May 2026', status: 'in_progress', statusLabel: 'In progress', schedule: 'Today · arriving', tech: 'Salim K.'),
    MaintenanceRequest(id: 'MR-298', deviceId: 'PW90-BZ-103', device: 'PW90 · Floor 12', issue: 'Annual deep clean', raised: '02 May 2026', status: 'completed', statusLabel: 'Completed', schedule: '08 May 2026', tech: 'Tariq A.'),
    MaintenanceRequest(id: 'MR-291', deviceId: 'S4-BZ-031', device: 'S4 · Lounge', issue: 'CO₂ canister low', raised: '28 Apr 2026', status: 'completed', statusLabel: 'Completed', schedule: '30 Apr 2026', tech: 'Hassan M.'),
  ];

  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(id: 'pm1', kind: 'visa', last4: '4912', exp: '09/27', primary: true, holder: 'Ahmed Al Mansoori'),
    PaymentMethod(id: 'pm2', kind: 'mastercard', last4: '1180', exp: '03/28', primary: false, holder: 'Ahmed Al Mansoori'),
  ];

  static const Company company = Company(
    name: 'Falcon Trading FZ-LLC',
    trn: '100-2340-8765-0003',
    industry: 'Trading & Distribution',
    address: 'Office 1402, Emaar Square, Downtown Dubai',
    contact: 'Layla Hassan · Facilities Manager',
    email: 'facilities@falcontrading.ae',
  );

  static const AppUser userIndividual = AppUser(
    name: 'Ahmed Al Mansoori', initials: 'AM', phone: '+971 50 123 4567',
    email: 'ahmed.m@gmail.com', kind: AccountKind.individual, addressLabel: 'Home · Dubai Marina',
  );

  static const AppUser userBusiness = AppUser(
    name: 'Layla Hassan', initials: 'LH', phone: '+971 50 998 1124',
    email: 'layla.h@falcontrading.ae', kind: AccountKind.business, addressLabel: 'HQ Tower · Downtown Dubai',
    company: company,
  );

  static const List<Address> individualAddresses = [
    Address(id: 'addr1', label: 'Home', line: 'Apt 1203, Marina Gate 1, Dubai Marina', city: 'Dubai', phone: '+971 50 123 4567', isDefault: true),
    Address(id: 'addr2', label: 'Work', line: 'Office 805, Boulevard Plaza Tower 1, Downtown', city: 'Dubai', phone: '+971 4 555 0182', isDefault: false),
  ];

  static const List<Invoice> individualInvoices = [
    Invoice(id: 'INV-2042', date: '01 May 2026', desc: 'PW90 · Monthly rental', amount: 294.00, status: 'paid'),
    Invoice(id: 'INV-1987', date: '01 Apr 2026', desc: 'PW90 · Monthly rental', amount: 294.00, status: 'paid'),
    Invoice(id: 'INV-1903', date: '02 Jan 2026', desc: 'S4 Sparkling · Purchase', amount: 2730.00, status: 'paid'),
    Invoice(id: 'INV-1844', date: '01 Mar 2026', desc: 'PW90 · Monthly rental', amount: 294.00, status: 'paid'),
  ];

  static const List<Invoice> businessInvoices = [
    Invoice(id: 'INV-B-5521', date: '01 May 2026', desc: 'Fleet rental · 4 devices', amount: 1333.50, status: 'paid'),
    Invoice(id: 'INV-B-5402', date: '01 Apr 2026', desc: 'Fleet rental · 4 devices', amount: 1333.50, status: 'due'),
    Invoice(id: 'INV-B-5288', date: '08 May 2026', desc: 'Maintenance · deep clean', amount: 210.00, status: 'paid'),
    Invoice(id: 'INV-B-5104', date: '04 Nov 2025', desc: 'S4 Sparkling · Purchase', amount: 2730.00, status: 'paid'),
  ];

  static const Map<String, bool> notifDefaults = {
    'maintenance': true, 'billing': true, 'orders': true, 'offers': false,
  };
}
