import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  String? customerGenderValue;
  String? customerBankName;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> paymentAccountOptions = [
    'BRI',
    'BNI',
    'BCA',
    'Gopay',
    'Shopee Pay',
    'Dana'
  ];

  // Customer Controllers
  final Map<String, TextEditingController> customerControllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'address': TextEditingController(),
    'city': TextEditingController(),
    'bank_account': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  final Map<String, TextEditingController> vendorControllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'address': TextEditingController(),
    'city': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double bottomInset =
                  MediaQuery.of(context).viewInsets.bottom;
              return SizedBox(
                height: constraints.maxHeight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(32, 48, 32, 16 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: themeFromContext(context).textTheme.displaySmall,
                      ),
                      Text(
                        'HireLens',
                        style: themeFromContext(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 24),

                      // TabBar for Customer / Vendor
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              tabBarTheme: const TabBarThemeData(
                                indicator: BoxDecoration(),
                                dividerColor: Colors.transparent,
                              ),
                              dividerColor: Colors.transparent,
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: themeFromContext(
                                  context,
                                ).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelColor:
                                  themeFromContext(context).colorScheme.surface,
                              unselectedLabelColor: themeFromContext(
                                context,
                              ).colorScheme.surfaceBright,
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              indicatorColor: Colors.transparent,
                              tabs: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: Text('Customer'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                  child: Text('Vendor'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Expanded(
                        child: TabBarView(
                          physics: _isLoading
                              ? const NeverScrollableScrollPhysics()
                              : null,
                          children: [
                            // Customer Tab
                            ListView(
                              padding: EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                              ),
                              children: [
                                inputField(
                                  "Nama Lengkap",
                                  customerControllers['name']!,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DropdownButtonFormField<String>(
                                    value: customerGenderValue,
                                    items: genderOptions
                                        .map(
                                          (gender) => DropdownMenuItem(
                                            value: gender,
                                            child: Text(gender),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              customerGenderValue = value;
                                            });
                                          },
                                    decoration: InputDecoration(
                                      labelText: "Jenis Kelamin",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                inputField(
                                  "Nomor Telepon/Whatsapp",
                                  customerControllers['phone']!,
                                  type: TextInputType.phone,
                                ),
                                inputField(
                                  "Alamat",
                                  customerControllers['address']!,
                                ),
                                inputField(
                                  "Kota",
                                  customerControllers['city']!,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DropdownButtonFormField<String>(
                                    value: customerBankName,
                                    items: paymentAccountOptions
                                        .map(
                                          (payment) => DropdownMenuItem(
                                            value: payment,
                                            child: Text(payment),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              customerBankName = value;
                                            });
                                          },
                                    decoration: InputDecoration(
                                      labelText: "Rekening / E-Wallet",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                inputField(
                                  "No. Rek / No. E-Wallet",
                                  customerControllers['bank_account']!,
                                ),
                                inputField(
                                  "Email",
                                  customerControllers['email']!,
                                  type: TextInputType.emailAddress,
                                ),
                                inputField(
                                  "Kata Sandi",
                                  customerControllers['password']!,
                                  obscure: true,
                                ),
                                inputField(
                                  "Konfirmasi Kata Sandi",
                                  customerControllers['confirmPassword']!,
                                  obscure: true,
                                ),
                                const SizedBox(height: 16),
                                MyFilledButton(
                                  isLoading: _isLoading,
                                  width: double.infinity,
                                  variant: MyButtonVariant.primary,
                                  onTap: () => !_isLoading
                                      ? _onRegisterPressed('customer')
                                      : null,
                                  child: Text(
                                    "Daftar",
                                    style: TextStyle(
                                      color: themeFromContext(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Dengan mendaftar, kamu menyetujui syarat & ketentuan kami.',
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                MyFilledButton(
                                  variant: MyButtonVariant.neutral,
                                  onTap: () =>
                                      GoRouter.of(context).go('/opening'),
                                  isLoading: _isLoading,
                                  child: Text(
                                    "Kembali",
                                    style: TextStyle(
                                      color: themeFromContext(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Vendor Tab
                            ListView(
                              padding: EdgeInsets.only(
                                top: 8,
                                left: 8,
                                right: 8,
                              ),
                              children: [
                                inputField(
                                  "Nama Vendor",
                                  vendorControllers['name']!,
                                ),
                                inputField(
                                  "Nomor Telepon",
                                  vendorControllers['phone']!,
                                  type: TextInputType.phone,
                                ),
                                inputField(
                                  "Alamat",
                                  vendorControllers['address']!,
                                ),
                                inputField("Kota", vendorControllers['city']!),
                                inputField(
                                  "Email",
                                  vendorControllers['email']!,
                                  type: TextInputType.emailAddress,
                                ),
                                inputField(
                                  "Kata Sandi",
                                  vendorControllers['password']!,
                                  obscure: true,
                                ),
                                inputField(
                                  "Konfirmasi Kata Sandi",
                                  vendorControllers['confirmPassword']!,
                                  obscure: true,
                                ),
                                const SizedBox(height: 16),
                                MyFilledButton(
                                  isLoading: _isLoading,
                                  width: double.infinity,
                                  variant: MyButtonVariant.primary,
                                  onTap: () => !_isLoading
                                      ? _onRegisterPressed('vendor')
                                      : null,
                                  child: Text(
                                    "Daftar",
                                    style: TextStyle(
                                      color: themeFromContext(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Dengan mendaftar, kamu menyetujui syarat & ketentuan kami.',
                                  style: TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                MyFilledButton(
                                  variant: MyButtonVariant.neutral,
                                  onTap: () => GoRouter.of(context).go('/'),
                                  isLoading: _isLoading,
                                  child: Text(
                                    "Kembali",
                                    style: TextStyle(
                                      color: themeFromContext(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  // Registration validation and trigger function
  Future<void> _onRegisterPressed(String type) async {
    final isCustomer = type == 'customer';
    final ctrls = isCustomer ? customerControllers : vendorControllers;
    String? email = ctrls['email']?.text.trim();
    String? password = ctrls['password']?.text;
    String? confirmPassword = ctrls['confirmPassword']?.text;
    String? phone = ctrls['phone']?.text;
    String? name = ctrls['name']?.text;
    String? address = ctrls['address']?.text;
    String? city = ctrls['city']?.text;
    String? bankName = customerBankName;
    String? bankAccount = ctrls['bank_account']?.text;

    // Validasi fields
    for (var entry in ctrls.entries) {
      if (entry.value.text.trim().isEmpty) {
        _showError('Semua field harus diisi');
        return;
      }
    }

    if (email == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showError('Email tidak valid');
      return;
    }

    if (password != confirmPassword) {
      _showError('Konfirmasi password tidak sama');
      return;
    }

    if (isCustomer &&
        (customerGenderValue == null || customerGenderValue!.isEmpty)) {
      _showError('Pilih jenis kelamin');
      return;
    }

    if (isCustomer && (customerBankName == null || customerBankName!.isEmpty)) {
      _showError('Pilih jenis rekening');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔵 Starting signup for $type with email: $email');

      // Step 1: Signup
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password!,
        data: {
          'phone': phone,
          'displayName': name!,
          'address': address!,
          'city': city!,
          'role': isCustomer ? 'customer' : 'vendor',
          'bankName': isCustomer ? customerBankName : '',
          'bankAccount': isCustomer ? bankAccount : '',
        },
      );

      if (response.user != null) {
        // 🔴 PENTING: HAPUS SESSION
        await Supabase.instance.client.auth.signOut();

        // Optional delay biar trigger DB aman
        await Future.delayed(const Duration(milliseconds: 500));

        // Kirim OTP
        await Supabase.instance.client.auth.signInWithOtp(
          email: email,
          shouldCreateUser: false,
        );

        if (mounted) {
          GoRouter.of(context)
              .pushReplacement('/verify_registration?email=$email');
        }
      }
    } on AuthException catch (authError) {
      print('❌ Auth error: ${authError.message}');
      _showError('Error autentikasi: ${authError.message}');
    } catch (e) {
      print('❌ General error: $e');
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void clearForm() {
    for (var ctrl in customerControllers.values) {
      ctrl.clear();
    }
    for (var ctrl in vendorControllers.values) {
      ctrl.clear();
    }
    customerGenderValue = null;
    setState(() {});
  }
}
