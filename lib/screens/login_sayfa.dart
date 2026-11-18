import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/toast_helper.dart';

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
          backgroundColor: Colors.green.shade700,
        );
      }
    } catch (e) {
      if (!mounted) return;
      gFToastShowToast(
        context: context,
        message: 'Google girişi başarısız: Tekrar deneyin.',
        backgroundColor: Colors.red.shade700,
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

    return Scaffold(
      body: SafeArea(
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: renkSemasi.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.checklist_rounded,
                      size: 64,
                      color: renkSemasi.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Akıllı Liste',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
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
                    ),
                    icon: _girisYapiliyor
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mail_outline),
                    label: Text(
                      _girisYapiliyor
                          ? 'Giriş Yapılıyor...'
                          : 'Google (Gmail) ile Devam Et',
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
    );
  }
}