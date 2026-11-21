import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAdService._();
  static final InterstitialAdService instance = InterstitialAdService._();


  static const int _sikilik = 3; // her 3 yeni görev kaydında bir
  static const Duration _beklemeSuresi = Duration(minutes: 3);

  InterstitialAd? _ad;
  bool _yukleniyor = false;
  int _eylemSayaci = 0;
  DateTime? _sonGosterim;


  /// Reklamı arka planda yükler. Uygulama açılırken bir kez çağır.
  void yukle() {
    if (_ad != null || _yukleniyor) return;

    final id = dotenv.env['Android_GecisId'] ?? '';;
    debugPrint('Interstitial adUnitId: "$id"');
    if (id.isEmpty) return;

    _yukleniyor = true;
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _yukleniyor = false;
        },
        onAdFailedToLoad: (err) {
          debugPrint(
            'Interstitial yüklenemedi → kod: ${err.code}, mesaj: ${err.message}',
          );
          _yukleniyor = false;
        },
      ),
    );
  }

  /// Anlamlı bir eylemden (örn. görev kaydı) sonra çağır.
  /// Koşullar uygunsa reklamı gösterir, değilse hiçbir şey yapmaz.
  void eylemSonrasiGoster() {
    _eylemSayaci++;

    final ad = _ad;
    if (ad == null) {
      yukle(); // hazır değilse sıradaki için yüklemeyi başlat
      return;
    }
    if (_eylemSayaci < _sikilik) return;

    final simdi = DateTime.now();
    if (_sonGosterim != null &&
        simdi.difference(_sonGosterim!) < _beklemeSuresi) {
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        yukle();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('Interstitial gösterilemedi: ${err.message}');
        ad.dispose();
        yukle();
      },
    );

    _ad = null;
    _eylemSayaci = 0;
    _sonGosterim = simdi;
    ad.show();
  }
}