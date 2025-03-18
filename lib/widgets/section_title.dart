import 'package:flutter/material.dart';

class SectionTitle extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final bool showSeeAll;

  const SectionTitle({
    super.key,
    required this.title,
    required this.onTap,
    this.showSeeAll = true,
  });

  @override
  State<SectionTitle> createState() => _SectionTitleState();
}

class _SectionTitleState extends State<SectionTitle> {
  late String _title;
  late VoidCallback _onTap;
  late bool _showSeeAll;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _onTap = widget.onTap;
    _showSeeAll = widget.showSeeAll;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      height: MediaQuery.sizeOf(context).height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (_showSeeAll)
            TextButton(
              onPressed: _onTap,
              child: Text(
                "See all",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
    ;
  }
}
