import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/kelola_item.dart';
import 'package:unsplash_clone/screens/vendor_profile.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
            ? (user.userMetadata!['role'].toUpperCase() +
                user.userMetadata!['role'].toLowerCase())
            : '-';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
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
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
                      ? const Color.fromARGB(250, 160, 250, 161)
                      : const Color.fromARGB(177, 250, 225, 161),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    role.toLowerCase() == 'customer'
                        ? Colors.green.shade700
                        : Colors.yellow.shade700,
              ),
            ),
            child: Text(
              role,
              style: TextStyle(
                color:
                    role.toLowerCase() == 'customer'
                        ? Colors.green.shade900
                        : Colors.yellow.shade900,
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: 'Riwayat Pesanan',
            subtitle: 'Lihat pesanan sebelumnya',
            onTap: _onOrderHistory,
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Favorit Saya',
            subtitle: 'Layanan fotografi yang disimpan',
            onTap: _onFavorites,
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'Metode Pembayaran',
            subtitle: 'Kelola opsi pembayaran',
            onTap: _onPaymentMethods,
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            subtitle: 'Kelola alamat pengiriman',
            onTap: _onAddresses,
          ),
        ],
      ),
    );
  }

  Widget _buildVendorMenuSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
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

  void _onFavorites() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Menu Favorit Saya dibuka.')));
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Informasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
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
            subtitle: 'Versi : 0.02_dev',
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
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildMenuItemDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          minimumSize: Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(Icons.logout),
        label: Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
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
