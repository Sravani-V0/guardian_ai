
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const GuardianAI());
}

class GuardianAI extends StatelessWidget {
  const GuardianAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool journeyActive = false;
  bool gettingLocation = false;

  String locationText = 'Location not available';
  String journeyText = 'No active journey';

  Future<void> startJourney() async {
    setState(() {
      gettingLocation = true;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          locationText = 'Please turn on GPS/location services.';
          gettingLocation = false;
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          locationText = 'Location permission denied.';
          gettingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        journeyActive = true;
        gettingLocation = false;

        locationText =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';

        journeyText = 'Journey is being monitored';
      });
    } catch (e) {
      setState(() {
        gettingLocation = false;
        locationText = 'Unable to get location';
      });
    }
  }

  void stopJourney() {
    setState(() {
      journeyActive = false;
      journeyText = 'Journey stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Guardian AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shield,
                      size: 70,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You are protected',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      journeyText,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        journeyActive ? null : startJourney,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('START JOURNEY'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        journeyActive ? stopJourney : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('STOP JOURNEY'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Current Location'),
                subtitle: gettingLocation
                    ? const Text('Getting GPS location...')
                    : Text(locationText),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: const ListTile(
                leading: Icon(Icons.psychology),
                title: Text('Guardian AI'),
                subtitle: Text(
                  'AI-powered safety monitoring is ready.',
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EmergencyContactsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.contacts),
                label: const Text('EMERGENCY CONTACTS'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SafetyProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Text('SAFETY PROFILE'),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SafetyCheckScreen(
                        journeyActive: journeyActive,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.health_and_safety),
                label: const Text('SAFETY CHECK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SAFETY PROFILE
// ============================================================

class SafetyProfileScreen extends StatefulWidget {
  const SafetyProfileScreen({super.key});

  @override
  State<SafetyProfileScreen> createState() =>
      _SafetyProfileScreenState();
}

class _SafetyProfileScreenState
    extends State<SafetyProfileScreen> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController detailsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    nameController.text =
        prefs.getString('profile_name') ?? '';

    detailsController.text =
        prefs.getString('profile_details') ?? '';

    setState(() {});
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'profile_name',
      nameController.text.trim(),
    );

    await prefs.setString(
      'profile_details',
      detailsController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safety profile saved'),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: detailsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Safety Details',
                hintText:
                    'Example: allergies, usual route, important information',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('SAVE PROFILE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMERGENCY CONTACTS
// ============================================================

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState
    extends State<EmergencyContactsScreen> {
  final List<TextEditingController> nameControllers =
      List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> phoneControllers =
      List.generate(
    5,
    (_) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < 5; i++) {
      nameControllers[i].text =
          prefs.getString('contact_name_$i') ?? '';

      phoneControllers[i].text =
          prefs.getString('contact_phone_$i') ?? '';
    }

    setState(() {});
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < 5; i++) {
      await prefs.setString(
        'contact_name_$i',
        nameControllers[i].text.trim(),
      );

      await prefs.setString(
        'contact_phone_$i',
        phoneControllers[i].text.trim(),
      );
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency contacts saved'),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in nameControllers) {
      controller.dispose();
    }

    for (final controller in phoneControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Add up to 5 emergency contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...List.generate(
              5,
              (index) {
                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          'Emergency Contact ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller:
                              nameControllers[index],
                          decoration:
                              const InputDecoration(
                            labelText: 'Name',
                            border:
                                OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller:
                              phoneControllers[index],
                          keyboardType:
                              TextInputType.phone,
                          decoration:
                              const InputDecoration(
                            labelText: 'Phone Number',
                            border:
                                OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveContacts,
                child: const Text('SAVE CONTACTS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SAFETY CHECK
// ============================================================

class SafetyCheckScreen extends StatefulWidget {
  final bool journeyActive;

  const SafetyCheckScreen({
    super.key,
    required this.journeyActive,
  });

  @override
  State<SafetyCheckScreen> createState() =>
      _SafetyCheckScreenState();
}

class _SafetyCheckScreenState
    extends State<SafetyCheckScreen> {

  static const MethodChannel _phoneChannel =
      MethodChannel('guardian_ai/phone');

  bool analyzing = false;

  String aiResult = '';
  String locationResult = 'Location not checked';

  String riskLevel = '';

  Color riskColor = Colors.grey;

  // ==========================================================
  // GET REAL GPS LOCATION
  // ==========================================================

  Future<Position?> getRealLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          locationResult =
              'GPS/location services are disabled.';
        });
        return null;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        setState(() {
          locationResult =
              'Location permission denied.';
        });
        return null;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        locationResult =
            '${position.latitude.toStringAsFixed(6)}, '
            '${position.longitude.toStringAsFixed(6)}';
      });

      return position;
    } catch (e) {
      setState(() {
        locationResult =
            'Unable to get current location.';
      });

      return null;
    }
  }

  // ==========================================================
  // DETECT RISK LEVEL
  // ==========================================================

  void detectRiskLevel(String result) {
    final upper = result.toUpperCase();

    if (upper.contains('HIGH')) {
      riskLevel = 'HIGH';
      riskColor = Colors.red;
    } else if (upper.contains('MEDIUM')) {
      riskLevel = 'MEDIUM';
      riskColor = Colors.orange;
    } else {
      riskLevel = 'LOW';
      riskColor = Colors.green;
    }
  }

  // ==========================================================
  // SEND DATA TO FEATHERLESS BACKEND
  // ==========================================================

  Future<void> sendSafetyResponse(
    String response,
  ) async {
    setState(() {
      analyzing = true;
      aiResult = 'Analyzing safety situation...';
    });

    final position = await getRealLocation();

    final prefs =
        await SharedPreferences.getInstance();

    final name =
        prefs.getString('profile_name') ??
            'Guardian AI user';

    final details =
        prefs.getString('profile_details') ?? '';

    final latitude = position?.latitude;
    final longitude = position?.longitude;

    try {
      final backendResponse =
          await http.post(
        Uri.parse(
          'http://10.10.180.59:5000/analyze-risk',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'person': name,
          'safety_profile': details,
          'latitude': latitude,
          'longitude': longitude,
          'location': position == null
              ? 'Unavailable'
              : '${position.latitude},${position.longitude}',
          'time':
              DateTime.now().toIso8601String(),
          'journey_status':
              widget.journeyActive
                  ? 'active'
                  : 'inactive',
          'unexpected_movement':
              response != 'I am Safe',
          'unexpected_stop': false,
          'user_response': response,
          'location_available':
              position != null,
        }),
      );

      if (backendResponse.statusCode == 200) {
        final data =
            jsonDecode(backendResponse.body);

        final analysis =
            data['ai_analysis']?.toString() ??
                'No AI analysis received.';

        detectRiskLevel(analysis);

        setState(() {
          aiResult = analysis;
          analyzing = false;
        });
      } else {
        setState(() {
          aiResult =
              'Backend error: ${backendResponse.statusCode}';
          analyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        aiResult =
            'Unable to connect to Guardian AI backend.\n$e';
        analyzing = false;
      });
    }
  }

  // ==========================================================
  // AUTOMATIC EMERGENCY CALL
  // ==========================================================

  Future<void> callEmergencyContact() async {
    final prefs =
        await SharedPreferences.getInstance();

    String? phoneNumber;
    String? contactName;

    // Find the first configured emergency contact.
    for (int i = 0; i < 5; i++) {
      final phone =
          prefs.getString('contact_phone_$i') ?? '';

      final name =
          prefs.getString('contact_name_$i') ?? '';

      if (phone.trim().isNotEmpty) {
        phoneNumber = phone.trim();

        contactName = name.trim().isEmpty
            ? 'Emergency Contact'
            : name.trim();

        break;
      }
    }

    if (phoneNumber == null) {
      setState(() {
        aiResult =
            '$aiResult\n\n'
            'No emergency contact is configured.';
      });
      return;
    }

    try {
      final bool success =
          await _phoneChannel.invokeMethod(
        'makeDirectCall',
        {
          'phoneNumber': phoneNumber,
        },
      );

      if (success) {
        setState(() {
          aiResult =
              '$aiResult\n\n'
              'Emergency call started to $contactName.';
        });
      } else {
        setState(() {
          aiResult =
              '$aiResult\n\n'
              'Waiting for phone-call permission.';
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        aiResult =
            '$aiResult\n\n'
            'Unable to place emergency call: '
            '${e.message}';
      });
    } catch (e) {
      setState(() {
        aiResult =
            '$aiResult\n\n'
            'Emergency call failed: $e';
      });
    }
  }

  // ==========================================================
  // EMERGENCY MODE
  // ==========================================================

  Future<void> handleEmergency() async {
    setState(() {
      riskLevel = 'HIGH';
      riskColor = Colors.red;

      aiResult =
          '🚨 EMERGENCY MODE ACTIVATED\n\n'
          'Checking location and contacting emergency support...';
    });

    // Send emergency event to the Featherless AI backend.
    await sendSafetyResponse(
      'I am Not Safe / I Need Help',
    );

    // Automatically call the first emergency contact.
    await callEmergencyContact();
  }

  // ==========================================================
  // SAFE RESPONSE
  // ==========================================================

  void handleSafe() {
    setState(() {
      riskLevel = 'LOW';
      riskColor = Colors.green;

      aiResult =
          'You are marked SAFE.\n\n'
          'Guardian AI will continue monitoring the journey.';
    });
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Check'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.health_and_safety,
                      size: 65,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Are you safe?',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Guardian AI detected activity '
                      'that may require your attention.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.location_on),
                title: const Text(
                  'Current GPS Location',
                ),
                subtitle:
                    Text(locationResult),
              ),
            ),

            const SizedBox(height: 20),

            // I'M SAFE
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    analyzing ? null : handleSafe,
                icon:
                    const Icon(Icons.check_circle),
                label: const Text(
                  "I'M SAFE",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // SOMETHING FEELS WRONG
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: analyzing
                    ? null
                    : () {
                        sendSafetyResponse(
                          'Something Feels Wrong',
                        );
                      },
                icon: const Icon(
                  Icons.warning_amber,
                ),
                label: const Text(
                  'SOMETHING FEELS WRONG',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // EMERGENCY
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    analyzing ? null : handleEmergency,
                icon: const Icon(
                  Icons.emergency,
                  size: 28,
                ),
                label: const Text(
                  "I'M NOT SAFE / I NEED HELP",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (analyzing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(
                    'Guardian AI is analyzing...',
                  ),
                ],
              ),

            const SizedBox(height: 15),

            if (riskLevel.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: riskColor,
                        size: 35,
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Risk Level',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            riskLevel,
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 10),

            if (aiResult.isNotEmpty)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology),
                          SizedBox(width: 8),
                          Text(
                            'Guardian AI Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(aiResult),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

