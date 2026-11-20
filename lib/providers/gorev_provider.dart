import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gorev_ogesi.dart';
import '../services/depolama_servisi.dart';
import '../services/bildirim_servisi.dart';
import 'auth_provider.dart';

// 1. Servis Sağlayıcıları (Dependency Injection)
final depolamaServisiProvider = Provider<DepolamaServisi>((ref) {
  return DepolamaServisi();
});

final bildirimServisiProvider = Provider<BildirimServisi>((ref) {
  return BildirimServisi();
});

// 2. Filtre ve Sıralama State Sağlayıcıları
enum TarihFiltresi {
  hepsi('Tüm Tarihler'),
  bugun('Bugün'),
  yarin('Yarın'),
  buHafta('Bu Hafta');

  final String etiket;
  const TarihFiltresi(this.etiket);
}

bool _tarihFiltresineUyuyor(DateTime? sonTarih, TarihFiltresi filtre) {
  if (filtre == TarihFiltresi.hepsi) return true;
  if (sonTarih == null) return false;

  final simdi = DateTime.now();
  final bugun = DateTime(simdi.year, simdi.month, simdi.day);
  final gun = DateTime(sonTarih.year, sonTarih.month, sonTarih.day);

  switch (filtre) {
    case TarihFiltresi.hepsi:
      return true;
    case TarihFiltresi.bugun:
      return gun == bugun;
    case TarihFiltresi.yarin:
      return gun == DateTime(bugun.year, bugun.month, bugun.day + 1);
    case TarihFiltresi.buHafta:
      final haftaSonu = DateTime(
        bugun.year,
        bugun.month,
        bugun.day + (DateTime.sunday - bugun.weekday),
      );
      return !gun.isBefore(bugun) && !gun.isAfter(haftaSonu);
  }
}

final tarihFiltresiProvider =
    StateProvider<TarihFiltresi>((ref) => TarihFiltresi.hepsi);
final seciliKategoriProvider = StateProvider<String>((ref) => 'Tümü');
final aramaMetniProvider = StateProvider<String>((ref) => '');
final sadeceTamamlanmayanlarProvider = StateProvider<bool>((ref) => false);
final siralamaKriteriProvider = StateProvider<SiralamaKriteri>(
  (ref) => SiralamaKriteri.eklenmeSirasi,
);

// 3. Ana Görev Listesi (Asenkron State + CRUD + Kalıcı Depolama + Bildirim)
class GorevlerNotifier extends AsyncNotifier<List<GorevOgesi>> {
  String? get _aktifUid => ref.read(authStateProvider).valueOrNull?.uid;

  @override
  Future<List<GorevOgesi>> build() async {
    ref.watch(authStateProvider.select((val) => val.valueOrNull?.uid));
    final servis = ref.read(depolamaServisiProvider);
    return servis.gorevleriYukle(uid: _aktifUid);
  }

  Future<void> _kaydet(List<GorevOgesi> yeniListe) async {
    state = AsyncData(yeniListe);
    await ref
        .read(depolamaServisiProvider)
        .gorevleriKaydet(yeniListe, uid: _aktifUid);
  }

  void _bildirimSenkronizeEtArkaPlanda(GorevOgesi oge) {
    unawaited(() async {
      try {
        final bildirim = ref.read(bildirimServisiProvider);
        if (oge.tamamlandi || oge.hatirlaticiZamani == null) {
          await bildirim.iptalEt(oge.id);
          return;
        }
        await bildirim.gorevHatirlaticisiZamanla(
          gorevId: oge.id,
          baslik: oge.baslik,
          bildirimZamani: oge.hatirlaticiZamani!,
        );
      } catch (_) {
        // Bildirim servisi hatası görev ekleme ve listeleme akışını bozmamalı
      }
    }());
  }

  Future<void> ekle({
    required String baslik,
    required String kategori,
    required Oncelik oncelik,
    DateTime? sonTarih,
    DateTime? hatirlaticiZamani,
    List<AltGorev> altGorevler = const [],
  }) async {
    final mevcut = state.valueOrNull ?? <GorevOgesi>[];
    final yeniOge = GorevOgesi(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      baslik: baslik,
      kategori: kategori,
      oncelik: oncelik,
      sonTarih: sonTarih,
      hatirlaticiZamani: hatirlaticiZamani,
      altGorevler: altGorevler,
    );
    await _kaydet([yeniOge, ...mevcut]);
    _bildirimSenkronizeEtArkaPlanda(yeniOge);
  }

  Future<void> guncelle(GorevOgesi guncelOge) async {
    final mevcut = state.valueOrNull ?? [];
    final yeniListe = [
      for (final oge in mevcut)
        if (oge.id == guncelOge.id) guncelOge else oge,
    ];
    await _kaydet(yeniListe);
    _bildirimSenkronizeEtArkaPlanda(guncelOge);
  }

  Future<void> durumDegistir(String id, bool tamamlandi) async {
    final mevcut = state.valueOrNull ?? [];
    GorevOgesi? hedefOge;
    final yeniListe = [
      for (final oge in mevcut)
        if (oge.id == id)
          (hedefOge = oge.copyWith(tamamlandi: tamamlandi))
        else
          oge,
    ];
    await _kaydet(yeniListe);
    if (hedefOge != null) {
      _bildirimSenkronizeEtArkaPlanda(hedefOge);
    }
  }

