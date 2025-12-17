class ShoppingItem {
  final String id;
  final String name;
  final bool isChecked;
  final String recipeId;
  final String recipeName;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
    required this.recipeId,
    required this.recipeName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
      'recipeId': recipeId,
      'recipeName': recipeName,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      isChecked: map['isChecked'] ?? false,
      recipeId: map['recipeId'] ?? '',
      recipeName: map['recipeName'] ?? '',
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
    String? recipeId,
    String? recipeName,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
    );
  }
}