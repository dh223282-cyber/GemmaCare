import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String? _selectedCountry;
  String? _selectedCity;
  bool _isLoading = false;

  final Map<String, List<String>> _countryCities = {
    'Sri Lanka': ['Colombo', 'Kandy', 'Wattala', 'Galle', 'Jaffna'],
    'India': ['Mumbai', 'Delhi', 'Chennai', 'Bangalore'],
    'United States': ['New York', 'Los Angeles', 'Chicago', 'Houston'],
    'United Kingdom': ['London', 'Manchester', 'Birmingham', 'Edinburgh'],
  };

  void _signup() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill basic details")));
      return;
    }
    if (_selectedCountry == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select Country and City")));
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signUp(
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      name: _nameCtrl.text,
      age: int.tryParse(_ageCtrl.text) ?? 0,
      height: double.tryParse(_heightCtrl.text) ?? 0.0,
      weight: double.tryParse(_weightCtrl.text) ?? 0.0,
      country: _selectedCountry!,
      city: _selectedCity!,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      } else {
        Navigator.pop(context); // Go back as StreamBuilder redirects to Home
      }
    }
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPremiumDropdown({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -30,
            child: Icon(Icons.health_and_safety, size: 200, color: Colors.blue.withOpacity(0.05)),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF005CB2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Create Profile',
                      style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the GemmaCare network today.',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildPremiumTextField(controller: _nameCtrl, hint: 'Full Name', icon: Icons.person_outline),
                  _buildPremiumTextField(controller: _emailCtrl, hint: 'Email', icon: Icons.email_outlined, type: TextInputType.emailAddress),
                  _buildPremiumTextField(controller: _passwordCtrl, hint: 'Password', icon: Icons.lock_outline, obscure: true),
                  
                  Row(
                    children: [
                      Expanded(child: _buildPremiumTextField(controller: _ageCtrl, hint: 'Age', icon: Icons.cake, type: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildPremiumTextField(controller: _heightCtrl, hint: 'Height (cm)', icon: Icons.height, type: TextInputType.number)),
                    ],
                  ),
                  _buildPremiumTextField(controller: _weightCtrl, hint: 'Weight (kg)', icon: Icons.monitor_weight_outlined, type: TextInputType.number),
                  
                  _buildPremiumDropdown(
                    hint: 'Select Country',
                    icon: Icons.public,
                    value: _selectedCountry,
                    items: _countryCities.keys.toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCountry = val;
                        _selectedCity = null; // reset city when country changes
                      });
                    },
                  ),
                  
                  _buildPremiumDropdown(
                    hint: 'Select City',
                    icon: Icons.location_city,
                    value: _selectedCity,
                    items: _selectedCountry != null ? _countryCities[_selectedCountry!]! : [],
                    onChanged: (val) {
                      setState(() {
                        _selectedCity = val;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(
                        'Complete Registration',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
