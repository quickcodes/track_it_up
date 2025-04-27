import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/home_screen/hs_date_button.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/home_screen/hs_live_data_card.dart';
import 'package:track_it_up/features/tracking/presentation/widgets/home_screen/hs_records_button.dart';
import 'package:track_it_up/objectbox.g.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 Background Service Monitor'),
        centerTitle: true,
        elevation: 2,
         actions: [
          if (Admin.isAvailable() && kDebugMode)
            IconButton(
              onPressed: () async {
                const String url = "http://127.0.0.1:8090";
                if (!await launchUrl(Uri.parse(url))) {
                  log("Unable to open DB");
                }
              },
              icon: const Icon(Icons.storage),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            HSLiveDataCard(),
            SizedBox(height: 15),
            HSDateButton(),
            SizedBox(height: 15),
            HSRecordsButton(),
          ],
        ),
      ),
    );
  }
}
