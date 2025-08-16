// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Suhu IoT',
      theme: ThemeData.dark(),
      home: const MonitoringPage(),
    );
  }
}

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final DatabaseReference _sensorRef =
      FirebaseDatabase.instance.ref('Data-Sensor');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. TAMBAHKAN GRADIENT BACKGROUND UNTUK TAMPILAN MODERN
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A2A2A),
              Color(0xFF1E1E1E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- Header ---
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Monitoring Suhu OVEN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _sensorRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData ||
                        snapshot.data?.snapshot.value == null) {
                      return const Center(
                        child: Text(
                          'Tidak ada data sensor.',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      );
                    }

                    final data =
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    final double suhu =
                        double.tryParse(data['Suhu'].toString()) ?? 0.0;
                    final double kelembapan =
                        double.tryParse(data['Kelembapan'].toString()) ?? 0.0;

                    // 2. GUNAKAN LAYOUT YANG LEBIH FLEKSIBEL
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gunakan widget Gauge yang baru
                          SensorGauge(
                            value: suhu,
                            title: 'Suhu',
                            unit: '°C',
                            icon: Icons.thermostat,
                            primaryColor: Colors.orangeAccent,
                            maxValue: 100, // Asumsi suhu maksimal 100°C
                          ),
                          const SizedBox(height: 30),
                          SensorGauge(
                            value: kelembapan,
                            title: 'Kelembapan',
                            unit: '%',
                            icon: Icons.water_drop_outlined,
                            primaryColor: Colors.lightBlueAccent,
                            maxValue: 100, // Kelembapan maksimal 100%
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET GAUGE BARU YANG LEBIH MODERN ---

class SensorGauge extends StatelessWidget {
  final double value;
  final String title;
  final String unit;
  final IconData icon;
  final Color primaryColor;
  final double maxValue;

  const SensorGauge({
    super.key,
    required this.value,
    required this.title,
    required this.unit,
    required this.icon,
    required this.primaryColor,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- Bagian Gauge (Lingkaran) ---
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: value / maxValue,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
                Center(
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // --- Bagian Teks (Data) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: primaryColor.withOpacity(0.5),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}