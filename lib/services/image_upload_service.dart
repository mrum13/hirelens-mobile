import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageUploadService {
  Future<void> _deleteByPublicUrl(String url) async {
    final client = Supabase.instance.client;

    final uri = Uri.parse(url);
    final filePath = uri.path.split('/storage/v1/object/public/items/').last;

    await client.storage.from('items').remove([filePath]);
  }

  Future<List<String>> editMultipleImages({
    required List<String> oldUrls,
    required List<File> newImages,
    required String itemId,
    required String category,
  }) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    final List<String> finalUrls = [];

    // 1️⃣ Delete old images
    for (final url in oldUrls) {
      await _deleteByPublicUrl(url);
    }

    // 2️⃣ Delete old DB rows
    final table = category == 'gallery' ? 'item_gallery' : 'item_bts';
    await client.from(table).delete().eq('item_id', itemId);

    // 3️⃣ Upload new images
    for (final image in newImages) {
      final fileName =
          '$userId/$category/${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';

      await client.storage.from('items').uploadBinary(
            fileName,
            await image.readAsBytes(),
          );

      final url = client.storage.from('items').getPublicUrl(fileName);
      finalUrls.add(url);

      await client.from(table).insert({
        'item_id': itemId,
        'image_url': url,
      });
    }

    return finalUrls;
  }

  Future<List<String>> uploadMultipleImages(List<File> images,
      {required String itemId, // tambahkan itemId
      required String category}) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

    if (category == "gallery") {
      List<String> urls = [];

      for (var image in images) {
        final fileName =
            '$userId/gallery/${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';

        // Upload ke Supabase Storage
        await client.storage.from('items').uploadBinary(
              fileName,
              await image.readAsBytes(),
              fileOptions: const FileOptions(upsert: false),
            );

        final url = client.storage.from('items').getPublicUrl(fileName);
        urls.add(url);

        // Simpan ke table item_gallery
        await client.from('item_gallery').insert({
          'item_id': itemId,
          'image_url': url,
        });
      }

      return urls;
    } else {
      List<String> urls = [];

      for (var image in images) {
        final fileName =
            '$userId/bts/${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';

        // Upload ke Supabase Storage
        await client.storage.from('items').uploadBinary(
              fileName,
              await image.readAsBytes(),
              fileOptions: const FileOptions(upsert: false),
            );

        final url = client.storage.from('items').getPublicUrl(fileName);
        urls.add(url);

        // Simpan ke table item_gallery
        await client.from('item_bts').insert({
          'item_id': itemId,
          'image_url': url,
        });
      }

      return urls;
    }
  }
}
