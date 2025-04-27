import 'package:flutter/material.dart';
import 'package:track_it_up/features/tracking/domain/entities/device_info.dart';
import 'package:track_it_up/features/tracking/domain/entities/frequently_visited.dart';
import 'package:url_launcher/url_launcher.dart';

class DSFrequentVisitedPlacesList extends StatelessWidget {
  final List<DeviceInfo> deviceInfoList;

  const DSFrequentVisitedPlacesList({super.key, required this.deviceInfoList});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<FrequentVisit>>(
      future: getFrequentlyVisitedPlacesWithAddress(
        deviceInfoList,
        radiusMeters: 500,
        minDuration: const Duration(minutes: 10),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '❌ Error loading locations',
              style:
                  theme.textTheme.bodyLarge!.copyWith(color: Colors.redAccent),
            ),
          );
        }

        final places = snapshot.data ?? [];
        if (places.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No frequent places found.\n(Min 45 mins stay required)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '📌 Frequently Visited Places',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              itemCount: places.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final place = places[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: const Icon(Icons.location_on_rounded,
                        color: Colors.deepPurple, size: 28),
                    title: Text(
                      place.address ?? '📍 Loading address...',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '🕓 Stayed for ${formatDurationInMinutes(place.duration.inMinutes)}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => openInGoogleMaps(
                        place.location.latitude, place.location.longitude),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openInGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  String formatDurationInMinutes(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes mins';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
    } else {
      return '$hours ${hours == 1 ? 'hr' : 'hrs'} $minutes mins';
    }
  }
}
