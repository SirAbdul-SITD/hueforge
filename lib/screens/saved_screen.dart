import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/color_info.dart';
import '../services/palette.dart';
import '../services/saved_service.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedService>();
    return Scaffold(
      backgroundColor: Palette.void_,
      appBar: AppBar(
        backgroundColor: Palette.void_,
        elevation: 0,
        foregroundColor: Palette.ink,
        title: const Text('Saved Colors'),
      ),
      body: SafeArea(
        child: saved.saved.isEmpty
            ? const Center(
                child: Text('No saved colors yet', style: TextStyle(color: Palette.haze)),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: saved.saved.length,
                itemBuilder: (context, i) {
                  final c = saved.saved[i];
                  final hex = ColorInfo(c).hexString;
                  return GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: hex));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied $hex'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Palette.raised,
                        ),
                      );
                    },
                    onLongPress: () => saved.removeAt(i),
                    child: Container(
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Palette.line),
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(8),
                      child: Text(hex,
                          style: TextStyle(
                              color: ColorInfo(c).relativeLuminance > 0.4
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
