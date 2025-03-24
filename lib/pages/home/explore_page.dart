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
  bool isPopularLoading = true;
  String selectedMealType = 'all';
  Set<String> favoriteRecipeIds = {};
  List<dynamic> mostPopularRecipes = [];
  bool hasFetchedPopular = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    fetchData("all");
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
        favoriteRecipeIds = snapshot.docs.map((doc) => doc.id).toSet();
      });
    } catch (e) {
      // Handle error
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
      DocumentSnapshot docSnapshot = await favoritesRef.doc(recipeId).get();

      setState(() {
        if (docSnapshot.exists) {
          favoritesRef.doc(recipeId).delete();
          favoriteRecipeIds.remove(recipeId);
        } else {
          favoritesRef.doc(recipeId).set(recipe);
          favoriteRecipeIds.add(recipeId);
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Explore Foods")),
      body: SafeArea(child: _buildUi()),
    );
  }

  Widget _buildUi() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
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

  Widget _recipeTypeButtons() {
    return SizedBox(
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
    );
  }

  Widget _buildMealButton(String mealType, String label) {
    bool isSelected = selectedMealType == mealType;
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: FilledButton(
        onPressed: () {
          setState(() {
            selectedMealType = mealType;
          });
          fetchData(mealType);
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

  Future<void> fetchData(String mealType) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot restaurantSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      List<Map<String, dynamic>> allMenus = [];

      for (var restaurantDoc in restaurantSnapshot.docs) {
        String restaurantId = restaurantDoc.id;
        String restaurantName = restaurantDoc['name'] ?? "Unknown Restaurant";
        String restaurantPhotoUrl = restaurantDoc['photoUrl'] ?? "";
        String restaurantAddress = restaurantDoc['address'] ?? "";

        QuerySnapshot menuSnapshot =
            await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantId)
                .collection('menu')
                .get();

        for (var menuDoc in menuSnapshot.docs) {
          Map<String, dynamic> menuItem =
              menuDoc.data() as Map<String, dynamic>;

          QuerySnapshot reviewsSnapshot =
              await FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(restaurantId)
                  .collection('menu')
                  .doc(menuDoc.id)
                  .collection('reviews')
                  .get();

          double totalRating = 0;
          int reviewCount = reviewsSnapshot.docs.length;

          for (var review in reviewsSnapshot.docs) {
            totalRating += (review['rating'] as num).toDouble();
          }

          double averageRating =
              reviewCount > 0 ? totalRating / reviewCount : 0.0;

          menuItem['restaurantId'] = restaurantId;
          menuItem['restaurantName'] = restaurantName;
          menuItem['restaurantPhotoUrl'] = restaurantPhotoUrl;
          menuItem['menuId'] = menuDoc.id;
          menuItem['restaurantAddress'] = restaurantAddress;
          menuItem['averageRating'] = averageRating;

          allMenus.add(menuItem);
        }
      }

      setState(() {
        if (mealType == "all") {
          data = allMenus;
          data.shuffle();
        } else {
          data =
              allMenus.where((recipe) {
                String category =
                    (recipe['category'] ?? '').toString().toLowerCase();
                return category == mealType.toLowerCase();
              }).toList();
        }
      });
    } catch (e) {
      // Handle error
    } finally {
      if (!mounted) {
        isLoading = false;
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
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
        String recipeId = recipe['menuId'].toString();
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
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        recipe['imageUrl'],
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.16,
                        fit: BoxFit.contain,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${recipe['restaurantName']} - ${recipe['restaurantAddress']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.yellow),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${recipe['averageRating']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "P ${recipe['price'].toString()}",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
