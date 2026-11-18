import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_servisi.dart';

final authServisiProvider = Provider<AuthServisi>((ref) {
  return AuthServisi();
});

/// Kullanıcının oturum açıp açmadığını canlı takip eder
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServisiProvider).authDurumuDegisiklikleri;
});