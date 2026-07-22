/// Product model + sample catalogue (mirrors Shop.html data).
class Product {
  final String id;
  final String name;
  final String sub;
  final double price;
  final double? oldPrice; // set when discounted
  final int? discountPct;
  final String image; // asset path
  final String? tag; // 'seller' | 'new'
  final String? tagLabel;

  const Product({
    required this.id,
    required this.name,
    required this.sub,
    required this.price,
    this.oldPrice,
    this.discountPct,
    required this.image,
    this.tag,
    this.tagLabel,
  });

  bool get discounted => oldPrice != null;
}

// Catalogue is 1:1 with Shop.html (8 products, same ids / names / prices / images).
const kProducts = <Product>[
  Product(id: 'pw50-r', name: 'PW50-R', sub: 'Hot & Cold Water Dispenser', price: 621, oldPrice: 690, discountPct: 10, image: 'assets/images/pw50.png', tag: 'seller', tagLabel: 'Best Seller'),
  Product(id: 'pw30-c', name: 'PW30-C', sub: 'Countertop Water Dispenser', price: 590, image: 'assets/images/pw0ctr.png', tag: 'new', tagLabel: 'New'),
  Product(id: 'pw100-b', name: 'PW100-B', sub: '3 Taps Water Dispenser', price: 1480, image: 'assets/images/s4.png'),
  Product(id: 'pw-ro5', name: 'PW-RO5', sub: 'Reverse Osmosis System', price: 650, image: 'assets/images/ct.png'),
  Product(id: 'pw-ih07', name: 'PW-IH07', sub: '7-Stage RO System', price: 890, image: 'assets/images/pw90.png'),
  Product(id: 'pw-1088', name: 'PW-1088', sub: 'Big Blue Filter Housing', price: 120, image: 'assets/images/pw50.png'),
  Product(id: 'pw-cb10', name: 'PW-CB10', sub: 'Carbon Block Filter', price: 45, image: 'assets/images/pw0ctr.png'),
  Product(id: 'pw-uv11', name: 'PW-UV11', sub: 'UV Water Sterilizer', price: 189, image: 'assets/images/ct.png'),
];

/// A device owned/rented by a customer (mirrors the dashboard device lists).
class Device {
  final String name;
  final String type;
  final bool rented;
  final String tenure; // e.g. "36 months" or purchase date
  final String? nextDue; // rented: "£29 · 15 Jul 2026"
  final String? maintenanceOn; // e.g. "20 Jun 2026" when scheduled
  final bool ordered; // newly ordered / incoming
  final String? orderNo; // ordered: "#PW12612"
  final String? arriving; // ordered: "12 Jun 2026"
  final String? orderType; // ordered: "Purchase" | "Rental"
  const Device({
    required this.name,
    required this.type,
    required this.rented,
    required this.tenure,
    this.nextDue,
    this.maintenanceOn,
    this.ordered = false,
    this.orderNo,
    this.arriving,
    this.orderType,
  });
}

// Individuals hold a single active device plus (optionally) one incoming order.
// Mirrors Dashboard.html: PW50-R (rented, active) + PW30-C (ordered, purchase).
const kIndividualDevices = <Device>[
  Device(name: 'PW50-R', type: 'Hot & Cold Water Dispenser', rented: true, tenure: '36 months', nextDue: '£29 · 15 Jul 2026'),
  Device(name: 'PW30-C', type: 'Countertop Dispenser', rented: false, tenure: 'Purchase', ordered: true, orderNo: '#PW12612', arriving: '12 Jun 2026', orderType: 'Purchase'),
];
