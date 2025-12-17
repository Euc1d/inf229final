import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    if (authProvider.user != null) {
      await recipeProvider.loadFavoriteRecipes(authProvider.user!.favoriteRecipes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final favoriteRecipes = recipeProvider.favoriteRecipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: favoriteRecipes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              'Start adding recipes to your favorites!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                ).then((_) => _loadFavorites());
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        recipe.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            recipe.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(
                                '${recipe.cookingTime} min',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const SizedBox(width: 15),
                              Icon(Icons.restaurant, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 5),
                              Text(
                                recipe.category,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.favorite, color: Colors.red),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}