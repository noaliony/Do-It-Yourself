import 'package:flutter/material.dart';
import 'CategoryScreenState.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen(
      {super.key, required this.itemTitle, required this.isHomePage});

  final String itemTitle;
  final bool isHomePage;

  @override
  State<CategoryScreen> createState() =>
      CategoryScreenState(itemTitle: itemTitle, isHomePage: isHomePage);
}
