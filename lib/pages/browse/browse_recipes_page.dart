import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recepies_app/pages/profile/settings/update_profile_page.dart';
import 'package:recepies_app/pages/browse/recipe_page.dart';
import 'package:recepies_app/widgets/image_container.dart';

class BrowseRecipesPage extends StatefulWidget {
  const BrowseRecipesPage({super.key});

  @override
  State<BrowseRecipesPage> createState() => _BrowseRecipesPageState();
}

class _BrowseRecipesPageState extends State<BrowseRecipesPage> {
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
    fetchMostPopularRecipes();
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
      print("Error loading favorites: $e");
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
      print("Error updating favorite: $e");
    }
  }

  Future<void> fetchMostPopularRecipes() async {
    if (hasFetchedPopular) return;
    hasFetchedPopular = true;

    setState(() {
      isPopularLoading = true;
    });

    try {
      var res = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(res.body);

      setState(() {
        mostPopularRecipes = List.from(jsonData['recipes']);
        mostPopularRecipes.sort((a, b) {
          if (b['rating'] == a['rating']) {
            return b['reviewCount'].compareTo(a['reviewCount']);
          }
          return b['rating'].compareTo(a['rating']);
        });
        mostPopularRecipes = mostPopularRecipes.take(10).toList();
      });
    } catch (e) {
      print("Error fetching popular recipes $e");
    } finally {
      setState(() {
        isPopularLoading = false;
      });
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
                _sectionTitle("Most popular"),
                _popularRecipesList(),
                const SizedBox(height: 20),
                _sectionTitle("Choose your food"),
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

  Widget _sectionTitle(String title) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _profileMenu() {
    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName;
    String? photoUrl = user?.photoURL;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.95,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                ).then((updatedName) {
                  if (updatedName != null) {
                    setState(() {
                      userName = updatedName;
                    });
                  }
                });
              },
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    child: ImageContainer(
                      imageUrl: photoUrl,
                      width: 40,
                      height: 40,
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
      width: screenWidth * 0.95,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 10,
          children: List.generate(popularRecipes.length, (index) {
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
                width: screenWidth * 0.37,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        recipe['image'],
                        width: screenWidth * 0.37,
                        height: screenHeight * 0.16,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            alignment: Alignment.topLeft,
                            child: Text(
                              recipe['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${recipe['cookTimeMinutes']} mins",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${recipe['rating']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Calories: ${recipe['caloriesPerServing']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
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
