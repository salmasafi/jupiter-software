import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jupiter_academy/core/utils/variables.dart';
import 'firebase_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

StreamSubscription<Position>? positionStream;

class LocationService {
  String apiKey = 'AIzaSyDE8IavGqJWYDTC7gik9PzFZGOxdmJB2v0';

  static Future<Map<String, dynamic>> determineCompanyPosition() async {
    DocumentReference branchDoc = FirebaseApi.getBranchDoc(branch: Branch);
    DocumentSnapshot branchSnapshot = await branchDoc.get();

    double latitude = 0;
    double longitude = 0;

    if (branchSnapshot.exists) {
      Map<String, dynamic> location =
          branchSnapshot['location'] as Map<String, dynamic>;
      latitude = location['latitude']?.toDouble() ?? 0.0;
      longitude = location['longitude']?.toDouble() ?? 0.0;
    }

    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Future<void> determinePosition(
      String id, Function(String) onPositionUpdate) async {
    final double companyLatitude;
    final double companyLongitude;

    Map<String, dynamic> companyLocation =
        await LocationService.determineCompanyPosition();
    companyLatitude = companyLocation['latitude'] ?? 0;
    companyLongitude = companyLocation['longitude'] ?? 0;

    print('companyLocation: $companyLatitude, $companyLongitude');

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position? position) async {
      if (position != null) {
        print('Current position: ${position.latitude}, ${position.longitude}');

        print('Company position: $companyLatitude, $companyLatitude');

        DocumentReference employeeDoc = FirebaseApi.getEmployeeDoc(id: id);
        DocumentSnapshot employeeSnapshot = await employeeDoc.get();

        if (employeeSnapshot.exists) {
          await employeeDoc.update(
              {'location': '${position.latitude}, ${position.longitude}'});

          // Calculate the distance between the employee and the company
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            companyLatitude,
            companyLongitude,
          );

          print('Distance from company: $distance meters');

          String isWithinCompanyPremises = (distance <= 250) ? 'true' : 'false';
          print('Is within company premises: $isWithinCompanyPremises');
          onPositionUpdate(isWithinCompanyPremises);
        }
      } else {
        print('Position is null');
      }
    }, onError: (e) {
      print('Error receiving location updates: $e');
    });
  }

  static Future<Map<String, double>> getCoordinatesFromGoogleMapsUrl(
      String googleMapsUrl) async {
    final Uri uri = Uri.parse(googleMapsUrl);
    final String address = uri.queryParameters['q'] ?? '';

    String apiKey = 'AIzaSyDE8IavGqJWYDTC7gik9PzFZGOxdmJB2v0';
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
        };
      } else {
        throw Exception('Error from Geocoding API: ${data['status']}');
      }
    } else {
      throw Exception('Failed to fetch data from Geocoding API');
    }
  }

  static Future<Map<String, double>> getCoordinatesFromAddress(
      String address) async {
    String apiKey = 'AIzaSyDE8IavGqJWYDTC7gik9PzFZGOxdmJB2v0';

    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey');

    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') {
      throw Exception('Error from Geocoding API: ${data['status']}');
    }

    final location = data['results'][0]['geometry']['location'];
    return {
      'latitude': location['lat'],
      'longitude': location['lng'],
    };
  }

  static Map<String, double> extractCoordinatesFromUrl(String url) {
    final regex = RegExp(r'@([-\d.]+),([-\d.]+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      final latitude = double.parse(match.group(1)!);
      final longitude = double.parse(match.group(2)!);
      return {'latitude': latitude, 'longitude': longitude};
    } else {
      throw Exception('Coordinates not found in URL');
    }
  }

  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
  String apiKey = 'AIzaSyDE8IavGqJWYDTC7gik9PzFZGOxdmJB2v0';
  final url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final String formattedAddress = data['results'][0]['formatted_address'];
      return formattedAddress;
    } else {
      throw Exception('Error from Geocoding API: ${data['status']}');
    }
  } else {
    throw Exception('Failed to fetch data from Geocoding API');
  }
}

  void stopTracking() {
    positionStream?.cancel();
  }
}
