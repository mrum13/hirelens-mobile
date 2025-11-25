import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const CheckoutSuccessPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<CheckoutSuccessPage> createState() => _CheckoutSuccessPageState();
}

class _CheckoutSuccessPageState extends State<CheckoutSuccessPage> {
  bool isLoading = true;

  Future<void> loadAndUpdateTransaction() async {
    final client = Supabase.instance.client;

    try {
      final transactionResponse = await client
          .from('transactions')
          .select()
          .eq('midtrans_order_id', widget.orderId)
          .single();

      final curTime = DateTime.now();
      final tglFoto = DateTime.parse(transactionResponse['tgl_foto']);
      // final waktuFoto = DateTime.parse(transactionResponse['waktu_foto']); // ✅ FIX: Pakai 'waktu_foto' bukan 'tgl_foto'
      final schedule = DateTime(
        tglFoto.year,
        tglFoto.month,
        tglFoto.day,
        // waktuFoto.hour,
        // waktuFoto.minute,
      );

      final midtransTransactionInvoke = await client.functions.invoke(
        'sync-midtrans-transaction',
        body: {'midtrans_order_id': widget.orderId},
      );
      final midtransTransactionData =
          midtransTransactionInvoke.data as Map<String, dynamic>;

      // DMethod.log(midtransTransactionData.keys.toString(),prefix: "Checkout Success Midtrans Transactions Data");
      DMethod.log(midtransTransactionData['payment_type'],prefix: "Checkout Success Payment Type");
      DMethod.log(midtransTransactionData['transaction_status'],prefix: "Checkout Success Transactions Status");


      await client.from('transactions').update({
        'payment_type': midtransTransactionData['payment_type'],
        'status_payment':
            midtransTransactionData['transaction_status'] != 'settlement'
                ? 'pending'
                : transactionResponse['payment_type'] == 'panjar'
                    ? 'panjar_paid'
                    : 'complete',
        'status_work': curTime.compareTo(schedule) > 0 ? 'waiting' : 'pending',
      }).eq('midtrans_order_id', widget.orderId);

      // ✅ FIX: Cek mounted sebelum setState
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ✅ FIX: Delay dan navigate dengan mounted check
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return; // ✅ Cek mounted sebelum pakai context

      GoRouter.of(context).go('/home');
    } catch (e) {
      // ✅ FIX: Cek mounted sebelum pakai context
      if (!mounted) return;
      DMethod.log('Terjadi Kesalahan : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan! $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // loadAndUpdateTransaction();
    redirect();
  }

  void redirect() async {
          // ✅ FIX: Delay dan navigate dengan mounted check
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return; // ✅ Cek mounted sebelum pakai context

      GoRouter.of(context).go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Pembayaran Berhasil!"),
          automaticallyImplyLeading: false,
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Mohon Tunggu..."),
                  ],
                ),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    "Animasi dalam pengerjaan. Anda akan diarahkan kembali ke Halaman Utama dalam 3 detik",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
    );
  }
}
