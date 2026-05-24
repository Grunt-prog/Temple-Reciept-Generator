# Temple Donation Receipt App — Complete Setup Guide

## 📁 Final File Structure

```
temple_donation_receipt/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── form_screen.dart
│   │   └── preview_screen.dart
│   ├── services/
│   │   ├── pdf_service.dart
│   │   └── number_to_words.dart
│   └── theme/
│       └── app_theme.dart
├── assets/
│   └── fonts/
│       ├── Cinzel-Bold.ttf
│       ├── LibreBaskerville-Regular.ttf
│       ├── LibreBaskerville-Bold.ttf
│       └── NotoSerifTelugu-Regular.ttf
└── android/
    └── app/
        └── build.gradle  ← set minSdk 21
```

---

## STEP 1 — Create the Flutter project

```bash
flutter create --org com.temple temple_donation_receipt
cd temple_donation_receipt
```

---

## STEP 2 — Replace generated files

Copy each generated file into the exact path shown in the structure above.

---

## STEP 3 — Download the 4 fonts

Go to **https://fonts.google.com** and download:

| Font | File needed |
|------|-------------|
| Cinzel (Bold 700) | `Cinzel-Bold.ttf` |
| Libre Baskerville (Regular 400) | `LibreBaskerville-Regular.ttf` |
| Libre Baskerville (Bold 700) | `LibreBaskerville-Bold.ttf` |
| Noto Serif Telugu (Regular 400) | `NotoSerifTelugu-Regular.ttf` |

Place all 4 files inside `assets/fonts/`.

### Quick download links:
- https://fonts.google.com/specimen/Cinzel → Download family → extract Cinzel-Bold.ttf
- https://fonts.google.com/specimen/Libre+Baskerville → Download → extract both weights
- https://fonts.google.com/noto/specimen/Noto+Serif+Telugu → Download → extract Regular

---

## STEP 4 — Add deity image (Optional but recommended)

You have two options:

### Option A — Use your base64 string (from your file)
In `pdf_service.dart`, replace the deity image loading block:

```dart
// In pdf_service.dart — at the top, add:
const String DEITY_IMAGE_BASE64 = 'YOUR_BASE64_STRING_HERE';

// In generateReceipt(), replace deityImageBytes loading with:
final deityImageBytes = base64Decode(DEITY_IMAGE_BASE64);
final deityImage = pw.MemoryImage(deityImageBytes);
```

Add this import at top of `pdf_service.dart`:
```dart
import 'dart:convert';
```

### Option B — Load from assets
Place your deity image as `assets/deity_image.png` and add to `pubspec.yaml`:
```yaml
assets:
  - assets/fonts/
  - assets/deity_image.png
```

The `form_screen.dart` already tries to load `assets/deity_image.png` automatically.

---

## STEP 5 — Set minSdkVersion

Open `android/app/build.gradle` and find:
```gradle
defaultConfig {
    minSdkVersion flutter.minSdkVersion  // ← change this
```
Change to:
```gradle
    minSdkVersion 21
```

---

## STEP 6 — Add permissions (Android)

Open `android/app/src/main/AndroidManifest.xml` and add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
```

---

## STEP 7 — Install dependencies and run

```bash
flutter pub get
flutter run
```

---

## 🧪 Testing the number-to-words function

You can test it quickly in `main()` before running the app:

```dart
import 'lib/services/number_to_words.dart';

void main() {
  print(convertToIndianWords(5100));     // Five Thousand One Hundred Only
  print(convertToIndianWords(150000));   // One Lakh Fifty Thousand Only
  print(convertToIndianWords(10000000)); // One Crore Only
  print(convertToIndianWords(25650));    // Twenty Five Thousand Six Hundred Fifty Only
}
```

---

## 📱 App Flow

```
FormScreen (Screen 1)
   ↓ Fill fields
   ↓ Tap "GENERATE RECEIPT"
   ↓ PDF bytes generated in memory
PreviewScreen (Screen 2)
   ↓ PdfPreview widget renders the PDF
   ├── Share button → share_plus → WhatsApp / Email / etc.
   └── Download button → saved to /storage/emulated/0/Download/
```

---

## 🎨 Design tokens

| Element | Value |
|---------|-------|
| App bar | `#6B1A1A` (dark maroon) |
| Background | `#FAF0DC` (warm cream) |
| Accent / borders | `#C4960A` (gold) |
| Button text | `#F5E0A0` (light gold) |
| Body text | `#3D2200` (dark brown) |
| Subtitle text | `#8B5A00` (medium brown) |

---

## ⚠️ Common Issues

| Issue | Fix |
|-------|-----|
| `FileSystemException` on download | Make sure `WRITE_EXTERNAL_STORAGE` permission is in AndroidManifest |
| Telugu text shows boxes | `NotoSerifTelugu-Regular.ttf` must be in `assets/fonts/` and registered in `pubspec.yaml` |
| `FormatException` on base64 decode | Make sure your base64 string has no line breaks — it must be one continuous string |
| `Unable to load asset` for fonts | Run `flutter clean && flutter pub get` then rebuild |
| PDF looks unstyled | One of the font files is missing or has wrong filename |

---

## ✅ Checklist before first run

- [ ] 4 font files in `assets/fonts/`
- [ ] `pubspec.yaml` has fonts registered (already done in provided file)
- [ ] `minSdkVersion 21` in `android/app/build.gradle`
- [ ] Android permissions in `AndroidManifest.xml`
- [ ] `flutter pub get` completed with no errors
- [ ] If using deity image: base64 string pasted OR image file placed in `assets/`
