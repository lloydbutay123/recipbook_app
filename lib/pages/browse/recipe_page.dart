import 'package:flutter/material.dart';
import 'package:recepies_app/widgets/section_title.dart';

class RecipePage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipePage({super.key, required this.recipe});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(child: _buildUi()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              "Add to cart",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUi() {
    double screenHeight = MediaQuery.sizeOf(context).height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    double containerHeight = screenHeight * 0.5;
    double imageSize = screenWidth * 0.90;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Image.network(
                    widget.recipe['imageUrl'] ?? '',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: containerHeight,
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(
                        widget.recipe['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, color: Colors.green),
                              Text("15 mins"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_outlined,
                                color: Colors.red,
                              ),
                              Text("500 Kal"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star_outline, color: Colors.yellow),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "4.9",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: "(300 Reviews)",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SectionTitle(
                    title: "Description",
                    onTap: () {},
                    showSeeAll: false,
                  ),
                  Text(widget.recipe['description']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
