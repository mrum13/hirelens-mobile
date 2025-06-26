import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/verify_registration.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  String? customerGenderValue;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  // Customer Controllers
  final Map<String, TextEditingController> customerControllers = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'address': TextEditingController(),
    'city': TextEditingController(),
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
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Text(
                        'Project HireLens',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
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
                              tabBarTheme: const TabBarTheme(
                                indicator:
                                    BoxDecoration(), // Remove underline/separator
                                dividerColor:
                                    Colors.transparent, // Remove separator line
                              ),
                              dividerColor:
                                  Colors
                                      .transparent, // Remove separator line for newer Flutter
                            ),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: const Color.fromARGB(255, 41, 41, 41),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.black87,
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
                      // Make TabBarView fill available space and scroll the whole page, height dynamic
                      Expanded(
                        child: TabBarView(
                          physics:
                              _isLoading
                                  ? const NeverScrollableScrollPhysics()
                                  : null,
                          children: [
                            // Customer Tab
                            ListView(
                              padding: EdgeInsets.only(top: 8),
                              children: [
                                inputField(
                                  "Nama Lengkap",
                                  customerControllers['name']!,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DropdownButtonFormField<String>(
                                    value: customerGenderValue,
                                    items:
                                        genderOptions
                                            .map(
                                              (gender) => DropdownMenuItem(
                                                value: gender,
                                                child: Text(gender),
                                              ),
                                            )
                                            .toList(),
                                    onChanged:
                                        _isLoading
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
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(
                                            255,
                                            41,
                                            41,
                                            41,
                                          ),
                                        ),
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
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        41,
                                        41,
                                        41,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () =>
                                                _onRegisterPressed('customer'),
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Dengan mendaftar, kamu menyetujui syarat & ketentuan kami.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Sudah punya akun? ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () {
                                                Navigator.pop(context);
                                              },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Vendor Tab
                            ListView(
                              padding: EdgeInsets.only(top: 8),
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
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        41,
                                        41,
                                        41,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    onPressed:
                                        _isLoading
                                            ? null
                                            : () =>
                                                _onRegisterPressed('vendor'),
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                            : const Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Dengan mendaftar, kamu menyetujui syarat & ketentuan kami.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Sudah punya akun? ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          _isLoading
                                              ? null
                                              : () {
                                                Navigator.pop(context);
                                              },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 41, 41, 41),
            ),
          ),
        ),
      ),
    );
  }

  // Registration validation and trigger function
  Future<void> _onRegisterPressed(String type) async {
    // Example validation logic (customize as needed)
    final isCustomer = type == 'customer';
    final ctrls = isCustomer ? customerControllers : vendorControllers;
    String? email = ctrls['email']?.text.trim();
    String? password = ctrls['password']?.text;
    String? confirmPassword = ctrls['confirmPassword']?.text;
    String? phone = ctrls['phone']?.text;
    String? name = ctrls['name']?.text;
    String? address = ctrls['address']?.text;
    String? city = ctrls['city']?.text;

    // Check for empty fields
    for (var entry in ctrls.entries) {
      if (entry.value.text.trim().isEmpty) {
        _showError('Semua field harus diisi');
        return;
      }
    }
    // Email validation
    if (email == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showError('Email tidak valid');
      return;
    }
    // Password match
    if (password != confirmPassword) {
      _showError('Konfirmasi password tidak sama');
      return;
    }
    // Gender validation for customer
    if (isCustomer &&
        (customerGenderValue == null || customerGenderValue!.isEmpty)) {
      _showError('Pilih jenis kelamin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password!,
        data: {
          'phone': phone,
          'displayName': name!,
          'address': address!,
          'city': city!,
          'role': isCustomer ? 'customer' : 'vendor',
        },
      );
      if (response.user != null) {
        // Registration success: redirect to OTP verification screen with email
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyRegistrationPage(email: email),
          ),
        );
      } else {
        _showError('Registrasi gagal. Silakan coba lagi.');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: \\${e.toString()}');
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
