import 'package:flutter/material.dart';
import 'package:unsplash_clone/components/item_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TopBarDelegate(minExtent: 80, maxExtent: 145),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 16,
                itemBuilder: (context, index) {
                  return ItemCard(
                    thumbnailUrl:
                        'https://randomuser.me/api/portraits/men/$index.jpg',
                    title: 'Item ${index + 1}',
                    subtitle: 'Subtitle ${index + 1}',
                    price: '\$${(index + 1) * 10}',
                    isFavorite: false,
                    onFavoritePressed: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopBarDelegate extends SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;

  TopBarDelegate({required this.minExtent, required this.maxExtent});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double percent = (1 - (shrinkOffset / (maxExtent - minExtent))).clamp(
      0.0,
      1.0,
    );

    final double avatarSize = 60 * percent + 32 * (1 - percent);
    final double opacity = percent;

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // Profile picture (top, shrinks as you scroll)
              Positioned(
                top: 16 + 40 * (1 - percent),
                left: 0,
                child: Opacity(
                  opacity: opacity,
                  child: CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/1.jpg',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hello, User!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_bag_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.search_outlined),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.person_outline_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant TopBarDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent;
  }
}
