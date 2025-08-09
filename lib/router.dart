import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/screens/cart.dart';
import 'package:unsplash_clone/screens/checkout.dart';
import 'package:unsplash_clone/screens/create_item.dart';
import 'package:unsplash_clone/screens/edit_item.dart';
import 'package:unsplash_clone/screens/home.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:unsplash_clone/screens/product_detail.dart';
import 'package:unsplash_clone/screens/profile.dart';
import 'package:unsplash_clone/screens/vendor_profile.dart';

// LATER: You need to refactor the whole project to use this code
// LATER: Create and implement layout for each pages

final router = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => LoginPage()),
    GoRoute(path: "/home", builder: (context, state) => HomePage()),
    GoRoute(path: "/cart", builder: (context, state) => CartPage()),
    GoRoute(path: "/profile", builder: (context, state) => ProfilePage()),
    GoRoute(path: "/vendor", builder: (context, state) => VendorProfilePage()),
    // TODO: Create VendorDetailPage
    // GoRoute(path: "/vendor/detail/:dataId", builder: (context, state) => VendorDetailPage(dataId: int.parse(state.pathParameters['dataId']!))),
    GoRoute(
      path: "/vendor/kelola_item",
      builder: (context, state) => KelolaItemPage(),
    ),
    GoRoute(
      path: "/vendor/kelola_item/edit/:dataId",
      builder:
          (context, state) =>
              EditItemPage(dataId: int.parse(state.pathParameters['dataId']!)),
    ),
    GoRoute(
      path: "/vendor/kelola_item/create",
      builder: (context, state) => CreateItemPage(),
    ),
    GoRoute(
      path: "/item/detail/:dataId",
      builder:
          (context, state) => ProductDetailPage(
            dataId: int.parse(state.pathParameters['dataId']!),
          ),
    ),
    GoRoute(
      path: "/checkout/:dataId",
      builder:
          (context, state) =>
              CheckoutPage(dataId: int.parse(state.pathParameters['dataId']!)),
    ),
  ],
);
