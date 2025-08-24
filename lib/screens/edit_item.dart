import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
// import 'package:provider/provider.dart';
// import 'package:unsplash_clone/providers/user_provider.dart';
import 'dart:io';
import 'package:unsplash_clone/components/image_picker_widget.dart';

class EditItemPage extends StatefulWidget {
  const EditItemPage({super.key, required this.dataId});
  final int dataId;

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late int dataId;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;

  void fetchAndSetData() async {
    dataId = widget.dataId;
    final client = Supabase.instance.client;

    try {
      final data =
          await client.from('items').select().eq('id', dataId).single();

      if (data.isEmpty) {
        throw Exception('Product not found');
      }

      setState(() {
        _nameController.value = TextEditingValue(text: data['name']);
        _descController.value = TextEditingValue(text: data['description']);
        _priceController.value = TextEditingValue(
          text: (data['price'] as num).toString(),
        );
        _addressController.value = TextEditingValue(text: data['address']);

        _isLoading = false;
      });
    } catch (e) {
      mounted
          ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error while fetching data details: $e")),
          )
          : null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetData();
  }

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

    final fullPath = await Supabase.instance.client.storage
        .from(bucket)
        .uploadBinary(
          fileName,
          await imageFile.readAsBytes(),
          fileOptions: const FileOptions(upsert: false),
        );

    return fullPath;
  }

  // TODO: Refactor this function to actually update data
  Future<void> updateItem({
    required int dataId,
    required String name,
    required String thumbnail,
    required int price,
    required String address,
    String description = '',
  }) async {
    try {
      await Supabase.instance.client
          .from('items')
          .update({
            'name': name,
            'thumbnail': thumbnail,
            'price': price,
            'address': address,
            'description': description,
          })
          .eq('id', dataId)
          .select()
          .single();
    } on PostgrestException catch (e) {
      log('Insert failed: ${e.message}');
      rethrow;
    }
  }

  Future<void> _updateItem() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final path = await uploadImage(_selectedImage!);
      // final fileId = await getFileId('item-thumbnails', path);
      await updateItem(
        dataId: dataId,
        name: _nameController.text,
        address: _addressController.text,
        price: int.parse(_priceController.text),
        thumbnail: path,
        description: _descController.text,
      );
      // Optionally show success
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item berhasil disimpan')));
      Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Item',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
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
                                _updateItem();
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
    );
  }
}
