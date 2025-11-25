import 'dart:convert';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatefulWidget {
  final String snapToken;
  final String orderId;
  final bool? paySisa;

  const PaymentPage({
    super.key,
    required this.snapToken,
    required this.orderId,
    this.paySisa,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  MidtransSDK? _midtrans;

  Future initSDK() async {
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: dotenv.env['MIDTRANS_CLIENT_KEY'] ?? "",
        merchantBaseUrl: dotenv.env['MIDTRANS_MERCHANT_BASE_URL'] ?? "",
        enableLog: true,
      ),
    );

    _midtrans!.setTransactionFinishedCallback((result) {
      DMethod.log(result.transactionId.toString() ,prefix: "Result Midtrans Transaction ID");
      DMethod.log(result.status.toString() ,prefix: "Result Midtrans Status");
      DMethod.log(result.message.toString() ,prefix: "Result Midtrans Message");
      DMethod.log(result.paymentType.toString() ,prefix: "Result Midtrans Payment Type");
    });
  }

  @override
  void initState() {
    super.initState();
    initSDK();
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DMethod.log("Payment Page");
    final clientKey = dotenv.env['MIDTRANS_CLIENT_KEY']!;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'HirelensPayment',
        onMessageReceived: (JavaScriptMessage message) {
          DMethod.log("💬 JavaScript Message: ${message.message}");
          final data = message.message;
          DMethod.log("💬 Payment Callback: $data");

          try {
            final jsonData = jsonDecode(data) as Map<String, dynamic>;
            final status = jsonData['status'];
            // final orderId = jsonData['order_id'] ?? '';

            switch (status) {
              case 'success':
                GoRouter.of(context)
                    .go('/checkout_success?order_id=${widget.orderId}');
                break;
              case 'pending':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pembayaran masih pending')),
                );
                Navigator.pop(context);
                break;
              case 'error':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terjadi kesalahan pembayaran')),
                );
                Navigator.pop(context);
                break;
              case 'closed':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Kamu menutup halaman pembayaran')),
                );
                Navigator.pop(context);
                break;
            }
          } catch (e) {
            DMethod.log("❌ Error decoding payment result: $e");
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest req) {
            DMethod.log(req.url, prefix: "🌐 NAVIGATE URL");

            // ✅ Tangkap default redirect Midtrans
            if (req.url.startsWith('http://example.com')) {
              DMethod.log("✅ Redirect ke example.com (selesai bayar)");

              // Tidak ada order_id di URL ini, jadi abaikan

              GoRouter.of(context)
                  .go('/checkout_success?order_id=${widget.orderId}');
              return NavigationDecision.prevent;
            }

            // ✅ Jika punya domain sendiri (opsional)
            if (req.url.startsWith('http://project-hirelens')) {
              // final redirectUrl = Uri.parse(req.url);
              // final orderId = redirectUrl.queryParameters['order_id'] ?? '';
              DMethod.log(
                  "✅ Redirect ke project-hirelens, order_id=${widget.orderId}");

              GoRouter.of(context)
                  .go('/checkout_success?order_id=${widget.orderId}');
              return NavigationDecision.prevent;
            }

            // ✅ Jika Midtrans menambahkan status_code (opsional)
            if (req.url.contains('status_code=')) {
              final uri = Uri.parse(req.url);
              final orderId = uri.queryParameters['order_id'] ?? '';
              DMethod.log("✅ Redirect dengan status_code, order_id=$orderId");

              GoRouter.of(context).go('/checkout_success?order_id=$orderId');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      // 🔥 hanya load HTML string (tidak perlu loadFlutterAsset)
      ..loadHtmlString('''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <script 
          type="text/javascript" 
          src="https://app.sandbox.midtrans.com/snap/snap.js" 
          data-client-key="$clientKey">
        </script>
      </head>
      <body>
        <script type="text/javascript">
          window.onload = function() {
            HirelensPayment.postMessage(JSON.stringify({status: 'test'}));
          };
          function startPayment() {
            console.log("🚀 Starting Snap Pay...");
            snap.pay('${widget.snapToken}', {
              onSuccess: function(result) {
                console.log("✅ Snap script loaded");
                console.log("📤 Sending message to Flutter...");
                HirelensPayment.postMessage(JSON.stringify({...result, status: 'success'}));
              },
              onPending: function(result) {
                HirelensPayment.postMessage(JSON.stringify({...result, status: 'pending'}));
              },
              onError: function(result) {
                HirelensPayment.postMessage(JSON.stringify({...result, status: 'error'}));
              },
              onClose: function() {
                HirelensPayment.postMessage(JSON.stringify({status: 'closed'}));
              }
            });
          }

          document.addEventListener("DOMContentLoaded", function() {
            setTimeout(startPayment, 1000);
          });
        </script>
      </body>
    </html>
  ''');

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: Center(
        child: Text("Payment Page"),
      ),
    );
  }
}
