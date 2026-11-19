import 'package:flutter/material.dart';

class IlerlemeOzetKarti extends StatelessWidget {
  final int tamamlananSayisi;
  final int toplamSayi;

  const IlerlemeOzetKarti({
    super.key,
    required this.tamamlananSayisi,
    required this.toplamSayi,
  });

  @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;
    final ilerleme = toplamSayi == 0 ? 0.0 : tamamlananSayisi / toplamSayi;
    final yuzde = (ilerleme * 100).round();
    final hepsiBitti = toplamSayi > 0 && tamamlananSayisi == toplamSayi;
    final yaziRengi = renkSemasi.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(renkSemasi.primary, Colors.black, 0.18)!,
              renkSemasi.primary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: renkSemasi.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hepsiBitti ? 'Harika, hepsi tamam!' : 'Günlük İlerleme',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: yaziRengi,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$tamamlananSayisi / $toplamSayi tamamlandı',
                      style: TextStyle(
                        fontSize: 13,
                        color: yaziRengi.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                Text(
                  '%$yuzde',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: yaziRengi,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ilerleme),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, deger, _) => LinearProgressIndicator(
                  value: deger,
                  minHeight: 8,
                  backgroundColor: yaziRengi.withValues(alpha: 0.25),
                  valueColor: AlwaysStoppedAnimation(
                    hepsiBitti ? renkSemasi.tertiaryContainer : yaziRengi,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}