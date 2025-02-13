import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const HospitalMapApp());
}

class HospitalMapApp extends StatelessWidget {
  const HospitalMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HospitalMapScreen(),
    );
  }
}

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}
// Set map defult Bangkok
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
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
  // Check LocationPermission
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
        _showErrorDialog(
          'Permission Denied',
          'Location permission is required to use this feature.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
        'Permission Denied Forever',
        'Location permissions are permanently denied. Please enable permissions from settings.',
      );
      return;
    }

    await _getCurrentLocation();
  }
  // Get LocationPermission
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng currentLatLng =
          LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = CameraPosition(target: currentLatLng, zoom: 15);
        _addMarker(
          'current_location',
          currentLatLng,
          'Your Current Location',
          BitmapDescriptor.hueBlue,
        );
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 15),
        ),
      );
      await _fetchNearbyHospitals(currentLatLng);
    } catch (e) {
      _showErrorDialog(
        'Location Error',
        'Could not determine your current location. Please try again.',
      );
    }
  }
  //backend NearbyHospitals
  Future<void> _fetchNearbyHospitals(LatLng currentLocation) async {
    const String backendUrl = 'http://localhost:3000/nearby-hospitals';
    try {
      final response = await http.get(Uri.parse(
          '$backendUrl?lat=${currentLocation.latitude}&lng=${currentLocation.longitude}'));
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
      } else {
        _showErrorDialog('Error', 'Failed to fetch hospitals');
      }
    } catch (e) {
      _showErrorDialog('Error', 'Could not connect to the server');
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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

    const String backendUrl = 'http://localhost:3000/search-hospitals';
    try {
      // Log Backend
      print('Sending request to: $backendUrl?query=$query');

      final response = await http.get(Uri.parse('$backendUrl?query=$query'));

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
              'name': hospital['name'] ??
                  'Unknown Hospital', // Default to 'Unknown Hospital'
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
      } else {
        _showErrorDialog('Error', 'No hospitals found matching your search');
        print('No hospitals found matching the search query');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  // SearchBar
  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      _fetchNearbyHospitals(
          _currentPosition.target); 
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
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                setState(() {
                  _selectedHospital = null; 
                  _searchController.clear(); 
                });
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(_currentPosition),
                );
              },
            ),
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
                              ? Color(0xFF12358F)
                              : Colors
                                  .red, 
                          radius: 16,
                          child: Icon(
                            _selectedHospital == null
                                ? Icons.search
                                : Icons.local_hospital,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabled: _selectedHospital ==
                          null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(color: Colors.white),
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
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
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
                                        color: Colors.red),
                                    onTap: () {
                                      _onHospitalSelected(
                                          hospital);
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
                                          color: Colors.black,
                                          letterSpacing: 0,
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
                                                      color: Color(0xFF12358F),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                        Icons.location_on,
                                                        color: Colors.white,
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
                                                      color: Color(0xFF12358F),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(Icons.phone,
                                                        color: Colors.white,
                                                        size: 24),
                                                  ),
                                                  SizedBox(width: 20),
                                                  Text(
                                                    _selectedHospital![
                                                            'phone'] ??
                                                        'ไม่พบเบอร์โทร',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: 'BaiJamjuree',
                                                      letterSpacing: 0,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  GestureDetector(
                                                    onTap: () {
                                                      final lat =
                                                          _selectedHospital![
                                                                  'location']
                                                              ['lat'];
                                                      final lng =
                                                          _selectedHospital![
                                                                  'location']
                                                              ['lng'];
                                                      final url =
                                                          'https://www.google.com/maps/search/?q=$lat,$lng';
                                                      launch(url);
                                                    },
                                                    child: Image.asset(
                                                      'assets/images/Group 25.png',
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                  ),
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
