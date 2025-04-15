import 'dart:developer';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../models/device_info_model.dart';

class FrequentVisit {
  final LatLng location;
  final Duration duration;
  String? address;

  FrequentVisit({required this.location, required this.duration, this.address});
}

Future<List<FrequentVisit>> getFrequentlyVisitedPlacesWithAddress(List<DeviceInfoModel> list) async {
  if (list.isEmpty) return [];

  final distance = Distance();
  final sorted = List<DeviceInfoModel>.from(list)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  List<FrequentVisit> visits = [];

  int start = 0;
  for (int i = 1; i < sorted.length; i++) {
    final d = distance(
      LatLng(sorted[i].latitude, sorted[i].longitude),
      LatLng(sorted[start].latitude, sorted[start].longitude),
    );

    final timeGap = sorted[i].timestamp.difference(sorted[start].timestamp);

    // If user stayed in the same area for more than 1 hour (distance < 20m)
    if (d < 20 && timeGap.inMinutes >= 60) {
      final center = LatLng(
        (sorted.sublist(start, i).map((e) => e.latitude).reduce((a, b) => a + b)) / (i - start),
        (sorted.sublist(start, i).map((e) => e.longitude).reduce((a, b) => a + b)) / (i - start),
      );

      visits.add(FrequentVisit(location: center, duration: timeGap));
      start = i; // move start forward to avoid duplicates
    } else if (d > 50) {
      // reset start if distance jumped (i.e., user moved)
      start = i;
    }
  }

  // Fetch addresses for each visit
  for (var visit in visits) {
    visit.address = await fetchFrequentlyVisitedAddress(visit.location);
  }

  return visits;
}

Future<String> fetchFrequentlyVisitedAddress(LatLng position) async {
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark place = placemarks.first;
  log("=====>>>>> Most Visited Address ${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}");
  return "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}";
}
