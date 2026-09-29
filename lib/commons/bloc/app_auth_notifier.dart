import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:web_personal_finances/repositories/user_repository.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

/// Tracks the current Firebase auth + onboarding state and notifies
/// GoRouter's [refreshListenable] so the router re-evaluates its redirect
/// whenever the user signs in, signs out, or completes onboarding.
class AppAuthNotifier extends ChangeNotifier {
  AppAuthNotifier({
    required final UserRepository userRepository,
    final FirebaseAuth? firebaseAuth,
  }) : _userRepository = userRepository,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    // Start listening immediately.
    _authSubscription = _firebaseAuth.userChanges().listen(_onAuthChanged);
  }

  final UserRepository _userRepository;
  final FirebaseAuth _firebaseAuth;
  late final StreamSubscription<User?> _authSubscription;

  // ─── Public state ────────────────────────────────────────────────────────

  /// `true` while the initial auth + profile check hasn't resolved yet.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// The currently signed-in Firebase user, or `null` if unauthenticated.
  User? get firebaseUser => _firebaseUser;
  User? _firebaseUser;

  /// The Firestore profile for [firebaseUser], or `null` if none exists.
  UserModel? get userProfile => _userProfile;
  UserModel? _userProfile;

  /// Convenience: `true` when a user is signed in AND has completed onboarding.
  bool get isAuthenticated => _firebaseUser != null;
  bool get isOnboarded => _userProfile?.isOnboarded == true;

  // ─── Private helpers ─────────────────────────────────────────────────────

  Future<void> _onAuthChanged(final User? user) async {
    _firebaseUser = user;

    if (user == null) {
      // Signed out — clear profile immediately.
      _userProfile = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Signed in — fetch profile to determine onboarding status.
    try {
      _userProfile = await _userRepository.getUser(user.uid);
    } catch (_) {
      _userProfile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Call this after successfully saving the onboarding profile so the router
  /// immediately re-evaluates and lets the user into the app.
  Future<void> refreshProfile() async {
    final User? user = _firebaseUser;
    if (user == null) return;
    try {
      _userProfile = await _userRepository.getUser(user.uid);
    } catch (_) {
      _userProfile = null;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
