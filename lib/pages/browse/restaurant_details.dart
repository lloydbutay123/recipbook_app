import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/widgets/section_title.dart';

class RestaurantDetails extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetails({super.key, required this.restaurant});

  @override
  State<RestaurantDetails> createState() => _RestaurantDetailsState();
}

class _RestaurantDetailsState extends State<RestaurantDetails> {
  List<dynamic> reviewData = [];
  List<dynamic> menuData = [];
  bool isReviewLoading = true;
  bool isMenuLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews(widget.restaurant['restaurantId']);
    fetchMenu(widget.restaurant['restaurantId']);
  }

  @override
  Widget build(BuildContext context) {
    String selectedValue = "Delivery";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                dropdownColor: Colors.black.withOpacity(0.8),
                items:
                    ["Delivery", "Pickup"].map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: _buildUi(),
      extendBodyBehindAppBar: true,
    );
  }

  Future<void> fetchReviews(String restaurantId) async {
    if (!mounted) return;
    setState(() {
      isReviewLoading = true;
    });
    try {
      QuerySnapshot reviewsSnapshot =
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .get();
      List<Map<String, dynamic>> fetchedReviews =
          reviewsSnapshot.docs.map((doc) {
            return {
              'rating': doc['rating'] ?? 0,
              'comment': doc['comment'] ?? '',
              'timestamp': doc['timestamp'] ?? Timestamp.now(),
            };
          }).toList();

      if (mounted) {
        setState(() {
          reviewData = fetchedReviews;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (!mounted) {
        isReviewLoading = false;
      } else {
        setState(() {
          isReviewLoading = false;
        });
      }
    }
  }

  Widget _buildUi() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _restaurantDetails(),
                  SectionTitle(
                    title: "For You",
                    showSeeAll: false,
                    onTap: () {},
                  ),
                  _menu(),
                  SectionTitle(
                    title: "What people say",
                    showSeeAll: false,
                    onTap: () {},
                  ),
                  _reviews(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> fetchMenu(String restaurantId) async {
    setState(() {
      isMenuLoading = true;
    });

    try {
      QuerySnapshot menuSnapshot =
          await FirebaseFirestore.instance
              .collection('restaurants')
              .doc(restaurantId)
              .collection('menu')
              .get();

      List<Map<String, dynamic>> fetchedMenu =
          menuSnapshot.docs.map((doc) {
            return {
              'name': doc['name'] ?? '',
              'price': doc['price'] ?? 0,
              'imageUrl': doc['imageUrl'] ?? '',
              'category': doc['category'] ?? '',
            };
          }).toList();

      if (mounted) {
        setState(() {
          menuData = fetchedMenu;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (!mounted) {
        setState(() {
          isMenuLoading = false;
        });
      } else {
        setState(() {
          isMenuLoading = false;
        });
      }
    }
  }

  Widget _restaurantDetails() {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: SizedBox(
        width: screenWidth,
        height: screenHeight * 0.4,
        child: (Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.restaurant['photoUrl']),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), // Adjust opacity here
                    BlendMode.darken, // Darkens the image
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Container(
                  width: screenWidth * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.restaurant['name']}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.restaurant['address']}",
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 18,
                                ),
                                Text(
                                  "4.7",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.free_breakfast,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                Text(
                                  "5 Promo Update",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _reviews() {
    List<dynamic> reviews = reviewData.take(5).toList();

    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text("No Reviews", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          spacing: 10,
          children: [
            ...List.generate(reviews.length, (index) {
              var review = reviews[index];

              return SizedBox(
                width: 300,
                height: 130,
                child: Card(
                  elevation: 1,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review['comment'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 14),
                            SizedBox(width: 5),
                            Text("${review['rating']}"),
                            SizedBox(width: 5),
                            Text("Anonymous"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _menu() {
    if (isMenuLoading) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (menuData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "No Menu Available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children:
          menuData.map((item) {
            return SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 20,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (item['imageUrl'] != null && item['imageUrl'].isNotEmpty)
                        ? ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            item['imageUrl'],
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg?20200913095930",
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Row(
                            children: [
                              Text(
                                "P ${item['price']}",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
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
          }).toList(),
    );
  }
}
