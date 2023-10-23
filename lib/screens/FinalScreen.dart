import 'package:do_it_yourself/dto/SequenceData.dart';
import 'package:do_it_yourself/screens/FinalScreenState.dart';
import 'package:flutter/material.dart';

class FinalScreen extends StatefulWidget {
  const FinalScreen(
      {super.key,
      required this.sequenceName,
      required this.actionsTimesList,
      required this.sequenceData});

  final String sequenceName;
  final List<int> actionsTimesList;
  final SequenceData sequenceData;

  @override
  State<FinalScreen> createState() => FinalScreenState(
      sequenceName: sequenceName,
      actionsTimesList: actionsTimesList,
      sequenceData: sequenceData);
}
