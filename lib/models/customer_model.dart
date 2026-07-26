class CustomerModel {
  final int cid;
  final String phone;

  CustomerModel({required this.cid, required this.phone});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(cid: json['cid'], phone: json['phone']);
  }

  Map<String, dynamic> toJson() => {'cid': cid, 'phone': phone};
}
