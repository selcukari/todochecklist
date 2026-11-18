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
    final gecikti = oge.geciktiMi;

    return Dismissible(
      key: ValueKey(oge.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: renkSemasi.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: renkSemasi.onErrorContainer,
        ),
      ),
      onDismissed: (_) => onSilindi(),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: gecikti ? renkSemasi.error : renkSemasi.outlineVariant,
            width: gecikti ? 1.2 : 0.8,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onTap: onDuzenle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          leading: Checkbox(
            value: oge.tamamlandi,
            onChanged: (val) => onDurumDegisti(val ?? false),
          ),
          title: Text(
            oge.baslik,
            style: TextStyle(
              decoration: oge.tamamlandi ? TextDecoration.lineThrough : null,
              color:
                  oge.tamamlandi ? renkSemasi.outline : renkSemasi.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Kategori Bilgisi
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_outlined,
                        size: 14, color: renkSemasi.outline),
                    const SizedBox(width: 4),
                    Text(oge.kategori, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                // Öncelik Rozeti
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: oncelikRengi.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    oge.oncelik.etiket,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                        color: gecikti ? renkSemasi.error : renkSemasi.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _tarihFormatla(oge.sonTarih!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              gecikti ? FontWeight.bold : FontWeight.normal,
                          color:
                              gecikti ? renkSemasi.error : renkSemasi.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            size: 20,
            color: renkSemasi.outline,
          ),
        ),
      ),
    );
  }
}