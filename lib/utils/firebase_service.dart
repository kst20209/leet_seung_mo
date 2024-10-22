import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<DocumentSnapshot> getDocument(
      String collection, String documentId) async {
    return await _firestore.collection(collection).doc(documentId).get();
  }

  Future<QuerySnapshot> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }

  Future<void> setDocument(
      String collection, String document, Map<String, dynamic> data,
      {bool merge = false}) async {
    await _firestore
        .collection(collection)
        .doc(document)
        .set(data, SetOptions(merge: merge));
  }

  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await _firestore.collection(collection).add(data);
  }

  Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Stream<DocumentSnapshot> streamDocument(
      String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }

  // Auth methods
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserDocument(
      String uid, Map<String, dynamic> userData) async {
    // 보안을 위해 전화번호 관련 데이터는 제외
    final Map<String, dynamic> safeUserData = Map.from(userData)
      ..removeWhere((key, value) => key == 'phoneNumber')
      ..addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'isPhoneVerified': true,
        'phoneVerifiedAt': FieldValue.serverTimestamp(),
      });

    await _firestore
        .collection('users')
        .doc(uid)
        .set(safeUserData, SetOptions(merge: true));
  }

  Future<void> updateUserDocument(
      String uid, Map<String, dynamic> userData) async {
    // 보안을 위해 전화번호 관련 데이터는 제외
    final Map<String, dynamic> safeUserData = Map.from(userData)
      ..removeWhere((key, value) => key == 'phoneNumber');

    await _firestore.collection('users').doc(uid).update(safeUserData);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  String? getCurrentUserPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
