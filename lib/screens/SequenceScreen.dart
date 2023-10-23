import 'package:flutter/material.dart';
import 'SequenceScreenState.dart';

class SequenceScreen extends StatefulWidget {
  const SequenceScreen({super.key, required this.itemTitle});

  final String itemTitle;

  @override
  State<SequenceScreen> createState() =>
      SequenceScreenState(itemTitle: itemTitle);
}
