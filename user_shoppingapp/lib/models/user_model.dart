class UserModel {
  final String name;
  final String email;
  final String phone;
  final String alternatePhone;
  final String pincode;
  final String state;
  final String city;
  final String houseNo;
  final String roadName;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.alternatePhone,
    required this.pincode,
    required this.state,
    required this.city,
    required this.houseNo,
    required this.roadName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "User",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      alternatePhone: json["alternatePhone"] ?? "",
      pincode: json["pincode"] ?? "",
      state: json["state"] ?? "",
      city: json["city"] ?? "",
      houseNo: json["houseNo"] ?? "",
      roadName: json["roadName"] ?? "",
    );
  }
}
