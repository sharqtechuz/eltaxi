import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login va parolni kiriting')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (_userController.text == 'sharqtech' &&
          _passController.text == 'sharq1505') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login yoki parol xato')));
      }
      if (mounted) setState(() => _isLoading = false);
    });
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Text('🔧', style: TextStyle(fontSize: 50)),
                const SizedBox(height: 20),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _userController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'User',
                    hintStyle: const TextStyle(color: Color(0xFF64748b)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passController,
                  style: const TextStyle(color: Colors.white),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Parol',
                    hintStyle: const TextStyle(color: Color(0xFF64748b)),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFfbbf24),
                      foregroundColor: const Color(0xFF0f172a),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0f172a),
                            ),
                          )
                        : const Text(
                            'KIRISH',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070b14),
      body: IndexedStack(
        index: _currentIndex,
        children: const [AdminHome(), DriversList(), AddDriverForm()],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0f172a),
        indicatorColor: const Color(0xFFfbbf24).withValues(alpha: 0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard, color: Colors.white54),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFFfbbf24)),
            label: 'Boshqaruv',
          ),
          NavigationDestination(
            icon: Icon(Icons.people, color: Colors.white54),
            selectedIcon: Icon(Icons.people, color: Color(0xFFfbbf24)),
            label: 'Haydovchilar',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle, color: Colors.white54),
            selectedIcon: Icon(Icons.add_circle, color: Color(0xFFfbbf24)),
            label: 'Qo\'shish',
          ),
        ],
      ),
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://eltaxi-production.up.railway.app/api/admin/stats',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070b14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'ElTaksi Admin',
          style: TextStyle(color: Color(0xFFfbbf24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFfbbf24)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Statistika',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people,
                          title: 'Jami Mijozlar',
                          value: '${_stats?['customerCount'] ?? 0}',
                          color: const Color(0xFF3b82f6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.directions_car,
                          title: 'Online Haydovchilar',
                          value: '${_stats?['onlineCount'] ?? 0}',
                          color: const Color(0xFF22c55e),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.attach_money,
                          title: 'Umumiy Tushum',
                          value:
                              '${_formatNumber(_stats?['totalEarnings'] ?? 0)} UZS',
                          color: const Color(0xFFfbbf24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.route,
                          title: 'Jami Safarlar',
                          value: '${_stats?['totalTrips'] ?? 0}',
                          color: const Color(0xFF8b5cf6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '⚡ Tezkor Amallar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _QuickAction(
                    icon: Icons.add_circle_outline,
                    title: 'Haydovchi Qo\'shish',
                    onTap: () {
                      final adminState = context
                          .findAncestorStateOfType<
                            _AdminDashboardScreenState
                          >();
                      adminState?.setState(() => adminState._currentIndex = 2);
                    },
                  ),
                  const SizedBox(height: 12),
                  _QuickAction(
                    icon: Icons.people_outline,
                    title: 'Haydovchilar Ro\'yxati',
                    onTap: () {
                      final adminState = context
                          .findAncestorStateOfType<
                            _AdminDashboardScreenState
                          >();
                      adminState?.setState(() => adminState._currentIndex = 1);
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFfbbf24).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFfbbf24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF64748b),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class DriversList extends StatefulWidget {
  const DriversList({super.key});

  @override
  State<DriversList> createState() => _DriversListState();
}

class _DriversListState extends State<DriversList> {
  List<dynamic> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://eltaxi-production.up.railway.app/api/admin/drivers',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _drivers = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070b14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Haydovchilar',
          style: TextStyle(color: Color(0xFFfbbf24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDrivers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFfbbf24)),
            )
          : _drivers.isEmpty
          ? const Center(
              child: Text(
                'Haydovchilar topilmadi',
                style: TextStyle(color: Color(0xFF94a3b8)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _drivers.length,
              itemBuilder: (context, index) {
                final driver = _drivers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: driver['isOnline'] == true
                          ? const Color(0xFF22c55e)
                          : const Color(0xFF475569),
                    ),
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
                        child: const Center(
                          child: Text('🚗', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver['driverName'] ?? driver['login'] ?? 'N/A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${driver['carModel'] ?? ''} | ${driver['carNumber'] ?? ''}',
                              style: const TextStyle(
                                color: Color(0xFF94a3b8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF64748b),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  driver['region'] ?? 'Hudud belgilanmagan',
                                  style: const TextStyle(
                                    color: Color(0xFF64748b),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: driver['isOnline'] == true
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              driver['isOnline'] == true ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: driver['isOnline'] == true
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                '${driver['statistics']?['balls'] ?? 0}',
                                style: const TextStyle(
                                  color: Color(0xFFfbbf24),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${driver['statistics']?['totalTrips'] ?? 0} safar',
                            style: const TextStyle(
                              color: Color(0xFF64748b),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AddDriverForm extends StatefulWidget {
  const AddDriverForm({super.key});

  @override
  State<AddDriverForm> createState() => _AddDriverFormState();
}

class _AddDriverFormState extends State<AddDriverForm> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carNumberController = TextEditingController();
  String _selectedRegion = 'Urgut';
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(
              'https://eltaxi-production.up.railway.app/api/admin/add-driver',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'login': _loginController.text,
              'password': _passwordController.text,
              'driverName': _nameController.text,
              'phone': _phoneController.text,
              'carModel': _carModelController.text,
              'carNumber': _carNumberController.text,
              'region': _selectedRegion,
              'tariff': 'Standart',
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Haydovchi muvaffaqiyatli qo\'shildi!'),
              backgroundColor: Colors.green,
            ),
          );
          _loginController.clear();
          _passwordController.clear();
          _nameController.clear();
          _phoneController.clear();
          _carModelController.clear();
          _carNumberController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xatolik: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070b14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Haydovchi Qo\'shish',
          style: TextStyle(color: Color(0xFFfbbf24)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _loginController,
                label: 'Login *',
                hint: 'Masalan: anvar123',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Parol *',
                hint: 'Kamida 4 ta belgi',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Ism Familiya *',
                hint: 'Masalan: Anvar Karimov',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefon *',
                hint: '+998901234567',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _carModelController,
                label: 'Mashina Modeli *',
                hint: 'Masalan: Daewoo Matiz',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _carNumberController,
                label: 'Mashina Raqami *',
                hint: 'Masalan: 01 A 777 AA',
              ),
              const SizedBox(height: 16),
              const Text(
                'Hudud',
                style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedRegion,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1e293b),
                  underline: const SizedBox(),
                  items: ['Urgut', 'Bulungur', 'Tayloq', 'Samarkand', 'Nurata']
                      .map(
                        (region) => DropdownMenuItem(
                          value: region,
                          child: Text(
                            region,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedRegion = value);
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfbbf24),
                    foregroundColor: const Color(0xFF0f172a),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0f172a),
                          ),
                        )
                      : const Text(
                          'Qo\'shish',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Maydon to\'ldirilishi kerak';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748b)),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFfbbf24)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
