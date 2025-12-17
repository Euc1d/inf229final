import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_item.dart';

class ShoppingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ShoppingItem>> getShoppingList(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => ShoppingItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting shopping list: $e');
      return [];
    }
  }

  Future<void> addShoppingItem(String userId, ShoppingItem item) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(item.id)
          .set(item.toMap());
    } catch (e) {
      print('Error adding shopping item: $e');
      rethrow;
    }
  }

  Future<void> toggleItemChecked(String userId, String itemId, bool isChecked) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(itemId)
          .update({'isChecked': isChecked});
    } catch (e) {
      print('Error toggling item: $e');
      rethrow;
    }
  }

  Future<void> deleteShoppingItem(String userId, String itemId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error deleting shopping item: $e');
      rethrow;
    }
  }

  Future<void> clearCheckedItems(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .where('isChecked', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing checked items: $e');
      rethrow;
    }
  }

  Future<void> addIngredientsFromRecipe(
      String userId,
      String recipeId,
      String recipeName,
      List<String> ingredients,
      ) async {
    try {
      for (var ingredient in ingredients) {
        String itemId = DateTime.now().millisecondsSinceEpoch.toString() + ingredient.hashCode.toString();
        ShoppingItem item = ShoppingItem(
          id: itemId,
          name: ingredient,
          recipeId: recipeId,
          recipeName: recipeName,
        );
        await addShoppingItem(userId, item);
      }
    } catch (e) {
      print('Error adding ingredients: $e');
      rethrow;
    }
  }
}