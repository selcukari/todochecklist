import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServisi {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _baslatildi = false;

  // Web Client ID'nizin Google Cloud / Firebase konsolu ile eşleştiğinden emin olun
  static const String _webClientId = '750249627763-i0a4eqj4hd4gg8nvnmcm332kspe2n1sc.apps.googleusercontent.com';

  Future<void> _baslatilmisOlsun() async {
    if (!_baslatildi) {
      try {
        await _googleSignIn.initialize(
          serverClientId: _webClientId,
        );
        _baslatildi = true;
      } catch (e) {
        rethrow;
      }
    }
  }

  Stream<User?> get authDurumuDegisiklikleri => _firebaseAuth.authStateChanges();

  User? get mevcutKullanici => _firebaseAuth.currentUser;

  Future<UserCredential?> googleIleGirisYap() async {
    await _baslatilmisOlsun();

    try {
      // 1. Google hesap seçme penceresini aç
      final GoogleSignInAccount? googleKullanici = await _googleSignIn.authenticate();
      
      // Kullanıcı pencereyi kapatırsa (iptal ederse) null döner
      if (googleKullanici == null) {
        return null;
      }

      // 2. Kimlik doğrulama bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleKullanici.authentication;

      // 3. Firebase kimlik bilgisini (credential) oluştur
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Firebase'e giriş yap
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      return userCredential;
    } on GoogleSignInException catch (e, stack) {
      
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    } catch (e, stack) {
      rethrow;
    }
  }

  Future<void> cikisYap() async {
    await _baslatilmisOlsun();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }
}