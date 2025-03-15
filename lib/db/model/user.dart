class User {
  final int? id;
  final String name;
  final String username;
  final String password;

  User({
    this.id,
    required this.name,
    required this.username,
    required this.password,
  });

  // Convert a User into a Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'username': username, 'password': password};
  }

  // Convert a Map into a User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      password: map['password'],
    );
  }
}
