import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';
import 'package:unsplash_clone/screens/vendor_profile.dart';
import 'package:unsplash_clone/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  late User user;

  void loadUserData() async {
    final client = Supabase.instance.client;
    user = client.auth.currentUser!;
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            user.userMetadata!['role'].toLowerCase() == 'customer'
                ? _buildCustomerMenuSection()
                : _buildVendorMenuSection(),
            SizedBox(height: 20),
            _buildSettingsSection(),
            SizedBox(height: 20),
            _buildLogoutButton(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name = user.userMetadata!['displayName'] ?? '-';
    final email = user.email ?? '-';
    final role =
        (user.userMetadata!['role'] ?? '-').isNotEmpty
            ? (user.userMetadata!['role'].toString()[0].toUpperCase() +
                user.userMetadata!['role']
                    .toString()
                    .substring(1)
                    .toLowerCase())
            : '-';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeFromContext(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?background=6777cc&color=fff&name=${user.userMetadata!['displayName'].toUpperCase()}',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _onChangeProfilePicture,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(),
                    ),
                    child: Icon(Icons.camera_alt, size: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: themeFromContext(context).textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  role.toLowerCase() == 'customer'
                      ? themeFromContext(context).colorScheme.tertiary
                      : themeFromContext(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: TextStyle(
                color: themeFromContext(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dummy function for changing profile picture
  void _onChangeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur ganti foto profil akan segera hadir.')),
    );
  }

  Widget _buildCustomerMenuSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _onOrderHistory,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 96,
                  width: 172,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: themeFromContext(context).colorScheme.surfaceBright,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Riwayat Pesanan",
                    style: themeFromContext(context).textTheme.displayMedium,
                  ),
                ),
                Positioned(
                  left: 12,
                  top: -32,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: themeFromContext(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.history_outlined, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _onPaymentMethods,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 96,
                  width: 172,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: themeFromContext(context).colorScheme.surfaceBright,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Metode Pembayaran",
                    style: themeFromContext(context).textTheme.displayMedium,
                  ),
                ),
                Positioned(
                  left: 12,
                  top: -32,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: themeFromContext(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.credit_card_outlined, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _onAddresses,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 96,
                  width: 172,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: themeFromContext(context).colorScheme.surfaceBright,
                  ),
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Alamat",
                    style: themeFromContext(context).textTheme.displayMedium,
                  ),
                ),
                Positioned(
                  left: 12,
                  top: -32,
                  child: Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: themeFromContext(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.location_on_outlined, size: 40),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorMenuSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeFromContext(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.list,
            title: 'Your Page',
            subtitle: 'Cek halaman profil anda sebagai vendor.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VendorProfilePage(),
                  ),
                ),
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.inbox_outlined,
            title: 'Pesanan',
            subtitle:
                'Cek pesanan yang masuk atau riwayat pesanan yang sudah dikerjakan',
            onTap: _onComingSoonTM,
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.bookmark_border_outlined,
            title: 'Kelola Item',
            subtitle: 'Kelola jasa, studio atau tempat foto yang anda sewakan',
            onTap:
                () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KelolaItemPage(),
                    ),
                  ),
                },
          ),
        ],
      ),
    );
  }

  // Dummy functions for menu links
  void _onComingSoonTM() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Coming Soon....')));
  }

  void _onOrderHistory() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu Riwayat Pesanan dibuka.')));
  }

  void _onPaymentMethods() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu Metode Pembayaran dibuka.')));
  }

  void _onAddresses() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu Alamat dibuka.')));
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: themeFromContext(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Informasi',
              style: themeFromContext(context).textTheme.displaySmall,
            ),
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Syarat & Ketentuan',
            subtitle: 'Syarat & Ketentuan terkait penggunaan layanan kami',
            onTap: _onPrivacyPolicy,
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'Info Aplikasi',
            subtitle: 'Versi : 0.03_dev',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Dummy functions for settings links
  void _onPrivacyPolicy() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu Syarat & Ketentuan dibuka.')));
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: themeFromContext(context).textTheme.displayMedium,
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildMenuItemDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade400),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeFromContext(context).colorScheme.error,
          foregroundColor: themeFromContext(context).colorScheme.onError,
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(Icons.logout),
        label: Text(
          'Keluar',
          style: TextStyle(
            fontWeight:
                themeFromContext(context).textTheme.displaySmall!.fontWeight,
            fontSize:
                themeFromContext(context).textTheme.displaySmall!.fontSize,
          ),
        ),
        onPressed: _onLogoutPressed,
      ),
    );
  }

  void _onLogoutPressed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Konfirmasi Logout'),
            content: Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => GoRouter.of(context).pop(),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () => GoRouter.of(context).pop(),
                child: Text('Keluar'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();

      if (mounted) {
        GoRouter.of(context).replace("/login");
      }
    }
  }
}
