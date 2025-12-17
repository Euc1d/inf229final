import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/database_service.dart';

class RecipeProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Recipe> _recipes = [];
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<Recipe> get recipes => _recipes;
  List<Recipe> get favoriteRecipes => _favoriteRecipes;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Recipe> get filteredRecipes {
    List<Recipe> filtered = _recipes;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((recipe) => recipe.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((recipe) {
        final titleMatch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
        final descMatch = recipe.description.toLowerCase().contains(_searchQuery.toLowerCase());
        final ingredientMatch = recipe.ingredients.any(
                (ingredient) => ingredient.toLowerCase().contains(_searchQuery.toLowerCase())
        );
        return titleMatch || descMatch || ingredientMatch;
      }).toList();
    }

    return filtered;
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> loadRecipes(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _databaseService.getRecipes(userId);
    } catch (e) {
      print('Error loading recipes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRecipe(Recipe recipe) async {
    try {
      await _databaseService.addRecipe(recipe);
      _recipes.add(recipe);
      notifyListeners();
    } catch (e) {
      print('Error adding recipe: $e');
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    try {
      await _databaseService.updateRecipe(recipe);
      final index = _recipes.indexWhere((r) => r.id == recipe.id);
      if (index != -1) {
        _recipes[index] = recipe;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }

  Future<void> loadFavoriteRecipes(List<String> recipeIds) async {
    try {
      _favoriteRecipes = await _databaseService.getFavoriteRecipes(recipeIds);
      notifyListeners();
    } catch (e) {
      print('Error loading favorite recipes: $e');
    }
  }

  Future<void> toggleFavorite(String userId, String recipeId) async {
    try {
      await _databaseService.toggleFavorite(userId, recipeId);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<Recipe?> getRecipeById(String id) async {
    return await _databaseService.getRecipeById(id);
  }

  Future<void> deleteRecipe(String recipeId, String userId) async {
    try {
      await _databaseService.deleteRecipe(recipeId);
      _recipes.removeWhere((recipe) => recipe.id == recipeId);
      notifyListeners();
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }
}