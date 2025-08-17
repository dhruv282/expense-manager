import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  late final SharedPreferences prefs;
  final _auth = LocalAuthentication();
  final _isAuthEnabledKey = 'isAuthEnabled';
  bool isAuthEnabled = false;
  bool isAuthenticated = false;

  Future<bool> _shouldAuthenticate() async {
    prefs = await SharedPreferences.getInstance();
    isAuthEnabled = prefs.getBool(_isAuthEnabledKey) ?? false;
    if (!isAuthEnabled) return false;

    final List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();
    return availableBiometrics.isNotEmpty || await _auth.isDeviceSupported();
  }

  AuthProvider() {
    _shouldAuthenticate().then((v) {
      if (v) {
        _auth
            .authenticate(
          localizedReason: "Please authenticate to access transaction data",
          options: AuthenticationOptions(),
        )
            .then((isAuthenticated) {
          this.isAuthenticated = isAuthenticated;
          notifyListeners();
        }).catchError((e) {
          logger.e("Authentication failed: $e");
          isAuthenticated = false;
          notifyListeners();
        });
      } else {
        isAuthenticated = true;
        notifyListeners();
      }
    });
  }

  void updateIsAuthEnabled(bool value) {
      isAuthEnabled = value;
      prefs.setBool(_isAuthEnabledKey, value);
      notifyListeners();
    }
}
