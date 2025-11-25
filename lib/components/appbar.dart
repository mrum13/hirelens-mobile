import 'package:flutter/material.dart';

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
    return SafeArea(
      bottom: false,
      child: Container(
        height: 48,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: onCartPressed,
              tooltip: 'Keranjang',
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
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
