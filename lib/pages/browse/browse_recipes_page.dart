import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class _BrowseRecipesPageState extends State<BrowseRecipesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<dynamic> data = [];
  bool isLoading = true;
  bool isPopularLoading = true;
  String selectedMealType = 'all';
  Set<String> favoriteRecipeIds = {};
  List<dynamic> mostPopularRecipes = [];
  bool hasFetchedPopular = false;
  bool isMostPopularLoading = false;
  bool isMenuLoading = true;
  List<dynamic> menuData = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    fetchMostPopularRecipes();
    fetchAllMenusFromAllRestaurants();
    _recommendedRestaurantsFuture = fetchRecommendedRestaurants();
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
      isMostPopularLoading = true;
    });

    try {
      QuerySnapshot mostPopularSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      List<Map<String, dynamic>> popularRecipes = [];

      for (var restaurantDoc in mostPopularSnapshot.docs) {
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

        for (var mostPopularDoc in menuSnapshot.docs) {
          Map<String, dynamic> mostPopularItem =
              mostPopularDoc.data() as Map<String, dynamic>;

          QuerySnapshot reviewsSnapshot =
              await FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(restaurantId)
                  .collection('menu')
                  .doc(mostPopularDoc.id)
                  .collection('reviews')
                  .get();

          double totalRating = 0;
          int reviewCount = reviewsSnapshot.docs.length;

          for (var reviewDoc in reviewsSnapshot.docs) {
            double rating = (reviewDoc['rating'] as num).toDouble();
            totalRating += rating;
          }

          double averageRating =
              reviewCount > 0 ? totalRating / reviewCount : 0.0;
          popularRecipes.add({
            'restaurantId': restaurantId,
            'restaurantName': restaurantName,
            'restaurantPhotoUrl': restaurantPhotoUrl,
            'restaurantAddress': restaurantAddress,
            'menuId': mostPopularDoc.id,
            'name': mostPopularItem['name'],
            'imageUrl': mostPopularItem['imageUrl'],
            'price': mostPopularItem['price'],
            'category': mostPopularItem['category'],
            'rating': averageRating,
          });
        }
      }
      popularRecipes.sort((a, b) => b['rating'].compareTo(a['rating']));

      setState(() {
        mostPopularRecipes = popularRecipes;
      });
    } catch (e) {
      // Handle error
    } finally {
      if (!mounted) {
        isPopularLoading = false;
        isMostPopularLoading = false;
      } else {
        setState(() {
          isPopularLoading = false;
          isMostPopularLoading = false;
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

  Future<void> fetchAllMenusFromAllRestaurants() async {
    if (!mounted) return;
    setState(() {
      isMenuLoading = true;
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

      if (mounted) {
        setState(() {
          menuData = allMenus;
          menuData.shuffle();
          isMenuLoading = false;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (!mounted) {
        isMenuLoading = false;
      } else {
        setState(() {
          isMenuLoading = false;
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
    if (isMostPopularLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (mostPopularRecipes.isEmpty) {
      return const Center(child: Text("No popular recipes found."));
    }
    List<dynamic> popularRecipes = mostPopularRecipes.take(5).toList();
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
                        recipe['imageUrl'],
                        width: screenWidth * 0.37,
                        height: screenHeight * 0.16,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${recipe['restaurantName']} - ${recipe['restaurantAddress']}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
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
      future: _recommendedRestaurantsFuture,
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

  late Future<List<Map<String, dynamic>>> _recommendedRestaurantsFuture;

  Widget _recipeList() {
    if (isMenuLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (menuData.isEmpty) {
      return const Center(child: Text("No recipes found for this category."));
    }
    List<dynamic> recipeList = menuData.take(10).toList();

    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recipeList.length,
      itemBuilder: (context, index) {
        var recipe = recipeList[index];
        String menuId = recipe['menuId'].toString();
        bool isFavorite = favoriteRecipeIds.contains(menuId);

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
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:
                        (recipe['imageUrl'] != null && recipe['imageUrl'] != '')
                            ? ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              child: Image.network(
                                recipe['imageUrl'] ?? '',
                                width: screenWidth * 0.35,
                                height: screenHeight * 0.16,
                                fit: BoxFit.contain,
                              ),
                            )
                            : ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15),
                              ),
                              child: Image.network(
                                "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930",
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
                            width: MediaQuery.sizeOf(context).width * 0.35,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${recipe['restaurantName']} - ${recipe['restaurantAddress']}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                  _toggleFavorite(menuId, recipe);
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
