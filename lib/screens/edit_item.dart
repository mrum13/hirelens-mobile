import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:unsplash_clone/components/image_picker_widget.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';
import 'package:http/http.dart' as http;

class EditItemPage extends StatefulWidget {
  const EditItemPage({super.key, required this.dataId});

  final int dataId;

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

// TODO: Vendor can upload image and behind the scene media (image and videos) in edit_item
class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _durasiController = TextEditingController();
  List<int> durationList = [];
  bool _isLoading = false;
  bool _isImageUpdated = false;
  File? _selectedImage;

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
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

  Future<File> _loadImageFromUrl(String url) async {
    final Directory tempDir = await getTemporaryDirectory();
    final tempDirPath = tempDir.path;
    final curTime = DateTime.now();

    final response = await http.get(Uri.parse(url));
    final file = File(
      "$tempDirPath/img/${curTime.year}${curTime.month}${curTime.day}${curTime.hour}${curTime.minute}${curTime.second}${curTime.millisecond}.jpg",
    );

    file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<void> _fetchAndSetData() async {
    final client = Supabase.instance.client;
    final response =
        await client.from('items').select().eq('id', widget.dataId).single();

    _nameController.text = response['name'];
    _addressController.text = response['address'];
    _descController.text = response['description'];
    _priceController.text = response['price'];
    final thumbnailFile = await _loadImageFromUrl(response['thumbnail']);

    setState(() {
      durationList =
          (response['durations'] as List<String>)
              .map((d) => int.parse(d))
              .toList();
      _selectedImage = thumbnailFile;
      _isLoading = false;
    });
  }

  Future<void> _updateItem() async {
    setState(() {
      _isLoading = true;
    });

    final client = Supabase.instance.client;
    final vendorId = await findVendorId();
    String? url;
    Map<String, dynamic> data = {};

    if (_isImageUpdated) {
      url = await uploadImage(_selectedImage!);
      data['thumbnail'] = url;
    }

    data['name'] = _nameController.text.trim();
    data['price'] = _priceController.text.trim();
    data['address'] = _addressController.text.trim();
    data['description'] = _descController.text.trim();
    data['vendor'] = vendorId;
    data['durations'] =
        durationList.map((duration) => duration.toString()).toList();

    try {
      await client.from('items').update(data).eq('id', widget.dataId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item berhasil disimpan!')));

      GoRouter.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan item: $e')));

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> _deleteItem() async {}

  @override
  void initState() {
    super.initState();
    _fetchAndSetData();
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
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
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
                        _isImageUpdated = true;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Item',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                    style: TextStyle(fontSize: 16),
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
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                    minLines: 3,
                    maxLines: 5,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 16),
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
                      labelStyle: TextStyle(fontSize: 16),
                    ),
                    style: TextStyle(fontSize: 16),
                    maxLines: 2,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
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
                          decoration: InputDecoration(
                            label: Text("Durasi (Jam)"),
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
                        onTap: () {
                          final value = _durasiController.text.trim();
                          final List<int> tmp =
                              durationList +
                              value
                                  .split(',')
                                  .map((v) => int.parse(v))
                                  .toList();
                          tmp.sort();

                          setState(() {
                            durationList = tmp;
                          });

                          _durasiController.clear();
                        },
                        child: Text(
                          "Tambah",
                          style: TextStyle(
                            color:
                                themeFromContext(
                                  context,
                                ).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...durationList.map(
                    (duration) => MyLinkButton(
                      variant: MyButtonVariant.secondary,
                      alignment: Alignment.centerLeft,
                      onTap: () {
                        final tmp = durationList;
                        tmp.remove(duration);

                        setState(() {
                          durationList = tmp;
                        });
                      },
                      child: Text("$duration Jam", textAlign: TextAlign.start),
                    ),
                  ),

                  const SizedBox(height: 32),
                  MyFilledButton(
                    isLoading: _isLoading,
                    variant: MyButtonVariant.primary,
                    onTap: _updateItem,
                    child: Text(
                      "Simpan",
                      style: TextStyle(
                        color: themeFromContext(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  MyFilledButton(
                    isLoading: _isLoading,
                    variant: MyButtonVariant.danger,
                    onTap: _updateItem,
                    child: Text(
                      "Hapus",
                      style: TextStyle(
                        color: themeFromContext(context).colorScheme.onError,
                      ),
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
