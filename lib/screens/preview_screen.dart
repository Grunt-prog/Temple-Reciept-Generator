// ─────────────────────────────────────────────────────────────────────────────
// preview_screen.dart  (FIXED)
//
// FIX 3 (preview side):
//   • pdfBytes are already generated before navigation — PdfPreview just
//     renders them; it never re-calls generateReceipt().
//   • useActions: false / allowSharing: false to reduce PdfPreview overhead.
//   • initialPageFormat pinned to A4 so the viewer never re-renders on resize.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_theme.dart';

class PreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String    receiptNo;
  final String    donorName;

  const PreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.receiptNo,
    required this.donorName,
  });

  // ── File name helper ─────────────────────────────────────────────────────
  String get _fileName => 'Receipt_${receiptNo}_$donorName.pdf'
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'[^\w._-]'), '');

  // ── Share ────────────────────────────────────────────────────────────────
  Future<void> _sharePdf(BuildContext context) async {
    try {
      final tmp  = await getTemporaryDirectory();
      final file = File('${tmp.path}/$_fileName');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Donation Receipt – Sri Abhaya Anjaneya Swamy Devasthanam',
        text: 'Please find attached the donation receipt No. $receiptNo.',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Download ─────────────────────────────────────────────────────────────
  Future<void> _downloadPdf(BuildContext context) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File('${dir!.path}/$_fileName');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved to Downloads: $_fileName',
              style: GoogleFonts.libreBaskerville(color: AppTheme.darkBrown),
            ),
            backgroundColor: AppTheme.gold,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Capture bytes in a local final so the closure is stable.
    final bytes = pdfBytes;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.maroon,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.lightGold),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Receipt Preview',
          style: GoogleFonts.cinzel(
            color       : AppTheme.lightGold,
            fontSize    : 16,
            fontWeight  : FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon   : const Icon(Icons.share_rounded, color: AppTheme.lightGold),
            tooltip: 'Share PDF',
            onPressed: () => _sharePdf(context),
          ),
          IconButton(
            icon   : const Icon(Icons.download_rounded, color: AppTheme.lightGold),
            tooltip: 'Download PDF',
            onPressed: () => _downloadPdf(context),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ── FIX 3: PdfPreview optimisations ───────────────────────────────────
      // • build: (_) => bytes  — synchronous return, no async work here.
      //   All heavy lifting (base64 decode, font load, pdf.save()) already
      //   happened in FormScreen before navigation.
      // • initialPageFormat: A4  — prevents an extra render pass on first open.
      // • canChangePageFormat / canChangeOrientation: false  — locks layout.
      // • allowPrinting / allowSharing: false  — removes extra PdfPreview
      //   toolbar buttons we don't need (we have our own in the AppBar).
      body: PdfPreview(
        // The builder must return a Future<Uint8List>; wrapping in
        // Future.value() is near-zero cost since bytes are already in memory.
        build: (_) => Future.value(bytes),

        initialPageFormat   : PdfPageFormat.a4,
        canChangeOrientation: false,
        canChangePageFormat : false,
        canDebug            : false,
        allowPrinting       : true,
        allowSharing        : false,

        pdfPreviewPageDecoration: BoxDecoration(
          color     : Colors.white,
          boxShadow : [
            BoxShadow(
              color      : Colors.brown.withOpacity(0.2),
              blurRadius : 8,
              offset     : const Offset(0, 2),
            ),
          ],
        ),

        actions           : const [],
        previewPageMargin : const EdgeInsets.all(16),
      ),
    );
  }
}