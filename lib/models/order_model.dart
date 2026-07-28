class OrderItemModel {
  final String proname;
  final String uname;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  OrderItemModel({
    required this.proname,
    required this.uname,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      proname: json['proname'],
      uname: json['uname'],
      qty: json['qty'],
      unitPrice: double.parse(json['unit_price'].toString()),
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }
}

class OrderModel {
  final int orderid;
  final String orderCode;
  final String type;
  final String paymentMethod;
  final double total;
  final String status;
  final String createdAt;
  final String? rejectReason;
  final String? slipImageUrl;
  final int itemCount;
  final List<OrderItemModel> items;

  OrderModel({
    required this.orderid,
    required this.orderCode,
    required this.type,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.createdAt,
    this.rejectReason,
    this.slipImageUrl,
    this.itemCount = 0,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? [])
        .map((i) => OrderItemModel.fromJson(i))
        .toList();

    return OrderModel(
      orderid: json['orderid'],
      orderCode: json['order_code'],
      type: json['type'] ?? 'Online',
      paymentMethod: json['payment_method'] ?? 'ເງີນໂອນ',
      total: double.parse(json['total'].toString()),
      status: json['status'],
      createdAt: json['created_at'],
      rejectReason: json['reject_reason'],
      slipImageUrl: json['slip_image_url'],
      itemCount: json['item_count'] != null
          ? int.parse(json['item_count'].toString())
          : itemsList.length,
      items: itemsList,
    );
  }

  // ===== status ตรงตัวอักษรจาก backend เสมอ ตามที่ตกลงกันไว้ =====
  bool get isPaid => status == 'ຈ່າຍສຳເລັດ';
  bool get isPending => status == 'ລໍຖ້າຢືນຢັນການຊຳລະ';
  bool get isRejected => status == 'ປະຕິເສດ';
  bool get isCancelled => status == 'ຍົກເລີກ';
}