  Future<int> sil(String id) async {
    final mevcut = state.valueOrNull ?? [];
    final index = mevcut.indexWhere((e) => e.id == id);
    if (index == -1) return -1;

    final yeniListe = [...mevcut]..removeAt(index);
    await _kaydet(yeniListe);
    unawaited(ref.read(bildirimServisiProvider).iptalEt(id));
    return index;
  }

  Future<List<MapEntry<int, GorevOgesi>>> tamamlananlariTemizle() async {
    final mevcut = state.valueOrNull ?? <GorevOgesi>[];
    final silinenler = <MapEntry<int, GorevOgesi>>[];
    for (var i = 0; i < mevcut.length; i++) {
      if (mevcut[i].tamamlandi) silinenler.add(MapEntry(i, mevcut[i]));
    }
    if (silinenler.isEmpty) return silinenler;

    await _kaydet([
      for (final oge in mevcut)
        if (!oge.tamamlandi) oge,
    ]);

    final bildirim = ref.read(bildirimServisiProvider);
    for (final giris in silinenler) {
      unawaited(bildirim.iptalEt(giris.value.id));
    }
    return silinenler;
  }

  Future<void> geriAlToplu(List<MapEntry<int, GorevOgesi>> silinenler) async {
    final mevcut = [...(state.valueOrNull ?? <GorevOgesi>[])];
    for (final giris in silinenler) {
      final guvenliIndex = giris.key.clamp(0, mevcut.length);
      mevcut.insert(guvenliIndex, giris.value);
      _bildirimSenkronizeEtArkaPlanda(giris.value);
    }
    await _kaydet(mevcut);
  }

  Future<void> geriAl(int index, GorevOgesi oge) async {
    final List<GorevOgesi> mevcut = [...(state.valueOrNull ?? <GorevOgesi>[])];
    final guvenliIndex = index.clamp(0, mevcut.length);
    mevcut.insert(guvenliIndex, oge);
    await _kaydet(mevcut);
    _bildirimSenkronizeEtArkaPlanda(oge);
  }
  Future<void> yenidenSirala(int eskiIndex, int yeniIndex) async {
    final liste = [...(state.valueOrNull ?? <GorevOgesi>[])];
    if (eskiIndex < 0 || eskiIndex >= liste.length) return;

    if (yeniIndex > eskiIndex) yeniIndex -= 1; // Flutter'ın index kuralı
    yeniIndex = yeniIndex.clamp(0, liste.length - 1);
    if (yeniIndex == eskiIndex) return;

    final oge = liste.removeAt(eskiIndex);
    liste.insert(yeniIndex, oge);
    await _kaydet(liste);
  }
}

final gorevlerProvider =
    AsyncNotifierProvider<GorevlerNotifier, List<GorevOgesi>>(
  GorevlerNotifier.new,
);

// 4. Türetilmiş (Computed) Liste Sağlayıcısı: Filtreleme + Sıralama
final filtrelenmisGorevlerProvider = Provider<AsyncValue<List<GorevOgesi>>>((ref) {
  final gorevlerAsync = ref.watch(gorevlerProvider);
  final seciliKategori = ref.watch(seciliKategoriProvider);
  final aramaMetni = ref.watch(aramaMetniProvider).toLowerCase();
  final sadeceBekleyenler = ref.watch(sadeceTamamlanmayanlarProvider);
  final siralamaKriteri = ref.watch(siralamaKriteriProvider);
  final tarihFiltresi = ref.watch(tarihFiltresiProvider);

  return gorevlerAsync.whenData((ogeler) {
    final sonuc = ogeler.where((oge) {
      final kategoriUyumu =
          seciliKategori == 'Tümü' || oge.kategori == seciliKategori;
      final aramaUyumu = oge.baslik.toLowerCase().contains(aramaMetni) ||
          oge.altGorevler.any((a) => a.baslik.toLowerCase().contains(aramaMetni));
      final durumUyumu = !sadeceBekleyenler || !oge.tamamlandi;
      final tarihUyumu = _tarihFiltresineUyuyor(oge.sonTarih, tarihFiltresi);
      return kategoriUyumu && aramaUyumu && durumUyumu && tarihUyumu;
    }).toList();

    switch (siralamaKriteri) {
      case SiralamaKriteri.eklenmeSirasi:
        break;
      case SiralamaKriteri.sonTarih:
        sonuc.sort((a, b) {
          if (a.sonTarih == null && b.sonTarih == null) return 0;
          if (a.sonTarih == null) return 1;
          if (b.sonTarih == null) return -1;
          return a.sonTarih!.compareTo(b.sonTarih!);
        });
        break;
      case SiralamaKriteri.oncelik:
        sonuc.sort((a, b) {
          final puanFarki =
              b.oncelik.siralamaPuani.compareTo(a.oncelik.siralamaPuani);
          if (puanFarki != 0) return puanFarki;
          if (a.sonTarih == null && b.sonTarih == null) return 0;
          if (a.sonTarih == null) return 1;
          if (b.sonTarih == null) return -1;
          return a.sonTarih!.compareTo(b.sonTarih!);
        });
        break;
    }

    return sonuc;
  });
});