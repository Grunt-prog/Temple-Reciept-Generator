// pdf_layout_constants.dart
//
// All coordinates are in pixels relative to the reference template image.
// Reference image size: 1024 x 1536 px
//
// HOW TO TUNE:
//   - Open the template image in any image editor (Photoshop, Paint, Preview)
//   - Hover over the spot where you want text → note the x, y pixel values
//   - Paste those values below and hot-reload
//
// Coordinate system: top-left = (0, 0)
//   imgX → left to right
//   imgY → top to bottom

class PdfLayoutConstants {

  // ── Reference image dimensions ───────────────────────────────────────────
  static const double refWidth  = 1024;
  static const double refHeight = 1536;

  // ────────────────────────────────────────────────────────────────────────
  // DATE & RECEIPT ROW
  // ────────────────────────────────────────────────────────────────────────
  // The row is centered horizontally (left:0, right:0).
  // Only imgY controls vertical position.
  static const double dateReceiptY    = 830;   // imgY — move row up/down
  static const double dateReceiptGap  = 60;    // pt gap between date and receipt no.
  static const double dateReceiptSize = 12;    // font size (pt)

  // ────────────────────────────────────────────────────────────────────────
  // BODY PARAGRAPH
  // ────────────────────────────────────────────────────────────────────────
  static const double bodyX     = 135;   // imgX — left margin of paragraph
  static const double bodyY     = 894;   // imgY — top of paragraph
  // Right margin mirrors bodyX (symmetric). Effective width = page - 2*bodyX scaled.

  // ── Font sizes inside the paragraph ──────────────────────────────────────
  static const double bodyNormalSize  = 13;   // regular text
  static const double bodyBoldSize    = 14;   // donor name, gothram, district etc.
  static const double bodyAmountSize  = 15;   // ₹ amount figures
  static const double bodyRupeeSize   = 15;   // ₹ symbol (Telugu font)
  static const double bodyMaroonSize  = 13;   // temple name in maroon
  static const double bodyLineHeight  = 1.35; // line spacing multiplier

  // ── Address font (auto-shrinks for long addresses) ────────────────────────
  static const double addressSizeShort  = 13;  // address.length <= 50
  static const double addressSizeMedium = 14;  // address.length 51–70
  static const double addressSizeLong   = 15;  // address.length > 70
}