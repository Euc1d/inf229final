import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shopping_provider.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);

    if (authProvider.user != null) {
      await shoppingProvider.loadShoppingList(authProvider.user!.id);
    }
  }

  Future<void> _clearChecked() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);

    if (authProvider.user != null && shoppingProvider.checkedItems.isNotEmpty) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Checked Items'),
          content: const Text('Are you sure you want to remove all checked items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        await shoppingProvider.clearCheckedItems(authProvider.user!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked items cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shoppingProvider = Provider.of<ShoppingProvider>(context);

    if (shoppingProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final uncheckedItems = shoppingProvider.uncheckedItems;
    final checkedItems = shoppingProvider.checkedItems;
    final hasItems = uncheckedItems.isNotEmpty || checkedItems.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (checkedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearChecked,
              tooltip: 'Clear checked items',
            ),
        ],
      ),
      body: !hasItems
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Shopping list is empty',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Text(
              'Add ingredients from recipes!',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadShoppingList,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (uncheckedItems.isNotEmpty) ...[
              const Text(
                'To Buy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...uncheckedItems.map((item) => _buildShoppingItem(
                item,
                authProvider.user!.id,
              )),
            ],
            if (checkedItems.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Checked',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              ...checkedItems.map((item) => _buildShoppingItem(
                item,
                authProvider.user!.id,
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingItem(item, String userId) {
    final shoppingProvider = Provider.of<ShoppingProvider>(context, listen: false);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        shoppingProvider.deleteItem(userId, item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: CheckboxListTile(
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Text(
            'From: ${item.recipeName}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          value: item.isChecked,
          onChanged: (bool? value) {
            if (value != null) {
              shoppingProvider.toggleItemChecked(userId, item.id, value);
            }
          },
          activeColor: Colors.green,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}