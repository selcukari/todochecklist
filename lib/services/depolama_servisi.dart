import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gorev_ogesi.dart';

class DepolamaServisi {
  String _anahtarGetir(String? uid) => 'akilli_liste_gorevler_${uid ?? "misafir"}_v1';

  Future<void> gorevleriKaydet(List<GorevOgesi> ogeler, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonListesi = ogeler.map((oge) => oge.toJson()).toList();
    await prefs.setString(_anahtarGetir(uid), jsonEncode(jsonListesi));
  }

  /// Cihazda kayıtlı görevleri okur ve GorevOgesi listesine dönüştürür
  Future<List<GorevOgesi>> gorevleriYukle({String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_anahtarGetir(uid));
    if (jsonString == null) return _varsayilanOrnekVeriler();

    final cozumlenenListe = jsonDecode(jsonString) as List<dynamic>;
    return cozumlenenListe
        .map((item) => GorevOgesi.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  List<GorevOgesi> _varsayilanOrnekVeriler() {
    return [
      GorevOgesi(
        id: '1',
        baslik: 'Süt, yumurta ve tam buğday ekmeği al',
        kategori: 'Alışveriş',
        oncelik: Oncelik.yuksek,
      ),
      GorevOgesi(
        id: '2',
        baslik: 'API dokümantasyonunu gözden geçir',
        kategori: 'İş',
        oncelik: Oncelik.orta,
      ),
    ];
  }
}