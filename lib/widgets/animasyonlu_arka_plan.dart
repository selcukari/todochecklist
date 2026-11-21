import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Listenin arkasında çalışan modern animasyonlu arka plan:
///  - Mesh gradient: temanın renklerinden akışkan, birbirine karışan renk alanları
///  - Parıltı: yavaşça yanıp sönen küçük 4 köşeli yıldızlar
///
/// Dokunmaları engellemez, RepaintBoundary ile izole edilir ve cihazda
/// "animasyonları azalt" açıksa durur. Animasyon döngüsü kesintisizdir.
class AnimasyonluArkaPlan extends StatefulWidget {
  const AnimasyonluArkaPlan({
    super.key,
    this.parilti = 26,
    this.parildarGoster = true,
  });

  /// Parıltı (yıldız) sayısı.
  final int parilti;

  /// false yapılırsa sadece mesh gradient çizilir.
  final bool parildarGoster;

  @override
  State<AnimasyonluArkaPlan> createState() => _AnimasyonluArkaPlanState();
}

class _AnimasyonluArkaPlanState extends State<AnimasyonluArkaPlan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );

  late final List<_Parilti> _parildar;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(11);
    _parildar = List.generate(widget.parilti, (_) {
      return _Parilti(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        faz: rnd.nextDouble(),
        // Tam sayı döngü => animasyon başa sararken sıçrama olmaz.
        dongu: 2 + rnd.nextInt(4),
        yaricap: 2.5 + rnd.nextDouble() * 4.5,
        renkIndex: rnd.nextInt(3),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final koyu = cs.brightness == Brightness.dark;

    // Ana renge yakın dördüncü ve beşinci ton (mesh'in daha zengin görünmesi için)
    final hsl = HSLColor.fromColor(cs.primary);
    final analog1 = hsl.withHue((hsl.hue + 40) % 360).toColor();
    final analog2 = hsl.withHue((hsl.hue + 320) % 360).toColor();

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _ArkaPlanPainter(
            animation: _controller,
            parildar: _parildar,
            koyu: koyu,
            meshRenkleri: [
              cs.primary,
              cs.tertiary,
              cs.secondary,
              analog1,
              analog2,
            ],
            parildarGoster: widget.parildarGoster,
          ),
        ),
      ),
    );
  }
}

class _Parilti {
  const _Parilti({
    required this.x,
    required this.y,
    required this.faz,
    required this.dongu,
    required this.yaricap,
    required this.renkIndex,
  });

  final double x;
  final double y;
  final double faz;
  final int dongu;
  final double yaricap;
  final int renkIndex;
}

class _ArkaPlanPainter extends CustomPainter {
  _ArkaPlanPainter({
    required this.animation,
    required this.parildar,
    required this.koyu,
    required this.meshRenkleri,
    required this.parildarGoster,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Parilti> parildar;
  final bool koyu;
  final List<Color> meshRenkleri;
  final bool parildarGoster;

  static const double _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    _mesh(canvas, size, t);
    if (parildarGoster) _parilti(canvas, size, t);
  }

  void _leke(Canvas canvas, Offset merkez, double yaricap, Color renk) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [renk, renk.withValues(alpha: 0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: merkez, radius: yaricap));
    canvas.drawCircle(merkez, yaricap, paint);
  }

  void _mesh(Canvas canvas, Size s, double t) {
    final w = s.width;
    final h = s.height;
    final a = koyu ? 0.26 : 0.17;
    final c = meshRenkleri;

    // Her nokta farklı frekansta (1 veya 2 tam tur) hareket eder; bu da
    // döngüyü kesintisiz tutarken lekelerin birbirine karışmasını sağlar.
    final noktalar = <(double, double, double, int)>[
      (0.15 + 0.14 * math.sin(_tau * t), 0.10 + 0.07 * math.cos(_tau * t), 0.90, 0),
      (0.88 + 0.08 * math.cos(_tau * t), 0.28 + 0.10 * math.sin(_tau * 2 * t), 0.80, 1),
      (0.20 + 0.12 * math.cos(_tau * 2 * t), 0.58 + 0.09 * math.sin(_tau * t), 0.85, 3),
      (0.82 + 0.10 * math.sin(_tau * 2 * t), 0.78 + 0.07 * math.cos(_tau * t), 0.90, 2),
      (0.45 + 0.18 * math.sin(_tau * t + 2), 0.95 + 0.04 * math.cos(_tau * 2 * t), 0.85, 4),
    ];

    for (final n in noktalar) {
      _leke(
        canvas,
        Offset(w * n.$1, h * n.$2),
        w * n.$3,
        c[n.$4].withValues(alpha: a),
      );
    }
  }

  void _parilti(Canvas canvas, Size s, double t) {
    final w = s.width;
    final h = s.height;
    final paint = Paint()..style = PaintingStyle.fill;
    final glow = Paint()..style = PaintingStyle.fill;

    for (final p in parildar) {
      final d = (t * p.dongu + p.faz) % 1.0;
      // Yumuşak yanıp sönme: sin^3 ile kısa ve belirgin bir parlama
      final nabiz = math.pow(math.sin(math.pi * d), 3).toDouble();
      if (nabiz < 0.02) continue;

      // Çok hafif süzülme
      final cx = p.x * w + 5 * math.sin(_tau * (t + p.faz));
      final cy = p.y * h + 7 * math.cos(_tau * (t * 2 + p.faz));
      final merkez = Offset(cx, cy);

      final renk = koyu
          ? Colors.white
          : meshRenkleri[p.renkIndex].withValues(alpha: 1);
      final alfa = nabiz * (koyu ? 0.75 : 0.55);
      final r = p.yaricap * (0.6 + 0.4 * nabiz);

      // Arkadaki yumuşak ışıma
      glow.color = renk.withValues(alpha: alfa * 0.18);
      canvas.drawCircle(merkez, r * 2.6, glow);

      // 4 köşeli yıldız
      paint.color = renk.withValues(alpha: alfa);
      canvas.drawPath(_yildiz(merkez, r), paint);
    }
  }

  Path _yildiz(Offset c, double r) {
    final k = r * 0.22;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _ArkaPlanPainter old) =>
      old.koyu != koyu ||
      old.parildarGoster != parildarGoster ||
      old.meshRenkleri.length != meshRenkleri.length ||
      !_ayniRenkler(old.meshRenkleri, meshRenkleri);

  static bool _ayniRenkler(List<Color> a, List<Color> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}