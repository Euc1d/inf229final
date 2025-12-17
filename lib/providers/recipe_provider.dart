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

    // Фильтр по категории
    if (_selectedCategory != 'All') {
      filtered = filtered.where((recipe) => recipe.category == _selectedCategory).toList();
    }

    // Фильтр по поиску
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

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _databaseService.getRecipes();
    } catch (e) {
      print('Error loading recipes: $e');
    }

    _isLoading = false;
    notifyListeners();
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

  Future<void> deleteRecipe(String recipeId) async {
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