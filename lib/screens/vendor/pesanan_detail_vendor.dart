import 'dart:developer';

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/api/midtrans_api.dart';
import 'package:unsplash_clone/helper.dart';
import 'package:unsplash_clone/model/midtrans_model.dart';
import 'package:unsplash_clone/theme.dart';

class PesananDetailVendorPage extends StatefulWidget {
  const PesananDetailVendorPage({super.key, required this.dataId});

  final String dataId;

  @override
  State<PesananDetailVendorPage> createState() =>
      _PesananDetailVendorPageState();
}

class _PesananDetailVendorPageState extends State<PesananDetailVendorPage>
    with RouteAware {
  bool isLoading = true;
  late Map<String, dynamic> data;
  TextEditingController linkPhotoController = TextEditingController();

  Future<void> fetchAndSetData() async {
    final client = Supabase.instance.client;
    DMethod.log("Fetch and Set Data");
    try {
      final response = await client
          .from('transactions')
          .select(
            "*, item_id(id, name, price, thumbnail, vendor_id(id, name))",
          )
          .eq('id', widget.dataId)
          .single();

      if (mounted) {
        setState(() {
          data = response;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan! $e")));
    }
  }

  Future<void> rejectOrder() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;

      try {
        await client
            .from('transactions')
            .update({'status_work': 'cancel'}).eq('id', widget.dataId);

        await fetchAndSetData();
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan!")));
      }

      // MidtransModel refundStatus =
      //     await MidtransApi().refund(idOrder: widget.dataId);

      // if (refundStatus.statusCode == 200) {
      //   try {
      //     await client
      //         .from('transactions')
      //         .update({'status_work': 'cancel'}).eq('id', widget.dataId);

      //     await fetchAndSetData();
      //   } catch (e) {
      //     setState(() {
      //       isLoading = false;
      //     });
      //     ScaffoldMessenger.of(
      //       context,
      //     ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan!")));
      //   }
      // } else {
      //   setState(() {
      //     isLoading = false;
      //   });
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(SnackBar(content: Text(refundStatus.message)));
      // }
    }
  }

  Future<void> acceptOrder() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;
      try {
        await client
            .from('transactions')
            .update({'status_work': 'waiting'}).eq('id', widget.dataId);

        await fetchAndSetData();
      } catch (e) {
        log((e as PostgrestException).message);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan!")));
      }
    }
  }

  Future<void> finishTaking() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;

      final response = await client
          .from('transactions')
          .update({'status_work': 'editing'})
          .eq('id', widget.dataId)
          .select();

      if (response.isEmpty) {
        // Tidak ada row yang terupdate
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Update gagal: data tidak ditemukan.")),
          );
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Berhasil
        setState(() {
          isLoading = false;
        });
        DMethod.log("Update berhasil: $response");
        await fetchAndSetData(); // Refresh data
      }

      // fetchAndSetData();
    }
  }

  Future<void> finishEditing() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;
      await client
          .from('transactions')
          .update({
            'status_work': 'post_processing',
            'status_url_photos': 'pending'
          }).eq('id', widget.dataId);

      fetchAndSetData();
    }
  }

  Future<void> completeOrder() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      final client = Supabase.instance.client;
      await client.from('transactions').update({
        'status_work': 'complete',
        'url_photos': linkPhotoController.text.trim(),
        'photos_uploaded_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', widget.dataId);

      fetchAndSetData();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
    linkPhotoController.addListener(() {
      setState(() {}); // <-- trigger rebuild
    });
  }

  // FIXME: Why it's not refreshing the page
  @override
  void didPopNext() {
    super.didPopNext();
    fetchAndSetData();
  }

  num _calculateSisa(num price, int durasi, int payed, int transactionFee) {
    final subtotal = (price * durasi) + transactionFee;
    return subtotal - payed;
  }

  int _calculateTransactionFee(num price, int durasi, bool? isPanjar) {
    if (isPanjar == true) {
      return (((((price * durasi) * 0.3) + ((price * durasi) * 0.7)) * 0.025))
          .round();
    }

    return ((price * durasi) * 0.025).round();
  }

  Widget buildConfirmationBar(String workStatus, String payoutStatus) {
    switch (workStatus) {
      case 'pending':
        return SlideAction(
          sliderRotate: false,
          text: "Geser untuk menerima pesanan",
          textStyle: themeFromContext(context).textTheme.displaySmall,
          sliderButtonIconPadding: 12,
          submittedIcon: Icon(Icons.check),
          innerColor: themeFromContext(context).colorScheme.primary,
          outerColor: themeFromContext(context).colorScheme.onPrimary,
          onSubmit: () async {
            if (!mounted) return;
            Future.delayed(const Duration(seconds: 3)).then(
              (value) async {
                await acceptOrder();
              },
            );
          },
        );
      case 'waiting':
        return SlideAction(
          sliderRotate: false,
          text: "Geser untuk memproses pesanan (editing)",
          textStyle: themeFromContext(context).textTheme.displaySmall,
          sliderButtonIconPadding: 12,
          submittedIcon: Icon(Icons.check),
          innerColor: themeFromContext(context).colorScheme.primary,
          outerColor: themeFromContext(context).colorScheme.onPrimary,
          onSubmit: () async {
            if (!mounted) return;
            Future.delayed(const Duration(seconds: 3)).then(
              (value) async {
                await finishTaking();
              },
            );
          },
        );
      case 'editing':
        return SlideAction(
          sliderRotate: false,
          text: "Geser untuk memproses pesanan (post processing)",
          textStyle: themeFromContext(context).textTheme.displaySmall,
          sliderButtonIconPadding: 12,
          submittedIcon: Icon(Icons.check),
          innerColor: themeFromContext(context).colorScheme.primary,
          outerColor: themeFromContext(context).colorScheme.onPrimary,
          onSubmit: () async {
            if (!mounted) return;
            Future.delayed(const Duration(seconds: 3)).then(
              (value) async {
                await finishEditing();
              },
            );
          },
        );
      case 'post_processing':
        return SlideAction(
          sliderRotate: false,
          text: "Geser untuk menyelesaikan pesanan",
          textStyle: themeFromContext(context).textTheme.displaySmall,
          sliderButtonIconPadding: 12,
          submittedIcon: Icon(Icons.check),
          innerColor: themeFromContext(context).colorScheme.primary,
          outerColor: themeFromContext(context).colorScheme.onPrimary,
          onSubmit: () async {
            if (!mounted) return;
            Future.delayed(const Duration(seconds: 3)).then(
              (value) async {
                await completeOrder();
              },
            );
          },
        );
      case 'complete':
        return Center(child: Text("Dalam proses penyelesaian orderan"));
      case 'cancel':
        return Center(child: Text("Orderan dicancel"));
      default:
        return Center(child: Text(payoutStatus=="complete"?"Order Selesai, silahkan cek rekening":"Dalam proses verifikasi payout"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                "Rincian Pesanan",
                style: themeFromContext(context).textTheme.displayMedium,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              ),
            ),
            bottomNavigationBar: SizedBox(
              // height: 100,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: (data['status_work'] == "post_processing" &&
                              data['status_payment'] == "panjar_paid")
                          ? true
                          : false,
                      child: Center(child: Text("Orderan belum dibayar lunas oleh customer"))
                    ),
                    Visibility(
                        visible: (data['status_work'] == 'post_processing' &&
                                data['status_payment'] == 'complete')
                            ? true
                            : false,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: linkPhotoController,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  label: Text("Link Foto"),
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(
                              height: 16,
                            )
                          ],
                        )),
                    Visibility(
                        visible: (data['status_work'] == "post_processing" &&
                                linkPhotoController.text.isEmpty)
                            ? false
                            : true,
                        child: buildConfirmationBar(data['status_work'],data['status_payout'])),
                    const SizedBox(
                      height: 8,
                    ),
                    Visibility(
                      visible: data['status_work'] == 'pending' ? true : false,
                      child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Yakin mau menolak pesanan ?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          rejectOrder();
                                        },
                                        child: Text("Ya")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Tidak"))
                                  ],
                                );
                              },
                            );
                          },
                          child: Text("Tolak pesanan")),
                    )
                  ],
                ),
              ),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  "Tanggal Pesan : ${DateFormat('EEEE, dd MMMM yyyy, hh:mm').format(DateTime.parse(data['created_at'] as String))}",
                                ),
                                Text(
                                  "Tanggal Bayar : ${DateFormat('EEEE, dd MMMM yyyy, hh:mm').format(DateTime.parse(data['created_at'] as String))}",
                                ),
                              ],
                            ),
                            Divider(height: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  "Tipe Pembayaran : ${data['payment_type']}",
                                ),
                                Text(
                                  "Metode Pembayaran : ${data['payment_method']}",
                                ),
                              ],
                            ),
                            Divider(height: 32),
                            _ItemDescription(
                              name: data['item_id']['name'],
                              vendor: data['item_id']['vendor_id']['name'],
                              price: data['item_id']['price'],
                              thumbnail: data['item_id']['thumbnail'],
                            ),
                            Divider(height: 32),
                            Text(
                              "Detail Pembayaran",
                              style: themeFromContext(
                                context,
                              ).textTheme.displayMedium,
                            ),
                            SizedBox(height: 32),
                            Column(
                              spacing: 16,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Harga Item :"),
                                    Text(
                                      "${formatCurrency(data['item_id']['price'])} x ${data['durasi']}",
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Transaction Fee (2,5%) :"),
                                    Text(
                                      formatCurrency(
                                        _calculateTransactionFee(
                                          data['item_id']['price'],
                                          data['durasi'],
                                          data['payment_type'] != 'full_paid',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Dibayar :"),
                                    Text(
                                      formatCurrency(
                                        data['amount'].round(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Sisa :"),
                                    Text(
                                      formatCurrency(
                                        _calculateSisa(
                                          data['item_id']['price'],
                                          data['durasi'],
                                          data['amount'].round(),
                                          _calculateTransactionFee(
                                            data['item_id']['price'],
                                            data['durasi'],
                                            data['payment_type'] != 'full_paid',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Subtotal :",
                                      style: themeFromContext(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    Text(
                                      formatCurrency(
                                        (data['item_id']['price'] *
                                                data['durasi']) +
                                            _calculateTransactionFee(
                                              data['item_id']['price'],
                                              data['durasi'],
                                              data['payment_type'] !=
                                                  'full_paid',
                                            ),
                                      ),
                                      style: themeFromContext(
                                        context,
                                      ).textTheme.displayLarge,
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: (data['status_work']=="post_processing" || data['status_work']=="complete" || data['status_work']=="finish") ? true:false,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Status Link Hasil :"),
                                      Text(
                                        data['status_url_photos'] ?? "-"
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          );
  }
}

class _ItemDescription extends StatelessWidget {
  const _ItemDescription({
    required this.name,
    required this.vendor,
    required this.price,
    required this.thumbnail,
  });

  final String name;
  final String vendor;
  final num price;
  final String thumbnail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      height: 120,
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              thumbnail,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name.length < 18 ? name : "${name.substring(0, 18)}...",
                style: themeFromContext(context).textTheme.displayMedium,
              ),
              Text(
                "Dari $vendor",
                style: themeFromContext(context).textTheme.bodyMedium,
              ),
              Spacer(),
              Text(
                formatCurrency(price),
                style: themeFromContext(context).textTheme.displayMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
