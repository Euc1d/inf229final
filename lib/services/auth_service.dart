import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'favoriteRecipes': [],
      });

      return UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        favoriteRecipes: [],
      );
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await getUserData(_auth.currentUser!.uid);
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}