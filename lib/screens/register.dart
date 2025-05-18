import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isVendor = false;

  final TextEditingController firstController = TextEditingController();
  final TextEditingController secondController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Text(
                'Unsplash Clone',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Silahkan daftar untuk membuat akun.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Toggle Customer / Vendor di tengah
              Center(
                child: ToggleButtons(
                  isSelected: [!isVendor, isVendor],
                  onPressed: (index) {
                    setState(() {
                      isVendor = index == 1;
                      clearForm();
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  borderWidth: 1.5,
                  selectedBorderColor: const Color.fromARGB(255, 41, 41, 41),
                  selectedColor: Colors.white,
                  fillColor: const Color.fromARGB(255, 41, 41, 41),
                  children: const [
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

              const SizedBox(height: 24),
              ...buildFormFields(),
              const SizedBox(height: 16),

              // Tombol Sign Up
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 41, 41, 41),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // Aksi daftar
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Dengan mendaftar, kamu menyetujui syarat & ketentuan kami.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun? ",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal, // Pastikan tidak bold
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold, // Ini tetap bold
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildFormFields() {
    if (isVendor) {
      return [
        inputField("Nama Vendor", firstController),
        inputField("Email", secondController, type: TextInputType.emailAddress),
        inputField("Nomor Telepon", phoneController, type: TextInputType.phone),
        inputField("Alamat", addressController),
        inputField("Provinsi", cityController),
        inputField("Kota", TextEditingController()),
        inputField("Kata Sandi", passwordController, obscure: true),
        inputField(
          "Konfirmasi Kata Sandi",
          confirmPasswordController,
          obscure: true,
        ),
      ];
    } else {
      return [
        inputField("Nama Depan", firstController),
        inputField("Nama Belakang", secondController),
        inputField("Jenis Kelamin", TextEditingController()),
        inputField("Nomor Telepon", phoneController, type: TextInputType.phone),
        inputField("Alamat", addressController),
        inputField("Kota", cityController),
        inputField("Kata Sandi", passwordController, obscure: true),
        inputField(
          "Konfirmasi Kata Sandi",
          confirmPasswordController,
          obscure: true,
        ),
      ];
    }
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
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 41, 41, 41)),
          ),
        ),
      ),
    );
  }

  void clearForm() {
    firstController.clear();
    secondController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
