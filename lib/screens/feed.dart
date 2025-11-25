import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/bottomnav.dart';
import 'package:unsplash_clone/theme.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _setupRealtimeSubscription();
  }

  // Load posts dari database
  Future<void> _loadPosts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await _supabase.from('posts').select('''
            id,
            caption,
            created_at,
            item_id,
            vendor:vendors!posts_vendor_id_fkey (
              id,
              name
            ),
            item:items!posts_item_id_fkey (
              id,
              name
            )
          ''').order('created_at', ascending: false);

      // Get images untuk setiap post
      List<Map<String, dynamic>> postsWithData = [];

      for (var post in response) {
        // Get images dari item_gallery
        final images = await _supabase
            .from('item_gallery')
            .select('image_url')
            .eq('item_id', post['item_id'])
            .order('created_at');

        // Count likes
        final likesData = await _supabase
            .from('post_likes')
            .select('id')
            .eq('post_id', post['id']);

        final likesCount = likesData.length;

        // Check if current user liked this post
        bool isLiked = false;
        bool isSaved = false;
        final currentUserId = _supabase.auth.currentUser?.id;

        if (currentUserId != null) {
          // Check like status
          final userLike = await _supabase
              .from('post_likes')
              .select('id')
              .eq('post_id', post['id'])
              .eq('user_id', currentUserId)
              .maybeSingle();

          isLiked = userLike != null;

          // Check saved status
          final userSaved = await _supabase
              .from('saved_posts')
              .select('id')
              .eq('post_id', post['id'])
              .eq('user_id', currentUserId)
              .maybeSingle();

          isSaved = userSaved != null;
        }

        postsWithData.add({
          'postId': post['id'],
          'vendorId': post['vendor']['id'],
          'vendorName': post['vendor']['name'],
          'itemId': post['item']['id'],
          'itemName': post['item']['name'],
          'caption': post['caption'],
          'createdAt': post['created_at'],
          'images': images.map((img) => img['image_url'] as String).toList(),
          'likes': likesCount,
          'isLiked': isLiked,
          'isSaved': isSaved,
        });
      }

      setState(() {
        posts = postsWithData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error loading posts: $e');
    }
  }

  // Setup realtime subscription untuk update otomatis
  void _setupRealtimeSubscription() {
    _supabase
        .channel('posts_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'posts',
          callback: (payload) {
            _loadPosts(); // Reload posts ketika ada perubahan
          },
        )
        .subscribe();
  }

  // Toggle like
  Future<void> _toggleLike(String postId, bool currentlyLiked) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like posts')),
      );
      return;
    }

    try {
      if (currentlyLiked) {
        // Unlike
        await _supabase
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      } else {
        // Like
        await _supabase.from('post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
      }

      // Refresh posts
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Toggle save
  Future<void> _toggleSave(String postId, bool currentlySaved) async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save posts')),
      );
      return;
    }

    try {
      if (currentlySaved) {
        // Unsave
        await _supabase
            .from('saved_posts')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from saved'),
            duration: Duration(milliseconds: 800),
          ),
        );
      } else {
        // Save
        await _supabase.from('saved_posts').insert({
          'post_id': postId,
          'user_id': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to your collection'),
            duration: Duration(milliseconds: 800),
          ),
        );
      }

      // Refresh posts
      _loadPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavbar(curIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create post page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Coming Soon..."),
              duration: Duration(milliseconds: 500),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: $errorMessage'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPosts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.feed_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada post...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Jadilah yang pertama membuat post!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPosts,
                        child: ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];

                            return _Post(
                              postId: post['postId'],
                              vendorId: post['vendorId'],
                              vendorName: post['vendorName'],
                              itemName: post['itemName'],
                              itemId: post['itemId'],
                              likes: post['likes'] ?? 0,
                              isLiked: post['isLiked'] ?? false,
                              isSaved: post['isSaved'] ?? false,
                              images: List<String>.from(post['images'] ?? []),
                              caption: post['caption'],
                              createdAt: post['createdAt'],
                              onLikePressed: () => _toggleLike(
                                post['postId'],
                                post['isLiked'] ?? false,
                              ),
                              onSavePressed: () => _toggleSave(
                                post['postId'],
                                post['isSaved'] ?? false,
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  @override
  void dispose() {
    _supabase.removeChannel(_supabase.channel('posts_changes'));
    super.dispose();
  }
}

class _Post extends StatelessWidget {
  final String postId;
  final String vendorId;
  final String vendorName;
  final String itemName;
  final String itemId;
  final int likes;
  final bool isLiked;
  final bool isSaved;
  final List<String> images;
  final String? caption;
  final String createdAt;
  final VoidCallback onLikePressed;
  final VoidCallback onSavePressed;

  const _Post({
    required this.postId,
    required this.vendorId,
    required this.vendorName,
    required this.itemName,
    required this.itemId,
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
    required this.images,
    this.caption,
    required this.createdAt,
    required this.onLikePressed,
    required this.onSavePressed,
  });

  String _formatTimeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Vendor info)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        themeFromContext(context).colorScheme.primary,
                    child: Text(
                      vendorName.isNotEmpty ? vendorName[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorName,
                        style:
                            themeFromContext(context).textTheme.displayMedium,
                      ),
                      Row(
                        children: [
                          Text(
                            itemName,
                            style:
                                themeFromContext(context).textTheme.bodySmall,
                          ),
                          Text(
                            ' • ${_formatTimeAgo(createdAt)}',
                            style: themeFromContext(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.share),
                            title: const Text('Share'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implement share
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.report),
                            title: const Text('Report'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implement report
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.more_horiz),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 240,
              color: Colors.grey[300],
              child: images.isNotEmpty
                  ? Image.network(
                      images[0],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // Actions (Like, Share, Save, Open)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Like button
                  Row(
                    children: [
                      IconButton(
                        onPressed: onLikePressed,
                        icon: Icon(
                          isLiked
                              ? Icons.thumb_up_alt
                              : Icons.thumb_up_alt_outlined,
                          color: isLiked ? Colors.blue : null,
                        ),
                      ),
                      Text(
                        likes.toString(),
                        style: themeFromContext(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  // Share button
                  IconButton(
                    onPressed: () {
                      // TODO: Implement share functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share coming soon...'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                  ),
                ],
              ),
              Row(
                children: [
                  // Save button
                  IconButton(
                    onPressed: onSavePressed,
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.amber : null,
                    ),
                  ),
                  // Open detail button
                  IconButton(
                    onPressed: () =>
                        GoRouter.of(context).push('/item/detail/$itemId'),
                    icon: const Icon(Icons.open_in_browser_outlined),
                  ),
                ],
              ),
            ],
          ),

          // Caption (optional)
          if (caption != null && caption!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: RichText(
                text: TextSpan(
                  style: themeFromContext(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: '$vendorName ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: caption!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          const Divider(),
        ],
      ),
    );
  }
}
