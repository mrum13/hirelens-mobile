import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/core/auth/auth_flags.dart';
import 'package:unsplash_clone/main.dart' show routeObserver;
import 'package:unsplash_clone/screens/cart.dart';
import 'package:unsplash_clone/screens/customer/checkout.dart' as checkout;
import 'package:unsplash_clone/screens/checkout_success.dart';
import 'package:unsplash_clone/screens/vendor/create_item.dart';
import 'package:unsplash_clone/screens/customer/edit_profile_page.dart';
import 'package:unsplash_clone/screens/vendor/edit_item.dart';
import 'package:unsplash_clone/screens/forgot_password_page.dart';
import 'package:unsplash_clone/screens/home.dart';
import 'package:unsplash_clone/screens/loading.dart';
import 'package:unsplash_clone/screens/change_password_page.dart';
import 'package:unsplash_clone/screens/payment.dart';
import 'package:unsplash_clone/screens/customer/pesanan_detail_customer.dart';
import 'package:unsplash_clone/screens/vendor/pesanan_vendor.dart';
import 'package:unsplash_clone/screens/vendor/pesanan_detail_vendor.dart';
import 'package:unsplash_clone/screens/customer/pesanan_customer.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';
import 'package:unsplash_clone/screens/opening.dart';
import 'package:unsplash_clone/screens/login.dart';
import 'package:unsplash_clone/screens/register.dart';
import 'package:unsplash_clone/screens/reset_password.dart';
import 'package:unsplash_clone/screens/search_result.dart';
import 'package:unsplash_clone/screens/vendor_detail_page.dart';
import 'package:unsplash_clone/screens/verify_registration.dart';
import 'package:unsplash_clone/screens/customer/product_detail.dart';
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
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordPage()
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordPage(),
    ),
    GoRoute(path: "/register", builder: (context, state) => RegisterPage()),
    GoRoute(
      path: "/verify_registration",
      builder: (context, state) => VerifyRegistrationPage(
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

    GoRoute(path: "/feed", builder: (context, state) => FeedPage()),
    GoRoute(
      path: '/search',
      builder: (context, state) =>
          SearchResultPage(keyword: state.uri.queryParameters['keyword']!),
    ),

    GoRoute(
      path: "/vendor/kelola_item",
      builder: (context, state) => KelolaItemPage(),
    ),
    // ✅ UBAH INI - Hapus int.parse()
    GoRoute(
      path: "/vendor/kelola_item/edit/:dataId",
      builder: (context, state) =>
          EditItemPage(dataId: state.pathParameters['dataId']!),
    ),
    GoRoute(
      path: "/vendor/kelola_item/create",
      builder: (context, state) => CreateItemPage(),
    ),

    GoRoute(
      path: "/vendor/pesanan",
      builder: (context, state) =>
          PesananVendorPage(filter: state.uri.queryParameters['filter']),
    ),

    // ✅ UBAH INI - Tergantung apakah pesanan juga pakai UUID atau int
    GoRoute(
      path: "/vendor/pesanan-detail/:dataId",
      builder: (context, state) => PesananDetailVendorPage(
        dataId: state.pathParameters['dataId']!, // Ubah ke String dulu
      ),
    ),

    GoRoute(
      path: "/customer/pesanan",
      builder: (context, state) =>
          PesananCustomerPage(filter: state.uri.queryParameters['filter']),
    ),

    // ✅ UBAH INI
    GoRoute(
      path: "/customer/pesanan/:dataId",
      builder: (context, state) => PesananDetailCustomerPage(
        dataId: state.pathParameters['dataId']!, // Ubah ke String dulu
      ),
    ),

    // ✅ UBAH INI
    GoRoute(
      path: "/item/detail/:dataId",
      builder: (context, state) => ProductDetailPage(
        dataId: state.pathParameters['dataId']!, // Ubah ke String dulu
      ),
    ),

    // ✅ UBAH INI
    GoRoute(
      path: "/checkout/:dataId",
      builder: (context, state) =>
          checkout.CheckoutPage(dataId: state.pathParameters['dataId']!),
    ),

    GoRoute(
      path: "/payment/:snapToken/:orderId",
      builder: (context, state) => PaymentPage(
        snapToken: state.pathParameters['snapToken']!,
        orderId: state.pathParameters['orderId']!,
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
      path: '/change-password-page',
      builder: (context, state) {
        return ChangePasswordPage();
      },
    ),
    GoRoute(
      path: '/vendor-detail-page/:dataId',
      builder: (context, state) {
        return VendorDetailPage(
          idVendor: state.pathParameters['dataId']!,
        );
      },
    ),
    GoRoute(
      path: '/edit-profile/:role',
      builder: (context, state) {
        return EditProfilePage(role: state.pathParameters['role']!,);
      },
    ),
  ],
  initialLocation: '/',
  redirect: (ctx, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final loc = state.matchedLocation;

    final onLogin = loc == '/login';
    final onRegister = loc == '/register';
    final onVerify = loc == '/verify_registration';
    final onOpening = loc == '/opening';
    final onPreload = loc == '/';
    final onResetPassword = loc.startsWith('/reset-password');
    final onForgotPassword = loc == '/forgot-password';

      // 🔑 PENTING: SAAT PASSWORD RECOVERY
  if (isPasswordRecovery.value && !onResetPassword) {
    return '/reset-password';
  }

    if (user == null &&
        !(onLogin ||
            onRegister ||
            onVerify ||
            onOpening ||
            onPreload ||
            onResetPassword ||
            onForgotPassword)) {
      return '/login';
    }
    if (user != null &&
        (onLogin || onRegister || onVerify || onOpening || onPreload)) {
      return '/home';
    }

    return null;
  },
  observers: [routeObserver],
);
