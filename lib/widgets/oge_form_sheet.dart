import 'package:flutter/material.dart';
import '../models/gorev_ogesi.dart';
import '../utils/toast_helper.dart';

class OgeFormSheet extends StatefulWidget {
  final GorevOgesi? mevcutOge;
  final void Function(
    String baslik,
    String kategori,
    Oncelik oncelik,
    DateTime? sonTarih,
  ) onKaydet;

  const OgeFormSheet({
    super.key,
    this.mevcutOge,
    required this.onKaydet,
  });

  @override
  State<OgeFormSheet> createState() => _OgeFormSheetState();
}

class _OgeFormSheetState extends State<OgeFormSheet> {
  late final TextEditingController _baslikController;
  late String _seciliKategori;
  late Oncelik _seciliOncelik;
  DateTime? _seciliTarih;

  // İlk değerleri karşılaştırma için saklıyoruz
  late final String _ilkBaslik;
  late final String _ilkKategori;
  late final Oncelik _ilkOncelik;
  late final DateTime? _ilkTarih;

  bool _onaylanmisCikis = false;

  bool get _duzenlemeModu => widget.mevcutOge != null;

  @override
  void initState() {
    super.initState();
    _ilkBaslik = widget.mevcutOge?.baslik ?? '';
    _ilkKategori = widget.mevcutOge?.kategori ?? 'Alışveriş';
    _ilkOncelik = widget.mevcutOge?.oncelik ?? Oncelik.orta;
    _ilkTarih = widget.mevcutOge?.sonTarih;

    _baslikController = TextEditingController(text: _ilkBaslik);
    _seciliKategori = _ilkKategori;
    _seciliOncelik = _ilkOncelik;
    _seciliTarih = _ilkTarih;

    // Yazı değiştikçe PopScope'un güncel kalması için dinleyici ekliyoruz
    _baslikController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _baslikController.dispose();
    super.dispose();
  }

  /// Formda başlangıç durumuna göre herhangi bir değişiklik olup olmadığını kontrol eder
  bool get _degisiklikVarMi {
    if (_onaylanmisCikis) return false;

    final baslikDegisti = _baslikController.text.trim() != _ilkBaslik.trim();
    final kategoriDegisti = _seciliKategori != _ilkKategori;
    final oncelikDegisti = _seciliOncelik != _ilkOncelik;
    final tarihDegisti = !_ayniGunMu(_seciliTarih, _ilkTarih);

    return baslikDegisti || kategoriDegisti || oncelikDegisti || tarihDegisti;
  }

  bool _ayniGunMu(DateTime? a, DateTime? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _cikisOnayiGoster() async {
    final cikilsinMi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Kaydedilmemiş Değişiklikler'),
        content: const Text(
          'Yaptığınız değişiklikler henüz kaydedilmedi. Kaydetmeden çıkmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Kaydetmeden Çık'),
          ),
        ],
      ),
    );

    if (cikilsinMi == true && mounted) {
      setState(() => _onaylanmisCikis = true);
      Navigator.pop(context);
    }
  }

  Future<void> _tarihSec() async {
    final simdi = DateTime.now();
    final secilen = await showDatePicker(
      context: context,
      initialDate: _seciliTarih ?? simdi,
      firstDate: DateTime(simdi.year - 1),
      lastDate: DateTime(simdi.year + 5),
      helpText: 'Son Teslim Tarihi Seçin',
      cancelText: 'İptal',
      confirmText: 'Seç',
    );

    if (secilen != null) {
      setState(() => _seciliTarih = secilen);
    }
  }

  String _tarihFormatla(DateTime tarih) {
    final gun = tarih.day.toString().padLeft(2, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    return '$gun.$ay.${tarih.year}';
  }

  void _formuTamamla() {
    final metin = _baslikController.text.trim();
    if (metin.isEmpty) {
      gFToastShowToast(
        context: context,
        message: 'Lütfen bir başlık girin.',
        backgroundColor: Colors.orange.shade800,
      );
      return;
    }

    // PopScope uyarısını tetiklemeden kapatmak için işaretliyoruz
    _onaylanmisCikis = true;
    widget.onKaydet(metin, _seciliKategori, _seciliOncelik, _seciliTarih);
    Navigator.pop(context);
  }

 @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;
    final klavyeBoslugu = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_degisiklikVarMi,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _cikisOnayiGoster();
      },
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: klavyeBoslugu),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Kaydırılabilir Form Alanı
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _duzenlemeModu ? 'Öğeyi Düzenle' : 'Yeni Öğe Ekle',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            tooltip: 'Kapat',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              if (_degisiklikVarMi) {
                                _cikisOnayiGoster();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _baslikController,
                        autofocus: !_duzenlemeModu,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _formuTamamla(),
                        decoration: const InputDecoration(
                          labelText: 'Ne alınacak veya yapılacak?',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit_note),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Kategori',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Alışveriş', 'İş', 'Kişisel'].map((kat) {
                          return ChoiceChip(
                            label: Text(kat),
                            selected: _seciliKategori == kat,
                            onSelected: (val) {
                              if (val) setState(() => _seciliKategori = kat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Öncelik',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<Oncelik>(
                        segments: Oncelik.values
                            .map((o) =>
                                ButtonSegment(value: o,
                                label: Text(o.etiket)))
                            .toList(),
                        selected: {_seciliOncelik},
                        onSelectionChanged: (yeniSecim) {
                          setState(() => _seciliOncelik = yeniSecim.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _tarihSec,
                              icon: const Icon(Icons.calendar_today_outlined,
                                  size: 18),
                              label: Text(
                                _seciliTarih == null
                                    ? 'Son Tarih Ekle (İsteğe Bağlı)'
                                    : 'Son Tarih: ${_tarihFormatla(_seciliTarih!)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (_seciliTarih != null) ...[
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'Tarihi Kaldır',
                              onPressed: () =>
                                  setState(() => _seciliTarih = null),
                              icon: Icon(Icons.close, color: renkSemasi.error),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Telefonun Alt Çubuğunun Hemen Üstünde Sabit Duran Aksiyon Butonları
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (_degisiklikVarMi) {
                            _cikisOnayiGoster();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.close, color: Color.fromARGB(255, 255, 17, 0)),
                        label: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _formuTamamla,
                        icon: Icon(
                            _duzenlemeModu ? Icons.save_outlined : Icons.check),
                        label: Text(
                          _duzenlemeModu
                              ? 'Değişiklikleri Kaydet'
                              : 'Listeye Ekle',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}