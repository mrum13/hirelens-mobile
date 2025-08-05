import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
// import 'package:provider/provider.dart';
// import 'package:unsplash_clone/providers/user_provider.dart';
import 'dart:io';
import 'package:unsplash_clone/components/image_picker_widget.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<String> uploadImage(File imageFile) async {
    final bucket = 'item-thumbnails';
    final fileName =
        'item_thumbnails/${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';

    await Supabase.instance.client.storage
        .from(bucket)
        .uploadBinary(
          fileName,
          await imageFile.readAsBytes(),
          fileOptions: const FileOptions(upsert: false),
        );

    final fileUrl = await Supabase.instance.client.storage
        .from(bucket)
        .createSignedUrl(fileName, 60 * 24 * 365 * 3);

    return fileUrl;
  }

  Future<int?> findVendorId() async {
    final client = Supabase.instance.client;
    try {
      final result =
          await client
              .from('vendors')
              .select('id')
              .eq('user_id', client.auth.currentUser!.id)
              .single();

      return result['id'];
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar((SnackBar(content: Text("Failed to find vendor ID!"))));
    }

    return null;
  }

  Future<void> insertNewItem({
    required String name,
    required String thumbnail,
    required int price,
    required String address,
    String description = '',
  }) async {
    try {
      final vendorId = await findVendorId();

      final result =
          await Supabase.instance.client
              .from('items')
              .insert({
                'name': name,
                'thumbnail': thumbnail,
                'price': price,
                'address': address,
                'description': description,
                'vendor': vendorId,
              })
              .select()
              .single();

      // result is Map<String, dynamic> – your inserted row
      final String newRowId = (result['id'] as int).toString();
      print('Inserted row ID: $newRowId');
    } on PostgrestException catch (e) {
      print('Insert failed: ${e.message}');
      rethrow;
    }
  }

  Future<void> _createItem() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = await uploadImage(_selectedImage!);
      await insertNewItem(
        name: _nameController.text,
        address: _addressController.text,
        price: int.parse(_priceController.text),
        thumbnail: url,
        description: _descController.text,
      );
      // Optionally show success
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item berhasil disimpan')));
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => KelolaItemPage()));
    } catch (e) {
      print('Create item error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan item: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Buat Item Baru',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Item',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Nama item wajib diisi'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thumbnail',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ImagePickerWidget(
                    initialImage: _selectedImage,
                    enabled: !_isLoading,
                    onImageSelected: (file) {
                      setState(() {
                        _selectedImage = file;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Harga wajib diisi'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Alamat wajib diisi'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 41, 41),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  _createItem();
                                }
                              },
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
