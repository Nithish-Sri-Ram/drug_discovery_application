import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drug_discovery/core/constants/firebase_constants.dart';
import 'package:drug_discovery/core/failure.dart';
import 'package:drug_discovery/core/providers/firebase_providers.dart';
import 'package:drug_discovery/core/type_defs.dart';
import 'package:drug_discovery/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final userProfileRepositoryProvider = Provider((ref){
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
