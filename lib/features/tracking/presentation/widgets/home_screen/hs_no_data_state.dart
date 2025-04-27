import 'package:flutter/material.dart';

class HSNoDataState extends StatelessWidget {
  const HSNoDataState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
        SizedBox(height: 12),
        Text(
          "No data received.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
