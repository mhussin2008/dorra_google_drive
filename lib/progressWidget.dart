import 'package:flutter/material.dart';
import 'filesData.dart';

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: Data.newProgress,
        builder: (BuildContext context, String value, child) {
          return Text(
            'Download Progress: \n ${Data.newProgress.value}',
            style: const TextStyle(fontSize: 26),
          );
        });
  }
}
