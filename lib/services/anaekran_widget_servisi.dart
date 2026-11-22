import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../models/gorev_ogesi.dart';
import '../providers/gorev_provider.dart';

/// Ana ekran widget'ına en yakın son tarihli (en fazla 3) görevin
/// başlıklarını gönderir. Widget sadece başlıkları tek satır gösterir.
class AnaEkranWidgetServisi {
  AnaEkranWidgetServisi._();

  static const int _maksGorev = 3;
  static const String _androidSaglayici = 'GorevWidgetProvider';

  static DateTime _gunBasi(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Tamamlanmamış, son tarihi bugün veya sonrası olan görevlerden
  /// tarihe göre en yakın 3 tanesinin başlığı.
  static List<String> yaklasanBasliklar(List<GorevOgesi> ogeler) {
    final bugun = _gunBasi(DateTime.now());

    final yaklasanlar = ogeler
        .where((o) =>
            !o.tamamlandi &&
            o.sonTarih != null &&
            !_gunBasi(o.sonTarih!).isBefore(bugun))
        .toList()
      ..sort((a, b) => a.sonTarih!.compareTo(b.sonTarih!));

    return yaklasanlar.take(_maksGorev).map((o) => o.baslik).toList();
  }

  static Future<void> guncelle(List<GorevOgesi> ogeler) async {
    try {
      final basliklar = yaklasanBasliklar(ogeler);
      for (var i = 0; i < _maksGorev; i++) {
        await HomeWidget.saveWidgetData<String>(
          'gorev_${i + 1}',
          i < basliklar.length ? basliklar[i] : '',
        );
      }
      await HomeWidget.updateWidget(androidName: _androidSaglayici);
    } catch (_) {
      // Widget güncelleme hatası uygulama akışını bozmamalı
      // (web / masaüstü gibi desteklenmeyen platformlar dahil).
    }
  }
}

/// Görev listesi değiştikçe (ve ilk yüklemede) ana ekran widget'ını günceller.
/// Sayfada bir kez `ref.watch(anaEkranWidgetSenkronProvider);` yazmak yeterli.
final anaEkranWidgetSenkronProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<GorevOgesi>>>(
    gorevlerProvider,
    (onceki, sonraki) {
      sonraki.whenData(AnaEkranWidgetServisi.guncelle);
    },
    fireImmediately: true,
  );
});