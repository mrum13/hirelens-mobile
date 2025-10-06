import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/bottomnav.dart';
import 'package:unsplash_clone/theme.dart';

//
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<Map<String, dynamic>> datas = [];

  // URGENT: Fetch feed datas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavbar(curIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Coming Soon..."),
                duration: Duration(milliseconds: 500),
              ),
            ),
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child:
            datas.isNotEmpty
                ? ListView.builder(
                  itemBuilder: (context, index) {
                    final data = datas[index];

                    return _Post(
                      vendorId: data['vendorId'],
                      vendorName: data['vendorName'],
                      itemName: data['itemName'],
                      itemId: data['itemId'],
                      images: data['images'],
                      createdAt: data['createdAt'],
                    );
                  },
                )
                : Center(child: Text("Belum ada post...")),
      ),
    );
  }
}

// ignore: must_be_immutable
class _Post extends StatelessWidget {
  int vendorId;
  String vendorName;
  String itemName;
  int itemId;
  int likes;
  List<String> images = [];
  String? caption;
  String createdAt;

  _Post({
    required this.vendorId,
    required this.vendorName,
    required this.itemName,
    required this.itemId,
    this.likes = 0,
    required this.images,
    this.caption,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      themeFromContext(context).colorScheme.primary,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Vendor Name",
                      style: themeFromContext(context).textTheme.displayMedium,
                    ),
                    Text(
                      "Item Name",
                      style: themeFromContext(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            // URGENT: If user was the author of the post, show this button
            IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
          ],
        ),
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: themeFromContext(context).colorScheme.primary,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    IconButton(
                      // URGENT: Create optimistic like logic
                      onPressed: () {},
                      icon: Icon(Icons.thumb_up_alt_outlined),
                    ),
                    Text(
                      likes.toString(),
                      style: themeFromContext(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                // URGENT: Create share to logic
                IconButton(onPressed: () {}, icon: Icon(Icons.share_outlined)),
              ],
            ),
            IconButton(
              onPressed: () => GoRouter.of(context).go('/item/detail/$itemId}'),
              icon: Icon(Icons.open_in_browser_outlined),
            ),
          ],
        ),
      ],
    );
  }
}
