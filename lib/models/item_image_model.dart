class ItemImageModel {
  final int id;
  final DateTime createdAt;
  final int itemId;
  final String image;
  final String? title;
  final String? subtitle;

  ItemImageModel({
    required this.id,
    required this.createdAt,
    required this.itemId,
    required this.image,
    this.title,
    this.subtitle,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) => ItemImageModel(
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    itemId: json['item_id'] as int,
    image: json['image'] as String,
    title: json['title'] as String?,
    subtitle: json['subtitle'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'item_id': itemId,
    'image': image,
    'title': title,
    'subtitle': subtitle,
  };
}
