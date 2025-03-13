import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recepies_app/pages/recipe_page.dart';

class BrowseRecipesPage extends StatefulWidget {
  const BrowseRecipesPage({super.key});

  @override
  State<BrowseRecipesPage> createState() => _BrowseRecipesPageState();
}

class _BrowseRecipesPageState extends State<BrowseRecipesPage> {
  final String url = "https://dummyjson.com/recipes";
  List<dynamic> data = [];
  bool isLoading = true;
  String selectedMealType = 'all';
  Set<String> favoriteRecipeIds = {};
  List<dynamic> mostPopularRecipes = [];

  @override
  void initState() {
    super.initState();
    fetchData("all");
    _loadFavorites();
  }

  void _loadFavorites() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    try {
      QuerySnapshot snapshot = await favoritesRef.get();
      setState(() {
        favoriteRecipeIds =
            snapshot.docs
                .map((doc) => doc.id)
                .toSet(); // Store favorites in state
      });
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  void _saveFavorite(String recipeId, Map<String, dynamic> recipe) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    try {
      await favoritesRef.doc(recipeId).set(recipe);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe added to favorites.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add recipe to favorites: $e")),
      );
    }
  }

  void _toggleFavorite(String recipeId, Map<String, dynamic> recipe) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites');

    try {
      setState(() {
        if (favoriteRecipeIds.contains(recipeId)) {
          favoriteRecipeIds.remove(recipeId);
        } else {
          favoriteRecipeIds.add(recipeId);
        }
      });

      if (favoriteRecipeIds.contains(recipeId)) {
        await favoritesRef.doc(recipeId).set(recipe);
      } else {
        await favoritesRef.doc(recipeId).delete();
      }
    } catch (e) {
      print("Error updating favorite: $e");
    }
  }

  Future<void> fetchData(String mealType) async {
    setState(() {
      isLoading = true;
    });

    try {
      var res = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(res.body);

      setState(() {
        if (mostPopularRecipes.isEmpty) {
          mostPopularRecipes = List.from(
            jsonData['recipes'],
          ); // Store all recipes
          mostPopularRecipes.sort((a, b) {
            if (b['rating'] == a['rating']) {
              return b['reviewCount'].compareTo(a['reviewCount']);
            }
            return b['rating'].compareTo(a['rating']);
          });
        }
        if (mealType == "all") {
          data = jsonData['recipes'];
        } else {
          data =
              jsonData['recipes']
                  .where(
                    (recipe) => (recipe['mealType'] as List)
                        .map((type) => type.toLowerCase())
                        .contains(mealType.toLowerCase()),
                  )
                  .toList();
        }
      });
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildUi()));
  }

  Widget _buildUi() {
    return Column(
      children: [
        _profileMenu(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Most Popular",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "See all",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
                _popularRecipesList(),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.90,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Choose your food",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "See all",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
                _recipeTypeButtons(),
                const SizedBox(height: 10),
                _recipeList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileMenu() {
    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  child: Image.asset(
                    "assets/images/johnlloyd.jpg",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello 👋",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$userName",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _recipeTypeButtons() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.06,
      width: MediaQuery.sizeOf(context).width * 0.90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMealButton("all", "🍽️ All"),
          _buildMealButton("snack", "🍿 Snack"),
          _buildMealButton("breakfast", "🍳 Breakfast"),
          _buildMealButton("lunch", "🍗 Lunch"),
          _buildMealButton("dinner", "🍽️ Dinner"),
        ],
      ),
    );
  }

  Widget _buildMealButton(String mealType, String label) {
    bool isSelected = selectedMealType == mealType;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: FilledButton(
        onPressed: () {
          setState(() {
            selectedMealType = mealType;
          });
          fetchData(mealType); // Fetch filtered data
        },
        style: FilledButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.orangeAccent : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _popularRecipesList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data.isEmpty) {
      return const Center(child: Text("No popular recipes found."));
    }
    List<dynamic> popularRecipes = data.take(5).toList();
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight * 0.20,
      width: screenWidth * 0.90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularRecipes.length,
        itemBuilder: (context, index) {
          var recipe = popularRecipes[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipePage(recipe: recipe),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.only(right: 10),
              width: screenWidth * 0.55,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          recipe['image'],
                          width: screenWidth * 0.55,
                          height: screenHeight * 0.15,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        recipe['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _recipeList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(child: Text("No recipes found for this category."));
    }

    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var recipe = data[index];
        String recipeId = recipe['id'].toString();
        bool isFavorite = favoriteRecipeIds.contains(recipeId);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipePage(recipe: recipe),
              ),
            );
          },
          child: SizedBox(
            height: screenHeight * 0.18,
            child: Card(
              elevation: 0,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  // Image filling full height
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Image.network(
                        recipe['image'],
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Content aligned to the start
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Category: ${recipe['mealType'].join(", ")}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${recipe['rating']} ⭐",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {},
                              ),
                              IconButton(
                                onPressed: () {
                                  _toggleFavorite(recipeId, recipe);
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      isFavorite
                                          ? Colors.red
                                          : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
