import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/animasyonlu_arka_plan.dart';

class LoginSayfasi extends ConsumerStatefulWidget {
  const LoginSayfasi({super.key});

  @override
  ConsumerState<LoginSayfasi> createState() => _LoginSayfasiState();
}

class _LoginSayfasiState extends ConsumerState<LoginSayfasi> {
  bool _girisYapiliyor = false;

  Future<void> _googleIleGiris() async {
    setState(() => _girisYapiliyor = true);
    try {
      final sonuc = await ref.read(authServisiProvider).googleIleGirisYap();
      if (!mounted) return;

      if (sonuc != null && sonuc.user != null) {
        gFToastShowToast(
          context: context,
          message: 'Hoş geldiniz, ${sonuc.user!.displayName ?? sonuc.user!.email ?? ""}',
          backgroundColor: AppColors.teal,
        );
      }
    } catch (e) {
      if (!mounted) return;
      gFToastShowToast(
        context: context,
        message: 'Google girişi başarısız: Tekrar deneyin.',
        backgroundColor: AppColors.coral,
      );
    } finally {
      if (mounted) {
        setState(() => _girisYapiliyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;

    final koyu = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: koyu
                ? [const Color(0xFF0B3A36), AppColors.darkBg]
                : [const Color(0xFFD6F1EB), AppColors.lightBg],
            stops: const [0.0, 0.55],
          ),
        ),
        child: Stack(
          children: [
            // 1) Arka plan animasyonu (en altta)
            const Positioned.fill(child: AnimasyonluArkaPlan()),
            SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      // Uygulama İkonu
                      Center(
                        
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                renkSemasi.primary,
                                Color.lerp(renkSemasi.primary, Colors.black, 0.2)!,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: renkSemasi.primary.withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.checklist_rounded,
                            size: 60,
                            color: renkSemasi.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Akıllı Liste',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: renkSemasi.onSurface,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Görevlerini ve alışveriş listeni Google hesabınla güvenle yönet.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: renkSemasi.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 36),

                      // Google (Gmail) ile Giriş Butonu
                      FilledButton.icon(
                        onPressed: _girisYapiliyor ? null : _googleIleGiris,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor:
                              renkSemasi.primary.withValues(alpha: 0.55),
                          disabledForegroundColor: renkSemasi.onPrimary,
                        ),
                        icon: _girisYapiliyor
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: renkSemasi.onPrimary,
                                ),
                              )
                            : const Icon(Icons.mail_outline),
                        label: Text(
                          _girisYapiliyor
                              ? 'Giriş Yapılıyor...'
                              : 'Google ile Devam Et',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}