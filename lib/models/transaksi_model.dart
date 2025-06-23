enum PaymentProgress { zero, twenty, thirty, fifty, full }

PaymentProgress paymentProgressFromString(String value) {
  switch (value) {
    case '0%':
      return PaymentProgress.zero;
    case '20%':
      return PaymentProgress.twenty;
    case '30%':
      return PaymentProgress.thirty;
    case '50%':
      return PaymentProgress.fifty;
    case '100%':
      return PaymentProgress.full;
    default:
      throw Exception('Unknown payment progress: $value');
  }
}

String paymentProgressToString(PaymentProgress progress) {
  switch (progress) {
    case PaymentProgress.zero:
      return '0%';
    case PaymentProgress.twenty:
      return '20%';
    case PaymentProgress.thirty:
      return '30%';
    case PaymentProgress.fifty:
      return '50%';
    case PaymentProgress.full:
      return '100%';
  }
}

class TransaksiModel {
  final int id;
  final DateTime createdAt;
  final int itemId;
  final String paymentMethod;
  final bool isFullpay;
  final String durasi;
  final String? userId;
  final PaymentProgress paymentProgress;
  final DateTime tglFoto;
  final String waktuFoto;

  TransaksiModel({
    required this.id,
    required this.createdAt,
    required this.itemId,
    required this.paymentMethod,
    required this.isFullpay,
    required this.durasi,
    this.userId,
    required this.paymentProgress,
    required this.tglFoto,
    required this.waktuFoto,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) => TransaksiModel(
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    itemId: json['item_id'] as int,
    paymentMethod: json['payment_method'] as String,
    isFullpay: json['is_fullpay'] as bool,
    durasi: json['durasi'] as String,
    userId: json['user_id'] as String?,
    paymentProgress: paymentProgressFromString(
      json['payment_progress'] as String,
    ),
    tglFoto: DateTime.parse(json['tgl_foto'] as String),
    waktuFoto: json['waktu_foto'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'item_id': itemId,
    'payment_method': paymentMethod,
    'is_fullpay': isFullpay,
    'durasi': durasi,
    'user_id': userId,
    'payment_progress': paymentProgressToString(paymentProgress),
    'tgl_foto': tglFoto.toIso8601String(),
    'waktu_foto': waktuFoto,
  };
}
