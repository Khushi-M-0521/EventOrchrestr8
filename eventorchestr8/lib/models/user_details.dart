class UserDetailModel {
  String uid;
  String name;
  String profilePicture;
  int age;
  List? owned_communities;

  UserDetailModel( {
    required this.uid,
    required this.name,
    required this.profilePicture,
    required this.age,
    this.owned_communities,
  });

  factory UserDetailModel.fromMap(Map<String, dynamic> map) {
    return UserDetailModel(
      uid: map['uid']??'',
      name: map['name']??'',
      profilePicture: map['profilePicture']??'',
      age: map['age']??'',
      owned_communities: map['owned_communities']??'',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "profilePicture":profilePicture,
      "age":age,
      "owned_communities":owned_communities,
    };
  }
}
