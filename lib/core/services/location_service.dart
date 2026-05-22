import 'package:geolocator/geolocator.dart';

class LocationCoords {
  final double lat;
  final double lng;

  const LocationCoords({required this.lat, required this.lng});
}

class LocationService {
  Future<LocationCoords> getCurrent() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationCoords(lat: 24.7136, lng: 46.6753);
    }
    final pos = await Geolocator.getCurrentPosition();
    return LocationCoords(lat: pos.latitude, lng: pos.longitude);
  }
}
