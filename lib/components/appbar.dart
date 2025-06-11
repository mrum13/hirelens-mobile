import 'package:flutter/material.dart';

// Custom AppBar as per TODO on line 52
class HomeCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCartPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onSearchPressed;

  const HomeCustomAppBar({
    super.key,
    required this.onCartPressed,
    required this.onProfilePressed,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Search bar (left)
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.search, color: Colors.grey, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Shopping cart (right)
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black),
            onPressed: onCartPressed,
            tooltip: 'Keranjang',
          ),
          // Profile (right)
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black),
            onPressed: onProfilePressed,
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
