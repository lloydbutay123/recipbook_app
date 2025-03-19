import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recepies_app/pages/browse/browse_restaurant.dart';
import 'package:recepies_app/pages/browse/restaurant_details.dart';
import 'package:recepies_app/pages/home/explore_page.dart';
import 'package:recepies_app/pages/browse/recipe_page.dart';
import 'package:recepies_app/widgets/profile_header.dart';
import 'package:recepies_app/widgets/section_title.dart';

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
    fetchRecommendedRestaurants();
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

  Future<void> fetchMostPopularRecipes() async {
    if (hasFetchedPopular) return;
    hasFetchedPopular = true;

    if (!mounted) return;
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
      // Handle error
    } finally {
      if (!mounted) {
        isPopularLoading = false;
      } else {
        setState(() {
          isPopularLoading = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchRecommendedRestaurants() async {
    try {
      QuerySnapshot restaurantSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      List<Map<String, dynamic>> recommendedRestaurants = [];

      for (var doc in restaurantSnapshot.docs) {
        String restaurantId = doc.id;

        QuerySnapshot reviewsSnapshot =
            await FirebaseFirestore.instance
                .collection('restaurants')
                .doc(restaurantId)
                .collection('reviews')
                .get();

        double totalRating = 0;
        int reviewCount = reviewsSnapshot.docs.length;

        for (var review in reviewsSnapshot.docs) {
          totalRating += (review['rating'] as num).toDouble();
        }

        double averageRating =
            reviewCount > 0 ? totalRating / reviewCount : 0.0;

        Map<String, dynamic> restaurantData =
            doc.data() as Map<String, dynamic>;
        restaurantData['averageRating'] = averageRating;

        recommendedRestaurants.add(restaurantData);
      }
      recommendedRestaurants.sort(
        (a, b) => b['averageRating'].compareTo(a['averageRating']),
      );

      return recommendedRestaurants;
    } catch (e) {
      return [];
    }
  }

  Future<void> fetchData(String mealType) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      var res = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(res.body);

      setState(() {
        if (mealType == "all") {
          data = jsonData['recipes'].take(10).toList();
        } else {
          data =
              jsonData['recipes']
                  .where(
                    (recipe) => (recipe['mealType'] as List)
                        .map((type) => type.toLowerCase())
                        .contains(mealType.toLowerCase()),
                  )
                  .take(10)
                  .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildUi()));
  }

  Widget _buildUi() {
    return Column(
      children: [
        ProfileHeader(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SectionTitle(title: "Most popular", onTap: () {}),
                _popularRecipesList(),
                const SizedBox(height: 20),
                SectionTitle(
                  title: "Restaurants you may like",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowseRestaurant(),
                      ),
                    );
                  },
                ),
                _recommendedRestaurants(),
                const SizedBox(height: 20),
                SectionTitle(
                  title: "Choose your food",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExplorePage()),
                    );
                  },
                ),
                _recipeList(),
              ],
            ),
          ),
        ),
      ],
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

  Widget _recommendedRestaurants() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchRecommendedRestaurants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No recommended restaurants found."));
        }

        List<Map<String, dynamic>> recommendedRestaurants =
            snapshot.data!.take(5).toList();
        double screenWidth = MediaQuery.sizeOf(context).width;
        double screenHeight = MediaQuery.sizeOf(context).height;

        return SizedBox(
          width: screenWidth * 0.95,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 10,
              children: List.generate(recommendedRestaurants.length, (index) {
                var restaurant = recommendedRestaurants[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                RestaurantDetails(restaurant: restaurant),
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
                            restaurant['photoUrl'],
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
                                  '${restaurant['name']} - ${restaurant['address']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    restaurant['averageRating'].toStringAsFixed(
                                      1,
                                    ),
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
      },
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
