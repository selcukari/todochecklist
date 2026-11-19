import 'package:flutter/material.dart';

enum SiralamaKriteri {
  eklenmeSirasi('Eklenme Sırası'),
  sonTarih('Son Tarihe Göre'),
  oncelik('Önceliğe Göre');

  final String etiket;
  const SiralamaKriteri(this.etiket);
}

enum Oncelik {
  dusuk('Düşük', 1),
  orta('Orta', 2),
  yuksek('Yüksek', 3);

  final String etiket;
  final int siralamaPuani;
  const Oncelik(this.etiket, this.siralamaPuani);

  Color renkGetir(ColorScheme scheme) {
    switch (this) {
      case Oncelik.yuksek:
        return scheme.error;
      case Oncelik.orta:
        return Colors.orange;
      case Oncelik.dusuk:
        return scheme.primary;
    }
  }
}

class AltGorev {
  final String id;
  final String baslik;
  final bool tamamlandi;

  const AltGorev({
    required this.id,
    required this.baslik,
    this.tamamlandi = false,
  });

  AltGorev copyWith({
    String? id,
    String? baslik,
    bool? tamamlandi,
  }) {
    return AltGorev(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      tamamlandi: tamamlandi ?? this.tamamlandi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'tamamlandi': tamamlandi,
    };
  }

  factory AltGorev.fromJson(Map<String, dynamic> json) {
    return AltGorev(
      id: json['id'] as String,
      baslik: json['baslik'] as String,
      tamamlandi: json['tamamlandi'] as bool? ?? false,
    );
  }
}

class GorevOgesi {
  final String id;
  final String baslik;
  final String kategori;
  final Oncelik oncelik;
  final DateTime? sonTarih;
  final DateTime? hatirlaticiZamani;
  final List<AltGorev> altGorevler;
  final bool tamamlandi;

  const GorevOgesi({
    required this.id,
    required this.baslik,
    required this.kategori,
    required this.oncelik,
    this.sonTarih,
    this.hatirlaticiZamani,
    this.altGorevler = const [],
    this.tamamlandi = false,
  });

  GorevOgesi copyWith({
    String? id,
    String? baslik,
    String? kategori,
    Oncelik? oncelik,
    DateTime? sonTarih,
    bool sonTarihiTemizle = false,
    DateTime? hatirlaticiZamani,
    bool hatirlaticiTemizle = false,
    List<AltGorev>? altGorevler,
    bool? tamamlandi,
  }) {
    return GorevOgesi(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      kategori: kategori ?? this.kategori,
      oncelik: oncelik ?? this.oncelik,
      sonTarih: sonTarihiTemizle ? null : (sonTarih ?? this.sonTarih),
      hatirlaticiZamani: hatirlaticiTemizle
          ? null
          : (hatirlaticiZamani ?? this.hatirlaticiZamani),
      altGorevler: altGorevler ?? this.altGorevler,
      tamamlandi: tamamlandi ?? this.tamamlandi,
    );
  }

  bool get geciktiMi {
    if (sonTarih == null || tamamlandi) return false;
    final simdi = DateTime.now();
    final bugun = DateTime(simdi.year, simdi.month, simdi.day);
    final hedef = DateTime(sonTarih!.year, sonTarih!.month, sonTarih!.day);
    return hedef.isBefore(bugun);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baslik': baslik,
      'kategori': kategori,
      'oncelik': oncelik.name,
      'sonTarih': sonTarih?.toIso8601String(),
      'hatirlaticiZamani': hatirlaticiZamani?.toIso8601String(),
      'altGorevler': altGorevler.map((e) => e.toJson()).toList(),
      'tamamlandi': tamamlandi,
    };
  }

  factory GorevOgesi.fromJson(Map<String, dynamic> json) {
    final hamAltListe = json['altGorevler'] as List<dynamic>? ?? const [];
    return GorevOgesi(
      id: json['id'] as String,
      baslik: json['baslik'] as String,
      kategori: json['kategori'] as String,
      oncelik: Oncelik.values.firstWhere(
        (e) => e.name == json['oncelik'],
        orElse: () => Oncelik.orta,
      ),
      sonTarih: json['sonTarih'] != null
          ? DateTime.parse(json['sonTarih'] as String)
          : null,
      hatirlaticiZamani: json['hatirlaticiZamani'] != null
          ? DateTime.parse(json['hatirlaticiZamani'] as String)
          : null,
      altGorevler: hamAltListe
          .map((e) => AltGorev.fromJson(e as Map<String, dynamic>))
          .toList(),
      tamamlandi: json['tamamlandi'] as bool? ?? false,
    );
  }
}