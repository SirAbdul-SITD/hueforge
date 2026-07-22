import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/palette.dart';
import 'services/saved_service.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HueforgeApp());
}

class HueforgeApp extends StatefulWidget {
  const HueforgeApp({super.key});

  @override
  State<HueforgeApp> createState() => _HueforgeAppState();
}

class _HueforgeAppState extends State<HueforgeApp> {
  final saved = SavedService();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await saved.init();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: saved,
      child: MaterialApp(
        title: 'Hueforge',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Palette.void_,
          colorScheme: const ColorScheme.dark(
            primary: Palette.accent,
            surface: Palette.panel,
          ),
        ),
        home: _ready
            ? const HomeScreen()
            : const Scaffold(
                backgroundColor: Palette.void_,
                body: Center(
                  child: Icon(Icons.palette, color: Palette.accent, size: 56),
                ),
              ),
      ),
    );
  }
}
