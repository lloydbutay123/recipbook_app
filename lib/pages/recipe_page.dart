import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipePage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['name']), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                recipe['image'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            // Recipe Name
            Text(
              recipe['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // Rating & Review Count
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                Text(
                  " ${recipe['rating']} (${recipe['reviewCount']} reviews)",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Category
            Text(
              "Category: ${recipe['mealType'].join(", ")}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Ingredients Section
            const Text(
              "Ingredients:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe['ingredients'].map<Widget>((ingredient) {
              return Text(
                "- $ingredient",
                style: const TextStyle(fontSize: 16),
              );
            }).toList(),
            const SizedBox(height: 10),

            // Instructions Section
            const Text(
              "Instructions:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...recipe['instructions'].map<Widget>((instruction) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  "• $instruction",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
