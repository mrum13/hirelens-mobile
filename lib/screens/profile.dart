import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/components/bottomnav.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  late User userData;

  void fetchUserData() async {
    final client = Supabase.instance.client;
    userData = client.auth.currentUser!;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyBottomNavbar(curIndex: 2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _ProfileHeader(
                displayName:
                    (userData.userMetadata!['displayName'] as String).length >
                            18
                        ? "${(userData.userMetadata!['displayName'] as String).substring(0, 18)}..."
                        : userData.userMetadata!['displayName'],
                email: userData.email!,
                profileImage:
                    (userData.userMetadata!['profileImage'] as String?) ??
                    "https://ui-avatars.com/api/?background=6777cc&color=fff&name=${userData.userMetadata!['displayName'].toUpperCase()}",
                role: userData.userMetadata!['role'],
              ),

              userData.userMetadata!['role'] == 'vendor'
                  ? _VendorMenuSection()
                  : _CustomerMenuSection(),

              SizedBox(height: 32),

              _InformationSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profileImage,
    required this.displayName,
    required this.email,
    required this.role,
  });

  final String profileImage;
  final String displayName;
  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(profileImage),
              ),
              Positioned(
                bottom: -8,
                left: -4,
                child: GestureDetector(
                  // onTap: _onChangeProfilePicture,
                  child: Container(
                    height: 24,
                    width: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          role == 'vendor'
                              ? themeFromContext(
                                context,
                              ).colorScheme.secondaryContainer
                              : themeFromContext(
                                context,
                              ).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      "${role[0].toUpperCase()}${role.substring(1)}",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            role == 'vendor'
                                ? themeFromContext(
                                  context,
                                ).colorScheme.onSecondaryContainer
                                : themeFromContext(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                displayName.length > 24
                    ? "${displayName.substring(0, 24)}..."
                    : displayName,
                style: themeFromContext(context).textTheme.displayMedium,
              ),
              Opacity(
                opacity: 0.5,
                child: Text(
                  email,
                  style: themeFromContext(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerMenuSection extends StatelessWidget {
  const _CustomerMenuSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap:
                  () => GoRouter.of(
                    context,
                  ).push('/customer/pesanan?filter=pending'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.receipt, size: 24),
                    Text("Tagihan", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap:
                  () => GoRouter.of(
                    context,
                  ).push('/customer/pesanan?filter=processing'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.movie_edit, size: 24),
                    Text("Diproses", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap:
                  () => GoRouter.of(
                    context,
                  ).push('/customer/pesanan?filter=complete'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.history_outlined, size: 24),
                    Text("Riwayat", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorMenuSection extends StatelessWidget {
  const _VendorMenuSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => GoRouter.of(context).push('/vendor/kelola_item'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.list_alt_outlined, size: 24),
                    Text("Kelola Item", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => GoRouter.of(context).push('/vendor/pesanan'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.inbox_outlined, size: 24),
                    Text("Pesanan", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap:
                  () => GoRouter.of(
                    context,
                  ).push('/vendor/pesanan?filter=processing'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.movie_edit, size: 24),
                    Text("Diproses", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap:
                  () => GoRouter.of(
                    context,
                  ).push('/vendor/pesanan?filter=complete'),
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(Icons.price_check_outlined, size: 24),
                    Text("Payout", textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationSection extends StatelessWidget {
  const _InformationSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: ListTile(
              leading: Icon(Icons.privacy_tip, size: 24),
              title: Text(
                "Syarat & Ketentuan",
                style: themeFromContext(context).textTheme.displayMedium,
              ),
              subtitle: Text("Syarat dan ketentuan terkait layanan kami."),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {},
            child: ListTile(
              leading: Icon(Icons.info, size: 24),
              title: Text(
                "Versi Aplikasi",
                style: themeFromContext(context).textTheme.displayMedium,
              ),
              subtitle: Text("Versi : ${dotenv.env['APP_VERSION'] ?? 'dev'}"),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (ctx) => AlertDialog(
                      title: Text("Apakah anda yakin ingin keluar?"),
                      actions: [
                        Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: MyFilledButton(
                                variant: MyButtonVariant.neutral,
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Tidak"),
                              ),
                            ),
                            Expanded(
                              child: MyFilledButton(
                                variant: MyButtonVariant.primary,
                                onTap: () async {
                                  final client = Supabase.instance.client;

                                  await client.auth.signOut();

                                  while (GoRouter.of(context).canPop() ==
                                      true) {
                                    GoRouter.of(context).pop();
                                  }

                                  GoRouter.of(context).pushReplacement('/');
                                },
                                child: Text(
                                  "Ya",
                                  style: TextStyle(
                                    color:
                                        themeFromContext(
                                          context,
                                        ).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
              );
            },
            child: ListTile(
              leading: Icon(Icons.logout, size: 24, color: Colors.red),
              title: Text(
                "Keluar",
                style: themeFromContext(
                  context,
                ).textTheme.displayMedium!.copyWith(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
