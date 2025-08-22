import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBottomNavbar extends StatelessWidget {
  const MyBottomNavbar({super.key, required this.curIndex});

  final int curIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (tabIndex) {
        switch (tabIndex) {
          case 0:
            GoRouter.of(context).replace('/home');
            break;
          case 1:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Coming Soon"),
                duration: Duration(milliseconds: 350),
                showCloseIcon: true,
              ),
            );
            break;
          case 2:
            GoRouter.of(context).replace('/profile');
            break;
        }
      },
      currentIndex: curIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.movie_filter_outlined),
          activeIcon: Icon(Icons.movie_filter),
          label: "Feed",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}
