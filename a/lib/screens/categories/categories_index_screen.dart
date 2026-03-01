import 'package:uni_tech/partials/layout/layout.dart';
import 'package:uni_tech/screens/categories/_partials/categories_list.dart';
import 'package:flutter/material.dart';

class CategoriesIndexScreen extends StatefulWidget {
  CategoriesIndexScreen({super.key});

  @override
  State<CategoriesIndexScreen> createState() => _CategoriesIndexScreen();
}

class _CategoriesIndexScreen extends State<CategoriesIndexScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      content: Column(
        mainAxisSize: MainAxisSize.max,
        children: [CategoriesList(), SizedBox(height: 150)],
      ),
    );
  }
}
