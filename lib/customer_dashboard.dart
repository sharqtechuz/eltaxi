import 'package:flutter/material.dart';

class CustomerDashboard extends StatefulWidget {
  final String name;
  final String phone;
  const CustomerDashboard({super.key, required this.name, required this.phone});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String _orderStatus = 'idle';

  void _callTaxi() {
    setState(() => _orderStatus = 'searching');
  }

  void _cancelOrder() {
    setState(() => _orderStatus = 'idle');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070b14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070b14),
        title: Text(
          'Xush kelibsiz, ${widget.name}',
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
            if (_orderStatus != 'idle') _buildOrderCard(),
            const SizedBox(height: 16),
            if (_orderStatus == 'idle') ...[
              _buildServiceCard(
                '🚘',
                'Mashina tanlash',
                'Tanlangan mashina',
                () => _callTaxi(),
              ),
              const SizedBox(height: 12),
              _buildServiceCard(
                '📦',
                'Dostavka',
                'Nima kerak?',
                () => _callTaxi(),
              ),
              const SizedBox(height: 12),
              _buildServiceCard(
                '🏢',
                'Airport',
                'Airport transfer',
                () => _callTaxi(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _callTaxi,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFfbbf24), Color(0xFFf59e0b)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, color: Color(0xFF0f172a)),
                      SizedBox(width: 8),
                      Text(
                        'TEZKOR CHAQIRISH',
                        style: TextStyle(
                          color: Color(0xFF0f172a),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _orderStatus == 'searching'
              ? [const Color(0xFF3b82f6), const Color(0xFF2563eb)]
              : [const Color(0xFF22c55e), const Color(0xFF16a34a)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (_orderStatus == 'searching')
            const Icon(Icons.local_taxi, size: 50, color: Colors.white),
          if (_orderStatus == 'driver_found')
            const Text('🚗', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            _orderStatus == 'searching'
                ? 'Haydovchi qidirilmoqda...'
                : 'Haydovchi kelmoqda!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_orderStatus == 'driver_found') ...[
            const SizedBox(height: 8),
            const Text(
              'Haydovchi topildi',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0f172a),
              ),
              child: const Text("Qo'ng'iroq"),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: _cancelOrder,
            child: const Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFfbbf24).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94a3b8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFfbbf24),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
