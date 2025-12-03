import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken);
        await firebaseAuth.signInWithCredential(authCredential);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> googleSignOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username,
  }) async {
    await firebaseAuth.currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
    await firebaseAuth.currentUser!.delete();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
    await firebaseAuth.currentUser!.updatePassword(newPassword);
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// /// Global [AuthService] instance wrapped in a [ValueNotifier].
// ///
// /// This allows widgets to listen for changes if you ever decide to
// /// notify listeners when auth-related state changes.
// final ValueNotifier<AuthService> authService = ValueNotifier(
//   AuthService(),
// );

// /// A thin wrapper around [FirebaseAuth] and [GoogleSignIn].
// ///
// /// This class centralizes all authentication logic for:
// /// - Email/password sign in
// /// - Google sign in
// /// - Account creation
// /// - Password reset & update
// /// - Account deletion
// class AuthService {
//   AuthService({
//     FirebaseAuth? firebaseAuth,
//     GoogleSignIn? googleSignIn,
//   })  : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
//         googleSignIn = googleSignIn ?? GoogleSignIn();

//   /// Firebase auth instance used by the app.
//   final FirebaseAuth firebaseAuth;

//   /// Google sign-in helper instance.
//   final GoogleSignIn googleSignIn;

//   /// Currently signed-in user (if any).
//   User? get currentUser => firebaseAuth.currentUser;

//   /// Stream that emits events whenever the authentication state changes.
//   Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

//   /// Sign in with email and password.
//   Future<UserCredential> signIn({
//     required String email,
//     required String password,
//   }) async {
//     print(email);
//     return await firebaseAuth.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   /// Sign in using Google Sign-In.
//   ///
//   /// Returns [UserCredential] if sign-in succeeds, or `null` if the user
//   /// cancels the Google sign-in flow.
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleSignInAccount =
//           await googleSignIn.signIn();

//       // User closed the Google sign-in dialog.
//       if (googleSignInAccount == null) {
//         return null;
//       }

//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount.authentication;

//       final AuthCredential authCredential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );

//       return firebaseAuth.signInWithCredential(authCredential);
//     } on FirebaseAuthException catch (e) {
//       debugPrint('Google sign-in failed: ${e.message}');
//       rethrow;
//     }
//   }

//   /// Create a new account using email and password.
//   Future<UserCredential> createAccount({
//     required String email,
//     required String password,
//   }) async {
//     return firebaseAuth.createUserWithEmailAndPassword(
//       email: email,
//       password: password,
//     );
//   }

//   /// Sign out from both Firebase auth and Google (if used).
//   Future<void> googleSignOut() async {
//     await firebaseAuth.signOut();
//     await googleSignIn.signOut();
//   }

//   /// Sign out from Firebase only.
//   Future<void> signOut() async {
//     await firebaseAuth.signOut();
//   }

//   /// Send a reset password email to the given [email].
//   Future<void> resetPassword({
//     required String email,
//   }) async {
//     await firebaseAuth.sendPasswordResetEmail(email: email);
//   }

//   /// Update the current user's display name.
//   Future<void> updateUsername({
//     required String username,
//   }) async {
//     final user = firebaseAuth.currentUser;
//     if (user == null) {
//       throw StateError('No user is currently signed in.');
//     }
//     await user.updateDisplayName(username);
//   }

//   /// Delete the current user's account after re-authenticating
//   /// with email & password.
//   Future<void> deleteAccount({
//     required String email,
//     required String password,
//   }) async {
//     final user = firebaseAuth.currentUser;
//     if (user == null) {
//       throw StateError('No user is currently signed in.');
//     }

//     final AuthCredential credential = EmailAuthProvider.credential(
//       email: email,
//       password: password,
//     );

//     await user.reauthenticateWithCredential(credential);
//     await user.delete();
//   }

//   /// Update the current user's password by first re-authenticating
//   /// with the current password.
//   Future<void> resetPasswordFromCurrentPassword({
//     required String email,
//     required String currentPassword,
//     required String newPassword,
//   }) async {
//     final user = firebaseAuth.currentUser;
//     if (user == null) {
//       throw StateError('No user is currently signed in.');
//     }

//     final AuthCredential credential = EmailAuthProvider.credential(
//       email: email,
//       password: currentPassword,
//     );

//     await user.reauthenticateWithCredential(credential);
//     await user.updatePassword(newPassword);
//   }
// }
