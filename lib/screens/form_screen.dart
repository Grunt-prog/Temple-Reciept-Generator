import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/number_to_words.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──────────────────────────────────────────────────────────
  final _receiptNoCtrl = TextEditingController();
  final _donorNameCtrl = TextEditingController();
  final _gothramCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _amountFigCtrl = TextEditingController();
  final _amountWordsCtrl = TextEditingController();

  // ── State ────────────────────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();

  String _donorTitle = 'Sri';
  String _paymentMethod = 'Cash';
  String _donationType = 'Temple Donation';

  bool _isGenerating = false;

  static const _titles = [
    'Sri',
    'Smt',
  ];

  static const _payments = [
    'Cash',
    'PhonePe',
    'NEFT/RTGS',
    'Cheque',
    'DD'
  ];

  static const _donationTypes = [
  'Temple Donation',
  'Annadhanam Donation',
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _amountFigCtrl.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _receiptNoCtrl.dispose();
    _donorNameCtrl.dispose();
    _gothramCtrl.dispose();
    _districtCtrl.dispose();
    _addressCtrl.dispose();
    _amountFigCtrl.dispose();
    _amountWordsCtrl.dispose();
    super.dispose();
  }

  // ── Amount → Words auto-fill ────────────────────────────────────────────
  void _onAmountChanged() {
    final raw = _amountFigCtrl.text.replaceAll(',', '').trim();

    if (raw.isEmpty) {
      _amountWordsCtrl.text = '';
      return;
    }

    final n = int.tryParse(raw);

    if (n == null || n < 0) return;

    _amountWordsCtrl.text = convertToIndianWords(n);
  }

  // ── Date Picker ─────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.maroon,
            onPrimary: AppTheme.lightGold,
            onSurface: AppTheme.darkBrown,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate =>
      DateFormat('dd-MM-yyyy').format(_selectedDate);

  // ── Clear Form ───────────────────────────────────────────────────────────
  void _clearForm() {
    _formKey.currentState?.reset();

    _receiptNoCtrl.clear();
    _donorNameCtrl.clear();
    _gothramCtrl.clear();
    _districtCtrl.clear();
    _addressCtrl.clear();
    _amountFigCtrl.clear();
    _amountWordsCtrl.clear();

    setState(() {
      _selectedDate = DateTime.now();
      _donorTitle = 'Sri';
      _paymentMethod = 'Cash';
      _donationType = 'Temple Donation';
    });
  }

  // ── Error Snackbar ──────────────────────────────────────────────────────
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.libreBaskerville(
            color: AppTheme.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ── Generate Receipt ────────────────────────────────────────────────────
  Future<void> _generateReceipt() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount =
        int.tryParse(_amountFigCtrl.text.replaceAll(',', '')) ?? 0;

    if (amount <= 0) {
      _showError('Amount must be greater than zero.');
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final pdfBytes = await PdfService.generateReceipt(
        receiptNo: _receiptNoCtrl.text.trim(),
        date: _formattedDate,
        donorTitle: _donorTitle,
        donorName: _donorNameCtrl.text.trim(),
        gothram: _gothramCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        amountFigures: _amountFigCtrl.text.trim(),
        amountWords: _amountWordsCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        donationType: _donationType,
      );

      if (!mounted) return;

      // Save PDF to device
      final fileName = 'Receipt_${_receiptNoCtrl.text.trim()}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savedFile = await _savePdfFile(pdfBytes, fileName);

      if (savedFile != null) {
        _showSuccess('PDF saved: $fileName');
        // Show share dialog to open with any app
        await Share.shareXFiles(
          [XFile(savedFile.path)],
          text: 'Donation Receipt',
        );
      }
    } catch (e) {
      _showError('Error generating PDF: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  // ── Save PDF File ────────────────────────────────────────────────────────
  Future<File?> _savePdfFile(List<int> pdfBytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfPath = File('${directory.path}/$fileName');
      await pdfPath.writeAsBytes(pdfBytes);
      return pdfPath;
    } catch (e) {
      _showError('Error saving PDF: $e');
      return null;
    }
  }

  // ── Success Snackbar ─────────────────────────────────────────────────────
  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.libreBaskerville(
            color: AppTheme.darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🪷 Donation Receipt',
          style: GoogleFonts.cinzel(
            color: AppTheme.lightGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Clear Form',
            onPressed: _clearForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          children: [

            _sectionHeader('Receipt Details'),
            const SizedBox(height: 12),

            // ── Receipt No ───────────────────────────────────────────
            TextFormField(
              controller: _receiptNoCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: AppTheme.fieldDecoration(
                label: 'Receipt No.',
                hint: 'e.g. 001',
              ),
              style: AppTheme.bodyStyle,
              validator: (v) =>
                  (v == null || v.isEmpty)
                      ? 'Receipt No. is required'
                      : null,
            ),

            const SizedBox(height: 20),

            // ── Date ────────────────────────────────────────────────
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: AppTheme.fieldDecoration(
                    label: 'Date',
                    suffix: const Icon(
                      Icons.calendar_today,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                  ).copyWith(hintText: _formattedDate),
                  controller:
                      TextEditingController(text: _formattedDate),
                  style: AppTheme.bodyStyle,
                ),
              ),
            ),

            const SizedBox(height: 28),

            _sectionHeader('Donor Information'),
            const SizedBox(height: 12),

            // ── Title + Name ────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                SizedBox(
                  width: 120,
                  child: _buildDropdown(
                    label: 'Title',
                    value: _donorTitle,
                    items: _titles,
                    onChanged: (v) =>
                        setState(() => _donorTitle = v!),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextFormField(
                    controller: _donorNameCtrl,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: AppTheme.fieldDecoration(
                      label: 'Donor Full Name',
                    ),
                    style: AppTheme.bodyStyle,
                    validator: (v) =>
                        (v == null || v.isEmpty)
                            ? 'Donor name is required'
                            : null,
                  ),
                ),
              ],
            ),

            // ── Custom Title (if selected) ──────────────────────────
            if (_donorTitle == 'Custom')
              ...[
                const SizedBox(height: 20),
              ],

            const SizedBox(height: 20),

            // ── Gothram ────────────────────────────────────────────
            TextFormField(
              controller: _gothramCtrl,
              textCapitalization:
                  TextCapitalization.words,
              decoration: AppTheme.fieldDecoration(
                label: 'Gothram',
                hint: 'Optional',
              ),
              style: AppTheme.bodyStyle,
            ),

            const SizedBox(height: 20),

            // ── District ───────────────────────────────────────────
            TextFormField(
              controller: _districtCtrl,
              textCapitalization:
                  TextCapitalization.words,
              decoration:
                  AppTheme.fieldDecoration(label: 'District'),
              style: AppTheme.bodyStyle,
              validator: (v) =>
                  (v == null || v.isEmpty)
                      ? 'District is required'
                      : null,
            ),

            const SizedBox(height: 20),

            // ── Address ────────────────────────────────────────────
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: AppTheme.fieldDecoration(
                label: 'Address / Village',
                hint: 'Full address or village name',
              ),
              style: AppTheme.bodyStyle,
              validator: (v) =>
                  (v == null || v.isEmpty)
                      ? 'Address is required'
                      : null,
            ),

            const SizedBox(height: 28),

            _sectionHeader('Donation Details'),
            const SizedBox(height: 12),

            // ── Amount ─────────────────────────────────────────────
            TextFormField(
              controller: _amountFigCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: AppTheme.fieldDecoration(
                label: 'Amount in Figures (₹)',
                hint: 'e.g. 5100',
                suffix: const Icon(
                  Icons.currency_rupee,
                  color: AppTheme.gold,
                  size: 18,
                ),
              ),
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Amount is required';
                }

                final n = int.tryParse(v);

                if (n == null || n <= 0) {
                  return 'Enter a valid amount';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            // ── Amount in words ────────────────────────────────────
            TextFormField(
              controller: _amountWordsCtrl,
              maxLines: 2,
              decoration: AppTheme.fieldDecoration(
                label: 'Amount in Words',
                hint: 'Auto-filled from amount above',
              ),
              style: AppTheme.bodyStyle,
              validator: (v) =>
                  (v == null || v.isEmpty)
                      ? 'Amount in words is required'
                      : null,
            ),

            const SizedBox(height: 20),

            // ── Donation Type ──────────────────────────────────────
            _buildDropdown(
              label: 'Type of Donation',
              value: _donationType,
              items: _donationTypes,
              onChanged: (v) =>
                  setState(() => _donationType = v!),
            ),

            const SizedBox(height: 20),

            // ── Payment Method ─────────────────────────────────────
            _buildDropdown(
              label: 'Payment Method',
              value: _paymentMethod,
              items: _payments,
              onChanged: (v) =>
                  setState(() => _paymentMethod = v!),
            ),

            const SizedBox(height: 40),

            // ── Generate Button ────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed:
                    _isGenerating ? null : _generateReceipt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.maroon,
                  foregroundColor: AppTheme.lightGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppTheme.lightGold,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'GENERATE RECEIPT',
                        style: GoogleFonts.cinzel(
                          color: AppTheme.lightGold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title,
          style: GoogleFonts.cinzel(
            color: AppTheme.maroon,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 4),

        Container(
          height: 1.5,
          color: AppTheme.gold,
        ),
      ],
    );
  }

  // ── Dropdown ─────────────────────────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: AppTheme.fieldDecoration(label: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          dropdownColor: AppTheme.cream,
          style: AppTheme.bodyStyle,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.gold,
          ),
          items: items
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}