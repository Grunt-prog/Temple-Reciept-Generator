// pdf_service.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/template_base64.dart';

// ── Colours ─────────────────────────────────────────────────────────────────
const _maroon = PdfColor.fromInt(0xFF6B1A1A);
const _darkBrown = PdfColor.fromInt(0xFF3D2200);

class PdfService {
  // ── Static caches ────────────────────────────────────────────────────────
  static pw.MemoryImage? _cachedTemplate;

  static pw.Font? _cachedLibre;
  static pw.Font? _cachedLibreBold;
  static pw.Font? _cachedTelugu;

  // ── Load Template ────────────────────────────────────────────────────────
  static pw.MemoryImage _getTemplate() {
    _cachedTemplate ??=
        pw.MemoryImage(base64Decode(templeTemplateBase64));

    return _cachedTemplate!;
  }

  // ── Load Fonts ───────────────────────────────────────────────────────────
  static Future<void> _loadFonts() async {
    if (_cachedLibre != null) return;

    final regular = await rootBundle.load(
      'assets/fonts/LibreBaskerville-Regular.ttf',
    );

    final bold = await rootBundle.load(
      'assets/fonts/LibreBaskerville-Bold.ttf',
    );

    final telugu = await rootBundle.load(
      'assets/fonts/NotoSerifTelugu-Regular.ttf',
    );

    _cachedLibre = pw.Font.ttf(regular);
    _cachedLibreBold = pw.Font.ttf(bold);
    _cachedTelugu = pw.Font.ttf(telugu);
  }

