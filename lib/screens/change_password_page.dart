import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:unsplash_clone/components/new_buttons.dart';
import 'package:unsplash_clone/theme.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isLoading = false;
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  Future<void> getProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final client = Supabase.instance.client;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', client.auth.currentUser!.id)
        .single();

    setState(() {
      // tagihanCount = response;
      _isLoading = false;
      emailController.text = response['email'];
    });
  }

  Future<void> changePassword({required String newPassword}) async {
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Mohon isi password baru terlebih dahulu",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      await Supabase.instance.client.auth.signOut();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text("Password berhasil diubah"),
          actions: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: MyFilledButton(
                    variant: MyButtonVariant.primary,
                    onTap: () async {
                      final client = Supabase.instance.client;

                      await client.auth.signOut();

                      GoRouter.of(context).pushReplacement('/');
                    },
                    child: Text(
                      "Ya",
                      style: TextStyle(
                        color: themeFromContext(
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.toString(),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ganti password"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: FilledButton(
            onPressed: () {
              changePassword(newPassword: newPasswordController.text);
            },
            child: Text("Simpan")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    enabled: false,
                    decoration: InputDecoration(
                        label: Text("Email"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4))),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                        label: Text("Password baru"),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4))),
                  )
                ],
              ),
      ),
    );
  }
}
