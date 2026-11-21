import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gorev_ogesi.dart';
import '../providers/gorev_provider.dart';
import '../widgets/gorev_karti.dart';
import '../widgets/ilerleme_ozet_karti.dart';
import '../widgets/hizli_ekle_alani.dart';
import '../widgets/oge_form_sheet.dart';
import '../widgets/animasyonlu_arka_plan.dart';
import '../widgets/konfeti_katmani.dart';
import '../utils/toast_helper.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/banner_ad_service.dart';
import '../utils/interstitial_ad_service.dart';

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
        onKaydet: (
          baslik,
          kategori,
          oncelik,
          sonTarih,
          hatirlaticiZamani,
          altGorevler,
        ) {
          final notifier = ref.read(gorevlerProvider.notifier);
          if (mevcutOge == null) {
            notifier.ekle(
              baslik: baslik,
              kategori: kategori,
              oncelik: oncelik,
              sonTarih: sonTarih,
              hatirlaticiZamani: hatirlaticiZamani,
              altGorevler: altGorevler,
            );
            gFToastShowToast(
              context: context,
              message: 'Yeni görev başarıyla kaydedildi.',
              backgroundColor: AppColors.teal,
            );
            // geciş Reklamı şimdilik kapat canlıya alınınca ac
            // Future.delayed(
            //   const Duration(milliseconds: 600),
            //   InterstitialAdService.instance.eylemSonrasiGoster,
            // );
          } else {
            notifier.guncelle(
              mevcutOge.copyWith(
                baslik: baslik,
                kategori: kategori,
                oncelik: oncelik,
                sonTarih: sonTarih,
                sonTarihiTemizle: sonTarih == null,
                hatirlaticiZamani: hatirlaticiZamani,
                hatirlaticiTemizle: hatirlaticiZamani == null,
                altGorevler: altGorevler,
              ),
            );
            gFToastShowToast(
              context: context,
              message: 'Değişiklikler kaydedildi.',
              backgroundColor: AppColors.teal,
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
          textColor: AppColors.coralLight,
          onPressed: () => notifier.geriAl(silinenIndex, oge),
        ),
      ),
    );
  }

  Future<void> _tamamlananlariTemizle(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final notifier = ref.read(gorevlerProvider.notifier);
    final silinenler = await notifier.tamamlananlariTemizle();
    if (!context.mounted || silinenler.isEmpty) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${silinenler.length} tamamlanan görev silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: AppColors.coralLight,
          onPressed: () => notifier.geriAlToplu(silinenler),
        ),
      ),
    );
  }

  IconData _tarihIkonu(TarihFiltresi filtre) {
    switch (filtre) {
      case TarihFiltresi.hepsi:
        return Icons.all_inclusive;
      case TarihFiltresi.bugun:
        return Icons.today_outlined;
      case TarihFiltresi.yarin:
        return Icons.event_outlined;
      case TarihFiltresi.buHafta:
        return Icons.date_range_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renkSemasi = Theme.of(context).colorScheme;

    final aramaMetni = ref.watch(aramaMetniProvider);

    final kullanici = ref.watch(authStateProvider).valueOrNull;

    final tumGorevlerAsync = ref.watch(gorevlerProvider);
    final filtrelenmisAsync = ref.watch(filtrelenmisGorevlerProvider);
    final seciliKategori = ref.watch(seciliKategoriProvider);
    final sadeceBekleyenler = ref.watch(sadeceTamamlanmayanlarProvider);
    final siralamaKriteri = ref.watch(siralamaKriteriProvider);
    final tarihFiltresi = ref.watch(tarihFiltresiProvider);

    final tumOgeler = tumGorevlerAsync.valueOrNull ?? [];
    final tamamlananSayisi = tumOgeler.where((e) => e.tamamlandi).length;

    final siralamaAktif = siralamaKriteri == SiralamaKriteri.eklenmeSirasi &&
      seciliKategori == 'Tümü' &&
      tarihFiltresi == TarihFiltresi.hepsi &&
      !sadeceBekleyenler &&
      aramaMetni.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akıllı Liste'),
        actions: [
          FilterChip(
            label: const Text('Bekleyenler'),
            selected: sadeceBekleyenler,
            showCheckmark: false,
            avatar: Icon(
              Icons.schedule,
              size: 18,
              color: sadeceBekleyenler
                  ? renkSemasi.onTertiaryContainer
                  : renkSemasi.onSurface.withValues(alpha: 0.6),
            ),
            selectedColor: renkSemasi.tertiaryContainer,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: sadeceBekleyenler
                  ? renkSemasi.onTertiaryContainer
                  : renkSemasi.onSurface,
            ),
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
                      secili ? Icons.check_circle : Icons.circle_outlined,
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
                          Icon(Icons.email_outlined,
                              size: 18, color: renkSemasi.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              kullanici?.email ?? 'Gmail bilgisi bulunamadı',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Kapat'),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
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
              backgroundColor: renkSemasi.primaryContainer,
              foregroundColor: renkSemasi.onPrimaryContainer,
              backgroundImage: kullanici?.photoURL != null
                  ? NetworkImage(kullanici!.photoURL!)
                  : null,
              child: kullanici?.photoURL == null
                  ? Text(
                      (kullanici?.email?.isNotEmpty == true)
                          ? kullanici!.email![0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimasyonluArkaPlan()),
          Column(
        children: [
          Expanded(
            child: filtrelenmisAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (hata, _) => Center(child: Text('Veriler yüklenemedi: $hata')),
              data: (gosterilecekListe) => CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        IlerlemeOzetKarti(
                          tamamlananSayisi: tamamlananSayisi,
                          toplamSayi: tumOgeler.length,
                        ),
                        HizliEkleAlani(
                          onEkle: (baslik) {
                      final kategori =
                          seciliKategori == 'Tümü' ? 'Alışveriş' : seciliKategori;
                            ref.read(gorevlerProvider.notifier).ekle(
                                  baslik: baslik,
                                  kategori: kategori,
                                  oncelik: Oncelik.orta,
                                  sonTarih: null,
                                );
                          },
                        ),
                        Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: SearchBar(
                            hintText: 'Görev veya ürün ara...',
                      leading: Icon(Icons.search, color: renkSemasi.primary),
                            elevation: const WidgetStatePropertyAll(0),
                            backgroundColor:
                                WidgetStatePropertyAll(renkSemasi.surface),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: renkSemasi.outline),
                              ),
                            ),
                      onChanged: (deger) =>
                          ref.read(aramaMetniProvider.notifier).state = deger,
                          ),
                        ),
                        SizedBox(
                          height: 54,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            scrollDirection: Axis.horizontal,
                            itemCount: _kategoriler.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final kategori = _kategoriler[index];
                              final secili = seciliKategori == kategori;
                              return FilterChip(
                                label: Text(kategori),
                                selected: secili,
                                showCheckmark: false,
                                backgroundColor: renkSemasi.surface,
                                selectedColor: renkSemasi.primary,
                                side: BorderSide(
                                  color: secili
                                      ? renkSemasi.primary
                                      : renkSemasi.outline,
                                ),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: secili
                                      ? renkSemasi.onPrimary
                                      : renkSemasi.onSurface,
                                ),
                                onSelected: (_) => ref
                                    .read(seciliKategoriProvider.notifier)
                                    .state = kategori,
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            scrollDirection: Axis.horizontal,
                            itemCount: TarihFiltresi.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final filtre = TarihFiltresi.values[index];
                              final secili = tarihFiltresi == filtre;
                              return FilterChip(
                                avatar: Icon(
                                  _tarihIkonu(filtre),
                                  size: 16,
                                  color: secili
                                      ? renkSemasi.onPrimaryContainer
                                : renkSemasi.onSurface.withValues(alpha: 0.6),
                                ),
                                label: Text(filtre.etiket),
                                selected: secili,
                                showCheckmark: false,
                                backgroundColor: renkSemasi.surface,
                                selectedColor: renkSemasi.primaryContainer,
                                side: BorderSide(
                                  color: secili
                                      ? renkSemasi.primary
                                      : renkSemasi.outline,
                                ),
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: secili
                                      ? renkSemasi.onPrimaryContainer
                                      : renkSemasi.onSurface,
                                ),
                                onSelected: (_) => ref
                                    .read(tarihFiltresiProvider.notifier)
                                    .state = filtre,
                              );
                            },
                          ),
                        ),
                        if (tamamlananSayisi > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _tamamlananlariTemizle(context, ref),
                                icon: const Icon(Icons.cleaning_services_outlined,
                                    size: 18),
                          label:
                              Text('Tamamlananları temizle ($tamamlananSayisi)'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (gosterilecekListe.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: renkSemasi.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.checklist_rtl,
                                  size: 44,
                                  color: renkSemasi.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Listede gösterilecek öğe yok',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: renkSemasi.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Yeni Ekle ile ilk görevini oluştur',
                                style: TextStyle(
                            color:
                                renkSemasi.onSurface.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      sliver: SliverReorderableList(
                        itemCount: gosterilecekListe.length,
                        onReorder: (eskiIndex, yeniIndex) {
                          if (!siralamaAktif) return;
                          ref
                              .read(gorevlerProvider.notifier)
                              .yenidenSirala(eskiIndex, yeniIndex);
                        },
                        proxyDecorator: (child, index, animation) => Material(
                          color: Colors.transparent,
                          elevation: 6,
                          borderRadius: BorderRadius.circular(16),
                          child: child,
                        ),
                        itemBuilder: (context, index) {
                          final oge = gosterilecekListe[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(oge.id),
                            index: index,
                            enabled: siralamaAktif,
                            child: GorevKarti(
                              oge: oge,
                              onDurumDegisti: (yeniDurum) {
                                ref
                                    .read(gorevlerProvider.notifier)
                                    .durumDegistir(oge.id, yeniDurum);
                                if (yeniDurum == true) {
                                  ref
                                      .read(konfetiTetikleyiciProvider.notifier)
                                      .state++;
                                }
                              },
                              onDuzenle: () => _formPenceresiniAc(
                                context,
                                ref,
                                mevcutOge: oge,
                              ),
                              onSilindi: () => _ogeSil(context, ref, oge),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: BannerAdWidget(),
            ),
          ),
        ],
      ),
          const Positioned.fill(child: KonfetiKatmani()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formPenceresiniAc(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ekle'),
      ),
    );
  }
}