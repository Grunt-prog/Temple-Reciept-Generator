// pdf_service.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constants/template_base64.dart';
import '../constants/pdf_layout_constants.dart';

// ── Colours ──────────────────────────────────────────────────────────────────
const _maroon    = PdfColor.fromInt(0xFF6B1A1A);
const _darkBrown = PdfColor.fromInt(0xFF3D2200);

class PdfService {
  // ── Static caches ─────────────────────────────────────────────────────────
  static pw.MemoryImage? _cachedTemplate;
  static pw.Font?        _cachedLibre;
  static pw.Font?        _cachedLibreBold;
  static pw.Font?        _cachedTelugu;

  // ── Load Template ─────────────────────────────────────────────────────────
  static pw.MemoryImage _getTemplate() {
    _cachedTemplate ??= pw.MemoryImage(base64Decode(templeTemplateBase64));
    return _cachedTemplate!;
  }

  // ── Load Fonts ────────────────────────────────────────────────────────────
  static Future<void> _loadFonts() async {
    if (_cachedLibre != null) return;

    final regular = await rootBundle.load('assets/fonts/LibreBaskerville-Regular.ttf');
    final bold    = await rootBundle.load('assets/fonts/LibreBaskerville-Bold.ttf');
    final telugu  = await rootBundle.load('assets/fonts/NotoSerifTelugu-Regular.ttf');

    _cachedLibre     = pw.Font.ttf(regular);
    _cachedLibreBold = pw.Font.ttf(bold);
    _cachedTelugu    = pw.Font.ttf(telugu);
  }

