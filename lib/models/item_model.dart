class ItemModel {
  final int id;
  final DateTime createdAt;
  final String name;
  final String? description;
  final String thumbnail;
  final int price;
  final String vendor;
  final String? verified_at;
  final String address;

  ItemModel({
    required this.id,
    required this.createdAt,
    required this.name,
    this.description,
    required this.thumbnail,
    required this.price,
    required this.vendor,
    this.verified_at,
    required this.address,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
    id: json['id'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    name: json['name'] as String,
    description: json['description'] as String?,
    thumbnail: json['thumbnail'] as String,
    price: json['price'] as int,
    vendor: json['vendor'] as String,
    verified_at: json['verified_at'] as String?,
    address: json['address'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'name': name,
    'description': description,
    'thumbnail': thumbnail,
    'price': price,
    'vendor': vendor,
    'verified_at': verified_at,
    'address': address,
  };
}
