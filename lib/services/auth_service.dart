import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthService() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserDetails(user.uid);
      } else {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user details: \$e");
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String country,
    required String city,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
      
      if (cred.user != null) {
        AppUser newUser = AppUser(
          uid: cred.user!.uid,
          name: name,
          email: email.trim(),
          age: age,
          height: height,
          weight: weight,
          country: country,
          city: city,
        );

        await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
        _currentUser = newUser;
        notifyListeners();
        return null; // Success
      }
      return "Signup failed.";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication Error";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Authentication Error";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
