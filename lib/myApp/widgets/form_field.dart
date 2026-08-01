// Form field + account-mode tabs, ported from proto/login.jsx (FormField,
// ModeTabs). Reused across login, signup and account forms.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/tokens.dart';
import '../models/models.dart';

class PwtField extends StatefulWidget {
  const PwtField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.leading,
    this.trailing,
    this.prefix,
    this.obscure = false,
    this.keyboardType,
    this.forceLtr = false,
    this.readOnly = false,
    this.inputFormatters,
    this.autofillHints,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final IconData? leading;
  final Widget? trailing;
  final String? prefix;
  final bool obscure;
  final TextInputType? keyboardType;
  final bool forceLtr;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  /// Pass `const []` to opt this field out of platform/browser autofill
  /// suggestions (e.g. so password-change fields never get pre-filled with a
  /// saved credential). Leave null for default autofill behaviour.
  final Iterable<String>? autofillHints;

  @override
  State<PwtField> createState() => _PwtFieldState();
}

class _PwtFieldState extends State<PwtField> {
  late final FocusNode _focus;
  TextEditingController? _internal;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internal ??= TextEditingController(text: widget.initialValue));

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = AnimatedContainer(
      duration: PwtMotion.fast,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: PwtColors.surface,
        border: Border.all(color: _focused ? PwtColors.brand : PwtColors.hairline, width: 1.5),
        borderRadius: BorderRadius.circular(PwtRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: PwtType.eyebrow().copyWith(fontSize: 11, letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (widget.leading != null) ...[
                Icon(widget.leading, size: 16, color: PwtColors.textTer),
                const SizedBox(width: 10),
              ],
              if (widget.prefix != null) ...[
                Text(widget.prefix!, style: PwtType.body(color: PwtColors.textSec, weight: FontWeight.w500)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscure,
                  keyboardType: widget.keyboardType,
                  readOnly: widget.readOnly,
                  textDirection: widget.forceLtr ? TextDirection.ltr : null,
                  inputFormatters: widget.inputFormatters,
                  autofillHints: widget.autofillHints,
                  style: PwtType.body(weight: FontWeight.w500),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ],
      ),
    );
    return field;
  }
}

/// Individual / Business toggle used on login + signup.
class ModeTabs extends StatelessWidget {
  const ModeTabs({
    super.key,
    required this.mode,
    required this.onChanged,
    required this.individualLabel,
    required this.businessLabel,
  });

  final AccountKind mode;
  final ValueChanged<AccountKind> onChanged;
  final String individualLabel;
  final String businessLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PwtColors.surface2,
        borderRadius: BorderRadius.circular(PwtRadius.md),
        border: Border.all(color: PwtColors.hairline),
      ),
      child: Row(
        children: [
          _tab(AccountKind.individual, individualLabel, Icons.person_outline),
          _tab(AccountKind.business, businessLabel, Icons.apartment_outlined),
        ],
      ),
    );
  }

  Widget _tab(AccountKind val, String label, IconData icon) {
    final on = val == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(val),
        child: AnimatedContainer(
          duration: PwtMotion.fast,
          constraints: const BoxConstraints(minHeight: 44),
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: on ? PwtColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: on ? const [BoxShadow(color: Color(0x1F0F172A), blurRadius: 4, offset: Offset(0, 1))] : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: on ? PwtColors.brand : PwtColors.textTer),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: on ? FontWeight.w600 : FontWeight.w500, color: on ? PwtColors.brand : PwtColors.textSec),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
