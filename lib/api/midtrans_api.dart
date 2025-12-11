import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:d_method/d_method.dart';
import 'package:unsplash_clone/model/midtrans_model.dart';

class MidtransApi {
  var baseUrl = "https://api.sandbox.midtrans.com/v2";
  var serverKey = dotenv.env['MIDTRANS_SERVER_KEY'];
  
  Future<MidtransModel> refund({required String idOrder}) async {
    
    try {
      final basicAuth = 'Basic ${base64Encode(utf8.encode('$serverKey:'))}';
      var url = '$baseUrl/$idOrder/refund';
      var header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      };
      var body = jsonEncode({
        "refund_key": "refund-$idOrder",
        "amount": 1,
        "reason": "for some reason"
      });

      var response = await http.post(
        Uri.parse(url),
        headers: header,
        body: body
      );

      var data = jsonDecode(response.body);
      DMethod.log(data.toString(), prefix: "Status Transaction");
      return MidtransModel.fromJson(jsonDecode(data));
    } catch (e) {
      rethrow;
    }
  }
}
