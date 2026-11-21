import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Konfeti patlatmak için sayacı bir artır:
/// `ref.read(konfetiTetikleyiciProvider.notifier).state++;`
final konfetiTetikleyiciProvider = StateProvider<int>((ref) => 0);

/// Ekranın üstünde çalışan, paket gerektirmeyen konfeti efekti.
/// Dokunmaları engellemez; "animasyonları azalt" açıksa çalışmaz.
class KonfetiKatmani extends ConsumerStatefulWidget {
  const KonfetiKatmani({super.key, this.parcaSayisi = 100});

  final int parcaSayisi;

  @override
  ConsumerState<KonfetiKatmani> createState() => _KonfetiKatmaniState();
}

class _KonfetiKatmaniState extends ConsumerState<KonfetiKatmani>
    with SingleTickerProviderStateMixin {
  static const Duration _sure = Duration(milliseconds: 2600);

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _sure);

  List<_Parca> _parcalar = const [];
  final math.Random _rnd = math.Random();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _patlat() {
    if (MediaQuery.disableAnimationsOf(context)) return;

    final cs = Theme.of(context).colorScheme;
    final renkler = <Color>[
      cs.primary,
      cs.tertiary,
      cs.secondary,
      const Color(0xFFFFD93D),
      const Color(0xFFFF6B8B),
      const Color(0xFF4D96FF),
      const Color(0xFF6BCB77),
    ];

    _parcalar = List.generate(widget.parcaSayisi, (_) {
      // Yukarı doğru yelpaze şeklinde fırlatma
      final aci = -math.pi / 2 + (_rnd.nextDouble() - 0.5) * 1.7;
      return _Parca(
        aci: aci,
        hiz: 520 + _rnd.nextDouble() * 620,
        renk: renkler[_rnd.nextInt(renkler.length)],
        sekil: _rnd.nextInt(3),
        boyut: 6 + _rnd.nextDouble() * 6,
        donus: _rnd.nextDouble() * math.pi * 2,
        donusHizi: (_rnd.nextDouble() - 0.5) * 12,
        cevirmeHizi: 4 + _rnd.nextDouble() * 8,
      );
    });

    HapticFeedback.lightImpact();
    setState(() {});
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(konfetiTetikleyiciProvider, (onceki, sonraki) {
      if (onceki != sonraki) _patlat();
    });

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _KonfetiPainter(
            animation: _controller,
            parcalar: _parcalar,
            sureSaniye: _sure.inMilliseconds / 1000,
          ),
        ),
      ),
    );
  }
}

class _Parca {
  const _Parca({
    required this.aci,
    required this.hiz,
    required this.renk,
    required this.sekil,
    required this.boyut,
    required this.donus,
    required this.donusHizi,
    required this.cevirmeHizi,
  });

  final double aci;
  final double hiz;
  final Color renk;
  final int sekil; // 0: dikdörtgen, 1: daire, 2: ince şerit
  final double boyut;
  final double donus;
  final double donusHizi;
  final double cevirmeHizi;
}

class _KonfetiPainter extends CustomPainter {
  _KonfetiPainter({
    required this.animation,
    required this.parcalar,
    required this.sureSaniye,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<_Parca> parcalar;
  final double sureSaniye;

  static const double _yercekimi = 1500;
  static const double _surtunme = 2.2;

  @override
  void paint(Canvas canvas, Size size) {
    final v = animation.value;
    if (parcalar.isEmpty || v <= 0 || v >= 1) return;

    final s = v * sureSaniye;
    // Patlama noktası: ekranın alt-orta kısmı
    final x0 = size.width * 0.5;
    final y0 = size.height * 0.82;
    final fade = v < 0.7 ? 1.0 : (1 - v) / 0.3;
    final paint = Paint();

    for (final p in parcalar) {
      final sf = (1 - math.exp(-_surtunme * s)) / _surtunme;
      final x = x0 + math.cos(p.aci) * p.hiz * sf;
      final y = y0 + math.sin(p.aci) * p.hiz * sf + 0.5 * _yercekimi * s * s;

      paint.color = p.renk.withValues(alpha: fade.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.donus + p.donusHizi * s);
      // Takla atma hissi için dikey ölçek
      canvas.scale(1, math.cos(p.cevirmeHizi * s).abs().clamp(0.15, 1.0));

      switch (p.sekil) {
        case 0:
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: p.boyut, height: p.boyut * 0.6),
            paint,
          );
        case 1:
          canvas.drawCircle(Offset.zero, p.boyut * 0.38, paint);
        default:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.boyut * 1.6, height: 3),
              const Radius.circular(1.5),
            ),
            paint,
          );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _KonfetiPainter old) =>
      old.parcalar != parcalar;
}