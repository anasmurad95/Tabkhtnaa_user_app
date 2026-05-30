import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationCoords {
  final double lat;
  final double lng;

  const LocationCoords({required this.lat, required this.lng});
}

/// Default coords — Amman, Jordan (for web / denied permission).
const _fallback = LocationCoords(lat: 31.9539, lng: 35.9106);

class LocationService {
  Future<LocationCoords> getCurrent() async {
    if (kIsWeb) return _fallback;

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallback;
      }
      final pos = await Geolocator.getCurrentPosition();
      return LocationCoords(lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return _fallback;
    }
  }
}
