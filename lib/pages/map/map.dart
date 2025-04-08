import 'dart:convert';
import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:client/services/http_client.dart';
import 'package:client/services/user_service.dart';
import 'dart:io' show Platform;
import 'package:client/main.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

// Set map default Bangkok
class _HospitalMapScreenState extends State<HospitalMapScreen> {
  GoogleMapController? _mapController;
  final Map<MarkerId, Marker> _hospitalMarkers = {};
  static const LatLng _defaultLocation = LatLng(13.7563, 100.5018);
  CameraPosition _currentPosition = const CameraPosition(
    target: _defaultLocation,
    zoom: 12,
  );
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _nearHospital = [];
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedHospital;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final token = await UserService.getToken();
    if (token == null || token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(
          'Authentication Required',
          'Please log in to use the map features.',
        );

        Future.delayed(Duration(seconds: 2), () {
          context.go('/login');
        });
      });
      return;
    }

    // User is authenticated, proceed to check location permissions
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Check LocationPermission
  Future<void> _checkLocationPermission() async {
    // Flag location services as media picker to prevent lifecycle issues
    lifecycleObserver.setMediaPickerActive();

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        lifecycleObserver.setMediaPickerInactive();
        _showErrorDialog(
          'Location Services Disabled',
          'Please enable location services to use this feature.',
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          lifecycleObserver.setMediaPickerInactive();
          _showErrorDialog(
            'Permission Denied',
            'Location permissions are denied. Please grant permissions to use this feature.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        lifecycleObserver.setMediaPickerInactive();
        _showErrorDialog(
          'Permission Denied Forever',
          'Location permissions are permanently denied. Please enable permissions from settings.',
        );
        return;
      }

      await _getCurrentLocation();
    } finally {
      // Reset flag regardless of outcome
      lifecycleObserver.setMediaPickerInactive();
    }
  }

  // Get LocationPermission
  Future<void> _getCurrentLocation() async {
    try {
      lifecycleObserver.setMediaPickerActive();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      lifecycleObserver.setMediaPickerInactive();

      final LatLng currentLatLng =
          LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = CameraPosition(target: currentLatLng, zoom: 15);
        _addMarker(
          'Your Location',
          currentLatLng,
          'Your current location',
          BitmapDescriptor.hueAzure,
        );
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 15),
        ),
      );
      await _fetchNearbyHospitals(currentLatLng);
    } catch (e) {
      lifecycleObserver.setMediaPickerInactive();
      _showErrorDialog(
        'Location Error',
        'Could not determine your current location. Please try again.',
      );
    }
  }

  //backend NearbyHospitals
  Future<void> _fetchNearbyHospitals(LatLng currentLocation) async {
    try {
      // Replace direct http call with HttpClient.get
      final response = await HttpClient.get(
        '/nearby-hospitals?lat=${currentLocation.latitude}&lng=${currentLocation.longitude}',
      );

      print('Fetching hospitals from: ${HttpClient.baseUrl}/nearby-hospitals');

      if (response.statusCode == 200) {
        final List hospitals = json.decode(response.body);
        setState(() {
          _hospitalMarkers.clear();
          _nearHospital = hospitals.cast<Map<String, dynamic>>();
          for (var hospital in hospitals) {
            _addMarker(
              hospital['name'],
              LatLng(hospital['location']['lat'], hospital['location']['lng']),
              hospital['address'],
              BitmapDescriptor.hueRed,
            );
          }
        });
      } else if (response.statusCode == 401) {
        // Handle authentication errors
        _showErrorDialog(
            'Authentication Error', 'Please log in to use this feature');
      } else {
        _showErrorDialog(
            'Error', 'Failed to fetch hospitals: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Could not connect to the server: $e');
    }
  }

  void _addMarker(String id, LatLng position, String info, double colorHue) {
    final MarkerId markerId = MarkerId(id);
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: id, snippet: info),
      icon: BitmapDescriptor.defaultMarkerWithHue(colorHue),
    );
    _hospitalMarkers[markerId] = marker;
  }

  void _setMapStyle() async {
    if (_mapController != null) {
      final String mapStyle = '''
      [
        {
          "featureType": "poi",
          "stylers": [
            { "visibility": "off" }
          ]
        },
        {
          "featureType": "poi.medical",
          "stylers": [
            { "visibility": "on" }
          ]
        }
      ]
      ''';
      await _mapController!.setMapStyle(mapStyle);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontFamily: 'BaiJamjuree'),
        ),
        content: Text(
          message,
          style: TextStyle(fontFamily: 'BaiJamjuree'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ตกลง',
              style: TextStyle(fontFamily: 'BaiJamjuree'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchHospitals(String? query) async {
    if (query == null || query.isEmpty) {
      _showErrorDialog('Invalid Input', 'Search query cannot be empty');
      print('Search query is empty or null');
      return;
    }

    try {
      // Replace with HttpClient.get
      print('Sending request to: /search-hospitals?query=$query');

      final response = await HttpClient.get('/search-hospitals?query=$query');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List hospitals = json.decode(response.body);

        print('Received hospitals: $hospitals');

        setState(() {
          _hospitalMarkers.clear();
          _searchResults = hospitals
              .where((hospital) =>
                  hospital['name'] != null && hospital['location'] != null)
              .map((hospital) {
            return {
              'name': hospital['name'] ?? 'Unknown Hospital',
              'location': hospital['location'] ?? {'lat': 0.0, 'lng': 0.0},
              'address': hospital['address'] ?? 'Unknown Address',
              'rating': hospital['rating'] ?? 'No Rating',
            };
          }).toList();

          for (var hospital in _searchResults) {
            _addMarker(
              hospital['name'],
              LatLng(hospital['location']['lat'], hospital['location']['lng']),
              hospital['address'],
              BitmapDescriptor.hueRed,
            );
          }
        });
      } else if (response.statusCode == 401) {
        _showErrorDialog(
            'Authentication Error', 'Please log in to use this feature');
      } else {
        _showErrorDialog('Error', 'No hospitals found matching your search');
        print('No hospitals found matching the search query');
      }
    } catch (e) {
      print('Error occurred: $e');
      _showErrorDialog('Error', 'Could not connect to the server: $e');
    }
  }

  // SearchBar
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _fetchNearbyHospitals(_currentPosition.target);
    } else {
      _searchHospitals(query);
    }
  }

  void _onHospitalSelected(Map<String, dynamic> hospital) {
    setState(() {
      _selectedHospital = hospital;
    });

    final lat = _selectedHospital!['location']['lat'];
    final lng = _selectedHospital!['location']['lng'];
    final position = LatLng(lat, lng);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 16.0),
    );
  }

  Widget _buildNavigationButton() {
    return GestureDetector(
      onTap: () async {
        if (_selectedHospital == null) {
          return;
        }

        final lat = _selectedHospital!['location']['lat'];
        final lng = _selectedHospital!['location']['lng'];

        // Create platform-appropriate URL
        String url;
        if (Platform.isAndroid) {
          // For Android, use geo URI
          url =
              'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(_selectedHospital!['name'])})';
        } else if (Platform.isIOS) {
          // For iOS, use comgooglemaps://
          url = 'comgooglemaps://?q=$lat,$lng';
        } else {
          // Fallback for other platforms (like Web)
          url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        }

        // Check and launch URL
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          // Fallback to web if app launching fails
          final fallbackUrl =
              'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
          if (await canLaunch(fallbackUrl)) {
            await launch(fallbackUrl);
          } else {
            _showErrorDialog('Error', 'ไม่สามารถเปิด Google Maps ได้');
          }
        }
      },
      child: CircleAvatar(
        backgroundColor: MainTheme.mapBlue,
        radius: 16,
        child: Icon(
          Icons.directions,
          color: MainTheme.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBackButtons() {
    return Positioned(
      top: 40,
      left: 20,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: MainTheme.white),
            onPressed: () {
              context.go('/home');
            },
            style: IconButton.styleFrom(
              backgroundColor: MainTheme.navbarFocusText,
              padding: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: MainTheme.profileGrey),
              ),
            ),
          ),

          // Only show back button when a hospital is selected
          if (_selectedHospital != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                // **  อันนี้ใช้ Icons.arrow_back แทนนะ เพราะไม่ได้เป็นปุ่มกลับปุ่มเดียวนะ
                icon: const Icon(Icons.arrow_back, color: MainTheme.white),
                onPressed: () {
                  setState(() {
                    _selectedHospital = null;
                    _searchController.clear();
                  });

                  // Reset camera position to user's location or default location
                  final target = _currentPosition.target;
                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(target: target, zoom: 15),
                    ),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: MainTheme.navbarFocusText,
                  padding: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: MainTheme.profileGrey),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // UX UI Design
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _currentPosition,
            markers: Set<Marker>.of(_hospitalMarkers.values),
            onMapCreated: (controller) {
              _mapController = controller;
              _setMapStyle();
            },
          ),

          // Replace the old back button with our new back buttons component
          _buildBackButtons(),

          // Rest of your UI components...
          // When you have the hospital detail panel showing, add the navigation button
          if (_selectedHospital != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildNavigationButton(),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: _selectedHospital == null
                          ? 'ค้นหาโรงพยาบาล'
                          : _selectedHospital!['name'],
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: _selectedHospital == null
                              ? MainTheme.resultBlue
                              : MainTheme.redWarning,
                          radius: 16,
                          child: Icon(
                            _selectedHospital == null
                                ? Icons.search
                                : Icons.local_hospital,
                            color: MainTheme.white,
                            size: 20,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: MainTheme.white,
                      enabled: _selectedHospital == null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: MainTheme.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MainTheme.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: MainTheme.mapBlack,
                          blurRadius: 5,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                        child: _selectedHospital == null
                            ? ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _searchResults.isEmpty
                                    ? _nearHospital.length
                                    : _searchResults.length,
                                itemBuilder: (context, index) {
                                  var hospital = _searchResults.isEmpty
                                      ? _nearHospital[index]
                                      : _searchResults[index];
                                  return ListTile(
                                    title: Text(hospital['name']),
                                    subtitle: Text(hospital['address']),
                                    leading: Icon(Icons.local_hospital,
                                        color: MainTheme.redWarning),
                                    onTap: () {
                                      _onHospitalSelected(hospital);
                                    },
                                  );
                                },
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 25, vertical: 10),
                                      child: Text(
                                        'รายละเอียด',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'BaiJamjuree',
                                          color: MainTheme.black,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 0),
                                      child: Card(
                                        color: Color.fromRGBO(217, 217, 217, 1),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: MainTheme.resultBlue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                        Icons.location_on,
                                                        color: MainTheme.white,
                                                        size: 24),
                                                  ),
                                                  SizedBox(width: 20),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _selectedHospital![
                                                              'name'],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'BaiJamjuree',
                                                            letterSpacing: 0,
                                                          ),
                                                        ),
                                                        Text(
                                                          'จ.${_selectedHospital!['address'].split(',').last.trim()} ประเทศไทย',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'BaiJamjuree',
                                                            color:
                                                                Color.fromRGBO(
                                                                    158,
                                                                    158,
                                                                    158,
                                                                    1),
                                                            letterSpacing: 0,
                                                          ),
                                                        ),
                                                        Text(
                                                          _selectedHospital![
                                                              'address'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'BaiJamjuree',
                                                            letterSpacing: 0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: MainTheme.resultBlue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.phone,
                                                        color: MainTheme.white,
                                                        size: 24),
                                                  ),
                                                  SizedBox(width: 20),
                                                  Text(
                                                    _selectedHospital![
                                                            'phone'] ??
                                                        'ไม่พบเบอร์โทร',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'BaiJamjuree',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  _buildNavigationButton(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}