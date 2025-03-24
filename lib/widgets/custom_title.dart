import 'package:flutter/material.dart';

class CustomTitle extends StatelessWidget {
  final String title;
  final String subTitle;

  const CustomTitle({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(subTitle, style: TextStyle(fontSize: 35)),
        ],
      ),
    );
  }
}