  // ── Generate Receipt ─────────────────────────────────────────────────────
  static Future<Uint8List> generateReceipt({
    required String receiptNo,
    required String date,
    required String donorTitle,
    required String donorName,
    required String gothram,
    required String district,
    required String address,
    required String amountFigures,
    required String amountWords,
    required String paymentMethod,
    required String donationType,
  }) async {
    await _loadFonts();

    final templateImage = _getTemplate();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildPage(
          templateImage: templateImage,
          receiptNo: receiptNo,
          date: date,
          donorTitle: donorTitle,
          donorName: donorName,
          gothram: gothram,
          district: district,
          address: address,
          amountFigures: amountFigures,
          amountWords: amountWords,
          paymentMethod: paymentMethod,
          donationType: donationType,
        ),
      ),
    );

    return pdf.save();
  }

  // ── Build PDF Page ───────────────────────────────────────────────────────
  static pw.Widget _buildPage({
    required pw.MemoryImage templateImage,
    required String receiptNo,
    required String date,
    required String donorTitle,
    required String donorName,
    required String gothram,
    required String district,
    required String address,
    required String amountFigures,
    required String amountWords,
    required String paymentMethod,
    required String donationType,
  }) {
    final pageWidth = PdfPageFormat.a4.width;
    final pageHeight = PdfPageFormat.a4.height;

    // ── Coordinate mapping ────────────────────────────────────────────────
    double px(double imgX) => imgX * (pageWidth / 1024);

    double py(double imgY) =>
        pageHeight - imgY * (pageHeight / 1536);

    // ── Styles ────────────────────────────────────────────────────────────
    pw.TextStyle normal(double size) => pw.TextStyle(
          font: _cachedLibre!,
          fontSize: size,
          color: _darkBrown,
          height: 1.35,
        );

    pw.TextStyle bold(double size) => pw.TextStyle(
          font: _cachedLibreBold!,
          fontSize: size,
          color: _darkBrown,
          height: 1.35,
        );

    pw.TextStyle maroonBold(double size) => pw.TextStyle(
          font: _cachedLibreBold!,
          fontSize: size,
          color: _maroon,
          height: 1.35,
        );

    pw.TextStyle rupee(double size) => pw.TextStyle(
          font: _cachedTelugu!,
          fontSize: size,
          color: _darkBrown,
        );

    // ── Paragraph safe zone ───────────────────────────────────────────────
    final bodyLeft = px(180);
    final bodyWidth = px(900) - px(180);

    // ── Responsive address font ───────────────────────────────────────────
    final addressFontSize = address.length > 70
        ? 8.0
        : address.length > 50
            ? 9.0
            : 10.5;

    // ── Donation sentence ────────────────────────────────────────────────
    final donationSentence =
        donationType == 'Annadhanam Donation'
            ? 'towards Annadhanam Donation at'
            : 'towards Temple Donation at';

    return pw.Stack(
      children: [

        // ── Background Template ─────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Image(
            templateImage,
            fit: pw.BoxFit.fill,
          ),
        ),

        // ── Date ───────────────────────────────────────────────────────
        pw.Positioned(
          left: px(555),
          bottom: py(780),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'Date : ',
                style: normal(10.5),
              ),
              pw.Text(
                date,
                style: bold(10.5),
              ),
            ],
          ),
        ),

        // ── Receipt Number ─────────────────────────────────────────────
        pw.Positioned(
          left: px(555),
          bottom: py(820),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'Receipt No. : ',
                style: normal(10.5),
              ),
              pw.Text(
                receiptNo,
                style: bold(10.5),
              ),
            ],
          ),
        ),

        // ── Main Body Paragraph ────────────────────────────────────────
        pw.Positioned(
          left: bodyLeft,
          bottom: py(1260),
          child: pw.SizedBox(
            width: bodyWidth,
            child: pw.RichText(
              textAlign: pw.TextAlign.center,
              text: pw.TextSpan(
                style: normal(10.5),
                children: [

                  // ── Intro ─────────────────────────────────────────
                  pw.TextSpan(
                    text:
                        'This is to acknowledge with gratitude that ',
                  ),

                  pw.TextSpan(
                    text: '$donorTitle $donorName',
                    style: bold(11),
                  ),

                  pw.TextSpan(
                    text: '\nof ',
                  ),

                  pw.TextSpan(
                    text:
                        gothram.trim().isEmpty ? 'N/A' : gothram,
                    style: bold(11),
                  ),

                  pw.TextSpan(
                    text: ' gothram, ',
                  ),

                  pw.TextSpan(
                    text: district,
                    style: bold(11),
                  ),

                  pw.TextSpan(
                    text: ', residing at\n',
                  ),

                  // ── Address ─────────────────────────────────────
                  pw.TextSpan(
                    text: address,
                    style: bold(addressFontSize),
                  ),

                  // ── Amount ──────────────────────────────────────
                  pw.TextSpan(
                    text: '\n\nhas devotedly donated ',
                  ),

                  pw.TextSpan(
                    text: '\u20B9 ',
                    style: rupee(12),
                  ),

                  pw.TextSpan(
                    text: '$amountFigures/-',
                    style: bold(12),
                  ),

                  // ── Amount in words ─────────────────────────────
                  pw.TextSpan(
                    text: '\n(Rupees ',
                  ),

                  pw.TextSpan(
                    text: '$amountWords Only',
                    style: bold(11),
                  ),

                  pw.TextSpan(
                    text: ') by way of ',
                  ),

                  pw.TextSpan(
                    text: paymentMethod,
                    style: bold(11),
                  ),

                  // ── Donation Type ───────────────────────────────
                  pw.TextSpan(
                    text: '\n$donationSentence ',
                  ),

                  pw.TextSpan(
                    text:
                        'SRI ABHAYA ANJANEYA SWAMY DEVASTHANAM',
                    style: maroonBold(10.5),
                  ),

                  pw.TextSpan(
                    text:
                        ',\nMidtur Village, Nandyal District.',
                  ),

                  // ── Blessing ────────────────────────────────────
                  pw.TextSpan(
                    text:
                        '\n\nWe pray to Sri Anjaneya Swamy to bless you and your family '
                        'with health, happiness, prosperity and all divine blessings.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}