class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> favoriteRecipes;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.favoriteRecipes,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      favoriteRecipes: List<String>.from(data['favoriteRecipes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'favoriteRecipes': favoriteRecipes,
    };
  }
}