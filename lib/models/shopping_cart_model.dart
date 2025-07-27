class ShoppingCartModel {
  final int id;
  final DateTime createdAt;
  final int itemId;
  final String userId;

  ShoppingCartModel({
    required this.id,
    required this.createdAt,
    required this.itemId,
    required this.userId,
  });

  factory ShoppingCartModel.fromJson(Map<String, dynamic> json) =>
      ShoppingCartModel(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        itemId: json['item_id'] as int,
        userId: json['user_id'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'item_id': itemId,
    'user_id': userId,
  };
}
