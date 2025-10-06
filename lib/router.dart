import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
import 'package:unsplash_clone/screens/cart.dart';
import 'package:unsplash_clone/screens/checkout.dart';
import 'package:unsplash_clone/screens/checkout_success.dart';
import 'package:unsplash_clone/screens/create_item.dart';
import 'package:unsplash_clone/screens/edit_item.dart';
import 'package:unsplash_clone/screens/home.dart';
import 'package:unsplash_clone/screens/loading.dart';
import 'package:unsplash_clone/screens/payment.dart';
import 'package:unsplash_clone/screens/pesanan_detail_customer.dart';
import 'package:unsplash_clone/screens/pesanan_vendor.dart';
import 'package:unsplash_clone/screens/pesanan_detail_vendor.dart';
import 'package:unsplash_clone/screens/pesanan_customer.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';
import 'package:unsplash_clone/screens/opening.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:unsplash_clone/screens/register.dart';
import 'package:unsplash_clone/screens/reset_password.dart';
import 'package:unsplash_clone/screens/search_result.dart';
import 'package:unsplash_clone/screens/verify_registration.dart';
import 'package:unsplash_clone/screens/product_detail.dart';
import 'package:unsplash_clone/screens/profile.dart';
import 'package:unsplash_clone/screens/feed.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoadingScreen()),
    GoRoute(
      path: '/opening',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: OpeningPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade to black then fade from black
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final fadeValue = (animation.value - 0.5) * 2.0;
                return FadeTransition(
                  opacity: AlwaysStoppedAnimation(fadeValue),
                  child: child,
                );
              },
            );
          },
          transitionDuration: Duration(milliseconds: 2650),
        );
      },
    ),
    GoRoute(path: "/login", builder: (context, state) => LoginPage()),
    GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
    GoRoute(
      path: "/verify_registration",
      builder:
          (context, state) => VerifyRegistrationPage(
            email: (state.uri.queryParameters['email'] as String),
          ),
    ),

    GoRoute(
      path: "/home",
      pageBuilder: (context, state) => NoTransitionPage(child: HomePage()),
    ),
    GoRoute(path: "/cart", builder: (context, state) => CartPage()),
    GoRoute(
      path: "/profile",
      pageBuilder: (context, state) => NoTransitionPage(child: ProfilePage()),
    ),

    // TODO: Create VendorDetailPage
    // GoRoute(path: "/vendor/detail/:dataId", builder: (context, state) => VendorDetailPage(dataId: int.parse(state.pathParameters['dataId']!))),

    // URGENT: Create feed table on Supabase
    GoRoute(path: "/feed", builder: (context, state) => FeedPage()),
    GoRoute(
      path: '/search',
      builder:
          (context, state) =>
              SearchResultPage(keyword: state.uri.queryParameters['keyword']!),
    ),

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
      path: "/vendor/pesanan",
      builder:
          (context, state) =>
              PesananVendorPage(filter: state.uri.queryParameters['filter']),
    ),

    GoRoute(
      path: "/vendor/pesanan/:dataId",
      builder:
          (context, state) => PesananDetailVendorPage(
            dataId: int.parse(state.pathParameters['dataId']!),
          ),
    ),

    GoRoute(
      path: "/customer/pesanan",
      builder:
          (context, state) =>
              PesananCustomerPage(filter: state.uri.queryParameters['filter']),
    ),

    GoRoute(
      path: "/customer/pesanan/:dataId",
      builder:
          (context, state) => PesananDetailCustomerPage(
            dataId: int.parse(state.pathParameters['dataId']!),
          ),
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
      path: "/payment/:snapToken",
      builder:
          (context, state) => PaymentPage(
            snapToken: state.pathParameters['snapToken']!,
            paySisa: (state.uri.queryParameters['pay_sisa'] as bool?),
          ),
    ),

    GoRoute(
      path: '/checkout_success',
      builder: (context, state) {
        return CheckoutSuccessPage(
          orderId: state.uri.queryParameters['order_id']!,
        );
      },
    ),
    GoRoute(
      path: '/reset_password',
      builder: (context, state) {
        return ResetPasswordPage(email: state.uri.queryParameters['email']);
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
    final onOpening = loc == '/opening';
    final onPreload = loc == '/';
    final onResetPassword = loc.startsWith('/reset_password');

    if (!logged &&
        !(onLogin ||
            onRegister ||
            onOpening ||
            onVerifyRegistration ||
            onPreload ||
            onResetPassword)) {
      return '/';
    }

    if (logged &&
        (onLogin || onRegister || onOpening || onVerifyRegistration)) {
      return '/home';
    }

    return null;
  },
  observers: [routeObserver],
);
