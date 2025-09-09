import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const CheckoutSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<CheckoutSuccessPage> createState() => _CheckOutSuocessPageState();
}

class _CheckOutSuocessPageState extends State<CheckoutSuccessPage> {
  bool isLoading = true;

  Future<void> loadAndUpdateTransaction() async {
    final client = Supabase.instance.client;

    try {
      final transactionResponse =
          await client
              .from('transactions')
              .select()
              .eq('midtrans_order_id', widget.orderId)
              .single();

      final curTime = DateTime.now();
      final tglFoto = DateTime.parse(transactionResponse['tgl_foto']);
      final waktuFoto = DateTime.parse(transactionResponse['tgl_foto']);
      final schedule = DateTime(
        tglFoto.year,
        tglFoto.month,
        tglFoto.day,
        waktuFoto.hour,
        waktuFoto.minute,
      );

      final midtransTransactionInvoke = await client.functions.invoke(
        'sync-midtrans-transaction',
        body: {'midtrans_order_id': widget.orderId},
      );
      final midtransTransactionData =
          midtransTransactionInvoke.data as Map<String, dynamic>;

      await client
          .from('transactions')
          .update({
            'payment_method': midtransTransactionData['payment_type'],
            'status_payment':
                midtransTransactionData['transaction_status'] != 'settlement'
                    ? 'pending'
                    : transactionResponse['payment_type'] == 'panjar'
                    ? 'panjar_paid'
                    : 'complete',
            'status_work':
                curTime.compareTo(schedule) > 0 ? 'waiting' : 'pending',
          })
          .eq('midtrans_order_id', widget.orderId);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan! $e")));
    } finally {
      if (mounted && !isLoading) {
        await Future.delayed(const Duration(seconds: 3));
        GoRouter.of(context).go('/home');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadAndUpdateTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Pembayaran Berhasil!"),
          automaticallyImplyLeading: false,
        ),
        body:
            isLoading
                ? Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      Text("Mohon Tunggu..."),
                    ],
                  ),
                )
                : Center(
                  child: Text(
                    "Animasi dalam pengerjaan. Anda akan diarahkan kembali ke Halaman Utama dalam 3 detik",
                  ),
                ),
      ),
    );
  }
}
