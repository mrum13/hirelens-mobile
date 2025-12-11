import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/item_card.dart';

class VendorDetailPage extends StatefulWidget {
  final String idVendor;

  const VendorDetailPage({super.key, required this.idVendor});

  @override
  State<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends State<VendorDetailPage> {
  ///vendorData
  String name = "-";
  String phone = "-";
  String email = "-";
  String city = "-";

  List<Map<String, dynamic>> itemData = [];

  Future<bool> getVendorData() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('vendors')
        .select()
        .eq('id', widget.idVendor)
        .maybeSingle();

    DMethod.log("Vendors Data = $response");

    if (response != null) {
      setState(() {
        name = response['name'];
        phone = response['phone'];
        email = response['email'];
        city = response['city'];
      });
    }

    return response != null;
  }

  Future<bool> getItemVendorData() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('items')
        .select()
        .eq('vendor_id', widget.idVendor)
        .order('created_at', ascending: false);

    DMethod.log("Item Data = $response");

    if (response != null) {
      setState(() {
        itemData = response;
      });
    }

    return response != null;
  }

  @override
  void initState() {
    super.initState();
    getVendorData();
    getItemVendorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Icon(
                Icons.person_pin,
                color: Colors.white,
                size: 120,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 36,
                      ),
                      Text(
                        "Phone",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        phone,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.email,
                        size: 36,
                      ),
                      Text("Email", style: TextStyle(fontSize: 12)),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_city,
                        size: 36,
                      ),
                      Text("Lokasi", style: TextStyle(fontSize: 12)),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        city,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  itemCount: itemData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing:20,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    return ItemCard(
                      id: itemData[index]['id'], 
                      name: itemData[index]['name'], 
                      vendor: name, 
                      price: itemData[index]['price'],
                      thumbnail: itemData[index]['thumbnail'], 
                      description: itemData[index]['description'], 
                      onTapHandler: (){}
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
