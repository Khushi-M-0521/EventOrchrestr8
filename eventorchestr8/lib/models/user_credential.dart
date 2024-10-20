class UserCredentialModel {
  String uid;
  String createdAt;
  String? email;
  String? phoneNumber;
  int password;

  UserCredentialModel(
      {required this.uid,
      required this.createdAt,
      required this.email,
      required this.phoneNumber,
      required this.password});

  //from map, ie , from server
  factory UserCredentialModel.fromMap(Map<String, dynamic> map) {
    return UserCredentialModel(
      uid: map['uid'] ?? '',
      createdAt: map['createdAt'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNmber'] ?? '',
      password: map['password'] ?? '',
    );
  }

  //to map,ie, to server
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "createdAt": createdAt,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
    };
  }
}
