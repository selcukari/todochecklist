import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gorev_ogesi.dart';
import '../services/depolama_servisi.dart';
import 'auth_provider.dart';

// 1. Servis Sağlayıcısı (Dependency Injection)
final depolamaServisiProvider = Provider<DepolamaServisi>((ref) {
  return DepolamaServisi();
});

// 2. Filtre ve Sıralama State Sağlayıcıları
final seciliKategoriProvider = StateProvider<String>((ref) => 'Tümü');
final aramaMetniProvider = StateProvider<String>((ref) => '');
final sadeceTamamlanmayanlarProvider = StateProvider<bool>((ref) => false);
final siralamaKriteriProvider = StateProvider<SiralamaKriteri>(
  (ref) => SiralamaKriteri.eklenmeSirasi,
);

// 3. Ana Görev Listesi (Asenkron State + CRUD + Kalıcı Depolama)
class GorevlerNotifier extends AsyncNotifier<List<GorevOgesi>> {
  String? get _aktifUid => ref.watch(authStateProvider).valueOrNull?.uid;

  @override
  Future<List<GorevOgesi>> build() async {
    final servis = ref.read(depolamaServisiProvider);
    return servis.gorevleriYukle(uid: _aktifUid);
  }

  Future<void> _kaydet(List<GorevOgesi> yeniListe) async {
    state = AsyncData(yeniListe);
    await ref
        .read(depolamaServisiProvider)
        .gorevleriKaydet(yeniListe, uid: _aktifUid);
  }

  Future<void> ekle({
    required String baslik,
    required String kategori,
    required Oncelik oncelik,
    DateTime? sonTarih,
  }) async {
    final mevcut = state.valueOrNull ?? <GorevOgesi>[];
    final yeniOge = GorevOgesi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baslik: baslik,
      kategori: kategori,
      oncelik: oncelik,
      sonTarih: sonTarih,
    );
    await _kaydet([yeniOge, ...mevcut]);
  }

  Future<void> guncelle(GorevOgesi guncelOge) async {
    final mevcut = state.valueOrNull ?? [];
    final yeniListe = [
      for (final oge in mevcut)
        if (oge.id == guncelOge.id) guncelOge else oge,
    ];
    await _kaydet(yeniListe);
  }

  Future<void> durumDegistir(String id, bool tamamlandi) async {
    final mevcut = state.valueOrNull ?? [];
    final yeniListe = [
      for (final oge in mevcut)
        if (oge.id == id) oge.copyWith(tamamlandi: tamamlandi) else oge,
    ];
    await _kaydet(yeniListe);
  }

  Future<int> sil(String id) async {
    final mevcut = state.valueOrNull ?? [];
    final index = mevcut.indexWhere((e) => e.id == id);
    if (index == -1) return -1;

    final yeniListe = [...mevcut]..removeAt(index);
    await _kaydet(yeniListe);
    return index;
  }

  Future<void> geriAl(int index, GorevOgesi oge) async {
    final List<GorevOgesi> mevcut = [...(state.valueOrNull ?? <GorevOgesi>[])];
    final guvenliIndex = index.clamp(0, mevcut.length);
    mevcut.insert(guvenliIndex, oge);
    await _kaydet(mevcut);
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

  return gorevlerAsync.whenData((ogeler) {
    final sonuc = ogeler.where((oge) {
      final kategoriUyumu =
          seciliKategori == 'Tümü' || oge.kategori == seciliKategori;
      final aramaUyumu = oge.baslik.toLowerCase().contains(aramaMetni);
      final durumUyumu = !sadeceBekleyenler || !oge.tamamlandi;
      return kategoriUyumu && aramaUyumu && durumUyumu;
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