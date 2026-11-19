import 'package:flutter/material.dart';
import '../models/gorev_ogesi.dart';

class YeniOgeEkleSheet extends StatefulWidget {
  final void Function(String baslik, String kategori, Oncelik oncelik) onEkle;

  const YeniOgeEkleSheet({super.key, required this.onEkle});

  @override
  State<YeniOgeEkleSheet> createState() => _YeniOgeEkleSheetState();
}

class _YeniOgeEkleSheetState extends State<YeniOgeEkleSheet> {
  final _baslikController = TextEditingController();
  String _seciliKategori = 'Alışveriş';
  Oncelik _seciliOncelik = Oncelik.orta;

  @override
  void dispose() {
    _baslikController.dispose();
    super.dispose();
  }

  void _kaydet() {
    final metin = _baslikController.text.trim();
    if (metin.isEmpty) return;

    widget.onEkle(metin, _seciliKategori, _seciliOncelik);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Yeni Öğe Ekle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _baslikController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _kaydet(),
            decoration: InputDecoration(
              labelText: 'Ne alınacak veya yapılacak?',
              prefixIcon: Icon(Icons.edit_note, color: renkSemasi.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  color: secili ? renkSemasi.primary : renkSemasi.outline,
                ),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: secili ? renkSemasi.onPrimary : renkSemasi.onSurface,
                ),
                onSelected: (val) {
                  if (val) setState(() => _seciliKategori = kat);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Öncelik', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<Oncelik>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: renkSemasi.primaryContainer,
              selectedForegroundColor: renkSemasi.onPrimaryContainer,
              side: BorderSide(color: renkSemasi.outline),
            ),
            segments: Oncelik.values
                .map((o) => ButtonSegment(value: o, label: Text(o.etiket)))
                .toList(),
            selected: {_seciliOncelik},
            onSelectionChanged: (yeniSecim) {
              setState(() => _seciliOncelik = yeniSecim.first);
            },
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _kaydet,
            icon: const Icon(Icons.check),
            label: const Text('Listeye Ekle'),
          ),
        ],
      ),
    );
  }
}