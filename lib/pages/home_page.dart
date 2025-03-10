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
  bool isLoading = true; // To handle loading state

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
    return Scaffold(
      appBar: AppBar(title: const Text("RecipBook"), centerTitle: true),
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
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.05,
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

  // Function to create filter buttons dynamically
  Widget _buildMealButton(String mealType, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilledButton(
        onPressed: () {
          fetchData(mealType); // Fetch filtered data
        },
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
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipePage(recipe: recipe),
                ),
              );
            },
            leading: Image.network(
              recipe['image'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(recipe['name']),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text("Category: ${recipe['mealType'].join(", ")}"),
                ),
                Row(children: [Text("${recipe['rating']} ⭐")]),
              ],
            ),
          ),
        );
      },
    );
  }
}
