import 'package:flutter/material.dart';

// Custom AppBar as per TODO on line 52

class HomeCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCartPressed;
  final VoidCallback onProfilePressed;

  const HomeCustomAppBar({
    super.key,
    required this.onCartPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Use a Container instead of AppBar to avoid any onScroll color shift
    return SafeArea(
      bottom: false,
      child: Container(
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white,
        child: Row(
          children: [
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
              ),
              onPressed: onCartPressed,
              tooltip: 'Keranjang',
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.black),
              onPressed: onProfilePressed,
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
