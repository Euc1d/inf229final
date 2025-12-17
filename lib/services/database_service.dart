import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Recipe>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting recipes by category: $e');
      return [];
    }
  }

  Future<Recipe?> getRecipeById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('recipes').doc(id).get();
      if (doc.exists) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting recipe: $e');
    }
    return null;
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _firestore.collection('recipes').doc(recipe.id).set(recipe.toMap());
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite(String userId, String recipeId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot snapshot = await userDoc.get();

      List<String> favorites = List<String>.from(snapshot.get('favoriteRecipes') ?? []);

      if (favorites.contains(recipeId)) {
        favorites.remove(recipeId);
      } else {
        favorites.add(recipeId);
      }

      await userDoc.update({'favoriteRecipes': favorites});
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<List<Recipe>> getFavoriteRecipes(List<String> recipeIds) async {
    if (recipeIds.isEmpty) return [];

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('recipes')
          .where(FieldPath.documentId, whereIn: recipeIds)
          .get();

      return snapshot.docs
          .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting favorite recipes: $e');
      return [];
    }
  }
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection('recipes').doc(recipeId).delete();
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }
}