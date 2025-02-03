class AddressModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String alternatePhone;
  final String pincode;
  final String state;
  final String city;
  final String houseNo;
  final String roadName;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.alternatePhone,
    required this.pincode,
    required this.state,
    required this.city,
    required this.houseNo,
    required this.roadName,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json, String id) {
    return AddressModel(
      id: id,
      name: json["name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      alternatePhone: json["alternatePhone"] ?? "",
      pincode: json["pincode"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      houseNo: json["houseNo"] ?? "",
      roadName: json["roadName"] ?? "",
      isDefault: json["isDefault"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "alternatePhone": alternatePhone,
      "pincode": pincode,
      "state": state,
      "city": city,
      "houseNo": houseNo,
      "roadName": roadName,
      "isDefault": isDefault,
    };
  }
}