import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


Future<void> getLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, show a message or handle it accordingly
      print('Location permissions are denied');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are permanently denied, open app settings
    print('Location permissions are permanently denied, please enable them in settings');
    await openAppSettings();
    return;
  }

  // If permission is granted, fetch location
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  
  print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
}
