class UserDetailModel {
  String uid;
  String name;
  String profilePicture;
  int age;

  UserDetailModel( {
    required this.uid,
    required this.name,
    required this.profilePicture,
    required this.age,
  });

  factory UserDetailModel.fromMap(Map<String, dynamic> map) {
    return UserDetailModel(
      uid: map['uid']??'',
      name: map['name']??'',
      profilePicture: map['profilePicture']??'',
      age: map['age']??'',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "profilePicture":profilePicture,
      "age":age,
    };
  }
}
