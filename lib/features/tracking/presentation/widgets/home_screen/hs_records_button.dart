import 'package:flutter/material.dart';
import 'package:track_it_up/features/tracking/presentation/screens/data_entry_view.dart';

class HSRecordsButton extends StatelessWidget {
  const HSRecordsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.date_range),
      label: const Text("View Records"),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const DateEntryView(),
        ));
      },
    );
  }
}
