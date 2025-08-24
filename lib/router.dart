import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
import 'package:unsplash_clone/screens/cart.dart';
import 'package:unsplash_clone/screens/checkout.dart';
import 'package:unsplash_clone/screens/checkout_success.dart';
import 'package:unsplash_clone/screens/create_item.dart';
import 'package:unsplash_clone/screens/edit_item.dart';
import 'package:unsplash_clone/screens/home.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';
import 'package:unsplash_clone/screens/loading.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:unsplash_clone/screens/register.dart';
import 'package:unsplash_clone/screens/verify_registration.dart';
import 'package:unsplash_clone/screens/product_detail.dart';
import 'package:unsplash_clone/screens/profile.dart';
import 'package:unsplash_clone/screens/vendor_profile.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoadingScreen()),
    GoRoute(path: "/login", builder: (context, state) => LoginPage()),
    GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
    GoRoute(
      path: "/verify_registration",
      builder:
          (context, state) => VerifyRegistrationPage(
            email: state.uri.queryParameters['email']!,
          ),
    ),
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
    GoRoute(
      path: '/checkout_success',
      builder: (context, state) {
        final orderId = state.uri.queryParameters['order_id'];
        final result = state.uri.queryParameters['result'];
        return CheckoutSuccessPage(orderId: orderId!, result: result!);
      },
    ),
  ],
  initialLocation: '/',
  redirect: (ctx, state) {
    final logged = Supabase.instance.client.auth.currentSession != null;
    final loc = state.matchedLocation;

    final onLogin = loc == '/login';
    final onRegister = loc == '/register';
    final onVerifyRegistration = loc == '/verify_registration';
    final onSplash = loc == '/';

    // Not logged in → allow only '/', '/login', '/register'
    if (!logged &&
        !(onLogin || onRegister || onSplash || onVerifyRegistration)) {
      return '/';
    }

    // Logged in → prevent '/', '/login', '/register'
    if (logged && (onLogin || onRegister || onSplash || onVerifyRegistration)) {
      return '/home';
    }

    return null;
  },
  observers: [routeObserver],
);
