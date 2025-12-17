class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> favoriteRecipes;
  final String? avatarPath;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.favoriteRecipes,
    this.avatarPath,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      favoriteRecipes: List<String>.from(data['favoriteRecipes'] ?? []),
      avatarPath: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'favoriteRecipes': favoriteRecipes,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? favoriteRecipes,
    String? avatarPath,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}