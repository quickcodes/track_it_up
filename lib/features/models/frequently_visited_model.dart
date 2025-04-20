import 'dart:developer';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../models/device_info_model.dart';

class FrequentVisit {
  LatLng location;
  Duration duration;
  String? address;

  FrequentVisit({
    required this.location,
    required this.duration,
    this.address,
  });
}

Future<List<FrequentVisit>> getFrequentlyVisitedPlacesWithAddress(
  List<DeviceInfoModel> list, {
  double radiusMeters = 500, // default: 500 meters
  Duration minDuration = const Duration(hours: 1), // default: 1 hour
}) async {
  if (list.isEmpty) return [];

  final distance = Distance();
  final sorted = List<DeviceInfoModel>.from(list)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  List<FrequentVisit> visits = [];
  int start = 0;

  for (int i = 1; i < sorted.length; i++) {
    final dist = distance(
      LatLng(sorted[i].latitude, sorted[i].longitude),
      LatLng(sorted[start].latitude, sorted[start].longitude),
    );

    final timeGap = sorted[i].timestamp.difference(sorted[start].timestamp);

    // Check for stay within given radius and time
    if (dist <= radiusMeters && timeGap >= minDuration) {
      final range = sorted.sublist(start, i);
      final centerLat = range.map((e) => e.latitude).reduce((a, b) => a + b) / range.length;
      final centerLng = range.map((e) => e.longitude).reduce((a, b) => a + b) / range.length;

      visits.add(FrequentVisit(
        location: LatLng(centerLat, centerLng),
        duration: timeGap,
      ));

      start = i; // move start forward to avoid duplicate detection
    } else if (dist > radiusMeters * 1.5) {
      // Consider user moved significantly, reset start
      start = i;
    }
  }

  // Remove duplicates by grouping similar locations
  visits = await groupNearbyLocations(visits, radiusMeters);

  // Fetch address for each group of locations
  for (var visit in visits) {
    visit.address = await fetchFrequentlyVisitedAddress(visit.location);
  }

  return visits;
}

Future<List<FrequentVisit>> groupNearbyLocations(
  List<FrequentVisit> visits,
  double radiusMeters,
) async {
  List<FrequentVisit> groupedVisits = [];

  for (var visit in visits) {
    bool foundGroup = false;

    // Try to find an existing group
    for (var groupedVisit in groupedVisits) {
      final dist = Distance().as(
        LengthUnit.Meter,
        visit.location,
        groupedVisit.location,
      );
      
      // If within the radius threshold, merge them
      if (dist <= radiusMeters) {
        // Update the central location to average location of the group
        groupedVisit.location = LatLng(
          (groupedVisit.location.latitude + visit.location.latitude) / 2,
          (groupedVisit.location.longitude + visit.location.longitude) / 2,
        );
        // Merge durations
        groupedVisit.duration += visit.duration;
        foundGroup = true;
        break;
      }
    }

    // If no group is found, add as a new group
    if (!foundGroup) {
      groupedVisits.add(visit);
    }
  }

  return groupedVisits;
}

Future<String> fetchFrequentlyVisitedAddress(LatLng position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;
    final address =
        "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}";

    log("=====>>>>> Most Visited Address: $address");
    return address;
  } catch (e) {
    log("Error fetching address: $e");
    return "Address not found";
  }
}
