import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

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
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              _showEditProfileDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20),
            _buildStatsSection(),
            SizedBox(height: 20),
            _buildMenuSection(),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
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
                  'https://randomuser.me/api/portraits/men/1.jpg',
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'john.doe@example.com',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              'Anggota Premium',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', 'Pesanan', Icons.shopping_bag_outlined),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _buildStatItem('8', 'Favorit', Icons.favorite_outline),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _buildStatItem('4.8', 'Penilaian', Icons.star_outline),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
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
            onTap: () => _showComingSoonSnackBar('Riwayat Pesanan'),
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Favorit Saya',
            subtitle: 'Layanan fotografi yang disimpan',
            onTap: () => _showComingSoonSnackBar('Favorit Saya'),
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.payment,
            title: 'Metode Pembayaran',
            subtitle: 'Kelola opsi pembayaran',
            onTap: () => _showComingSoonSnackBar('Metode Pembayaran'),
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            subtitle: 'Kelola alamat pengiriman',
            onTap: () => _showComingSoonSnackBar('Alamat'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
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
              'Pengaturan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          _buildSwitchMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Dapatkan pembaruan pesanan',
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
          _buildMenuItemDivider(),
          _buildSwitchMenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'Mode Gelap',
            subtitle: 'Beralih ke tema gelap',
            value: darkModeEnabled,
            onChanged: (value) {
              setState(() {
                darkModeEnabled = value;
              });
            },
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'Bahasa',
            subtitle: 'Indonesia',
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showComingSoonSnackBar('Pengaturan Bahasa'),
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan & Dukungan',
            subtitle: 'Bantuan terkait akun',
            onTap: () => _showComingSoonSnackBar('Bantuan & Dukungan'),
          ),
          _buildMenuItemDivider(),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Kebijakan Privasi',
            subtitle: 'Baca kebijakan privasi kami',
            onTap: () => _showComingSoonSnackBar('Kebijakan Privasi'),
          ),
        ],
      ),
    );
  }

  // Fungsi _buildMenuItem, _buildSwitchMenuItem, _buildLogoutButton, dan lainnya tetap sama

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
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
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

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature akan segera hadir.')),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black54, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profil'),
          content: Text('Fitur edit profil akan segera hadir.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup'),
            ),
          ],
        );
      },
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onPressed: () {
          // TODO: Implement logout logic here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout berhasil (dummy action)')),
          );
        },
      ),
    );
  }
}
