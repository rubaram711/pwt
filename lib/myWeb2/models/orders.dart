/// Individual-customer order model + sample data for the dashboard Orders page.

enum OrderState { ongoing, completed, cancelled }

class OrderEvent {
  final String title, sub;
  final bool done, pending;
  const OrderEvent(this.title, this.sub, {this.done = false, this.pending = false});
}

class OrderLine {
  final String image, name, sub;
  final int qty;
  final String mode; // 'Purchase' | 'Rental'
  final String price;
  const OrderLine({required this.image, required this.name, required this.sub, this.qty = 1, this.mode = 'Purchase', required this.price});
}

class CustomerOrder {
  final String id;
  final String image, name, sub;
  final String date;
  final String total;
  final String status; // free-text → drives badge colour
  final OrderState state;

  // shared detail
  final List<OrderLine> items;
  final String deliveryName;
  final String deliveryAddress;
  final String paymentLabel;
  final String subtotal, vat;

  // ongoing
  final List<OrderEvent> tracking;
  final String etaSlot;

  // completed
  final String? deliveredOn;
  final String? installedOn;
  final String? invoiceId;
  final String? warrantyUntil;
  final String? technician;

  // cancelled
  final String? cancelledOn;
  final String? refund;

  const CustomerOrder({
    required this.id,
    required this.image,
    required this.name,
    required this.sub,
    required this.date,
    required this.total,
    required this.status,
    required this.state,
    this.items = const [],
    this.deliveryName = 'Sarah Johnson',
    this.deliveryAddress = '12 Green Park Road, London, SW1A 2AA',
    this.paymentLabel = 'Visa •••• 4242',
    this.subtotal = '',
    this.vat = '',
    this.tracking = const [],
    this.etaSlot = '',
    this.deliveredOn,
    this.installedOn,
    this.invoiceId,
    this.warrantyUntil,
    this.technician,
    this.cancelledOn,
    this.refund,
  });
}

const kCustomerOrders = <CustomerOrder>[
  // -------- ongoing: out for delivery --------
  CustomerOrder(
    id: '#PWT-2026-04871',
    image: 'pw90.png',
    name: 'PW50-R',
    sub: 'Hot & Cold Dispenser',
    date: '30 May 2026',
    total: '£690',
    status: 'Out for delivery',
    state: OrderState.ongoing,
    subtotal: '£575',
    vat: '£115',
    etaSlot: 'Today · arriving 8:00–12:00',
    items: [
      OrderLine(image: 'pw90.png', name: 'PW50-R', sub: 'Hot & Cold Dispenser', price: '£690'),
    ],
    tracking: [
      OrderEvent('Order confirmed', '30 May, 09:24', done: true),
      OrderEvent('Payment received', '30 May, 09:25', done: true),
      OrderEvent('Dispatched from warehouse', '31 May, 14:10', done: true),
      OrderEvent('Out for delivery', 'Today · arriving 8:00–12:00'),
      OrderEvent('Installation', '4 June · Morning slot', pending: true),
    ],
  ),
  // -------- ongoing: processing --------
  CustomerOrder(
    id: '#PWT-2026-04863',
    image: 'pw0ctr.png',
    name: 'PW30-C',
    sub: 'Countertop Dispenser',
    date: '30 May 2026',
    total: '£590',
    status: 'Processing',
    state: OrderState.ongoing,
    subtotal: '£492',
    vat: '£98',
    etaSlot: 'Estimated dispatch 2 Jun',
    items: [
      OrderLine(image: 'pw0ctr.png', name: 'PW30-C', sub: 'Countertop Dispenser', price: '£590'),
    ],
    tracking: [
      OrderEvent('Order confirmed', '30 May, 11:02', done: true),
      OrderEvent('Payment received', '30 May, 11:03', done: true),
      OrderEvent('Preparing your order', 'In warehouse · packing'),
      OrderEvent('Dispatch', 'Estimated 2 June', pending: true),
      OrderEvent('Delivery & installation', 'To be scheduled', pending: true),
    ],
  ),
  // -------- completed: installed --------
  CustomerOrder(
    id: '#PWT-2026-04602',
    image: 's4.png',
    name: 'PW100-B',
    sub: '3 Taps Dispenser',
    date: '18 May 2026',
    total: '£1,480',
    status: 'Installed',
    state: OrderState.completed,
    subtotal: '£1,233',
    vat: '£247',
    deliveredOn: '21 May 2026',
    installedOn: '22 May 2026 · Morning slot',
    invoiceId: 'INV-2026-0081',
    warrantyUntil: '22 May 2028',
    technician: 'David Roberts',
    items: [
      OrderLine(image: 's4.png', name: 'PW100-B', sub: '3 Taps Dispenser', price: '£1,480'),
    ],
  ),
  // -------- completed: delivered --------
  CustomerOrder(
    id: '#PWT-2026-04188',
    image: 'pw50.png',
    name: 'PW50-R',
    sub: 'Hot & Cold Dispenser',
    date: '02 May 2026',
    total: '£690',
    status: 'Delivered',
    state: OrderState.completed,
    subtotal: '£575',
    vat: '£115',
    deliveredOn: '05 May 2026',
    installedOn: '05 May 2026 · Afternoon slot',
    invoiceId: 'INV-2026-0066',
    warrantyUntil: '05 May 2028',
    technician: 'Sana Khan',
    items: [
      OrderLine(image: 'pw50.png', name: 'PW50-R', sub: 'Hot & Cold Dispenser', price: '£690'),
    ],
  ),
  // -------- cancelled --------
  CustomerOrder(
    id: '#PWT-2026-03970',
    image: 'ct.png',
    name: 'PW-RO5',
    sub: 'Reverse Osmosis',
    date: '21 Apr 2026',
    total: '£650',
    status: 'Cancelled',
    state: OrderState.cancelled,
    subtotal: '£542',
    vat: '£108',
    cancelledOn: '22 Apr 2026',
    refund: '£650 refunded to Visa •••• 4242 on 23 Apr 2026',
    invoiceId: 'INV-2026-0059',
    items: [
      OrderLine(image: 'ct.png', name: 'PW-RO5', sub: 'Reverse Osmosis', price: '£650'),
    ],
  ),
];
