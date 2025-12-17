class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  final int cookingTime;
  final int servings;
  final String userId;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.cookingTime,
    required this.servings,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'cookingTime': cookingTime,
      'servings': servings,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      category: map['category'] ?? '',
      cookingTime: map['cookingTime'] ?? 0,
      servings: map['servings'] ?? 1,
      userId: map['userId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}