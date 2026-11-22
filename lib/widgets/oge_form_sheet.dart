import 'package:flutter/material.dart';
import '../models/gorev_ogesi.dart';
import '../utils/toast_helper.dart';
import '../theme/app_theme.dart';

class OgeFormSheet extends StatefulWidget {
  final GorevOgesi? mevcutOge;
  final void Function(
    String baslik,
    String kategori,
    Oncelik oncelik,
    DateTime? sonTarih,
    DateTime? hatirlaticiZamani,
    List<AltGorev> altGorevler,
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
  final TextEditingController _altGorevController = TextEditingController();

  late String _seciliKategori;
  late Oncelik _seciliOncelik;
  DateTime? _seciliTarih;
  DateTime? _seciliHatirlatici;
  late List<AltGorev> _altGorevler;

  late final String _ilkBaslik;
  late final String _ilkKategori;
  late final Oncelik _ilkOncelik;
  late final DateTime? _ilkTarih;
  late final DateTime? _ilkHatirlatici;
  late final List<AltGorev> _ilkAltGorevler;

  bool _onaylanmisCikis = false;

  bool get _duzenlemeModu => widget.mevcutOge != null;

  @override
  void initState() {
    super.initState();
    _ilkBaslik = widget.mevcutOge?.baslik ?? '';
    _ilkKategori = widget.mevcutOge?.kategori ?? 'Alışveriş';
    _ilkOncelik = widget.mevcutOge?.oncelik ?? Oncelik.orta;
    _ilkTarih = widget.mevcutOge?.sonTarih;
    _ilkHatirlatici = widget.mevcutOge?.hatirlaticiZamani;
    _ilkAltGorevler = List<AltGorev>.from(widget.mevcutOge?.altGorevler ?? []);

    _baslikController = TextEditingController(text: _ilkBaslik);
    _seciliKategori = _ilkKategori;
    _seciliOncelik = _ilkOncelik;
    _seciliTarih = _ilkTarih;
    _seciliHatirlatici = _ilkHatirlatici;
    _altGorevler = List<AltGorev>.from(_ilkAltGorevler);

    _baslikController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _altGorevController.dispose();
    super.dispose();
  }

  bool get _degisiklikVarMi {
    if (_onaylanmisCikis) return false;

    final baslikDegisti = _baslikController.text.trim() != _ilkBaslik.trim();
    final kategoriDegisti = _seciliKategori != _ilkKategori;
    final oncelikDegisti = _seciliOncelik != _ilkOncelik;
    final tarihDegisti = !_ayniGunMu(_seciliTarih, _ilkTarih);
    final hatirlaticiDegisti = _seciliHatirlatici != _ilkHatirlatici;
    final altGorevDegisti = _altGorevler.length != _ilkAltGorevler.length ||
        List.generate(
          _altGorevler.length,
          (i) =>
              _altGorevler[i].id != _ilkAltGorevler[i].id ||
              _altGorevler[i].baslik != _ilkAltGorevler[i].baslik ||
              _altGorevler[i].tamamlandi != _ilkAltGorevler[i].tamamlandi,
        ).any((degisti) => degisti);

    return baslikDegisti ||
        kategoriDegisti ||
        oncelikDegisti ||
        tarihDegisti ||
        hatirlaticiDegisti ||
        altGorevDegisti;
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
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.tertiary),
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
      setState(() {
        _seciliTarih = secilen;
        if (_seciliHatirlatici != null) {
          _seciliHatirlatici = DateTime(
            secilen.year,
            secilen.month,
            secilen.day,
            _seciliHatirlatici!.hour,
            _seciliHatirlatici!.minute,
          );
        }
      });
    }
  }

  Future<void> _hatirlaticiSec() async {
    final temelTarih = _seciliHatirlatici ?? _seciliTarih ?? DateTime.now();
    final saat = await showTimePicker(
      context: context,
      initialTime: _seciliHatirlatici != null
          ? TimeOfDay.fromDateTime(_seciliHatirlatici!)
          : const TimeOfDay(hour: 9, minute: 0),
      helpText: 'Hatırlatıcı Saati Seçin',
      cancelText: 'İptal',
      confirmText: 'Ayarla',
    );

    if (saat == null) return;

    setState(() {
      _seciliHatirlatici = DateTime(
        temelTarih.year,
        temelTarih.month,
        temelTarih.day,
        saat.hour,
        saat.minute,
      );
    });
  }

  void _altGorevEkle() {
    final metin = _altGorevController.text.trim();
    if (metin.isEmpty) return;

    setState(() {
      _altGorevler = [
        ..._altGorevler,
        AltGorev(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          baslik: metin,
        ),
      ];
      _altGorevController.clear();
    });
  }

  String _tarihFormatla(DateTime tarih) {
    final gun = tarih.day.toString().padLeft(2, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    return '$gun.$ay.${tarih.year}';
  }

  String _hatirlaticiFormatla(DateTime zaman) {
    final saat = zaman.hour.toString().padLeft(2, '0');
    final dakika = zaman.minute.toString().padLeft(2, '0');
    return '${_tarihFormatla(zaman)} • $saat:$dakika';
  }

  void _formuTamamla() {
    final metin = _baslikController.text.trim();
    if (metin.isEmpty) {
      gFToastShowToast(
        context: context,
        message: 'Lütfen bir başlık girin.',
        backgroundColor: AppColors.coral,
      );
      return;
    }

    _onaylanmisCikis = true;
    widget.onKaydet(
      metin,
      _seciliKategori,
      _seciliOncelik,
      _seciliTarih,
      _seciliHatirlatici,
      _altGorevler,
    );
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
                        decoration: InputDecoration(
                          labelText: 'Ne alınacak veya yapılacak?',
                          prefixIcon:
                              Icon(Icons.edit_note, color: renkSemasi.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Kategori',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Alışveriş', 'İş', 'Kişisel'].map((kat) {
                          final secili = _seciliKategori == kat;
                          return ChoiceChip(
                            label: Text(kat),
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
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: renkSemasi.primaryContainer,
                          selectedForegroundColor:
                              renkSemasi.onPrimaryContainer,
                          side: BorderSide(color: renkSemasi.outline),
                        ),
                        segments: Oncelik.values
                            .map((o) => ButtonSegment(
                                value: o, label: Text(o.etiket)))
                            .toList(),
                        selected: {_seciliOncelik},
                        onSelectionChanged: (yeniSecim) {
                          setState(() => _seciliOncelik = yeniSecim.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Son Teslim Tarihi
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
                      const SizedBox(height: 8),
                      // Hatırlatıcı Bildirim Saati
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _hatirlaticiSec,
                              icon: const Icon(
                                Icons.notifications_active_outlined,
                                size: 18, color: Colors.orange,),
                              label: Text(
                                _seciliHatirlatici == null
                                    ? 'Hatırlatıcı Ekle (İsteğe Bağlı)'
                                    : 'Hatırlat: ${_hatirlaticiFormatla(_seciliHatirlatici!)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (_seciliHatirlatici != null) ...[
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: 'Hatırlatıcıyı Kaldır',
                              onPressed: () =>
                                  setState(() => _seciliHatirlatici = null),
                              icon: Icon(Icons.close, color: renkSemasi.error),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Alt Görevler (Checklist)
                      const Text('Alt Görevler',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _altGorevController,
                              textInputAction: TextInputAction.done,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _altGorevEkle(),
                              decoration: const InputDecoration(
                                hintText: 'Alt adım veya liste öğesi ekle...',
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            tooltip: 'Alt Görev Ekle',
                            onPressed: _altGorevEkle,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      if (_altGorevler.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ..._altGorevler.map(
                          (alt) => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: alt.tamamlandi,
                            title: Text(
                              alt.baslik,
                              style: TextStyle(
                                decoration: alt.tamamlandi
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: alt.tamamlandi
                                    ? renkSemasi.onSurface
                                        .withValues(alpha: 0.5)
                                    : renkSemasi.onSurface,
                              ),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _altGorevler = [
                                  for (final item in _altGorevler)
                                    if (item.id == alt.id)
                                      item.copyWith(tamamlandi: val ?? false)
                                    else
                                      item,
                                ];
                              });
                            },
                            secondary: IconButton(
                              tooltip: 'Sil',
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _altGorevler = _altGorevler
                                      .where((i) => i.id != alt.id)
                                      .toList();
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
                        icon: const Icon(Icons.close, color: Colors.red,),
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