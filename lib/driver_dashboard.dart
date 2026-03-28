import 'package:flutter/material.dart';

class DriverDashboard extends StatefulWidget {
  final String login;
  const DriverDashboard({super.key, required this.login});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool _isOnline = false;
  String _orderStatus = 'waiting';
  int _currentPrice = 25000;

  void _toggleOnline() {
    setState(() => _isOnline = !_isOnline);
  }

  void _acceptOrder() {
    setState(() => _orderStatus = 'accepted');
  }

  void _driverArrived() {
    setState(() => _orderStatus = 'arrived');
  }

  void _startRide() {
    setState(() => _orderStatus = 'in_progress');
  }

  void _stopRide() {
    setState(() {
      _orderStatus = 'waiting';
      _currentPrice = 25000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070b14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070b14),
        title: Text(
          widget.login,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFfbbf24).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('🪙', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  '0 ball',
                  style: TextStyle(color: Color(0xFFfbbf24), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Taximeter
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFfbbf24).withValues(alpha: 0.08),
                    const Color(0xFF0f172a).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFFfbbf24).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$_currentPrice',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFfbbf24),
                    ),
                  ),
                  const Text(
                    'SO\'M',
                    style: TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_orderStatus == 'arrived')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3b82f6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'MIJOZ O\'TIRDI',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (_orderStatus == 'in_progress')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _stopRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFef4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'SAFARNI TUGATISH',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('🚗', style: TextStyle(fontSize: 20)),
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Safar',
                        style: TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text('|', style: TextStyle(color: Color(0xFF334155))),
                  Column(
                    children: [
                      Text('💰', style: TextStyle(fontSize: 20)),
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "so'm",
                        style: TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Text('|', style: TextStyle(color: Color(0xFF334155))),
                  Column(
                    children: [
                      Text('🪙', style: TextStyle(fontSize: 20)),
                      Text(
                        '0',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ball',
                        style: TextStyle(
                          color: Color(0xFF94a3b8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Online Toggle
            GestureDetector(
              onTap: _toggleOnline,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: _isOnline
                      ? const LinearGradient(
                          colors: [Color(0xFF22c55e), Color(0xFF16a34a)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                        ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isOnline ? 'ONLINE' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
