import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gorev_ogesi.dart';
import '../providers/gorev_provider.dart';
import '../widgets/gorev_karti.dart';
import '../widgets/ilerleme_ozet_karti.dart';
import '../widgets/oge_form_sheet.dart';
import '../utils/toast_helper.dart';
import '../providers/auth_provider.dart';

class ListeAnaSayfa extends ConsumerWidget {
  const ListeAnaSayfa({super.key});

  static const List<String> _kategoriler = ['Tümü', 'Alışveriş', 'İş', 'Kişisel'];

  void _formPenceresiniAc(
    BuildContext context,
    WidgetRef ref, {
    GorevOgesi? mevcutOge,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => OgeFormSheet(
        mevcutOge: mevcutOge,
        onKaydet: (baslik, kategori, oncelik, sonTarih) {
          final notifier = ref.read(gorevlerProvider.notifier);
          if (mevcutOge == null) {
            notifier.ekle(
              baslik: baslik,
              kategori: kategori,
              oncelik: oncelik,
              sonTarih: sonTarih,
            );
            gFToastShowToast(
              context: context,
              message: 'Yeni görev başarıyla kaydedildi.',
              backgroundColor: Colors.green.shade700,
            );
          } else {
            notifier.guncelle(
              mevcutOge.copyWith(
                baslik: baslik,
                kategori: kategori,
                oncelik: oncelik,
                sonTarih: sonTarih,
                sonTarihiTemizle: sonTarih == null,
              ),
            );
            gFToastShowToast(
              context: context,
              message: 'Değişiklikler kaydedildi.',
              backgroundColor: Colors.green.shade700,
            );
          }
        },
      ),
    );
  }

  Future<void> _ogeSil(
    BuildContext context,
    WidgetRef ref,
    GorevOgesi oge,
  ) async {
    final notifier = ref.read(gorevlerProvider.notifier);
    final silinenIndex = await notifier.sil(oge.id);
    if (!context.mounted || silinenIndex == -1) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${oge.baslik}" silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () => notifier.geriAl(silinenIndex, oge),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renkSemasi = Theme.of(context).colorScheme;

    final kullanici = ref.watch(authStateProvider).valueOrNull;

    final tumGorevlerAsync = ref.watch(gorevlerProvider);
    final filtrelenmisAsync = ref.watch(filtrelenmisGorevlerProvider);
    final seciliKategori = ref.watch(seciliKategoriProvider);
    final sadeceBekleyenler = ref.watch(sadeceTamamlanmayanlarProvider);
    final siralamaKriteri = ref.watch(siralamaKriteriProvider);

    final tumOgeler = tumGorevlerAsync.valueOrNull ?? [];
    final tamamlananSayisi = tumOgeler.where((e) => e.tamamlandi).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Liste'),
        actions: [
          FilterChip(
            label: const Text('Bekleyenler'),
            selected: sadeceBekleyenler,
            onSelected: (val) =>
                ref.read(sadeceTamamlanmayanlarProvider.notifier).state = val,
          ),
          PopupMenuButton<SiralamaKriteri>(
            tooltip: 'Sırala',
            icon: Icon(
              Icons.sort,
              color: siralamaKriteri != SiralamaKriteri.eklenmeSirasi
                  ? renkSemasi.primary
                  : null,
            ),
            initialValue: siralamaKriteri,
            onSelected: (kriter) =>
                ref.read(siralamaKriteriProvider.notifier).state = kriter,
            itemBuilder: (context) => SiralamaKriteri.values.map((kriter) {
              final secili = siralamaKriteri == kriter;
              return PopupMenuItem<SiralamaKriteri>(
                value: kriter,
                child: Row(
                  children: [
                    Icon(
                      secili ? Icons.check : Icons.radio_button_unchecked,
                      size: 18,
                      color: secili ? renkSemasi.primary : renkSemasi.outline,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      kriter.etiket,
                      style: TextStyle(
                        fontWeight:
                            secili ? FontWeight.bold : FontWeight.normal,
                        color: secili ? renkSemasi.primary : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 4),
          IconButton(
  tooltip: kullanici?.email ?? 'Hesap',
  onPressed: () {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(kullanici?.displayName ?? 'Kullanıcı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    kullanici?.email ?? 'Gmail bilgisi bulunamadı',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.red)),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authServisiProvider).cikisYap();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  },
  icon: CircleAvatar(
    radius: 16,
    backgroundImage: kullanici?.photoURL != null
        ? NetworkImage(kullanici!.photoURL!)
        : null,
    child: kullanici?.photoURL == null
        ? Text(
            (kullanici?.email?.isNotEmpty == true)
                ? kullanici!.email![0].toUpperCase()
                : '?',
          )
        : null,
  ),
),
        ],
      ),
      body: filtrelenmisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(child: Text('Veriler yüklenemedi: $hata')),
        data: (gosterilecekListe) => Column(
          children: [
            IlerlemeOzetKarti(
              tamamlananSayisi: tamamlananSayisi,
              toplamSayi: tumOgeler.length,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SearchBar(
                hintText: 'Görev veya ürün ara...',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  renkSemasi.surfaceContainerHighest.withValues(alpha: 0.5),
                ),
                onChanged: (deger) =>
                    ref.read(aramaMetniProvider.notifier).state = deger,
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _kategoriler.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final kategori = _kategoriler[index];
                  return FilterChip(
                    label: Text(kategori),
                    selected: seciliKategori == kategori,
                    onSelected: (_) => ref
                        .read(seciliKategoriProvider.notifier)
                        .state = kategori,
                  );
                },
              ),
            ),
            Expanded(
              child: gosterilecekListe.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.checklist_rtl,
                              size: 64, color: renkSemasi.outline),
                          const SizedBox(height: 12),
                          Text(
                            'Listede gösterilecek öğe yok',
                            style: TextStyle(color: renkSemasi.outline),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: gosterilecekListe.length,
                      itemBuilder: (context, index) {
                        final oge = gosterilecekListe[index];
                        return GorevKarti(
                          oge: oge,
                          onDurumDegisti: (yeniDurum) => ref
                              .read(gorevlerProvider.notifier)
                              .durumDegistir(oge.id, yeniDurum),
                          onDuzenle: () => _formPenceresiniAc(
                            context,
                            ref,
                            mevcutOge: oge,
                          ),
                          onSilindi: () => _ogeSil(context, ref, oge),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formPenceresiniAc(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ekle'),
      ),
    );
  }
}