import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../services/database_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  final List<TextEditingController> _ingredientControllers = [TextEditingController()];
  final List<TextEditingController> _stepControllers = [TextEditingController()];

  String _selectedCategory = 'Breakfast';
  final List<String> _categories = ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack'];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    for (var controller in _ingredientControllers) {
      controller.dispose();
    }
    for (var controller in _stepControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers[index].dispose();
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addStepField() {
    setState(() {
      _stepControllers.add(TextEditingController());
    });
  }

  void _removeStepField(int index) {
    if (_stepControllers.length > 1) {
      setState(() {
        _stepControllers[index].dispose();
        _stepControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to add recipes')),
        );
        return;
      }

      List<String> ingredients = _ingredientControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      List<String> steps = _stepControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      String recipeId = DateTime.now().millisecondsSinceEpoch.toString();

      Recipe newRecipe = Recipe(
        id: recipeId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? 'https://images.unsplash.com/photo-1495521821757-a1efb6729352?w=500'
            : _imageUrlController.text.trim(),
        ingredients: ingredients,
        steps: steps,
        category: _selectedCategory,
        cookingTime: int.parse(_cookingTimeController.text),
        servings: int.parse(_servingsController.text),
        userId: authProvider.user!.id,
        createdAt: DateTime.now(),
      );

      try {
        await DatabaseService().addRecipe(newRecipe);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe added successfully!')),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Recipe Title *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.restaurant),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL (optional)',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cookingTimeController,
                    decoration: InputDecoration(
                      labelText: 'Time (min) *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: InputDecoration(
                      labelText: 'Servings *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: _addIngredientField,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._ingredientControllers.asMap().entries.map((entry) {
              int idx = entry.key;
              TextEditingController controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Ingredient ${idx + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.shopping_basket),
                        ),
                        validator: (value) {
                          if (idx == 0 && (value == null || value.isEmpty)) {
                            return 'At least one ingredient required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_ingredientControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeIngredientField(idx),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cooking Steps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.orange),
                  onPressed: _addStepField,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._stepControllers.asMap().entries.map((entry) {
              int idx = entry.key;
              TextEditingController controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Step ${idx + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: CircleAvatar(
                            backgroundColor: Colors.orange,
                            radius: 12,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (idx == 0 && (value == null || value.isEmpty)) {
                            return 'At least one step required';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (_stepControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeStepField(idx),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Recipe',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}