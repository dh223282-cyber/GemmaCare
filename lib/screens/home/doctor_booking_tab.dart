import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class DoctorBookingTab extends StatefulWidget {
  const DoctorBookingTab({super.key});

  @override
  State<DoctorBookingTab> createState() => _DoctorBookingTabState();
}

class _DoctorBookingTabState extends State<DoctorBookingTab> {
  final _searchController = TextEditingController();
  
  final List<Map<String, dynamic>> _specialists = [
    {'name': 'Dr. Samantha Perera', 'specialty': 'Cardiologist', 'rating': 4.9, 'distance': '2.4 km'},
    {'name': 'Dr. Aruna Fernando', 'specialty': 'Endocrinologist', 'rating': 4.8, 'distance': '3.1 km'},
    {'name': 'Dr. Nilanthi Silva', 'specialty': 'General Physician', 'rating': 4.7, 'distance': '1.8 km'},
    {'name': 'Dr. Kamal Wickrama', 'specialty': 'Nutritionist', 'rating': 4.9, 'distance': '5.2 km'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSearchBar(),
            const SizedBox(height: 32),
            Text('Recommended Specialists', style: AppTheme.lightTheme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildSpecialistList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLINICAL DIRECTORY',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentTeal, letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        Text('Connect with Specialists', style: AppTheme.lightTheme.textTheme.displayMedium),
        const SizedBox(height: 8),
        const Text(
          'Access professional medical consultancy nearby.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by specialty or name...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSpecialistList() {
    return Column(
      children: _specialists.map((doc) => _buildSpecialistCard(doc)).toList(),
    );
  }

  Widget _buildSpecialistCard(Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.person_3_rounded, color: AppTheme.primaryBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(doc['specialty'], style: const TextStyle(color: AppTheme.accentTeal, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text('${doc['rating']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded, color: AppTheme.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(doc['distance'], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }
}
