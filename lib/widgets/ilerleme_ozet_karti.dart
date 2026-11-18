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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 0,
        color: renkSemasi.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Günlük İlerleme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: renkSemasi.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    '$tamamlananSayisi / $toplamSayi Tamamlandı',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: renkSemasi.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ilerleme,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}