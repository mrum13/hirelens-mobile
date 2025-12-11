import 'package:equatable/equatable.dart';

class MidtransModel extends Equatable {
  final int statusCode;
  final String message;

  const MidtransModel({
    required this.statusCode,
    required this.message
  });

  factory MidtransModel.fromJson(Map<String, dynamic> json) =>
    MidtransModel(
      statusCode: json["status_code"],
      message: json["message"],
    );
  
  @override
  List<Object?> get props => [
    statusCode, message
  ];

  
}