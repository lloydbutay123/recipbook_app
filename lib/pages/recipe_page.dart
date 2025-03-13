import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipePage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    double containerHeight = screenHeight * 0.4;
    double imageSize = screenWidth * 0.5;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, size: 24),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      recipe['image'],
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              height: containerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          recipe['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        "Ingredients:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...recipe['ingredients'].map<Widget>((ingredient) {
                        return Row(
                          children: [
                            Icon(Icons.emoji_food_beverage),
                            Text(
                              " $ingredient",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      }).toList(),
                      const SizedBox(height: 40),
                      const Text(
                        "Instructions:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...recipe['instructions'].map<Widget>((instruction) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start, // ✅ Aligns text to start
                            children: [
                              Icon(Icons.integration_instructions_outlined),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  "$instruction",
                                  style: const TextStyle(fontSize: 16),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
