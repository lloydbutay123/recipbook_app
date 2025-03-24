import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/browse/restaurant_details.dart';

class BrowseRestaurant extends StatefulWidget {
  const BrowseRestaurant({super.key});

  @override
  State<BrowseRestaurant> createState() => _BrowseRestaurantState();
}

class _BrowseRestaurantState extends State<BrowseRestaurant> {
  List<Map<String, dynamic>> restaurants = [];
  Set<String> favoriteRestaurantIds = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recommended for you")),
      body: SafeArea(child: _buildUi()),
    );
  }

  Widget _buildUi() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [_restaurantList()]),
          ),
        ),
      ],
    );
  }

  Future<void> fetchRestaurants() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot restaurantSnapshot =
          await FirebaseFirestore.instance.collection('restaurants').get();

      List<Map<String, dynamic>> fetchedRestaurants = [];

      for (var doc in restaurantSnapshot.docs) {
        String restaurantId = doc.id;

        // Fetch reviews to calculate average rating
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
        restaurantData['restaurantId'] = restaurantId;

        fetchedRestaurants.add(restaurantData);
      }

      setState(() {
        restaurants = fetchedRestaurants;
      });
    } catch (e) {
      // ignore: avoid_catches_without_on_clauses
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

  Widget _restaurantList() {
    if (isLoading) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (restaurants.isEmpty) {
      return const Center(child: Text("No restaurants found."));
    }

    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        var restaurant = restaurants[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestaurantDetails(restaurant: restaurant),
              ),
            );
          },
          child: SizedBox(
            height: screenHeight * 0.18,
            child: Card(
              elevation: 0,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: Image.network(
                        restaurant['photoUrl'],
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.16,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/placeholder.png',
                            width: screenWidth * 0.35,
                            height: screenHeight * 0.16,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${restaurant['name']} - ${restaurant['address']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${restaurant['averageRating']?.toStringAsFixed(1) ?? 'N/A'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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
