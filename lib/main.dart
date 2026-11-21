import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/liste_ana_sayfa.dart';
import 'screens/login_sayfa.dart';
import 'services/bildirim_servisi.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await BildirimServisi().baslat();

  runApp(
    const ProviderScope(
      child: AkilliListeApp(),
    ),
  );
}

class AkilliListeApp extends StatelessWidget {
  const AkilliListeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Liste',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
          child: child!,
        );
      },
      home: const AuthGate(),
    );
  }
}

/// Oturum durumuna göre Login veya Ana Sayfa'ya yönlendirir
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (hata, _) => Scaffold(
        body: Center(child: Text('Oturum hatası: $hata')),
      ),
      data: (kullanici) {
        if (kullanici != null) {
          return const ListeAnaSayfa();
        }
        return const LoginSayfasi();
      },
    );
  }
}