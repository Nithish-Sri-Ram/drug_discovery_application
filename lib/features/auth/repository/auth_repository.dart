import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drug_discovery/core/constants/constants.dart';
import 'package:drug_discovery/core/failure.dart';
import 'package:drug_discovery/core/constants/firebase_constants.dart';
import 'package:drug_discovery/core/providers/firebase_providers.dart';
import 'package:drug_discovery/core/type_defs.dart';
import 'package:drug_discovery/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firesore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  // These variables are private and only accessible within the class
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository(
      {required FirebaseFirestore firesore,
      required FirebaseAuth auth,
      required GoogleSignIn googleSignIn})
      : _firestore = firesore,
        _auth = auth,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

// To keep user signed in if the app is closed
  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential =
              await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userModel.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }

      return right(userModel);

      // await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();
      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
      );

      await _users.doc(userModel.uid).set(userModel.toMap());

      return right(userModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) {
      return UserModel.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
