class AltGorev {
  final String id;
  final String baslik;
  final bool tamamlandi;

  const AltGorev({
    required this.id,
    required this.baslik,
    this.tamamlandi = false,
  });

  AltGorev copyWith({
    String? id,
    String? baslik,
    bool? tamamlandi,
  }) {
    return AltGorev(
      id: id ?? this.id,
      baslik: baslik ?? this.baslik,
      tamamlandi: tamamlandi ?? this.tamamlandi,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'baslik': baslik,
        'tamamlandi': tamamlandi,
      };

  factory AltGorev.fromMap(Map<String, dynamic> map) => AltGorev(
        id: map['id'] as String,
        baslik: map['baslik'] as String,
        tamamlandi: map['tamamlandi'] as bool? ?? false,
      );
}