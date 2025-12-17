class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int cookingTime;
  final int servings;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String userId;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.userId,
    required this.createdAt,
  });

  factory Recipe.fromMap(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Other',
      cookingTime: data['cookingTime'] ?? 0,
      servings: data['servings'] ?? 1,
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'cookingTime': cookingTime,
      'servings': servings,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}