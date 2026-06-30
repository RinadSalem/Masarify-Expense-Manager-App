

class UserModel {
  final int? id;
  final String name;
  final String password;
  final String? email; 
  final int? age;      

  UserModel({
    this.id,
    required this.name,
    required this.password,
    this.email, 
    this.age,   
  });

  
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      password: map['password'] as String,
      email: map['email'] as String?, 
      age: map['age'] as int?,        
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'password': password,
      'email': email, 
      'age': age,     
    };
  }

  
  UserModel copyWith({
    int? id, 
    String? name, 
    String? password,
    String? email, 
    int? age,      
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      email: email ?? this.email, 
      age: age ?? this.age,       
    );
  }
}