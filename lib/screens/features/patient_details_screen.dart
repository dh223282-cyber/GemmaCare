import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/medical_context_provider.dart';
import '../../services/db_manager.dart';
import '../../core/theme.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _ageCtrl = TextEditingController();
  final _conditionCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  DateTime? _nextClinicDate;
  File? _reportImage;
  bool _isUploading = false;
  
  List<Map<String, dynamic>> _savedHistory = [];

  @override
  void initState() {
    super.initState();
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    _conditionCtrl.text = medicalContext.conditions.join(', ');
    _medsCtrl.text = medicalContext.medications.join(', ');
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final records = await DbManager().getAllRecords();
    setState(() {
      _savedHistory = records;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _reportImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextClinicDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _nextClinicDate) {
      setState(() {
        _nextClinicDate = picked;
      });
    }
  }

  void _saveDetails() async {
    final medicalContext = Provider.of<MedicalContextProvider>(context, listen: false);
    
    List<String> conds = _conditionCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    List<String> meds = _medsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    medicalContext.updateClinicalData(
      conditions: conds,
      medications: meds,
      score: 90, 
    );

    // Save to SQLite
    final now = DateTime.now();
    final dateStr = "\${now.day}/\${now.month}/\${now.year}";
    
    final record = ClinicalRecord(
      date: dateStr,
      conditions: conds,
      medications: meds,
      reportText: _reportImage != null ? "Image Attached" : "No Report",
      healthScore: 90,
    );

    await DbManager().insertRecord(record, customName: "Clinic Visit - $dateStr");
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details saved to clinical history!')));
    
    setState(() {
      _reportImage = null;
    });
    _loadHistory();
  }

  void _deleteRecord(int id) async {
    await DbManager().deleteRecord(id);
    _loadHistory();
  }

  void _editRecordName(int id, String currentName) {
    TextEditingController nameCtrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Record', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  await DbManager().updateRecordName(id, nameCtrl.text);
                  _loadHistory();
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text('Clinical Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GcSectionHeader(title: 'Medical History'),
            const SizedBox(height: 16),
            _buildTextField(controller: _conditionCtrl, label: 'Medical Conditions', icon: Icons.medical_information, hint: 'e.g. Diabetes, Asthma'),
            const SizedBox(height: 16),
            _buildTextField(controller: _medsCtrl, label: 'Current Medications', icon: Icons.medication, hint: 'e.g. Metformin, Panadol'),
            const SizedBox(height: 32),
            GcSectionHeader(title: 'Lab Reports'),
            const SizedBox(height: 16),
            _buildImageUploadArea(),
            const SizedBox(height: 32),
            GcSectionHeader(title: 'Upcoming Schedule'),
            const SizedBox(height: 16),
            _buildDatePickerTile(),
            const SizedBox(height: 32),
            _buildSaveButton(),
            const SizedBox(height: 48),
            GcSectionHeader(title: 'Saved Local History'),
            const SizedBox(height: 16),
            _buildHistoryList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, String? hint, TextInputType keyboardType = TextInputType.text}) {
    return GcCard(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1), width: 2),
        ),
        child: _reportImage != null
            ? ClipRRect(borderRadius: BorderRadius.circular(AppTheme.radiusLg), child: Image.file(_reportImage!, fit: BoxFit.cover))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text('Upload Lab Report Image', style: GoogleFonts.poppins(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                  Text('(JPEG, PNG)', style: GoogleFonts.poppins(color: AppTheme.textSecondary.withValues(alpha: 0.5), fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildDatePickerTile() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: GcCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Clinic Date', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(
                    _nextClinicDate == null ? 'Not Scheduled' : DateFormat('MMM dd, yyyy').format(_nextClinicDate!),
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded, color: AppTheme.accentTeal, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveDetails,
        child: const Text('Save Clinical Data'),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_savedHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('No local history saved yet.', style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _savedHistory.length,
      itemBuilder: (context, index) {
        final item = _savedHistory[index];
        final id = item['id'];
        final customName = item['customName'] ?? 'Clinic Visit';
        final date = item['date'] ?? '';
        final conds = item['conditions']?.replaceAll('|', ', ') ?? '';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GcCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.infoSurface, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.folder_shared_rounded, color: AppTheme.accentSky),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                      Text("\$date • \$conds", style: GoogleFonts.poppins(fontSize: 11, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.accentTeal, size: 20),
                  onPressed: () => _editRecordName(id, customName),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, color: AppTheme.errorRed, size: 20),
                  onPressed: () => _deleteRecord(id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
