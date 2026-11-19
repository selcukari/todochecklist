import 'package:flutter/material.dart';
import '../models/gorev_ogesi.dart';

class GorevKarti extends StatelessWidget {
  final GorevOgesi oge;
  final ValueChanged<bool> onDurumDegisti;
  final VoidCallback onDuzenle;
  final VoidCallback onSilindi;

  const GorevKarti({
    super.key,
    required this.oge,
    required this.onDurumDegisti,
    required this.onDuzenle,
    required this.onSilindi,
  });

  String _tarihFormatla(DateTime tarih) {
    final gun = tarih.day.toString().padLeft(2, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    return '$gun.$ay.${tarih.year}';
  }

  @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;
    final oncelikRengi = oge.oncelik.renkGetir(renkSemasi);
    final gecikti = oge.geciktiMi && !oge.tamamlandi;
    final radius = BorderRadius.circular(16);

    return Dismissible(
      key: ValueKey(oge.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: renkSemasi.errorContainer,
          borderRadius: radius,
        ),
        child: Icon(
          Icons.delete_outline,
          color: renkSemasi.onErrorContainer,
        ),
      ),
      onDismissed: (_) => onSilindi(),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(vertical: 5),
        // Tamamlanan görevler biraz soluk görünür
        color: oge.tamamlandi
            ? renkSemasi.surface.withValues(alpha: 0.6)
            : renkSemasi.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: gecikti ? renkSemasi.error : renkSemasi.outline,
            width: gecikti ? 1.2 : 1,
          ),
          borderRadius: radius,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Öncelik rengini gösteren sol şerit
              Container(
                width: 5,
                color: oge.tamamlandi
                    ? renkSemasi.outline
                    : oncelikRengi,
              ),
              Expanded(
                child: InkWell(
                  onTap: onDuzenle,
                  child: Padding(
                    // Altta ve üstte boşluk: içerik kesilmesin
                    padding: const EdgeInsets.fromLTRB(8, 12, 12, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: oge.tamamlandi,
                          onChanged: (val) => onDurumDegisti(val ?? false),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  oge.baslik,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: oge.tamamlandi
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: oge.tamamlandi
                                        ? renkSemasi.onSurface
                                            .withValues(alpha: 0.45)
                                        : renkSemasi.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // Kategori Bilgisi
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.folder_outlined,
                                          size: 14,
                                          color: renkSemasi.onSurface
                                              .withValues(alpha: 0.5)),
                                      const SizedBox(width: 4),
                                      Text(oge.kategori,
                                          style:
                                              const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  // Öncelik Rozeti
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          oncelikRengi.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      oge.oncelik.etiket,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: oncelikRengi,
                                      ),
                                    ),
                                  ),
                                  // Son Teslim Tarihi Rozeti (Varsa)
                                  if (oge.sonTarih != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          gecikti
                                              ? Icons.warning_amber_rounded
                                              : Icons.event_outlined,
                                          size: 14,
                                          color: gecikti
                                              ? renkSemasi.error
                                              : renkSemasi.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _tarihFormatla(oge.sonTarih!),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: gecikti
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: gecikti
                                                ? renkSemasi.error
                                                : renkSemasi.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: renkSemasi.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}