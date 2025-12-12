import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController accountController = TextEditingController();
  String? bankNameValue;
  final List<String> paymentAccountOptions = [
    'BRI',
    'BNI',
    'BCA',
    'Gopay',
    'Shopee Pay',
    'Dana'
  ];

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final client = Supabase.instance.client;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', client.auth.currentUser!.id)
        .single();

    DMethod.log(response.toString(), prefix: "Profile Data");

    setState(() {
      // tagihanCount = response;
      _isLoading = false;
      nameController.text = response['full_name'];
      phoneController.text = response['phone'];
      bankNameValue = response['bank_name'];
      accountController.text = response['bank_account'];
    });
  }

  void editUserData() async {
    if (nameController.text == "" ||
        nameController.text.isEmpty ||
        phoneController.text == "" ||
        phoneController.text.isEmpty ||
        accountController.text == "" ||
        accountController.text.isEmpty ||
        bankNameValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Lengkapi form terlebih dahulu !",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    } else {
      try {
        setState(() {
          _isLoading = true;
        });
        final client = Supabase.instance.client;
        var res = await client.from('profiles').update({
          'full_name': nameController.text,
          'phone': phoneController.text,
          'bank_name': bankNameValue,
          'bank_account': accountController.text,
        }).eq('id', client.auth.currentUser!.id);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Profile berhasil diupdate",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        )
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        DMethod.log(e.toString(), prefix: "Update Data Message");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        child: _isLoading
            ? Center(child: const CircularProgressIndicator())
            : FilledButton(
                onPressed: () {
                  editUserData();
                },
                child: Text("Simpan")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Icon(
              Icons.person,
              size: 120,
            ),
            const SizedBox(
              height: 24,
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                  label: Text("Nama"),
                  isDense: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey))),
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                  label: Text("No. hp"),
                  isDense: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey))),
            ),
            const SizedBox(
              height: 8,
            ),
            DropdownButtonFormField<String>(
              value: bankNameValue,
              items: paymentAccountOptions
                  .map(
                    (payment) => DropdownMenuItem(
                      value: payment,
                      child: Text(payment),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  bankNameValue = value;
                });
              },
              decoration: InputDecoration(
                labelText: "Rekening / E-Wallet",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              controller: accountController,
              decoration: InputDecoration(
                  hint: Text("No. Rekening"),
                  isDense: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey))),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }
}
