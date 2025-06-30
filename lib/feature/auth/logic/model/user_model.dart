

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;  
  

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profilePicture: json['photoURL'] as String?,
     
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': profilePicture,
      
    };
  }
}