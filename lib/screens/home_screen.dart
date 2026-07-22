import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/color_info.dart';
import '../services/palette.dart';
import '../services/saved_service.dart';
import 'contrast_screen.dart';
import 'saved_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HSVColor _hsv = const HSVColor.fromAHSV(1.0, 260, 0.55, 0.75);
  final _hexController = TextEditingController();

  Color get _color => _hsv.toColor();

  void _updateHsv(HSVColor v) {
    setState(() => _hsv = v);
    _hexController.text = ColorInfo(_color).hexString;
  }

  void _applyHex(String text) {
    final c = parseHex(text);
    if (c != null) {
      setState(() => _hsv = HSVColor.fromColor(c));
    }
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text'),
        duration: const Duration(seconds: 1),
        backgroundColor: Palette.raised,
      ),
    );
  }

  List<Color> _harmony() {
    final base = _hsv;
    Color at(double dh) => base
        .withHue((base.hue + dh) % 360)
        .toColor();
    return [
      _color,
      at(180), // complementary
      at(30), // analogous
      at(-30), // analogous
      at(120), // triadic
      at(-120), // triadic
    ];
  }

  @override
  void initState() {
    super.initState();
    _hexController.text = ColorInfo(_color).hexString;
  }

  @override
  Widget build(BuildContext context) {
    final info = ColorInfo(_color);
    return Scaffold(
      backgroundColor: Palette.void_,
      appBar: AppBar(
        backgroundColor: Palette.void_,
        elevation: 0,
        foregroundColor: Palette.ink,
        title: const Text('HUEFORGE',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Palette.line),
              ),
            ),
            const SizedBox(height: 16),
            _sliderRow('Hue', _hsv.hue, 0, 360, (v) => _updateHsv(_hsv.withHue(v))),
            _sliderRow('Saturation', _hsv.saturation * 100, 0, 100,
                (v) => _updateHsv(_hsv.withSaturation(v / 100))),
            _sliderRow(
                'Value', _hsv.value * 100, 0, 100, (v) => _updateHsv(_hsv.withValue(v / 100))),
            const SizedBox(height: 8),
            TextField(
              controller: _hexController,
              onSubmitted: _applyHex,
              style: const TextStyle(color: Palette.ink, fontSize: 20, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.tag, color: Palette.haze),
                filled: true,
                fillColor: Palette.panel,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Palette.line),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _formatRow('RGB', info.rgbString),
            _formatRow('HSL', info.hslString),
            _formatRow('HSV', info.hsvString),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Palette.accent,
                      side: BorderSide(color: Palette.accent.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => context.read<SavedService>().add(_color),
                    icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Palette.good,
                      side: BorderSide(color: Palette.good.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContrastScreen(initial: _color)),
                    ),
                    icon: const Icon(Icons.contrast, size: 18),
                    label: const Text('Contrast'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('COLOR HARMONY',
                style: TextStyle(
                    color: Palette.haze, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _harmony().length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = _harmony()[i];
                  return GestureDetector(
                    onTap: () => _copy(ColorInfo(c).hexString),
                    child: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Palette.line),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Palette.haze, fontSize: 13))),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: Palette.accent,
              inactiveColor: Palette.raised,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text('${value.round()}',
                textAlign: TextAlign.right,
                style: const TextStyle(color: Palette.ink, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _formatRow(String label, String value) {
    return GestureDetector(
      onTap: () => _copy(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Palette.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Palette.haze, fontSize: 12, fontWeight: FontWeight.w700)),
            Row(
              children: [
                Text(value,
                    style: const TextStyle(color: Palette.ink, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.copy, size: 14, color: Palette.haze),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
