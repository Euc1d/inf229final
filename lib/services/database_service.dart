import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Recipe>> getRecipes(String userId) async {
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('recipes')
          .where('userId', isEqualTo: userId)
          .get();

      QuerySnapshot defaultSnapshot = await _firestore
          .collection('recipes')
          .where('userId', isEqualTo: 'default')
          .get();

      List<Recipe> userRecipes = userSnapshot.docs
          .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      List<Recipe> defaultRecipes = defaultSnapshot.docs
          .map((doc) => Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return [...defaultRecipes, ...userRecipes];
    } catch (e) {
      print('Error getting recipes: $e');
      return [];
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _firestore.collection('recipes').add(recipe.toMap());
      print('Recipe added successfully');
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _firestore.collection('recipes').doc(recipe.id).update(recipe.toMap());
      print('Recipe updated successfully');
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection('recipes').doc(recipeId).delete();
      print('Recipe deleted successfully');
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }

  Future<Recipe?> getRecipeById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('recipes').doc(id).get();
      if (doc.exists) {
        return Recipe.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting recipe: $e');
      return null;
    }
  }

  Future<List<Recipe>> getFavoriteRecipes(List<String> recipeIds) async {
    if (recipeIds.isEmpty) return [];

    try {
      List<Recipe> favorites = [];
      for (String id in recipeIds) {
        Recipe? recipe = await getRecipeById(id);
        if (recipe != null) {
          favorites.add(recipe);
        }
      }
      return favorites;
    } catch (e) {
      print('Error getting favorite recipes: $e');
      return [];
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
      print('Favorite toggled successfully');
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }
}