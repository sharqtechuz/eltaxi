import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'customer_login.dart';
import 'customer_dashboard.dart';
import 'driver_login.dart';
import 'driver_dashboard.dart';
import 'admin_login.dart';

const String appVersion = '1.0.0';
const String serverUrl = 'https://eltaxi-production.up.railway.app';

void main() {
  runApp(const ElTaksiApp());
}

class ElTaksiApp extends StatelessWidget {
  const ElTaksiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElTaksi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFfbbf24),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF070b14),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/api/version'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'] ?? appVersion;

        if (latestVersion != appVersion && mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1e293b),
              title: const Text(
                'Yangilanish mavjud!',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Ilovaning yangi versiyasi chiqdi. Iltimos, yangilang.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'Keyinroq',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Server not available, skip update check
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0f172a), Color(0xFF070b14)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFfbbf24).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚕', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 10),
                  const Text(
                    'ElTaksi',
                    style: TextStyle(
                      fontSize: 2.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFfbbf24),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Premium Taksi Xizmati',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerLoginScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFfbbf24),
                        foregroundColor: const Color(0xFF0f172a),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Mijoz Sifatida Kirish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverLoginScreen(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFfbbf24),
                        side: const BorderSide(
                          color: Color(0xFFfbbf24),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Haydovchi Paneli',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    ),
                    child: const Text(
                      '🔧 Admin Panel',
                      style: TextStyle(color: Color(0xFF64748b)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
