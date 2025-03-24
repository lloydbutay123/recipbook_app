import 'package:flutter/material.dart';
import 'package:recepies_app/pages/browse/browse_recipes_page.dart';
import 'package:recepies_app/pages/home/explore_page.dart';
import 'package:recepies_app/pages/home/farovite_page.dart';
import 'package:recepies_app/pages/profile/profile_page.dart';
import 'package:recepies_app/widgets/bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BrowseRecipesPage(),
    const ExplorePage(),
    const FavoritePage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: [..._pages]),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
