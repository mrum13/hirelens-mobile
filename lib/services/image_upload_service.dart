import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageUploadService {
  Future<List<String>> uploadMultipleImages(
    List<File> images, {
    required String itemId, // tambahkan itemId
  }) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser!.id;

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
  }
}
