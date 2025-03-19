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
  List<dynamic> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews(widget.restaurant['restaurantId']);
  }

  @override
  Widget build(BuildContext context) {
    String selectedValue = "Delivery";
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                items:
                    ["Delivery", "Pickup"].map((String item) {
                      return DropdownMenuItem(value: item, child: Text(item));
                    }).toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildUi()),
    );
  }

  Future<void> fetchReviews(String restaurantId) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
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
          data = fetchedReviews;
        });
      }
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

  Widget _buildUi() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _restaurantDetails(),
                SectionTitle(title: "For You", showSeeAll: false, onTap: () {}),
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
      ],
    );
  }

  Widget _restaurantDetails() {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Center(
      child: SizedBox(
        width: screenWidth * 0.95,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenWidth * 0.28,
                height: screenHeight * 0.13,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Image.network(
                    widget.restaurant['photoUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: screenHeight * 0.13,
                  width: screenWidth * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.restaurant['name']}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.restaurant['address']}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "⭐ 4.7",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text("From 45 mins", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviews() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data.isEmpty) {
      return const Center(child: Text("No reviews"));
    }
    List<dynamic> reviews = data.take(5).toList();

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
}
