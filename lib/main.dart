import 'package:csbingo/adsense/ad_widget.dart';
import 'package:csbingo/csbingo.dart';
import 'package:csbingo/config/router_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdSenseAd.register();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 243, 139, 28),
      ),
      useMaterial3: true,
    );

    final dark = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 243, 139, 28),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );

    return MaterialApp.router(
      title: 'CS BINGO',
      theme: light,
      darkTheme: dark,
      themeMode: ThemeMode.dark,
      routerConfig: createRouter(),
    );
  }
}
