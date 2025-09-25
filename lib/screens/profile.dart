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

class _ProfilePageState extends State<ProfilePage> with RouteAware {
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

  // TODO: find a way to refresh customer and vendor menu section
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

class _CustomerMenuSection extends StatefulWidget {
  const _CustomerMenuSection();

  @override
  State<_CustomerMenuSection> createState() => _CustomerMenuSectionState();
}

class _CustomerMenuSectionState extends State<_CustomerMenuSection> {
  int tagihanCount = 0;
  int diprosesCount = 0;
  bool badgeCountReady = false;

  Future<void> countTagihan() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('transactions')
        .count()
        .eq('user_id', client.auth.currentUser!.id)
        .eq('status_payment', 'pending');

    tagihanCount = response;
  }

  Future<void> countDiproses() async {
    final client = Supabase.instance.client;

    final response = await client
        .from('transactions')
        .count()
        .eq('user_id', client.auth.currentUser!.id)
        .or('status_work.eq.editing,status_work.eq.post_processing')
        .or('status_payment.eq.panjar_paid,status_payment.eq.complete');

    diprosesCount = response;
  }

  @override
  void initState() {
    super.initState();
    countTagihan();
    countDiproses();
    setState(() {
      badgeCountReady = true;
    });
  }

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
                    Badge(
                      isLabelVisible:
                          badgeCountReady
                              ? tagihanCount > 0
                                  ? true
                                  : false
                              : false,
                      label:
                          badgeCountReady
                              ? Text(tagihanCount.toString())
                              : null,
                      offset: Offset(16, -12),
                      child: Icon(Icons.receipt, size: 24),
                    ),
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
                    Badge(
                      isLabelVisible:
                          badgeCountReady
                              ? diprosesCount > 0
                                  ? true
                                  : false
                              : false,
                      label:
                          badgeCountReady
                              ? Text(diprosesCount.toString())
                              : null,
                      offset: Offset(16, -12),
                      child: Icon(Icons.movie_edit, size: 24),
                    ),
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

class _VendorMenuSection extends StatefulWidget {
  const _VendorMenuSection();

  @override
  State<_VendorMenuSection> createState() => _VendorMenuSectionState();
}

class _VendorMenuSectionState extends State<_VendorMenuSection> {
  int pesananCount = 0;
  int diprosesCount = 0;
  int payoutCount = 0;
  bool badgeCountReady = false;

  Future<int> fetchVendorId() async {
    final client = Supabase.instance.client;

    final response =
        await client
            .from('vendors')
            .select('id')
            .eq('user_id', client.auth.currentUser!.id)
            .single();

    return response['id'] as int;
  }

  Future<void> countPesanan() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();

    final response = await client
        .from('transactions')
        .count()
        .eq('vendor_id', vendorId)
        .or('status_work.eq.editing,status_work.eq.post_processing')
        .or('status_payment.eq.panjar_paid,status_payment.eq.complete');

    pesananCount = response;
  }

  Future<void> countDiproses() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();

    final response = await client
        .from('transactions')
        .count()
        .eq('vendor_id', vendorId)
        .or('status_work.eq.editing,status_work.eq.post_processing')
        .or('status_payment.eq.panjar_paid,status_payment.eq.complete');

    diprosesCount = response;
  }

  Future<void> countPayout() async {
    final client = Supabase.instance.client;
    final vendorId = await fetchVendorId();

    final response = await client
        .from('transactions')
        .count()
        .eq('vendor_id', vendorId)
        .eq('status_work', 'complete');

    payoutCount = response;
  }

  @override
  void initState() {
    super.initState();

    countPesanan();
    countDiproses();
    countPayout();

    setState(() {
      badgeCountReady = true;
    });
  }

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
                    Badge(
                      isLabelVisible:
                          badgeCountReady
                              ? pesananCount > 0
                                  ? true
                                  : false
                              : false,
                      label:
                          badgeCountReady
                              ? Text(pesananCount.toString())
                              : null,
                      offset: Offset(16, -12),
                      child: Icon(Icons.inbox_outlined, size: 24),
                    ),
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
                    Badge(
                      isLabelVisible:
                          badgeCountReady
                              ? diprosesCount > 0
                                  ? true
                                  : false
                              : false,
                      label:
                          badgeCountReady
                              ? Text(diprosesCount.toString())
                              : null,
                      offset: Offset(16, -12),
                      child: Icon(Icons.movie_edit, size: 24),
                    ),
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
                    Badge(
                      isLabelVisible:
                          badgeCountReady
                              ? payoutCount > 0
                                  ? true
                                  : false
                              : false,
                      label:
                          badgeCountReady ? Text(payoutCount.toString()) : null,
                      offset: Offset(16, -12),
                      child: Icon(Icons.price_check_outlined, size: 24),
                    ),
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
