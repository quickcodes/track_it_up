import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track_it_up/features/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:track_it_up/features/tracking/presentation/screens/device_summary_screen.dart';

class HSDateButton extends StatefulWidget {
  const HSDateButton({super.key});

  @override
  State<HSDateButton> createState() => _HSDateButtonState();
}

class _HSDateButtonState extends State<HSDateButton> {
  // bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    // if (isLoading) return;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      // setState(() => isLoading = true);

      if (context.mounted) {
        context.read<TrackingBloc>().add(
              GetDeviceInfoByDateEvent(selectedDate),
            );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DeviceSummaryScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon:
          // isLoading
          //     ? const SizedBox(
          //         height: 15,
          //         width: 15,
          //         child: CircularProgressIndicator(
          //           color: Colors.white,
          //           strokeWidth: 2,
          //         ),
          //       )
          //     :
          const Icon(Icons.calendar_today),
      label: const Text("View Coordinates by Date"),
      onPressed: () => _selectDate(context),
    );
  }
}
