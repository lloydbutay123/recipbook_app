import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recepies_app/pages/recipe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String url = "https://dummyjson.com/recipes";
  List<dynamic> data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData("all");
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
    return Scaffold(body: SafeArea(child: _buildUi()));
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
        height: MediaQuery.sizeOf(context).height * 0.07,
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
      ),
    );
  }

  // Function to create filter buttons dynamically
  Widget _buildMealButton(String mealType, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilledButton(
        onPressed: () {
          fetchData(mealType); // Fetch filtered data
        },
        style: FilledButton.styleFrom(
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
              margin: const EdgeInsets.all(10),
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
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centers vertically
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
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Category: ${recipe['mealType'].join(", ")}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
