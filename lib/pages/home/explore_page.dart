import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recepies_app/pages/browse/recipe_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final String url = "https://dummyjson.com/recipes";
  List<dynamic> data = [];
  bool isLoading = true;
  String selectedMealType = 'all';
  Set<String> favoriteRecipeIds = {};

  @override
  void initState() {
    super.initState();
    fetchData("all");
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

  // Fetch data based on selected meal type
  Future<void> fetchData(String mealType) async {
    setState(() {
      isLoading = true;
    });

    try {
      var res = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(res.body);

      setState(() {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Explore Food",
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
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz_sharp, size: 24),
            ),
          ),
        ],
      ),

      body: SafeArea(child: _buildUi()),
    );
  }

  Widget _buildUi() {
    return Column(
      children: [
        _recipeTypeButtons(),
        const SizedBox(height: 10),
        Expanded(child: _recipeList()),
      ],
    );
  }

  Widget _recipeTypeButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.06,
        width: MediaQuery.sizeOf(context).width * 0.95,
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
      ),
    );
  }

  // Function to create filter buttons dynamically
  Widget _buildMealButton(String mealType, String label) {
    bool isSelected = selectedMealType == mealType;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilledButton(
        onPressed: () {
          setState(() {
            selectedMealType = mealType;
          });
          fetchData(mealType); // Fetch filtered data
        },
        style: FilledButton.styleFrom(
          backgroundColor: isSelected ? Colors.orangeAccent : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _recipeList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Show loading indicator
    }

    if (data.isEmpty) {
      return const Center(child: Text("No recipes found for this category."));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var recipe = data[index];
        String recipeId = recipe['id'].toString();

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
            height: 150, // Fixed height for the card
            child: Card(
              elevation: 0, // Removes shadow
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        width: MediaQuery.sizeOf(context).width * 0.35,
                        height: double.infinity, // Full height of SizedBox
                        fit: BoxFit.cover, // Ensures the image fills its space
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
                            width: MediaQuery.sizeOf(context).width * 0.35,
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center, // Centers vertically
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start, // Aligns text at the start
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
                              Icon(
                                Icons.more_vert,
                                color: Colors.grey.shade400,
                              ),
                              IconButton(
                                onPressed: () {
                                  _saveFavorite(recipeId, recipe);
                                },
                                icon: Icon(
                                  Icons.favorite_outline,
                                  color: Colors.grey.shade400,
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
