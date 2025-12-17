import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';

class ShoppingProvider extends ChangeNotifier {
  final ShoppingService _shoppingService = ShoppingService();
  List<ShoppingItem> _items = [];
  bool _isLoading = false;

  List<ShoppingItem> get items => _items;
  bool get isLoading => _isLoading;

  List<ShoppingItem> get uncheckedItems =>
      _items.where((item) => !item.isChecked).toList();

  List<ShoppingItem> get checkedItems =>
      _items.where((item) => item.isChecked).toList();

  Future<void> loadShoppingList(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _shoppingService.getShoppingList(userId);
    } catch (e) {
      print('Error loading shopping list: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleItemChecked(String userId, String itemId, bool isChecked) async {
    try {
      await _shoppingService.toggleItemChecked(userId, itemId, isChecked);

      int index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(isChecked: isChecked);
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling item: $e');
    }
  }

  Future<void> deleteItem(String userId, String itemId) async {
    try {
      await _shoppingService.deleteShoppingItem(userId, itemId);
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  Future<void> clearCheckedItems(String userId) async {
    try {
      await _shoppingService.clearCheckedItems(userId);
      _items.removeWhere((item) => item.isChecked);
      notifyListeners();
    } catch (e) {
      print('Error clearing checked items: $e');
    }
  }

  Future<void> addIngredientsFromRecipe(
      String userId,
      String recipeId,
      String recipeName,
      List<String> ingredients,
      ) async {
    try {
      await _shoppingService.addIngredientsFromRecipe(
        userId,
        recipeId,
        recipeName,
        ingredients,
      );
      await loadShoppingList(userId);
    } catch (e) {
      print('Error adding ingredients: $e');
      rethrow;
    }
  }
}