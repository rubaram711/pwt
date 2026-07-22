// Embedded fonts — runtime registration from base64, no pubspec `fonts:` section
// and no loose .ttf files. This is the "everything embedded in Dart" mechanism.
//
// ─────────────────────────────────────────────────────────────────────────────
// HOW TO FINISH EMBEDDING THE FONTS
// ─────────────────────────────────────────────────────────────────────────────
// The font *families* (Inter, IBM Plex Sans Arabic, JetBrains Mono) are all
// open-source (SIL OFL). To embed a weight, base64-encode its .ttf and paste the
// string into the matching slot below. One-liner to produce a slot value:
//
//     dart -e "import 'dart:io';import 'dart:convert';void main(){print(base64Encode(File('Inter-Regular.ttf').readAsBytesSync()));}"
//
// or on a shell:   base64 -w0 Inter-Regular.ttf
//
// Until a slot is filled, that weight simply isn't registered and the family
// name falls back to the platform's default sans — so the app always renders.
//
// Prefer the idiomatic route instead? Delete this file, add `google_fonts` to
// pubspec, and in theme.dart swap the family names for
// `GoogleFonts.inter().fontFamily` etc. (network fetch + on-device cache).
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'tokens.dart';

class _FontSlot {
  const _FontSlot(this.family, this.base64, {this.weightHint});
  final String family;
  final String base64;
  final String? weightHint;
}

/// Paste base64-encoded .ttf data into the empty strings below.
/// Family names MUST match the constants in [PwtFonts].
const List<_FontSlot> _embeddedFontSlots = <_FontSlot>[
  // ── Inter (sans) ──
  _FontSlot(PwtFonts.sans, '', weightHint: '400'),
  _FontSlot(PwtFonts.sans, '', weightHint: '500'),
  _FontSlot(PwtFonts.sans, '', weightHint: '600'),
  _FontSlot(PwtFonts.sans, '', weightHint: '700'),
  _FontSlot(PwtFonts.sans, '', weightHint: '800'),

  // ── IBM Plex Sans Arabic ──
  _FontSlot(PwtFonts.arabic, '', weightHint: '400'),
  _FontSlot(PwtFonts.arabic, '', weightHint: '600'),
  _FontSlot(PwtFonts.arabic, '', weightHint: '700'),

  // ── JetBrains Mono ──
  _FontSlot(PwtFonts.mono, '', weightHint: '400'),
  _FontSlot(PwtFonts.mono, '', weightHint: '500'),
];

/// Call once before `runApp` (already wired in main.dart). Registers every
/// non-empty slot with the Flutter engine. No-ops cleanly when slots are empty.
Future<void> loadEmbeddedFonts() async {
  // Group base64 blobs by family so all weights land under one FontLoader.
  final Map<String, List<String>> byFamily = <String, List<String>>{};
  for (final slot in _embeddedFontSlots) {
    if (slot.base64.trim().isEmpty) continue;
    byFamily.putIfAbsent(slot.family, () => <String>[]).add(slot.base64);
  }

  for (final entry in byFamily.entries) {
    final loader = FontLoader(entry.key);
    for (final b64 in entry.value) {
      final Uint8List bytes = base64Decode(b64.trim());
      loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }
}