  // ── Generate Receipt ──────────────────────────────────────────────────────
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

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildPage(
          templateImage: _getTemplate(),
          receiptNo:     receiptNo,
          date:          date,
          donorTitle:    donorTitle,
          donorName:     donorName,
          gothram:       gothram,
          district:      district,
          address:       address,
          amountFigures: amountFigures,
          amountWords:   amountWords,
          paymentMethod: paymentMethod,
          donationType:  donationType,
        ),
      ),
    );
    return pdf.save();
  }

  // ── Build PDF Page ────────────────────────────────────────────────────────
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
    final pageWidth  = PdfPageFormat.a4.width;
    final pageHeight = PdfPageFormat.a4.height;

    // ── Coordinate converters (image px → PDF points, top-based) ────────────
    double px(double imgX) => imgX * (pageWidth  / PdfLayoutConstants.refWidth);
    double py(double imgY) => imgY * (pageHeight / PdfLayoutConstants.refHeight);

    // ── Text styles (all driven by constants) ────────────────────────────────
    pw.TextStyle normal(double size) => pw.TextStyle(
      font:      _cachedLibre!,
      fontSize:  size,
      color:     _darkBrown,
      height:    PdfLayoutConstants.bodyLineHeight,
    );

    pw.TextStyle bold(double size) => pw.TextStyle(
      font:      _cachedLibreBold!,
      fontSize:  size,
      color:     _darkBrown,
      height:    PdfLayoutConstants.bodyLineHeight,
    );

    pw.TextStyle maroonBold(double size) => pw.TextStyle(
      font:      _cachedLibreBold!,
      fontSize:  size,
      color:     _maroon,
      height:    PdfLayoutConstants.bodyLineHeight,
    );

    pw.TextStyle maroonBoldUnderline(double size) => pw.TextStyle(
      font:           _cachedLibreBold!,
      fontSize:       size,
      color:          _maroon,
      height:         PdfLayoutConstants.bodyLineHeight,
      decoration:     pw.TextDecoration.underline,
      decorationStyle: pw.TextDecorationStyle.solid,
    );

    pw.TextStyle rupee(double size) => pw.TextStyle(
      font:      _cachedTelugu!,
      fontSize:  size,
      color:     _darkBrown,
    );

    // ── Layout values from constants ─────────────────────────────────────────
    final bodyLeft  = px(PdfLayoutConstants.bodyX);
    final bodyWidth = pageWidth - px(PdfLayoutConstants.bodyX) * 2;

    // ── Address font size (auto-shrinks for long text) ────────────────────────
    final addressFontSize = address.length > 70
        ? PdfLayoutConstants.addressSizeLong
        : address.length > 50
            ? PdfLayoutConstants.addressSizeMedium
            : PdfLayoutConstants.addressSizeShort;

    // ── Donation sentence ─────────────────────────────────────────────────────
    final donationSentence = donationType == 'Annadhanam Donation'
        ? 'towards Annadhanam Donation to'
        : 'towards Temple Donation to';

    return pw.Stack(
      children: [

        // ── Background template ───────────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Image(templateImage, fit: pw.BoxFit.fill),
        ),

        // ── Date & Receipt row (horizontally centered) ────────────────────────
        pw.Positioned(
          left:  0,
          right: 0,
          top:   py(PdfLayoutConstants.dateReceiptY),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('Date : ',        style: normal(PdfLayoutConstants.dateReceiptSize)),
              pw.Text(date,             style: bold(PdfLayoutConstants.dateReceiptSize)),
              pw.SizedBox(width: PdfLayoutConstants.dateReceiptGap),
              pw.Text('Receipt No. : ', style: normal(PdfLayoutConstants.dateReceiptSize)),
              pw.Text(receiptNo,        style: bold(PdfLayoutConstants.dateReceiptSize)),
            ],
          ),
        ),

        // ── Body paragraph ────────────────────────────────────────────────────
        pw.Positioned(
          left:  bodyLeft,
          top:   py(PdfLayoutConstants.bodyY),
          child: pw.SizedBox(
            width: bodyWidth,
            child: pw.RichText(
              textAlign: pw.TextAlign.center,
              text: pw.TextSpan(
                style: normal(PdfLayoutConstants.bodyNormalSize),
                children: [

                  // Intro
                  pw.TextSpan(text: 'This is to acknowledge with gratitude that '),
                  pw.TextSpan(
                    text:  '$donorTitle $donorName',
                    style: bold(PdfLayoutConstants.bodyBoldSize),
                  ),

                  // Gothram & district
                  pw.TextSpan(text: '\nof '),
                  pw.TextSpan(
                    text:  gothram.trim().isEmpty ? 'N/A' : gothram,
                    style: bold(PdfLayoutConstants.bodyBoldSize),
                  ),
                  pw.TextSpan(text: ' Gothram, residing at '),
                  pw.TextSpan(
                    text:  address,
                    style: bold(addressFontSize),
                  ),
                  pw.TextSpan(text: ', '),
                  pw.TextSpan(
                    text:  district,
                    style: bold(PdfLayoutConstants.bodyBoldSize),
                  ),

                  // Amount
                  pw.TextSpan(text: '\nhas devotedly donated '),
                  pw.TextSpan(text: '\u20B9 ', style: rupee(PdfLayoutConstants.bodyRupeeSize)),
                  pw.TextSpan(
                    text:  '$amountFigures/-',
                    style: bold(PdfLayoutConstants.bodyAmountSize),
                  ),

                  // Amount in words
                  pw.TextSpan(text: '\n(Rupees '),
                  pw.TextSpan(
                    text:  amountWords,
                    style: bold(PdfLayoutConstants.bodyBoldSize),
                  ),
                  pw.TextSpan(text: ' Only) by way of '),
                  pw.TextSpan(
                    text:  paymentMethod,
                    style: bold(PdfLayoutConstants.bodyBoldSize),
                  ),

                  // Donation type
                  pw.TextSpan(text: '\n'),
                  pw.TextSpan(
                    text:  donationSentence,
                    style: maroonBoldUnderline(PdfLayoutConstants.bodyMaroonSize + 0.5),
                  ),
                  pw.TextSpan(text: ' '),
                  pw.TextSpan(
                    text:  'SRI ABHAYA ANJANEYA SWAMY DEVASTHANAM',
                    style: maroonBold(PdfLayoutConstants.bodyMaroonSize),
                  ),
                  pw.TextSpan(text: '.'),

                  // Blessing
                  pw.TextSpan(
                    text: '\n\nWe pray to Sri Anjaneya Swamy to bless you and your family '
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