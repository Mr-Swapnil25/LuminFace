import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user document stream
  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return UserModel.fromFirestore(snapshot);
        }
        return null;
      },
    );
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current user data: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        // Create a new user document
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          fullName: fullName,
          gender: gender,
          dateOfBirth: dateOfBirth,
          isDarkMode: false,
        );
        
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        return newUser;
      }
      
      return null;
    } catch (e) {
      print('Error during sign up: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
      
      return null;
    } catch (e) {
      print('Error during sign in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    bool? isDarkMode,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      
      if (fullName != null) updates['fullName'] = fullName;
      if (gender != null) updates['gender'] = gender;
      if (dateOfBirth != null) updates['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (isDarkMode != null) updates['isDarkMode'] = isDarkMode;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update skin goal
  Future<void> updateSkinGoal({
    required String uid,
    required SkinGoal skinGoal,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'skinGoal': skinGoal.toMap(),
      });
    } catch (e) {
      print('Error updating skin goal: $e');
      rethrow;
    }
  }

  // Add skin analysis to history
  Future<void> addSkinAnalysis({
    required String uid,
    required SkinAnalysis analysis,
  }) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(uid);
      
      // Get current user data
      DocumentSnapshot doc = await userRef.get();
      if (doc.exists) {
        UserModel user = UserModel.fromFirestore(doc);
        List<SkinAnalysis> history = user.skinHistory ?? [];
        history.add(analysis);
        
        // Update user document with new skin analysis
        await userRef.update({
          'skinHistory': history.map((analysis) => analysis.toMap()).toList(),
        });
      }
    } catch (e) {
      print('Error adding skin analysis: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete user from Firebase Auth
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }
} 