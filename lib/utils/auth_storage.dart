import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> saveAuthSession(Map<String, dynamic> session) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('authSession', jsonEncode(session));
}

Future<Map<String, dynamic>?> getAuthSession() async {
  final prefs = await SharedPreferences.getInstance();
  final sessionString = prefs.getString('authSession');
  if (sessionString == null) return null;
  return jsonDecode(sessionString) as Map<String, dynamic>;
}

Future<void> clearAuthSession() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authSession');
}
