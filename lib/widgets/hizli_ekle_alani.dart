import 'package:flutter/material.dart';
import '../utils/toast_helper.dart';
import '../utils/interstitial_ad_service.dart';
import '../theme/app_theme.dart';

/// Listenin üstünde tek satırlık hızlı görev ekleme alanı.
/// Yaz, Enter'a bas (veya oka dokun) → görev eklenir, alan açık kalır.
class HizliEkleAlani extends StatefulWidget {
  final void Function(String baslik) onEkle;

  const HizliEkleAlani({super.key, required this.onEkle});

  @override
  State<HizliEkleAlani> createState() => _HizliEkleAlaniState();
}

class _HizliEkleAlaniState extends State<HizliEkleAlani> {
  final _controller = TextEditingController();
  final _odak = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _odak.dispose();
    super.dispose();
  }

  void _gonder() {
    final metin = _controller.text.trim();
    if (metin.isEmpty) return;

    widget.onEkle(metin);
    _controller.clear();
    // Arka arkaya görev girebilmek için odağı koru
    _odak.requestFocus();

    gFToastShowToast(
      context: context,
      message: 'Yeni görev başarıyla kaydedildi.',
      backgroundColor: AppColors.coral
    );
    // geciş Reklamı şimdilik kapat canlıya alınınca ac
    Future.delayed(
       const Duration(milliseconds: 600),
       InterstitialAdService.instance.eylemSonrasiGoster,
    );
  }

  @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, deger, _) {
          final doluMu = deger.text.trim().isNotEmpty;
          return TextField(
            controller: _controller,
            focusNode: _odak,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _gonder(),
            decoration: InputDecoration(
              hintText: 'Hızlı ekle: yaz ve Enter\'a bas',
              prefixIcon: Icon(Icons.add_task, color: renkSemasi.primary),
              suffixIcon: doluMu
                  ? Padding(
                      padding: const EdgeInsets.all(6),
                      child: IconButton.filled(
                        tooltip: 'Ekle',
                        onPressed: _gonder,
                        icon: const Icon(Icons.arrow_upward, size: 20),
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}