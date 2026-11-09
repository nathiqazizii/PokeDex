import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// Location-Based Service: cek layanan, minta izin, ambil koordinat.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationException('Layanan lokasi (GPS) sedang dimatikan');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Izin lokasi ditolak');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
