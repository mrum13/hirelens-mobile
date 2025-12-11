import 'dart:convert';

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unsplash_clone/api/midtrans_api.dart';

class MidtransApiPage extends StatelessWidget {
  const MidtransApiPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextButton(
              onPressed: () async {
                
              },
              child: Text("Refund Traksaksi"))
        ],
      ),
    );
  }
}
