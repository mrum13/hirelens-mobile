import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentPage extends StatelessWidget {
  final String snapToken;
  final bool? paySisa; // URGENT: utilize this option

  const PaymentPage({super.key, required this.snapToken, this.paySisa});

  @override
  Widget build(BuildContext context) {
    final clientKey = dotenv.env['MIDTRANS_CLIENT_KEY']!;
    final htmlContent = '''
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
            snap.pay('$snapToken', {
              onSuccess: function(result) {
                HirelensPayment.postMessage(JSON.stringify(result));
              },
              onPending: function(result) {
                HirelensPayment.postMessage(JSON.stringify(result));
              },
              onError: function(result) {
                HirelensPayment.postMessage(JSON.stringify(result));
              },
              onClose: function() {
                HirelensPayment.postMessage(JSON.stringify({status: 'closed'}));
              }
            });
          </script>
        </body>
      </html>
    ''';

    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest req) {
                if (req.url.startsWith("http://project-hirelens")) {
                  try {
                    final redirectUrl = Uri.parse(req.url);
                    final orderId = redirectUrl.queryParameters['order_id']!;
                    GoRouter.of(
                      context,
                    ).go('/checkout_success?order_id=$orderId');
                    return NavigationDecision.prevent;
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Terjadi kesalahan! $e")),
                    );
                  }
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.dataFromString(htmlContent, mimeType: 'text/html'));

    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
