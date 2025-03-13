import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/recipe_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favorites",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20), //
            child: Icon(Icons.more_horiz_sharp, size: 24),
          ),
        ],
      ),
      body: SafeArea(child: _buildFavoriteRecipes()),
    );
  }

  Widget _buildFavoriteRecipes() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please log in to view favorites."));
    }

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    return StreamBuilder<QuerySnapshot>(
      stream: favoritesRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No favorite recipes yet."));
        }

        var favoriteRecipes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: favoriteRecipes.length,
          itemBuilder: (context, index) {
            var recipe = favoriteRecipes[index].data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipePage(recipe: recipe),
                  ),
                );
              },
              child: Card(
                elevation: 0,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      recipe['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    recipe['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("Category: ${recipe['mealType'].join(", ")}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      _removeFavorite(recipe['id'].toString());
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _removeFavorite(String recipeId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    try {
      await favoritesRef.doc(recipeId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from favorites")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to remove favorite: $e")));
    }
  }
}
