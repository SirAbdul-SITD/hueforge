import 'package:flutter/material.dart';
import '../models/color_info.dart';
import '../services/palette.dart';

class ContrastScreen extends StatefulWidget {
  final Color initial;
  const ContrastScreen({super.key, required this.initial});

  @override
  State<ContrastScreen> createState() => _ContrastScreenState();
}

class _ContrastScreenState extends State<ContrastScreen> {
  late Color _fg;
  Color _bg = Colors.white;
  final _fgController = TextEditingController();
  final _bgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fg = widget.initial;
    _fgController.text = ColorInfo(_fg).hexString;
    _bgController.text = ColorInfo(_bg).hexString;
  }

  void _apply(bool isFg, String text) {
    final c = parseHex(text);
    if (c == null) return;
    setState(() {
      if (isFg) {
        _fg = c;
      } else {
        _bg = c;
      }
    });
  }

  void _swap() {
    setState(() {
      final t = _fg;
      _fg = _bg;
      _bg = t;
      _fgController.text = ColorInfo(_fg).hexString;
      _bgController.text = ColorInfo(_bg).hexString;
    });
  }

  String _levelLabel(WcagLevel l) {
    switch (l) {
      case WcagLevel.fail:
        return 'Fails WCAG';
      case WcagLevel.aaLarge:
        return 'AA (large text only)';
      case WcagLevel.aa:
        return 'AA';
      case WcagLevel.aaa:
        return 'AAA';
    }
  }

  Color _levelColor(WcagLevel l) {
    switch (l) {
      case WcagLevel.fail:
        return Palette.bad;
      case WcagLevel.aaLarge:
        return Palette.warn;
      case WcagLevel.aa:
        return Palette.good;
      case WcagLevel.aaa:
        return Palette.good;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = contrastRatio(_fg, _bg);
    final normalLevel = wcagLevelFor(ratio, largeText: false);
    final largeLevel = wcagLevelFor(ratio, largeText: true);

    return Scaffold(
      backgroundColor: Palette.void_,
      appBar: AppBar(
        backgroundColor: Palette.void_,
        elevation: 0,
        foregroundColor: Palette.ink,
        title: const Text('Contrast Checker'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Palette.line),
              ),
              alignment: Alignment.center,
              child: Text('Aa',
                  style: TextStyle(color: _fg, fontSize: 64, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _colorField('Text', _fgController, (t) => _apply(true, t)),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Palette.haze),
                  onPressed: _swap,
                ),
                Expanded(
                  child: _colorField('Background', _bgController, (t) => _apply(false, t)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Palette.panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Palette.line),
              ),
              child: Column(
                children: [
                  Text(ratio.toStringAsFixed(2),
                      style: const TextStyle(color: Palette.ink, fontSize: 48, fontWeight: FontWeight.w800)),
                  const Text('contrast ratio', style: TextStyle(color: Palette.haze, fontSize: 13)),
                  const SizedBox(height: 20),
                  _levelRow('Normal text', normalLevel),
                  const SizedBox(height: 10),
                  _levelRow('Large text (18pt+)', largeLevel),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'WCAG 2.x requires a contrast ratio of at least 4.5:1 for '
                'normal text (AA) and 7:1 for enhanced contrast (AAA). '
                'Large text (18pt or larger, or 14pt bold) needs only 3:1 '
                '(AA) or 4.5:1 (AAA).',
                style: TextStyle(color: Palette.haze, fontSize: 12, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelRow(String label, WcagLevel level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Palette.ink, fontSize: 14)),
        Row(
          children: [
            Icon(
              level == WcagLevel.fail ? Icons.close : Icons.check_circle,
              color: _levelColor(level),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(_levelLabel(level),
                style: TextStyle(color: _levelColor(level), fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _colorField(String label, TextEditingController controller, ValueChanged<String> onSubmit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Palette.haze, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onSubmitted: onSubmit,
          style: const TextStyle(color: Palette.ink, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Palette.panel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Palette.line),
            ),
          ),
        ),
      ],
    );
  }
}
