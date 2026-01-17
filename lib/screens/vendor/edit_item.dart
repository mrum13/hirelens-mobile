import 'dart:io';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:unsplash_clone/components/image_picker_widget.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/services/image_upload_service.dart';
import 'package:unsplash_clone/theme.dart';
import 'package:http/http.dart' as http;

class EditItemPage extends StatefulWidget {
  const EditItemPage({super.key, required this.dataId});

  final String dataId;

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
  bool _isLoading = true;
  bool _isImageUpdated = false;
  File? _selectedImage;

  List imageGalleryApi = [];
  List imageBtsApi = [];

  bool _isGalleryUpdated = false;
  List<File> selectedImageGalleries = [];
  List<String> uploadedImageGalleryUrls = [];

  bool _isBtsUpdated = false;
  List<File> selectedImageBts = [];
  List<String> uploadedImageBtsUrls = [];

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _addressController.dispose();
  }

  Future<String> uploadImage(File imageFile) async {
    final bucket = 'items';
    final userId = Supabase.instance.client.auth.currentUser!.id;

    // ✅ Gunakan user ID di path untuk RLS policy
    final fileName =
        '$userId/thumbnails/${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';

    print('📁 Uploading to: $fileName');
    await Supabase.instance.client.storage.from(bucket).uploadBinary(
          fileName,
          await imageFile.readAsBytes(),
          fileOptions: const FileOptions(upsert: false),
        );

    final fileUrl = await Supabase.instance.client.storage
        .from(bucket)
        .createSignedUrl(fileName, 60 * 24 * 365 * 3);

    return fileUrl;
  }

  Future<String?> findVendorId() async {
    final client = Supabase.instance.client;
    try {
      final result = await client
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
    final curTime = DateTime.now();

    // ✅ FIX: Buat folder 'img' jika belum ada
    final imgDir = Directory('${tempDir.path}/img');
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }

    final response = await http.get(Uri.parse(url));

    final file = File(
      "${imgDir.path}/${curTime.year}${curTime.month}${curTime.day}${curTime.hour}${curTime.minute}${curTime.second}${curTime.millisecond}.jpg",
    );

    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  Future<void> _fetchAndSetData() async {
    final client = Supabase.instance.client;
    final response =
        await client.from('items').select().eq('id', widget.dataId).single();
    final responseGallery = await client
        .from('item_gallery')
        .select('*')
        .eq('item_id', widget.dataId);
    final responseBts =
        await client.from('item_bts').select('*').eq('item_id', widget.dataId);

    selectedImageGalleries.clear();
    selectedImageBts.clear();

    imageGalleryApi = responseGallery;
    imageBtsApi = responseBts;

    _nameController.text = response['name'];
    _addressController.text = response['address'];
    _descController.text = response['description'];

    // ✅ FIX: Convert price (num/double) ke String
    _priceController.text = response['price'].toString();

    final thumbnailFile = await _loadImageFromUrl(response['thumbnail']);

    for (var item in imageGalleryApi) {
      selectedImageGalleries.add(await _loadImageFromUrl(item['image_url']));
    }

    for (var item in imageBtsApi) {
      selectedImageBts.add(await _loadImageFromUrl(item['image_url']));
    }

    setState(() {
      // ✅ FIX: Cast ke List<dynamic> dulu, baru map
      durationList = (response['durations'] as List<dynamic>)
          .map((d) => d is int ? d : int.parse(d.toString()))
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

    if (_isGalleryUpdated) {
      if (selectedImageGalleries.isNotEmpty) {
        await uploadAllGallery(itemId: widget.dataId);
      }
    }

    if (_isBtsUpdated) {
      if (selectedImageBts.isNotEmpty) {
        await uploadAllBts(itemId: widget.dataId);
      }
    }

    data['name'] = _nameController.text.trim();
    data['price'] = _priceController.text.trim();
    data['address'] = _addressController.text.trim();
    data['description'] = _descController.text.trim();
    data['vendor_id'] = vendorId;
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

  Future<void> _deleteItem() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final supabase = Supabase.instance.client;
      await supabase.from('items').delete().eq('id', widget.dataId);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Items berhasil dihapus",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      GoRouter.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAndSetData();
  }

  Future<List<File>> pickMultipleImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 80);

    return picked.map((e) => File(e.path)).toList();
  }

  Future pickImagesGallery() async {
    selectedImageGalleries = await pickMultipleImages();
    _isGalleryUpdated = true;
    DMethod.log(selectedImageGalleries.toString(),
        prefix: "Selected Image Gallery");
    setState(() {});
  }

  Future pickImagesBts() async {
    selectedImageBts = await pickMultipleImages();
    _isBtsUpdated = true;
    DMethod.log(selectedImageBts.toString(), prefix: "Selected Image Gallery");
    setState(() {});
  }

  Future uploadAllGallery({required String itemId}) async {
    ImageUploadService imageUploadService = ImageUploadService();
    uploadedImageGalleryUrls = await imageUploadService.editMultipleImages(
        oldUrls: imageGalleryApi.map((e) => e['image_url'] as String).toList(),
        newImages: selectedImageGalleries,
        itemId: itemId,
        category: "gallery");
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload Gallery selesai!")),
    );
  }

  Future uploadAllBts({required String itemId}) async {
    ImageUploadService imageUploadService = ImageUploadService();
    uploadedImageBtsUrls = await imageUploadService.editMultipleImages(
        oldUrls: imageBtsApi.map((e) => e['image_url'] as String).toList(),
        newImages: selectedImageBts,
        itemId: itemId,
        category: "bts");
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Upload BTS selesai!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Scaffold(
            body: Center(
            child: CircularProgressIndicator(),
          ))
        : Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        Dialog(child: Image.file(_selectedImage!)),
                  );
                },
                child: Text(
                  'Edit Item',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
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
                          validator: (value) => value == null || value.isEmpty
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
                          validator: (value) => value == null || value.isEmpty
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
                          validator: (value) => value == null || value.isEmpty
                              ? 'Alamat wajib diisi'
                              : null,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        InkWell(
                          onTap: () {
                            pickImagesGallery();
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text("Upload image gallery"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Visibility(
                          visible:
                              selectedImageGalleries.isNotEmpty ? true : false,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount:
                                            selectedImageGalleries.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                                child: InkWell(
                                                  onTap: () => showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      child: Image.file(
                                                        selectedImageGalleries[
                                                            index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Image.file(
                                                    selectedImageGalleries[
                                                        index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedImageGalleries.clear();
                                          });
                                        },
                                        icon: Container(
                                            width: 36,
                                            height: 36,
                                            margin: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.amber),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Icon(
                                              Icons.delete,
                                              size: 24,
                                            )))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            pickImagesBts();
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text("Upload image BTS"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Visibility(
                          visible: selectedImageBts.isNotEmpty ? true : false,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: selectedImageBts.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                                child: InkWell(
                                                  onTap: () => showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        Dialog(
                                                      child: Image.file(
                                                        selectedImageBts[index],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Image.file(
                                                    selectedImageBts[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedImageBts.clear();
                                          });
                                        },
                                        icon: Container(
                                            width: 36,
                                            height: 36,
                                            margin: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.amber),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Icon(
                                              Icons.delete,
                                              size: 24,
                                            )))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 56,
                        ),
                        Text(
                          "Durasi",
                          style:
                              themeFromContext(context).textTheme.displayLarge,
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
                                  hintStyle: themeFromContext(context)
                                      .textTheme
                                      .bodySmall,
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
                                final List<int> tmp = durationList +
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
                                  color: themeFromContext(
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
                            child: Text("$duration Jam",
                                textAlign: TextAlign.start),
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
                              color: themeFromContext(context)
                                  .colorScheme
                                  .onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        MyFilledButton(
                          isLoading: _isLoading,
                          variant: MyButtonVariant.danger,
                          onTap: _deleteItem,
                          child: Text(
                            "Hapus",
                            style: TextStyle(
                              color:
                                  themeFromContext(context).colorScheme.onError,
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
