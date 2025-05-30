import 'package:client/services/http_client.dart';

class StatusService {
  // Set user as online
  static Future<bool> setOnline() async {
    try {
      final response = await HttpClient.post('/api/online', {});
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting user online: $e');
      return false;
    }
  }

  // Set user as offline
  static Future<bool> setOffline() async {
    try {
      final response = await HttpClient.post('/api/offline', {});
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting user offline: $e');
      return false;
    }
  }
}