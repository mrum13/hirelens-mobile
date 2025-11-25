import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:unsplash_clone/components/image_picker_widget.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

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
  final TextEditingController _durasiController = TextEditingController();
  List<int> durationList = [];
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _durasiController.dispose();
    super.dispose();
  }

  Future<String> uploadImage(File imageFile) async {
    final bucket = 'items';
    final userId = Supabase.instance.client.auth.currentUser!.id;

    // ✅ Gunakan user ID di path untuk RLS policy
    final fileName =
        '$userId/thumbnails/${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';

    print('📁 Uploading to: $fileName');

    try {
      await Supabase.instance.client.storage.from(bucket).uploadBinary(
            fileName,
            await imageFile.readAsBytes(),
            fileOptions: const FileOptions(upsert: false),
          );

      // ✅ Gunakan public URL (lebih baik dari signed URL)
      final fileUrl =
          Supabase.instance.client.storage.from(bucket).getPublicUrl(fileName);

      print('✅ File uploaded: $fileUrl');
      return fileUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      rethrow;
    }
  }

  Future<String?> findVendorId() async {
    final client = Supabase.instance.client;
    try {
      final result = await client
          .from('vendors')
          .select('id')
          .eq('user_id', client.auth.currentUser!.id)
          .single();

      print('✅ Vendor ID found: ${result['id']}');
      return result['id'] as String;
    } catch (e) {
      print('❌ Error finding vendor ID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menemukan vendor ID: $e")),
        );
      }
    }

    return null;
  }

  Future<void> _createItem() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
      );
      return;
    }

    if (durationList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal 1 durasi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image
      print('📤 Uploading image...');
      final url = await uploadImage(_selectedImage!);
      print('✅ Image uploaded: $url');

      // Find vendor ID
      print('🔍 Finding vendor ID...');
      final vendorId = await findVendorId();

      if (vendorId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vendor ID tidak ditemukan')),
          );
        }
        return;
      }

      // Parse price
      final price = double.tryParse(_priceController.text.trim());
      if (price == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harga harus berupa angka valid')),
          );
        }
        return;
      }

      // Insert to database
      print('💾 Inserting item to database...');
      await Supabase.instance.client.from('items').insert({
        'name': _nameController.text.trim(),
        'thumbnail': url,
        'price': price,
        'address': _addressController.text.trim(),
        'description': _descController.text.trim(),
        'vendor_id': vendorId, // ✅ Database aktual menggunakan 'vendor_id'
        'durations':
            durationList.map((duration) => duration.toString()).toList(),
      });

      print('✅ Item created successfully!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Item berhasil disimpan! Menunggu verifikasi dari Admin Hirelens',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        GoRouter.of(context).pop();
      }
    } catch (e) {
      print('❌ Error creating item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan item: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addDuration() {
    final value = _durasiController.text.trim();

    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan durasi terlebih dahulu')),
      );
      return;
    }

    try {
      final List<int> newDurations = value
          .split(',')
          .map((v) => int.parse(v.trim()))
          .where((v) => v > 0) // Filter nilai > 0
          .toList();

      if (newDurations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Durasi harus berupa angka positif')),
        );
        return;
      }

      final List<int> tmp = [...durationList, ...newDurations];
      tmp.sort();

      setState(() {
        durationList = tmp.toSet().toList(); // Hapus duplikat
      });

      _durasiController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format durasi tidak valid')),
      );
    }
  }

  void _removeDuration(int duration) {
    setState(() {
      durationList.remove(duration);
    });
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
          'Buat Item Baru',
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImagePickerWidget(
                  initialImage: _selectedImage,
                  enabled: !_isLoading,
                  height: 240,
                  onImageSelected: (file) {
                    setState(() {
                      _selectedImage = file;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Nama Item',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama item wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 16),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Harga wajib diisi';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Harga harus berupa angka';
                    }
                    if (double.parse(value.trim()) <= 0) {
                      return 'Harga harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  style: const TextStyle(fontSize: 16),
                  maxLines: 2,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Alamat wajib diisi'
                      : null,
                ),
                const Divider(height: 56),
                Text(
                  "Durasi",
                  style: themeFromContext(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _durasiController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          label: const Text("Durasi (Jam)"),
                          hintText:
                              "Gunakan ',' untuk memasukkan lebih dari 1 durasi",
                          hintStyle:
                              themeFromContext(context).textTheme.bodySmall,
                          hintMaxLines: 2,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    MyFilledButton(
                      width: 96,
                      variant: MyButtonVariant.secondary,
                      onTap: _isLoading ? null : _addDuration,
                      child: Text(
                        "Tambah",
                        style: TextStyle(
                          color:
                              themeFromContext(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (durationList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Belum ada durasi ditambahkan',
                      style: themeFromContext(context).textTheme.bodySmall,
                    ),
                  ),
                ...durationList.map(
                  (duration) => MyLinkButton(
                    variant: MyButtonVariant.secondary,
                    alignment: Alignment.centerLeft,
                    onTap: _isLoading ? null : () => _removeDuration(duration),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "$duration Jam",
                          textAlign: TextAlign.start,
                        ),
                        const Spacer(),
                        if (!_isLoading)
                          const Icon(Icons.close, size: 16, color: Colors.red),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                MyFilledButton(
                  isLoading: _isLoading,
                  variant: MyButtonVariant.primary,
                  onTap: _isLoading ? null : _createItem,
                  child: Text(
                    _isLoading ? "Menyimpan..." : "Simpan",
                    style: TextStyle(
                      color: themeFromContext(context).colorScheme.onPrimary,
                    ),
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
